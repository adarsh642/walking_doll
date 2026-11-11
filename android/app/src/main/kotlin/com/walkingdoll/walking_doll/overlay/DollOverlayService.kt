package com.walkingdoll.walking_doll.overlay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.walkingdoll.walking_doll.MainActivity

/**
 * Foreground Service hosting the native Android Floating Doll Overlay.
 * Manages notification channel, system lifecycle, and routes commands
 * between the Flutter MethodChannel and the OverlayWindowManager.
 */
class DollOverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "doll_overlay_notification_channel"
        const val NOTIFICATION_ID = 1001

        const val ACTION_START = "com.walkingdoll.ACTION_START"
        const val ACTION_STOP = "com.walkingdoll.ACTION_STOP"
        const val ACTION_UPDATE_CHARACTER = "com.walkingdoll.ACTION_UPDATE_CHARACTER"
        const val ACTION_UPDATE_ANIMATION = "com.walkingdoll.ACTION_UPDATE_ANIMATION"

        const val EXTRA_ANIMATION = "extra_animation"
        const val EXTRA_CHARACTER_PAYLOAD = "extra_character_payload"

        var isRunning = false
            private set
    }

    private var windowManager: OverlayWindowManager? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        windowManager = OverlayWindowManager(this) {
            stopSelf()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            return START_NOT_STICKY
        }

        when (intent.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_UPDATE_ANIMATION -> {
                val anim = intent.getStringExtra(EXTRA_ANIMATION) ?: "idle"
                windowManager?.playAnimation(anim)
            }
            ACTION_UPDATE_CHARACTER -> {
                @Suppress("UNCHECKED_CAST")
                val characterData = intent.getSerializableExtra(EXTRA_CHARACTER_PAYLOAD) as? HashMap<String, Any?>
                if (characterData != null) {
                    windowManager?.updateCharacter(characterData)
                }
            }
            ACTION_START, null -> {
                @Suppress("UNCHECKED_CAST")
                val characterData = (intent.getSerializableExtra(EXTRA_CHARACTER_PAYLOAD) as? HashMap<String, Any?>) ?: hashMapOf()
                val characterName = characterData["name"] as? String ?: "Virtual Doll"

                startForegroundServiceWithNotification(characterName)
                windowManager?.show(characterData)
                isRunning = true
            }
        }

        return START_STICKY
    }

    private fun startForegroundServiceWithNotification(characterName: String) {
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingOpenApp = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val stopIntent = Intent(this, DollOverlayService::class.java).apply {
            action = ACTION_STOP
        }
        val pendingStop = PendingIntent.getService(
            this,
            1,
            stopIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Walking Doll: $characterName")
            .setContentText("Your virtual companion is walking on screen!")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentIntent(pendingOpenApp)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Hide Overlay", pendingStop)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (Build.VERSION.SDK_INT >= 34) {
                // Foreground service type specialUse on Android 14+
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Walking Doll Companion Service"
            val descriptionText = "Displays the floating virtual doll overlay companion on screen"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                setShowBadge(false)
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        isRunning = false
        windowManager?.destroy()
        windowManager = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

