import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:robokid/providers/connectivity_provider.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectivityProvider>();

    if (!conn.initialized || conn.hasInternet) return const SizedBox.shrink();

    final isRobot = conn.isOnRobotWifi;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isRobot ? Colors.orange.shade700 : Colors.red.shade700,
      child: Row(
        children: [
          Icon(
            isRobot ? Icons.router : Icons.wifi_off,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isRobot
                  ? 'Conectado al robot — sin acceso a internet'
                  : 'Sin conexión a internet',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}