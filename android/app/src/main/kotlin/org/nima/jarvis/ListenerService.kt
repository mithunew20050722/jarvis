package org.nima.jarvis

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Keeps the JARVIS process alive in the background with a persistent
 * notification (Android requires this for any app doing continuous mic
 * work while not in the foreground — same requirement Google Assistant,
 * Otter.ai etc. all have to satisfy).
 *
 * The actual wake-word listening loop runs on the Dart side
 * (lib/services/wake_word_service.dart) using the speech_to_text plugin;
 * this service's only job is to hold the process + notification open so
 * Android's task manager doesn't kill it.
 */
class ListenerService : Service() {
    private val channelId = "jarvis_listener_channel"
    private val notifId = 1001

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = buildNotification()
        startForeground(notifId, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "JARVIS Listener",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description = "Keeps JARVIS listening in the background"
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("JARVIS")
            .setContentText("Listening in the background for \"jarvis\"")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .build()
    }
}
