// lib/screens/send_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:robokid/providers/providers.dart';
import 'package:robokid/widgets/custom_snackbar.dart';

class SendScreen extends StatefulWidget {
  final Uint8List firmwareBytes;
  final String firmwareName;

  const SendScreen({
    super.key,
    required this.firmwareBytes,
    required this.firmwareName,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  // IP fija del Access Point del ESP8266 (definida en el Sketch 1)
  static const String _espIp = "192.168.4.1";
  static const int _espPort = 80;

  String _log = "";
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectivityProvider>().refresh();
    });
  }

  void _checkConnection() {
    final conn = context.read<ConnectivityProvider>();
    if (!conn.isOnRobotWifi && !_uploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conexión con el robot perdida'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _uploadFirmware() async {
    setState(() {
      _uploading = true;
      _log = "";
    });

    final url = Uri.parse("http://$_espIp:$_espPort/update");
    _appendLog("→ Conectando a ESP8266 en $_espIp ...");
    _appendLog(
      "⚠ Asegúrate de estar conectado al WiFi 'ESP8266-OTA' y tener desactivados los datos moviles",
    );

    try {
      final request = http.MultipartRequest("POST", url);

      request.files.add(
        await http.MultipartFile.fromBytes(
          "firmware",
          widget.firmwareBytes,
          filename: "firmware.bin",
        ),
      );

      final fileSize = widget.firmwareBytes.length;
      _appendLog("→ Enviando ${(fileSize / 1024).toStringAsFixed(1)} KB ...");

      final streamed = await request.send().timeout(
        const Duration(seconds: 120),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        _appendLog("✓ Flash completado. La placa está reiniciando...");
      } else {
        _appendLog("✗ Error (${response.statusCode}): ${response.body}");
      }
    } on SocketException {
      _appendLog("✗ No se pudo conectar.");
      _appendLog("  ¿Estás conectado al WiFi 'ESP8266-OTA'?");
      _appendLog(
        "  ¿La placa está encendida y los datos moviles estan desactivados?",
      );
    } catch (e) {
      _appendLog("✗ Error: $e");
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _appendLog(String line) {
    setState(() => _log += "$line\n");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final conn = context.watch<ConnectivityProvider>();

    if (!conn.isOnRobotWifi && !_uploading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CustomSnackBar.showSnackBar(
            'Se ha perdido la conexión con el robot',
            context,
            theme
          );
          Navigator.pop(context);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("OTA Flasher – ESP8266"),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.wifi, color: Colors.indigo),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Conecta el móvil al WiFi 'ESP8266-OTA' antes de flashear",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: !_uploading && conn.isOnRobotWifi ? _uploadFirmware : null,
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(conn.isOnRobotWifi ? Icons.upload : Icons.wifi_find),
              label: Text(_uploading ? "Flasheando…" : "Flashear por OTA"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 24),

            Text("Consola", style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _log.isEmpty ? "Esperando…" : _log,
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
