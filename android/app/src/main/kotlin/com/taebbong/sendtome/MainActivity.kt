package com.taebbong.sendtome

import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Drains quick captures buffered by QuickCaptureActivity into the app so
        // QuickCaptureListener can turn them into memos. See QuickCaptureStore.
        // Also reports/links to the accessibility-shortcut setup.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/quick_capture")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "drainPending" -> result.success(QuickCaptureStore.drain(applicationContext))
                    "isAccessibilityEnabled" -> result.success(isAccessibilityServiceEnabled())
                    "openAccessibilitySettings" -> {
                        openAccessibilitySettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val expected = ComponentName(this, QuickCaptureAccessibilityService::class.java)
            .flattenToString()
        val enabled = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        return enabled.split(':').any { it.equals(expected, ignoreCase = true) }
    }

    private fun openAccessibilitySettings() {
        val component =
            ComponentName(this, QuickCaptureAccessibilityService::class.java).flattenToString()
        // Android 11+: best-effort deep-link to our service's detail page. These
        // action/extra names aren't public SDK constants, so use string literals.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val intent = Intent("android.settings.ACCESSIBILITY_DETAILS_SETTINGS").apply {
                    putExtra(EXTRA_A11Y_COMPONENT, component)
                    // Some OEM Settings apps read the legacy fragment-args bundle.
                    val args = Bundle().apply { putString(EXTRA_A11Y_COMPONENT, component) }
                    putExtra(":settings:show_fragment_args", args)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                return
            } catch (_: Exception) {
                // Fall through to the generic accessibility settings page.
            }
        }
        startActivity(
            Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
    }

    private companion object {
        const val EXTRA_A11Y_COMPONENT =
            "android.provider.extra.ACCESSIBILITY_SERVICE_COMPONENT_NAME"
    }
}
