package com.taebbong.sendtome

import android.accessibilityservice.AccessibilityButtonController
import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Build
import android.view.accessibility.AccessibilityEvent

/**
 * An AccessibilityService whose ONLY job is to be a shortcut target: when the
 * user invokes the accessibility shortcut (the nav-bar / floating Accessibility
 * button, the volume-key hold, or the gesture-nav swipe — all route here), it
 * opens the quick-capture screen. This gives users far more trigger surfaces
 * than the Samsung side-key, which only offers "double press → open app".
 *
 * It deliberately inspects NO screen content (`typeNone`,
 * `canRetrieveWindowContent=false` in the XML config) — it only needs the button
 * callback. See [QuickCaptureActivity] for the launched screen.
 *
 * NOTE (Play policy): AccessibilityService is a high-scrutiny API. This service
 * must ship with `isAccessibilityTool=false`, a prominent in-app disclosure, and
 * a completed Play Console accessibility declaration before release.
 */
class QuickCaptureAccessibilityService : AccessibilityService() {

    private val buttonCallback =
        object : AccessibilityButtonController.AccessibilityButtonCallback() {
            override fun onClicked(controller: AccessibilityButtonController) {
                launchCapture()
            }
        }

    override fun onServiceConnected() {
        super.onServiceConnected()
        // The accessibility button (and the shortcut surfaces that map to it) is
        // only available from API 26.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            accessibilityButtonController.registerAccessibilityButtonCallback(buttonCallback)
        }
    }

    private fun launchCapture() {
        val intent = Intent(this, QuickCaptureActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        // AccessibilityServices are exempt from background-activity-launch limits.
        startActivity(intent)
    }

    override fun onUnbind(intent: Intent?): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            accessibilityButtonController.unregisterAccessibilityButtonCallback(buttonCallback)
        }
        return super.onUnbind(intent)
    }

    // We subscribe to no events and inspect nothing — these are required no-ops.
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}

    override fun onInterrupt() {}
}
