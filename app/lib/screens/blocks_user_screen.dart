import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:robokid/widgets/widgets.dart';
import 'package:robokid/services/services.dart';

import '../providers/auth_provider.dart';

class BlockScreen extends StatefulWidget {
  final String? projectId; // si viene un id, cargamos ese proyecto al abrir
  final String? themeMode;

  const BlockScreen({super.key, this.projectId, this.themeMode});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  late final WebViewController _controller;
  bool _loaded = false; // se pone en true cuando Blockly termina de cargar
  String? _code; // último código Arduino generado
  String? _workspaceJson; // estado serializado del workspace (JSON)
  String? _projectId; // id del proyecto actual (null si es nuevo)
  String? _projectName; // nombre del proyecto actual
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _projectId = widget.projectId;

    // Configuramos el WebView para cargar el editor Blockly
    // FlutterChannel es el puente JS -> Dart
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('FlutterChannel', onMessageReceived: _onMensaje)
      ..loadFlutterAsset('assets/blockly_editor.html');
  }

  @override
  void didUpdateWidget(covariant BlockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // si el proyectoId cambió y Blockly ya está listo, cargamos el proyecto
    if (widget.projectId != null &&
        widget.projectId != oldWidget.projectId &&
        _loaded) {
      _projectId = widget.projectId;
      _firebaseProjectsLoad(_projectId!);
    }

    if (widget.themeMode != null && widget.themeMode != oldWidget.themeMode && _loaded) {
      _controller.runJavaScript("setBlocklyTheme('${widget.themeMode}')");
    }
  }

  // Recibe los mensajes que manda Blockly desde JavaScript
  void _onMensaje(JavaScriptMessage mensaje) {
    final data = jsonDecode(mensaje.message);
    final tipo = data['type'];

    if (tipo == 'blocklyReady') {
      setState(() => _loaded = true);

      // aplicamos el tema actual de la app
      if (widget.themeMode != null) {
        _controller.runJavaScript("setBlocklyTheme('${widget.themeMode}')");
      }

      // si venimos con un proyecto, lo cargamos ahora que Blockly esta listo
      if (_projectId != null) {
        _firebaseProjectsLoad(_projectId!);
      }
    } else if (tipo == 'arduinoCode') {
      setState(() => _code = data['data']);
      _showCode();
    } else if (tipo == 'workspaceState') {
      setState(() => _workspaceJson = data['data']);
      // si estamos en medio de un guardado, continuamos
      if (_saving) {
        _saving = false;
        _completeSave();
      }
    }
  }

  // Le pide a Blockly que genere el código Arduino a partir de los bloques
  void _compile() {
    _controller.runJavaScript('requestCode()');
  }

  // Pide el estado actual del workspace a Blockly (se recibe en _onMensaje)
  void _getWorkspaceState() {
    _controller.runJavaScript('requestWorkspaceState()');
  }

  // Carga un workspace guardado en el editor (recibe el JSON como string)
  // Usamos jsonEncode para escapar caracteres especiales antes de pasarlo a JS
  Future<void> _loadWorkspace(String workspaceJson) async {
    final safe = jsonEncode(workspaceJson);
    await _controller.runJavaScript('loadWorkspace($safe)');
  }

  // Limpia todos los bloques del editor
  Future<void> _cleanWorkspace() async {
    await _controller.runJavaScript('clearWorkspace()');
    setState(() {
      _code = null;
      _workspaceJson = null;
    });
  }

  // Carga un proyecto de Firestore y lo mete en el editor
  Future<void> _firebaseProjectsLoad(String projectId) async {
    final proyecto = await getProyecto(projectId);
    if (proyecto != null && proyecto['workspaceJson'] != null) {
      setState(() {
        _projectName = proyecto['nombre'];
        _code = proyecto['codigoArduino'];
      });
      await _loadWorkspace(proyecto['workspaceJson']);
    }
  }

  // Empieza el proceso de guardado: primero pide el workspace a Blockly
  void _save() {
    _saving = true;
    _getWorkspaceState();
    // cuando llegue el workspaceState en _onMensaje, se llama a _completarGuardado
  }

  // Se ejecuta cuando ya tenemos el workspaceJson actualizado
  Future<void> _completeSave() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    final uid = user?.uid;

    if (uid == null || _workspaceJson == null) return;

    // si es un proyecto nuevo, pedimos el nombre
    if (_projectId == null) {
      final name = await _getProjectName();
      if (name == null || name.isEmpty) return;

      final id = await insertProyecto(uid, name, _workspaceJson!, _code ?? '');
      setState(() {
        _projectId = id;
        _projectName = name;
      });
    } else {
      // si ya existe, preguntamos si sobreescribir o crear uno nuevo
      final option = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Guardar proyecto'),
          content: Text(
            '¿Quieres sobreescribir "$_projectName" o guardarlo como un nuevo proyecto?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'nuevo'),
              child: const Text('Nuevo proyecto'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'sobreescribir'),
              child: const Text('Sobreescribir'),
            ),
          ],
        ),
      );

      if (option == null) return;

      if (option == 'sobreescribir') {
        await updateProyecto(_projectId!, _workspaceJson!, _code ?? '');
      } else {
        final name = await _getProjectName();
        if (name == null || name.isEmpty) return;

        final id = await insertProyecto(
          uid,
          name,
          _workspaceJson!,
          _code ?? '',
        );
        setState(() {
          _projectId = id;
          _projectName = name;
        });
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proyecto guardado'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Dialogo para que el usuario ponga nombre al proyecto
  Future<String?> _getProjectName() async {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(
            'Nombre del proyecto',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: theme.textTheme.titleMedium,
            decoration: const InputDecoration(hintText: 'Ej: Mi robot'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // url del servidor de compilacion (cambiar segun donde este desplegado)
  static const _urlServer = 'https://democrat-hence-safehouse.ngrok-free.dev';

  // Manda el código al servidor para compilarlo
  Future<void> _compilarYSubir() async {
    if (_code == null || _code!.isEmpty) return;

    // mostramos que estamos compilando
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compilando...'),
          duration: Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_urlServer/compile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'codigo': _code, 'placa': 'esp8266:esp8266:d1'}),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compilación exitosa'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        _showCompilingErrorMessage(
          error['detalle']?.toString() ?? 'Error desconocido',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo conectar al servidor: $e'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Muestra los errores de compilacion en un dialogo para que se lean bien
  void _showCompilingErrorMessage(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de compilación'),
        content: SingleChildScrollView(
          child: SelectableText(
            error,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Muestra el código generado en un panel inferior
  void _showCode() {
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();
    // Si no hay usuario es que está en modo invitado
    final bool isGuest = auth.isGuest;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
          color: theme.scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Código Arduino',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar código',
                        onPressed: () {
                          if (_code != null) {
                            Clipboard.setData(ClipboardData(text: _code!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Código copiado'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),

                      if (!isGuest)
                        IconButton(
                          icon: const Icon(Icons.save),
                          tooltip: 'Guardar proyecto',
                          onPressed: () {
                            Navigator.pop(context);
                            _save();
                          },
                        ),

                      IconButton(
                        icon: const Icon(Icons.upload),
                        tooltip: 'Compilar y subir',
                        onPressed: () {
                          Navigator.pop(context);
                          _compilarYSubir();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _code ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // Si no hay usuario es que está en modo invitado
    final bool isGuest = auth.isGuest;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // boton para limpiar el workspace
                FloatingActionButton(
                  heroTag: 'limpiar',
                  onPressed: _loaded ? _cleanWorkspace : null,
                  backgroundColor: _loaded ? null : Colors.grey,
                  child: const Icon(Icons.delete_outline),
                ),
                const SizedBox(width: 12),

                // boton para guardar el proyecto
                if (!isGuest)
                  FloatingActionButton(
                    heroTag: 'guardar',
                    onPressed: _loaded ? _save : null,
                    backgroundColor: _loaded ? null : Colors.grey,
                    child: const Icon(Icons.save),
                  ),

                if (!isGuest) const SizedBox(width: 12),

                // boton para compilar (generar codigo arduino)
                FloatingActionButton(
                  heroTag: 'compilar',
                  onPressed: _loaded ? _compile : null,
                  backgroundColor: _loaded ? null : Colors.grey,
                  child: const Icon(Icons.play_arrow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
