import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:robokid/widgets/custom_appbar.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  late final WebViewController _controller;
  bool _listo = false;
  String? _codigo;

  @override
  void initState() {
    super.initState();

    // cargar el editor Blockly en el webview
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel('FlutterChannel', onMessageReceived: _onMensaje)
      ..loadFlutterAsset('assets/blockly_editor.html');
  }

  // mensajes que llegan desde Blockly (JS -> Dart)
  void _onMensaje(JavaScriptMessage mensaje) {
    final datos = jsonDecode(mensaje.message);
    final tipo = datos['type'];

    if (tipo == 'blocklyReady') {
      setState(() => _listo = true);
    } else if (tipo == 'arduinoCode') {
      setState(() => _codigo = datos['data']);
      _mostrarCodigo();
    } else if (tipo == 'workspaceState') {
      setState(() {});
    }
  }

  void _compilar() {
    _controller.runJavaScript('requestCode()');
  }

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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
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
