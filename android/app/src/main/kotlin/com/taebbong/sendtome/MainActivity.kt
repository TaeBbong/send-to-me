package com.taebbong.sendtome

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Drains quick captures buffered by QuickCaptureActivity into the app so
        // QuickCaptureListener can turn them into memos. See QuickCaptureStore.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/quick_capture")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "drainPending" -> result.success(QuickCaptureStore.drain(applicationContext))
                    else -> result.notImplemented()
                }
            }
    }
}
