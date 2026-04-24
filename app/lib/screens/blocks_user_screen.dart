import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:robokid/widgets/custom_appbar.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  late final WebViewController _controller;
  bool _listo = false; // se pone en true cuando Blockly termina de cargar
  String? _codigo; // último código Arduino generado
  String? _workspaceJson; // estado serializado del workspace (JSON)

  @override
  void initState() {
    super.initState();

    // Configuramos el WebView para cargar el editor Blockly
    // FlutterChannel es el puente JS -> Dart
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('FlutterChannel', onMessageReceived: _onMensaje)
      ..loadFlutterAsset('assets/blockly_editor.html');
  }

  // Recibe los mensajes que manda Blockly desde JavaScript
  void _onMensaje(JavaScriptMessage mensaje) {
    final datos = jsonDecode(mensaje.message);
    final tipo = datos['type'];

    if (tipo == 'blocklyReady') {
      setState(() => _listo = true);
    } else if (tipo == 'arduinoCode') {
      setState(() => _codigo = datos['data']);
      _mostrarCodigo();
    } else if (tipo == 'workspaceState') {
      setState(() => _workspaceJson = jsonEncode(datos['data']));
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
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        onPressed: _listo ? _compilar : null,
        backgroundColor: _listo ? null : Colors.grey,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
