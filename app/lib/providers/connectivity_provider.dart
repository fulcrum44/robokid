import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:robokid/services/services.dart';

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

  bool _mobileDataActive = false;
  bool get mobileDataActive => _mobileDataActive;

  
  bool _mobileDataEnabled = false;
  bool get mobileDataEnabled => _mobileDataEnabled;

  bool get hasInternet => _state == AppConnectionState.online;
  bool get isOnRobotWifi => _state == AppConnectionState.robotWifi && !_mobileDataEnabled;
  bool get isOffile => _state == AppConnectionState.offline;


  // Con este flag controloamos cuando aparece el banner que indica si no hay conexión a internet o estamos conectados al robot.
  bool _initialized = false;
  bool get initialized => _initialized;
  
  ConnectivityProvider() {
    _init();
  }

  Timer? _pollingTimer;

  Future<void> _init() async {
    await _checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();

    // Primero comprobamos si los datos móviles están activados o desactivados
    final oldMobileData = _mobileDataEnabled;
    _mobileDataEnabled = await MobileDataChecker.isMobileDataEnabled();

    if (oldMobileData != _mobileDataEnabled) {
      notifyListeners();
    }

    // Ninguna conexión activa
    if (result.contains(ConnectivityResult.none) || result.isEmpty) {
      _updateState(AppConnectionState.offline);
      _setInitialized();
      return;
    }

    // Si hay WiFi, comprobar si es el robot primero
    if (result.contains(ConnectivityResult.wifi)) {
      if (await _isRobotReachable()) {
        _updateState(AppConnectionState.robotWifi);
        _setInitialized();
        return;
      }
    }

    // Si hay WiFi o datos móviles declaramos que estamos online
    if (result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile)) {
      _updateState(AppConnectionState.online);
      _setInitialized();
      // Verificar en segundo plano
      _verifyInternetInBackground();
      return;
    }

    _updateState(AppConnectionState.offline);
    _setInitialized();
  }

  void _setInitialized() {
    if (!_initialized) {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> _verifyInternetInBackground() async {
    if (!await _hasRealInternet()) {
      _updateState(AppConnectionState.offline);
    }
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _isRobotReachable() async {
    try {
      final socket = await Socket.connect(
        '192.168.4.1',
        80,
        timeout: const Duration(seconds: 2),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _updateState(AppConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
    // Cuando estamos cerca del robot, activar polling rápido
    if (_state == AppConnectionState.robotWifi || _couldBeRobotWifi()) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  Future<void> refresh() async {
    await _checkConnection();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkConnection();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  bool _couldBeRobotWifi() {
    // Si tenemos WiFi pero no internet, podríamos estar en el robot
    return _state == AppConnectionState.offline && !_mobileDataEnabled;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
