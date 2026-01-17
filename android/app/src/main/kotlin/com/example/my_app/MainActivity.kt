package com.example.my_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val CHANNEL_BATTERY = "toolset/battery"
private const val CHANNEL_MEDIASTORE = "toolset/mediastore"
private const val CHANNEL_SAF = "toolset/saf"
private const val CHANNEL_USAGE = "toolset/usage"
private const val CHANNEL_UMP = "toolset/ump_consent"

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_BATTERY)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getLiveMetrics" -> {
                        // TODO: Implement BatteryManager readings
                        result.success(mapOf<String, Any>())
                    }
                    else -> result.error("UNSUPPORTED_DEVICE", "Method not supported", null)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_MEDIASTORE)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "query" -> result.success(emptyList<Map<String, Any>>())
                    "delete" -> result.success(false)
                    else -> result.error("UNSUPPORTED_DEVICE", "Method not supported", null)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SAF)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openTreePicker" -> result.success(false)
                    else -> result.error("UNSUPPORTED_DEVICE", "Method not supported", null)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_USAGE)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(false)
                    "openPermissionSettings" -> result.success(null)
                    "appUsage" -> result.success(emptyList<Map<String, Any>>())
                    else -> result.error("UNSUPPORTED_DEVICE", "Method not supported", null)
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_UMP)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestConsentIfRequired" -> result.success(false)
                    "presentConsentForm" -> result.success(null)
                    "isConsentObtained" -> result.success(false)
                    else -> result.error("UNSUPPORTED_DEVICE", "Method not supported", null)
                }
            }
    }
}
