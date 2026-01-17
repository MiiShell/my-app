import 'package:flutter/services.dart';
import '../../core/platform_errors.dart';

class SafChannel {
  static const _channel = MethodChannel('toolset/saf');

  static Future<bool> openTreePicker() async {
    try {
      final result = await _channel.invokeMethod<bool>('openTreePicker');
      return result ?? false;
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }
}

