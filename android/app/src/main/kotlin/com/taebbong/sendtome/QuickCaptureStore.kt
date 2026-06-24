package com.taebbong.sendtome

import android.content.Context
import org.json.JSONArray

/**
 * A tiny FIFO queue of quick-capture texts, backed by [SharedPreferences].
 *
 * The translucent [QuickCaptureActivity] appends captures here (it can run while
 * the main app is dead); the main Flutter app drains them on launch/resume via
 * the `app/quick_capture` method channel and turns each into a real memo. The
 * native side never touches the Drift database — it only buffers raw text.
 */
object QuickCaptureStore {
    private const val PREFS = "quick_capture"
    private const val KEY = "pending"

    @Synchronized
    fun append(context: Context, text: String) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val arr = JSONArray(prefs.getString(KEY, "[]"))
        arr.put(text)
        prefs.edit().putString(KEY, arr.toString()).apply()
    }

    /** Returns every queued capture (oldest first) and clears the queue. */
    @Synchronized
    fun drain(context: Context): List<String> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val arr = JSONArray(prefs.getString(KEY, "[]"))
        val out = ArrayList<String>(arr.length())
        for (i in 0 until arr.length()) out.add(arr.getString(i))
        prefs.edit().remove(KEY).apply()
        return out
    }
}
