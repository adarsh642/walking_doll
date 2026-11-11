package com.walkingdoll.walking_doll.overlay

import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.abs

/**
 * Manages the floating WindowManager overlay view, screen-coordinate physics
 * (gravity, landing, velocity, screen boundaries), autonomous personality behavior,
 * and touch interactions (tap head, tap body, drag-and-drop falling, double-tap dance).
 */
class OverlayWindowManager(
    private val context: Context,
    private val onStopOverlayRequested: () -> Unit
) {

    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
    private val prefs: SharedPreferences =
        context.getSharedPreferences("walking_doll_overlay_prefs", Context.MODE_PRIVATE)

    private var rootView: LinearLayout? = null
    private var dollContainer: FrameLayout? = null
    private var controlsContainer: LinearLayout? = null

    private var currentRenderer: OverlayRenderer? = null
    private var currentCharacterData: Map<String, Any?> = emptyMap()
    private var currentAnimation: String = "idle"

    private lateinit var layoutParams: WindowManager.LayoutParams
    private var isAttached = false
    private var isControlsExpanded = false

    // Autonomous Personality and Screen Physics Engines
    private lateinit var physicsEngine: ScreenPhysicsEngine
    private lateinit var behaviourEngine: AutonomousBehaviourEngine

    // Double tap tracking
    private var lastTapTimeMs = 0L

    init {
        initPhysicsAndBehaviour()
    }

    private fun initPhysicsAndBehaviour() {
        physicsEngine = ScreenPhysicsEngine(
            context = context,
            onPositionUpdated = { x, y ->
                if (isAttached && rootView != null) {
                    layoutParams.x = x
                    layoutParams.y = y
                    try {
                        windowManager.updateViewLayout(rootView, layoutParams)
                    } catch (e: Exception) {
                        // View may be detached
                    }
                }
            },
            onLanded = {
                behaviourEngine.onLanded()
            },
            onEdgeReached = { isLeft ->
                // Turn around to face direction of movement
                (currentRenderer as? ThreeDOverlayRenderer)?.setFacingDirection(if (isLeft) 1 else -1)
                currentRenderer?.playAnimation("walk")
            }
        )

        behaviourEngine = AutonomousBehaviourEngine(
            onStateChanged = { state, animClip ->
                playAnimation(animClip)
            },
            onMoveRequest = { speed, dir ->
                physicsEngine.startWalking(speed, dir)
                (currentRenderer as? ThreeDOverlayRenderer)?.setFacingDirection(dir)
            },
            onStopMoveRequest = {
                physicsEngine.stopWalking()
                (currentRenderer as? ThreeDOverlayRenderer)?.setFacingDirection(0)
            }
        )
    }

    fun show(initialCharacterData: Map<String, Any?>) {
        if (isAttached) {
            updateCharacter(initialCharacterData)
            return
        }

        currentCharacterData = initialCharacterData
        val density = context.resources.displayMetrics.density

        // Setup WindowManager LayoutParams
        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        // Restore saved position or default to screen bottom
        val screenHeight = context.resources.displayMetrics.heightPixels
        val defaultY = (screenHeight - (220 * density)).toInt().coerceAtLeast(100)
        val savedX = prefs.getInt("overlay_x", (80 * density).toInt())
        val savedY = prefs.getInt("overlay_y", defaultY)

        layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = savedX
            y = savedY
        }

        physicsEngine.setPosition(savedX, savedY)

        // Build composite root view
        rootView = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            clipChildren = false
            clipToPadding = false
        }

        dollContainer = FrameLayout(context).apply {
            clipChildren = false
            clipToPadding = false
        }

        // Build quick control bar
        controlsContainer = buildControlsView()

        rootView?.addView(dollContainer)
        rootView?.addView(controlsContainer)

        setupRendererForCharacter(currentCharacterData)
        setupDragTouchListener()

        try {
            windowManager.addView(rootView, layoutParams)
            isAttached = true
            behaviourEngine.start()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun buildControlsView(): LinearLayout {
        val density = context.resources.displayMetrics.density

        val bar = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(
                (8 * density).toInt(),
                (4 * density).toInt(),
                (8 * density).toInt(),
                (4 * density).toInt()
            )
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#F01A1826"))
                cornerRadius = 18 * density
                setStroke((1.2f * density).toInt(), Color.parseColor("#66FF80AB"))
            }
            visibility = View.GONE
        }

        fun createPillButton(text: String, onClick: () -> Unit): TextView {
            return TextView(context).apply {
                this.text = text
                textSize = 10f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(Color.WHITE)
                setPadding(
                    (7 * density).toInt(),
                    (4 * density).toInt(),
                    (7 * density).toInt(),
                    (4 * density).toInt()
                )
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#33FFFFFF"))
                    cornerRadius = 12 * density
                }
                setOnClickListener { onClick() }
                val lp = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    marginEnd = (3 * density).toInt()
                }
                layoutParams = lp
            }
        }

        bar.addView(createPillButton("💤 Idle") {
            physicsEngine.stopWalking()
            playAnimation("idle")
        })
        bar.addView(createPillButton("🐾 Walk") {
            physicsEngine.startWalking(40f, 1)
            playAnimation("walk")
        })
        bar.addView(createPillButton("⚡ Run") {
            physicsEngine.startWalking(70f, 1)
            playAnimation("run")
        })
        bar.addView(createPillButton("🎵 Dance") {
            physicsEngine.stopWalking()
            playAnimation("dance")
        })
        bar.addView(createPillButton("🪑 Sit") {
            physicsEngine.stopWalking()
            playAnimation("sit")
        })
        bar.addView(createPillButton("🔄 360°") {
            (currentRenderer as? ThreeDOverlayRenderer)?.rotate360(45f)
        })

        // Close button
        val closeBtn = TextView(context).apply {
            text = "✕"
            textSize = 11f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.parseColor("#FF6B6B"))
            setPadding(
                (7 * density).toInt(),
                (4 * density).toInt(),
                (7 * density).toInt(),
                (4 * density).toInt()
            )
            setOnClickListener {
                onStopOverlayRequested()
            }
        }
        bar.addView(closeBtn)

        return bar
    }

    private fun setupRendererForCharacter(data: Map<String, Any?>) {
        val typeStr = data["type"] as? String ?: "threeD"
        val isThreeD =
            typeStr.contains("threeD", ignoreCase = true) || typeStr.contains("3d", ignoreCase = true)

        val targetRendererType = if (isThreeD) "3D" else "2D"

        if (currentRenderer?.getOverlayType() != targetRendererType) {
            currentRenderer?.onDestroy()
            dollContainer?.removeAllViews()

            currentRenderer = if (isThreeD) {
                ThreeDOverlayRenderer()
            } else {
                TwoDOverlayRenderer()
            }

            val view = currentRenderer!!.createView(context)
            dollContainer?.addView(view)
        }

        currentRenderer?.updateCharacter(data)
        currentRenderer?.playAnimation(currentAnimation)
    }

    private fun setupDragTouchListener() {
        val target = dollContainer ?: return

        target.setOnTouchListener(object : View.OnTouchListener {
            private var initialX = 0
            private var initialY = 0
            private var initialTouchX = 0f
            private var initialTouchY = 0f
            private var downTimeMs = 0L
            private var isDragging = false

            override fun onTouch(v: View, event: MotionEvent): Boolean {
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = layoutParams.x
                        initialY = layoutParams.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        downTimeMs = System.currentTimeMillis()
                        isDragging = false

                        behaviourEngine.onUserInteractionStart()
                        physicsEngine.stopWalking()
                        physicsEngine.stopPhysicsLoop()
                        return true
                    }

                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()

                        if (!isDragging && (abs(dx) > 10 || abs(dy) > 10)) {
                            isDragging = true
                            currentRenderer?.playAnimation("drag")
                        }

                        if (isDragging) {
                            layoutParams.x = initialX + dx
                            layoutParams.y = initialY + dy
                            physicsEngine.setPosition(layoutParams.x, layoutParams.y)

                            if (isAttached && rootView != null) {
                                windowManager.updateViewLayout(rootView, layoutParams)
                            }
                        }
                        return true
                    }

                    MotionEvent.ACTION_UP -> {
                        val duration = System.currentTimeMillis() - downTimeMs
                        val dx = abs(event.rawX - initialTouchX)
                        val dy = abs(event.rawY - initialTouchY)
                        val now = System.currentTimeMillis()

                        if (!isDragging && duration < 350 && dx < 15 && dy < 15) {
                            // Check for double tap
                            if (now - lastTapTimeMs < 350) {
                                // Double tap triggers Dance!
                                currentRenderer?.playAnimation("dance")
                                behaviourEngine.onUserInteractionEnd()
                            } else {
                                // Single tap: distinguish Head Tap vs Body Tap
                                val touchRelativeY = event.y
                                val viewHeight = v.height.coerceAtLeast(1)
                                val isHeadTap = (touchRelativeY / viewHeight) < 0.38f

                                if (isHeadTap) {
                                    currentRenderer?.playAnimation("tap")
                                } else {
                                    currentRenderer?.playAnimation("jump")
                                }
                                toggleControlsVisibility()
                                behaviourEngine.onUserInteractionEnd()
                            }
                            lastTapTimeMs = now
                        } else {
                            // Released after dragging!
                            val screenHeight = context.resources.displayMetrics.heightPixels
                            val floorY = screenHeight - physicsEngine.dollHeight

                            // Check if dropped high in mid-air -> triggers physical gravity fall!
                            if (layoutParams.y < (floorY - 60)) {
                                behaviourEngine.triggerFall()
                                physicsEngine.startFalling(80f)
                            } else {
                                // Close to floor, resume autonomous life
                                prefs.edit()
                                    .putInt("overlay_x", layoutParams.x)
                                    .putInt("overlay_y", layoutParams.y)
                                    .apply()

                                behaviourEngine.onUserInteractionEnd()
                            }
                        }
                        return true
                    }
                }
                return false
            }
        })
    }

    private fun toggleControlsVisibility() {
        isControlsExpanded = !isControlsExpanded
        controlsContainer?.visibility = if (isControlsExpanded) View.VISIBLE else View.GONE
    }

    fun updateCharacter(characterData: Map<String, Any?>) {
        currentCharacterData = characterData
        setupRendererForCharacter(characterData)
    }

    fun playAnimation(animation: String) {
        currentAnimation = animation
        currentRenderer?.playAnimation(animation)
    }

    fun destroy() {
        behaviourEngine.stop()
        physicsEngine.stopPhysicsLoop()

        if (isAttached && rootView != null) {
            try {
                windowManager.removeView(rootView)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        isAttached = false
        currentRenderer?.onDestroy()
        currentRenderer = null
        rootView = null
        dollContainer = null
        controlsContainer = null
    }
}
