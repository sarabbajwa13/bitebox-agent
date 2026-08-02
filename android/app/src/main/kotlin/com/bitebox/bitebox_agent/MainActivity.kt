package com.bitebox.bitebox_agent

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }
    }

    /**
     * "bitebox_orders" channel — custom sound (raw/notification_sound.mp3) ke saath.
     * Naya channel id use kar rahe hain kyunki purana "new_orders" default sound se
     * ban chuka tha (Android 8+ pe existing channel ka sound badla nahi ja sakta).
     */
    private fun createNotificationChannel() {
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "bitebox_orders"

        val soundUri = Uri.parse("android.resource://$packageName/raw/notification_sound")

        val audioAttributes = AudioAttributes.Builder()
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .build()

        val channel = NotificationChannel(
            channelId,
            "New orders",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Alerts when a new order arrives"
            setSound(soundUri, audioAttributes)
            enableVibration(true)
            enableLights(true)
        }

        notificationManager.createNotificationChannel(channel)
    }
}
