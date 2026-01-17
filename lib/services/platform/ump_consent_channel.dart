import 'package:flutter/services.dart';
import '../../core/platform_errors.dart';

class UmpConsentChannel {
  static const _channel = MethodChannel('toolset/ump_consent');

  static Future<bool> requestConsentIfRequired() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestConsentIfRequired');
      return result ?? false;
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }

  static Future<void> presentConsentForm() async {
    try {
      await _channel.invokeMethod('presentConsentForm');
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }

  static Future<bool> isConsentObtained() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConsentObtained');
      return result ?? false;
    } on PlatformException catch (e) {
      throw PlatformChannelException(e.code, e.message, e.details);
    }
  }
}

