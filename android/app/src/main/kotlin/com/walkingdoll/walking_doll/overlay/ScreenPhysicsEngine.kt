package com.walkingdoll.walking_doll.overlay

import android.content.Context
import android.os.Handler
import android.os.Looper

/**
 * Screen-Coordinate Physics Engine.
 * Treats the visible Android phone screen as the 3D doll's physical environment.
 * Manages screen boundaries, gravity, falling velocity, landing collision detection,
 * and walking locomotion across the screen.
 */
class ScreenPhysicsEngine(
    private val context: Context,
    private val onPositionUpdated: (x: Int, y: Int) -> Unit,
    private val onLanded: () -> Unit,
    private val onEdgeReached: (isLeftEdge: Boolean) -> Unit
) {
    private val handler = Handler(Looper.getMainLooper())

    var currentX: Float = 100f
    var currentY: Float = 200f
    var velocityX: Float = 0f
    var velocityY: Float = 0f

    var dollWidth: Int = 160
    var dollHeight: Int = 180

    var screenWidth: Int = 1080
    var screenHeight: Int = 2400

    private val gravity: Float = 2200f // px/s^2
    private var isPhysicsLoopActive = false
    private var lastUpdateTimeMs: Long = 0L

    var isWalking: Boolean = false
    var walkSpeedPxPerSec: Float = 50f
    var walkDirection: Int = 1 // +1 = right, -1 = left

    init {
        updateScreenDimensions()
    }

    fun updateScreenDimensions() {
        val dm = context.resources.displayMetrics
        screenWidth = dm.widthPixels
        screenHeight = dm.heightPixels
        val density = dm.density
        dollWidth = (160 * density).toInt()
        dollHeight = (180 * density).toInt()
    }

    fun setPosition(x: Int, y: Int) {
        currentX = x.toFloat()
        currentY = y.toFloat()
    }

    fun startPhysicsLoop() {
        if (isPhysicsLoopActive) return
        isPhysicsLoopActive = true
        lastUpdateTimeMs = System.currentTimeMillis()
        scheduleNextFrame()
    }

    fun stopPhysicsLoop() {
        isPhysicsLoopActive = false
    }

    fun startFalling(initialVy: Float = 0f) {
        velocityY = initialVy
        startPhysicsLoop()
    }

    fun startWalking(speedPxPerSec: Float, direction: Int) {
        walkSpeedPxPerSec = speedPxPerSec
        walkDirection = direction
        isWalking = true
        startPhysicsLoop()
    }

    fun stopWalking() {
        isWalking = false
        velocityX = 0f
    }

    private fun scheduleNextFrame() {
        if (!isPhysicsLoopActive) return
        handler.postDelayed({
            tickPhysics()
            scheduleNextFrame()
        }, 16) // ~60 FPS
    }

    private fun tickPhysics() {
        val now = System.currentTimeMillis()
        val dt = ((now - lastUpdateTimeMs).coerceIn(1L, 50L)) / 1000f
        lastUpdateTimeMs = now

        val floorY = (screenHeight - dollHeight).toFloat()
        val minX = 0f
        val maxX = (screenWidth - dollWidth).toFloat()

        var positionChanged = false

        // 1. Vertical Physics (Gravity & Floor Landing)
        if (currentY < floorY || velocityY != 0f) {
            velocityY += gravity * dt
            currentY += velocityY * dt

            if (currentY >= floorY) {
                currentY = floorY
                val impactSpeed = velocityY
                velocityY = 0f
                positionChanged = true
                if (impactSpeed > 350f) {
                    onLanded()
                }
            } else {
                positionChanged = true
            }
        }

        // 2. Horizontal Locomotion & Screen Boundaries
        if (isWalking) {
            currentX += (walkDirection * walkSpeedPxPerSec) * dt
            positionChanged = true

            // Collision with left / right screen edges
            if (currentX <= minX) {
                currentX = minX
                walkDirection = 1 // turn around right
                onEdgeReached(true)
            } else if (currentX >= maxX) {
                currentX = maxX
                walkDirection = -1 // turn around left
                onEdgeReached(false)
            }
        }

        if (positionChanged) {
            onPositionUpdated(currentX.toInt(), currentY.toInt())
        }
    }
}

