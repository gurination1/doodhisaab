import 'package:flutter/services.dart';

class BackGuardChannel {
  BackGuardChannel._();

  static const MethodChannel _channel = MethodChannel('doodhisaab/back_guard');

  static Future<void> setCurrentRoute(String route) {
    return _channel.invokeMethod<void>('setCurrentRoute', route);
  }
}
