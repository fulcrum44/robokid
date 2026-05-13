import 'package:flutter/services.dart';

class MobileDataChecker {
  static const _channel = MethodChannel('robokid/connectivity');

  static Future<bool> isMobileDataEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isMobileDataEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}