package com.walkingdoll.walking_doll.overlay

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.BounceInterpolator
import android.view.animation.LinearInterpolator
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.FlutterInjector
import java.io.File

/**
 * 2D Character Overlay Renderer.
 * Supports static PNGs, GIFs, and frame-by-frame Sprite Sheets.
 * Features native Android animators for idle, walk, dance, tap, and drag interactions.
 */
class TwoDOverlayRenderer : OverlayRenderer {

    companion object {
        private const val TAG = "TwoDOverlayRenderer"
    }

    private var context: Context? = null
    private var containerView: FrameLayout? = null
    private var dollImageView: ImageView? = null
    private var speechBubbleTextView: TextView? = null

    private var characterData: Map<String, Any?> = emptyMap()
    private var currentAnimation: String = "idle"

    // Animation controllers
    private var activeAnimators = mutableListOf<ValueAnimator>()
    private val handler = Handler(Looper.getMainLooper())
    private var spriteFrameRunnable: Runnable? = null

    // Sprite sheet state
    private var spriteFrames = mutableListOf<Bitmap>()
    private var currentSpriteFrameIndex = 0
    private var isSpriteSheet = false
    private var spriteFps = 8

    override fun createView(context: Context): View {
        this.context = context
        val density = context.resources.displayMetrics.density

        // Root container for doll and speech bubble
        containerView = FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                (140 * density).toInt(),
                (150 * density).toInt()
            )
            clipChildren = false
            clipToPadding = false
        }

        // Doll Image
        dollImageView = ImageView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                (110 * density).toInt(),
                (110 * density).toInt(),
                Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            )
            scaleType = ImageView.ScaleType.FIT_CENTER
        }

        // Cute Speech Bubble
        speechBubbleTextView = TextView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.TOP or Gravity.CENTER_HORIZONTAL
            )
            setPadding((10 * density).toInt(), (4 * density).toInt(), (10 * density).toInt(), (4 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.WHITE)
                cornerRadius = 16 * density
                setStroke((1.5f * density).toInt(), Color.parseColor("#FF80AB"))
            }
            setTextColor(Color.parseColor("#4A148C"))
            textSize = 11f
            typeface = Typeface.DEFAULT_BOLD
            visibility = View.GONE
            elevation = 6 * density
        }

        containerView?.addView(dollImageView)
        containerView?.addView(speechBubbleTextView)

        // Load doll image if data already provided
        loadCharacterAsset()
        playAnimation(currentAnimation)

        return containerView!!
    }

    override fun updateCharacter(characterData: Map<String, Any?>) {
        this.characterData = characterData
        loadCharacterAsset()
        playAnimation(currentAnimation)
    }

    private fun loadCharacterAsset() {
        val ctx = context ?: return
        val assetPath = characterData["assetPath"] as? String ?: return
        val isAsset = characterData["isAsset"] as? Boolean ?: true
        isSpriteSheet = characterData["isSpriteSheet"] as? Boolean ?: false
        val columns = (characterData["columns"] as? Number)?.toInt() ?: 1
        val rows = (characterData["rows"] as? Number)?.toInt() ?: 1
        spriteFps = (characterData["fps"] as? Number)?.toInt() ?: 8

        stopSpriteLoop()
        spriteFrames.clear()

        try {
            val fullBitmap: Bitmap? = if (isAsset) {
                val loader = FlutterInjector.instance().flutterLoader()
                val assetKey = loader.getLookupKeyForAsset(assetPath)
                ctx.assets.open(assetKey).use { inputStream ->
                    BitmapFactory.decodeStream(inputStream)
                }
            } else {
                val file = File(assetPath)
                if (file.exists()) {
                    BitmapFactory.decodeFile(file.absolutePath)
                } else null
            }

            if (fullBitmap != null) {
                if (isSpriteSheet && columns > 0 && rows > 0) {
                    // Slice sprite sheet
                    val frameWidth = fullBitmap.width / columns
                    val frameHeight = fullBitmap.height / rows
                    for (r in 0 until rows) {
                        for (c in 0 until columns) {
                            val frame = Bitmap.createBitmap(
                                fullBitmap,
                                c * frameWidth,
                                r * frameHeight,
                                frameWidth,
                                frameHeight
                            )
                            spriteFrames.add(frame)
                        }
                    }
                    if (spriteFrames.isNotEmpty()) {
                        dollImageView?.setImageBitmap(spriteFrames[0])
                        startSpriteLoop()
                    }
                } else {
                    dollImageView?.setImageBitmap(fullBitmap)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error loading 2D character bitmap: ${e.message}", e)
        }
    }

    private fun startSpriteLoop() {
        if (spriteFrames.isEmpty()) return
        val frameDurationMs = (1000L / spriteFps.coerceIn(1, 60))

        spriteFrameRunnable = object : Runnable {
            override fun run() {
                if (spriteFrames.isNotEmpty()) {
                    currentSpriteFrameIndex = (currentSpriteFrameIndex + 1) % spriteFrames.size
                    dollImageView?.setImageBitmap(spriteFrames[currentSpriteFrameIndex])
                    handler.postDelayed(this, frameDurationMs)
                }
            }
        }
        handler.post(spriteFrameRunnable!!)
    }

    private fun stopSpriteLoop() {
        spriteFrameRunnable?.let { handler.removeCallbacks(it) }
        spriteFrameRunnable = null
    }

    override fun playAnimation(animation: String) {
        currentAnimation = animation
        val target = dollImageView ?: return

        stopActiveAnimators()

        when (animation.lowercase()) {
            "walk" -> {
                // Rhythmic walking waddle and bounce
                val waddle = ObjectAnimator.ofFloat(target, "rotation", -8f, 8f).apply {
                    duration = 320
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                    interpolator = AccelerateDecelerateInterpolator()
                }
                val bob = ObjectAnimator.ofFloat(target, "translationY", 0f, -14f, 0f).apply {
                    duration = 320
                    repeatMode = ValueAnimator.RESTART
                    repeatCount = ValueAnimator.INFINITE
                    interpolator = LinearInterpolator()
                }
                activeAnimators.addAll(listOf(waddle, bob))
                waddle.start()
                bob.start()
            }
            "dance" -> {
                // Energetic dance jump, scale pulse, and spin
                val jump = ObjectAnimator.ofFloat(target, "translationY", 0f, -28f, 0f).apply {
                    duration = 400
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                    interpolator = AccelerateDecelerateInterpolator()
                }
                val spin = ObjectAnimator.ofFloat(target, "rotation", -15f, 15f).apply {
                    duration = 250
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                }
                val squashStretchX = ObjectAnimator.ofFloat(target, "scaleX", 0.9f, 1.15f).apply {
                    duration = 200
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                }
                val squashStretchY = ObjectAnimator.ofFloat(target, "scaleY", 1.15f, 0.9f).apply {
                    duration = 200
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                }
                activeAnimators.addAll(listOf(jump, spin, squashStretchX, squashStretchY))
                jump.start()
                spin.start()
                squashStretchX.start()
                squashStretchY.start()
            }
            "drag" -> {
                // Cute suspended floating pose
                target.rotation = 12f
                target.scaleX = 1.08f
                target.scaleY = 1.08f
                val floatAnim = ObjectAnimator.ofFloat(target, "translationY", -10f, 0f).apply {
                    duration = 300
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                }
                activeAnimators.add(floatAnim)
                floatAnim.start()
            }
            "tap" -> {
                // Pop bounce with speech bubble reaction
                showSpeechBubble()
                val scaleX = ObjectAnimator.ofFloat(target, "scaleX", 0.8f, 1.25f, 1.0f).apply {
                    duration = 450
                    interpolator = BounceInterpolator()
                }
                val scaleY = ObjectAnimator.ofFloat(target, "scaleY", 0.8f, 1.25f, 1.0f).apply {
                    duration = 450
                    interpolator = BounceInterpolator()
                }
                activeAnimators.addAll(listOf(scaleX, scaleY))
                scaleX.start()
                scaleY.start()
            }
            else -> {
                // "idle": Gentle breathing and soft bobbing
                target.rotation = 0f
                val gentleBob = ObjectAnimator.ofFloat(target, "translationY", 0f, -8f).apply {
                    duration = 900
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                    interpolator = AccelerateDecelerateInterpolator()
                }
                val gentleScale = ObjectAnimator.ofFloat(target, "scaleY", 1.0f, 1.04f).apply {
                    duration = 900
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                    interpolator = AccelerateDecelerateInterpolator()
                }
                activeAnimators.addAll(listOf(gentleBob, gentleScale))
                gentleBob.start()
                gentleScale.start()
            }
        }
    }

    private fun showSpeechBubble() {
        val bubble = speechBubbleTextView ?: return
        val greetings = listOf("(◕‿◕) Yay!", "♥ Hi friend!", "✨ Let's walk!", "♫ La la la!", "⭐ Walking Doll!")
        bubble.text = greetings.random()
        bubble.visibility = View.VISIBLE
        bubble.alpha = 1f
        bubble.translationY = 0f

        handler.removeCallbacksAndMessages("bubble")
        handler.postAtTime({
            bubble.animate()
                .alpha(0f)
                .translationY(-20f)
                .setDuration(400)
                .withEndAction { bubble.visibility = View.GONE }
                .start()
        }, "bubble", System.currentTimeMillis() + 2000)
    }

    private fun stopActiveAnimators() {
        for (anim in activeAnimators) {
            anim.cancel()
        }
        activeAnimators.clear()
        dollImageView?.apply {
            rotation = 0f
            scaleX = 1f
            scaleY = 1f
            translationY = 0f
        }
    }

    override fun getOverlayType(): String = "2D"

    override fun onDestroy() {
        stopActiveAnimators()
        stopSpriteLoop()
        handler.removeCallbacksAndMessages(null)
        containerView = null
        dollImageView = null
        speechBubbleTextView = null
        context = null
    }
}

