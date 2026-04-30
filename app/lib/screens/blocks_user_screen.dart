import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:robokid/widgets/custom_appbar.dart';
import 'package:robokid/services/firebase_proyectos.dart';

class BlockScreen extends StatefulWidget {
  final String? proyectoId; // si viene un id, cargamos ese proyecto al abrir
  const BlockScreen({super.key, this.proyectoId});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  late final WebViewController _controller;
  bool _listo = false; // se pone en true cuando Blockly termina de cargar
  String? _codigo; // último código Arduino generado
  String? _workspaceJson; // estado serializado del workspace (JSON)
  String? _proyectoId; // id del proyecto actual (null si es nuevo)
  String? _nombreProyecto; // nombre del proyecto actual
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _proyectoId = widget.proyectoId;

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
    if (widget.proyectoId != null &&
        widget.proyectoId != oldWidget.proyectoId &&
        _listo) {
      _proyectoId = widget.proyectoId;
      _cargarProyectoDesdeFirestore(_proyectoId!);
    }
  }

  // Recibe los mensajes que manda Blockly desde JavaScript
  void _onMensaje(JavaScriptMessage mensaje) {
    final datos = jsonDecode(mensaje.message);
    final tipo = datos['type'];

    if (tipo == 'blocklyReady') {
      setState(() => _listo = true);
      // si venimos con un proyecto, lo cargamos ahora que Blockly esta listo
      if (_proyectoId != null) {
        _cargarProyectoDesdeFirestore(_proyectoId!);
      }
    } else if (tipo == 'arduinoCode') {
      setState(() => _codigo = datos['data']);
      _mostrarCodigo();
    } else if (tipo == 'workspaceState') {
      setState(() => _workspaceJson = datos['data']);
      // si estamos en medio de un guardado, continuamos
      if (_guardando) {
        _guardando = false;
        _completarGuardado();
      }
    }
  }

  // Le pide a Blockly que genere el código Arduino a partir de los bloques
  void _compilar() {
    _controller.runJavaScript('requestCode()');
  }

  // Pide el estado actual del workspace a Blockly (se recibe en _onMensaje)
  void _pedirWorkspaceState() {
    _controller.runJavaScript('requestWorkspaceState()');
  }

  // Carga un workspace guardado en el editor (recibe el JSON como string)
  // Usamos jsonEncode para escapar caracteres especiales antes de pasarlo a JS
  Future<void> _cargarWorkspace(String workspaceJson) async {
    final safe = jsonEncode(workspaceJson);
    await _controller.runJavaScript('loadWorkspace($safe)');
  }

  // Limpia todos los bloques del editor
  Future<void> _limpiarWorkspace() async {
    await _controller.runJavaScript('clearWorkspace()');
    setState(() {
      _codigo = null;
      _workspaceJson = null;
    });
  }

  // Carga un proyecto de Firestore y lo mete en el editor
  Future<void> _cargarProyectoDesdeFirestore(String projectId) async {
    final proyecto = await getProyecto(projectId);
    if (proyecto != null && proyecto['workspaceJson'] != null) {
      setState(() {
        _nombreProyecto = proyecto['nombre'];
        _codigo = proyecto['codigoArduino'];
      });
      await _cargarWorkspace(proyecto['workspaceJson']);
    }
  }

  // Empieza el proceso de guardado: primero pide el workspace a Blockly
  void _guardar() {
    _guardando = true;
    _pedirWorkspaceState();
    // cuando llegue el workspaceState en _onMensaje, se llama a _completarGuardado
  }

  // Se ejecuta cuando ya tenemos el workspaceJson actualizado
  Future<void> _completarGuardado() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _workspaceJson == null) return;

    // si es un proyecto nuevo, pedimos el nombre
    if (_proyectoId == null) {
      final nombre = await _pedirNombreProyecto();
      if (nombre == null || nombre.isEmpty) return;

      final id = await insertProyecto(
        uid,
        nombre,
        _workspaceJson!,
        _codigo ?? '',
      );
      setState(() {
        _proyectoId = id;
        _nombreProyecto = nombre;
      });
    } else {
      // si ya existe, preguntamos si sobreescribir o crear uno nuevo
      final opcion = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Guardar proyecto'),
          content: Text(
            '¿Quieres sobreescribir "$_nombreProyecto" o guardarlo como un nuevo proyecto?',
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

      if (opcion == null) return;

      if (opcion == 'sobreescribir') {
        await updateProyecto(_proyectoId!, _workspaceJson!, _codigo ?? '');
      } else {
        final nombre = await _pedirNombreProyecto();
        if (nombre == null || nombre.isEmpty) return;

        final id = await insertProyecto(
          uid,
          nombre,
          _workspaceJson!,
          _codigo ?? '',
        );
        setState(() {
          _proyectoId = id;
          _nombreProyecto = nombre;
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
  Future<String?> _pedirNombreProyecto() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nombre del proyecto'),
          content: TextField(
            controller: controller,
            autofocus: true,
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
  static const _servidorUrl = 'http://localhost:3000';

  // Manda el código al servidor para compilarlo
  Future<void> _compilarYSubir() async {
    if (_codigo == null || _codigo!.isEmpty) return;

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
        Uri.parse('$_servidorUrl/compile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'codigo': _codigo,
          'placa': 'esp8266:esp8266:nodemcuv2',
        }),
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
        _mostrarErrorCompilacion(
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
  void _mostrarErrorCompilacion(String error) {
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
  void _mostrarCodigo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
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
                          if (_codigo != null) {
                            Clipboard.setData(ClipboardData(text: _codigo!));
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
                      IconButton(
                        icon: const Icon(Icons.save),
                        tooltip: 'Guardar proyecto',
                        onPressed: () {
                          Navigator.pop(context);
                          _guardar();
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
                    _codigo ?? '',
                    style: const TextStyle(
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
                  onPressed: _listo ? _limpiarWorkspace : null,
                  backgroundColor: _listo ? null : Colors.grey,
                  child: const Icon(Icons.delete_outline),
                ),
                const SizedBox(width: 12),
                // boton para guardar el proyecto
                FloatingActionButton(
                  heroTag: 'guardar',
                  onPressed: _listo ? _guardar : null,
                  backgroundColor: _listo ? null : Colors.grey,
                  child: const Icon(Icons.save),
                ),
                const SizedBox(width: 12),
                // boton para compilar (generar codigo arduino)
                FloatingActionButton(
                  heroTag: 'compilar',
                  onPressed: _listo ? _compilar : null,
                  backgroundColor: _listo ? null : Colors.grey,
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
