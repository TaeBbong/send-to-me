package com.taebbong.sendtome

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Quick Settings tile that opens the translucent [QuickCaptureActivity] straight
 * from the notification shade — the lowest-friction "capture from anywhere"
 * entry point that works on every OEM (including Samsung) without special
 * permissions.
 */
class QuickCaptureTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_INACTIVE
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        // unlockAndRun runs immediately when the device is unlocked, and after a
        // successful unlock otherwise — so capture works from the lock screen too.
        unlockAndRun { launchCapture() }
    }

    private fun launchCapture() {
        val intent = Intent(this, QuickCaptureActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // Android 14+: startActivityAndCollapse(Intent) throws; must use a PendingIntent.
            val pending = PendingIntent.getActivity(
                this,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            startActivityAndCollapse(pending)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }
}
