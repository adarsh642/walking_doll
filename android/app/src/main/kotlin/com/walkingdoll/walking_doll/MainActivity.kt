package com.walkingdoll.walking_doll

import android.content.Intent
import android.os.Build
import com.walkingdoll.walking_doll.overlay.DollOverlayService
import com.walkingdoll.walking_doll.overlay.OverlayPermissionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val OVERLAY_CHANNEL = "com.walkingdoll/overlay"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkOverlayPermission" -> {
                        val hasPermission = OverlayPermissionManager.hasOverlayPermission(context)
                        result.success(hasPermission)
                    }

                    "requestOverlayPermission" -> {
                        OverlayPermissionManager.requestOverlayPermission(this)
                        result.success(true)
                    }

                    "isOverlayActive" -> {
                        result.success(DollOverlayService.isRunning)
                    }

                    "startOverlay" -> {
                        val hasPermission = OverlayPermissionManager.hasOverlayPermission(context)
                        if (!hasPermission) {
                            result.error(
                                "PERMISSION_DENIED",
                                "SYSTEM_ALERT_WINDOW overlay permission has not been granted",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        @Suppress("UNCHECKED_CAST")
                        val characterArgs = call.arguments as? Map<String, Any?> ?: emptyMap()
                        val characterPayload = HashMap<String, Any?>(characterArgs)

                        val serviceIntent = Intent(context, DollOverlayService::class.java).apply {
                            action = DollOverlayService.ACTION_START
                            putExtra(DollOverlayService.EXTRA_CHARACTER_PAYLOAD, characterPayload)
                        }

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent)
                        } else {
                            startService(serviceIntent)
                        }
                        result.success(true)
                    }

                    "stopOverlay" -> {
                        val serviceIntent = Intent(context, DollOverlayService::class.java).apply {
                            action = DollOverlayService.ACTION_STOP
                        }
                        stopService(serviceIntent)
                        result.success(true)
                    }

                    "updateCharacter" -> {
                        @Suppress("UNCHECKED_CAST")
                        val characterArgs = call.arguments as? Map<String, Any?> ?: emptyMap()
                        val characterPayload = HashMap<String, Any?>(characterArgs)

                        val updateIntent = Intent(context, DollOverlayService::class.java).apply {
                            action = DollOverlayService.ACTION_UPDATE_CHARACTER
                            putExtra(DollOverlayService.EXTRA_CHARACTER_PAYLOAD, characterPayload)
                        }
                        startService(updateIntent)
                        result.success(true)
                    }

                    "updateAnimation" -> {
                        val animation = call.argument<String>("animation") ?: "idle"
                        val updateIntent = Intent(context, DollOverlayService::class.java).apply {
                            action = DollOverlayService.ACTION_UPDATE_ANIMATION
                            putExtra(DollOverlayService.EXTRA_ANIMATION, animation)
                        }
                        startService(updateIntent)
                        result.success(true)
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
