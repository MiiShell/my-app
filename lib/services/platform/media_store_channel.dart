import 'package:flutter/services.dart';
import '../../core/platform_errors.dart';

class MediaStoreChannel {
  static const _channel = MethodChannel('toolset/mediastore');

  static Future<List<Map<String, dynamic>>> query(Map<String, dynamic> args) async {
    try {
      final result = await _channel.invokeListMethod<Map>('query', args);
      return (result ?? []).cast<Map<String, dynamic>>();
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }

  static Future<bool> delete(List<String> uris) async {
    try {
      final result = await _channel.invokeMethod<bool>('delete', {'uris': uris});
      return result ?? false;
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }
}

