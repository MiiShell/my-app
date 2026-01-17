import 'package:flutter/services.dart';
import '../../core/platform_errors.dart';

class UsageStatsChannel {
  static const _channel = MethodChannel('toolset/usage');

  static Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }

  static Future<void> openPermissionSettings() async {
    try {
      await _channel.invokeMethod('openPermissionSettings');
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }

  static Future<List<Map<String, dynamic>>> appUsage({required int sinceMs}) async {
    try {
      final result = await _channel.invokeListMethod<Map>('appUsage', {'sinceMs': sinceMs});
      return (result ?? []).cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }
}

