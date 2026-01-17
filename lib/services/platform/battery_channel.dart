import 'package:flutter/services.dart';
import '../../core/platform_errors.dart';

class BatteryChannel {
  static const _channel = MethodChannel('toolset/battery');

  static Future<Map<String, dynamic>> getLiveMetrics() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getLiveMetrics');
      return result ?? <String, dynamic>{};
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }
}

