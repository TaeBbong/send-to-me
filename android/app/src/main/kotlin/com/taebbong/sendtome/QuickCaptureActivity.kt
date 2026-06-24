package com.taebbong.sendtome

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Translucent, single-purpose capture screen launched by [QuickCaptureTileService].
 *
 * It runs the dedicated `quickCaptureMain` Dart entry point (a minimal sheet UI)
 * in its own Flutter engine with a transparent background, so the user gets a
 * keyboard-focused note field floating over a dim scrim. On send, the Dart side
 * calls `saveCapture`, we buffer the text in [QuickCaptureStore], and the main
 * app imports it later. `close` finishes the activity.
 */
class QuickCaptureActivity : FlutterActivity() {

    override fun getDartEntrypointFunctionName(): String = "quickCaptureMain"

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/quick_capture")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveCapture" -> {
                        val text = call.argument<String>("text")
                        if (!text.isNullOrBlank()) {
                            QuickCaptureStore.append(applicationContext, text)
                        }
                        result.success(null)
                    }
                    "close" -> {
                        result.success(null)
                        finish()
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
