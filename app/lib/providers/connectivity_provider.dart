import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum AppConnectionState {
  online, // Conectado a internet
  robotWifi, // Conectado a la placa del robot
  offline, // Sin conexión
}

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  AppConnectionState _state = AppConnectionState.offline;
  AppConnectionState get state => _state;

  bool get hasInternet => _state == AppConnectionState.online;
  bool get isOnRobotWifi => _state == AppConnectionState.robotWifi;
  bool get isOffile => _state == AppConnectionState.offline;

  // Con este flag controloamos cuando aparece el banner que indica si no hay conexión a internet o estamos conectados al robot.
  bool _initialized = false;
  bool get initialized => _initialized;
  
  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();

    if (result.contains(ConnectivityResult.none) || result.isEmpty) {
      _updateState(AppConnectionState.offline);
      return;
    } else if (await _isRobotReachable()) { // Comprobamos si estamos en la red que hemos configurado para el robot (192.168.4.1)
      _updateState(AppConnectionState.robotWifi);
      return;
    } else if (await _hasRealInternet()) { // Comprobamos si hay internet real
      _updateState(AppConnectionState.online);
      return;
    } else {
      _updateState(AppConnectionState.offline);
    }

    if (!_initialized) {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> _isRobotReachable() async {
    try {
      final response = await HttpClient()
          .getUrl(Uri.parse('http://192.168.4.1/status'))
          .timeout(const Duration(seconds: 15))
          .then((req) => req.close())
          .timeout(const Duration(seconds: 15));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _updateState(AppConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _checkConnection();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
