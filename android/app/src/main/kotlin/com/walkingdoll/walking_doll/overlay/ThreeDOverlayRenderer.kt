package com.walkingdoll.walking_doll.overlay

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.BounceInterpolator
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.webkit.WebViewAssetLoader
import java.io.File

/**
 * Photorealistic 3D Character Overlay Renderer.
 * Embeds a genuine 3D rendering engine via hardware-accelerated Android WebView
 * hosting Google's <model-viewer> PBR pipeline with a transparent background
 * directly inside Android's TYPE_APPLICATION_OVERLAY floating window.
 *
 * Uses WebViewAssetLoader to securely load local models, offline JS, and
 * animations from assets or internal storage without network dependency or CORS issues.
 */
class ThreeDOverlayRenderer : OverlayRenderer {

    private var context: Context? = null
    private var containerView: FrameLayout? = null
    private var webView: WebView? = null
    private var speechBubbleTextView: TextView? = null
    private var fallbackView: LinearLayout? = null
    private var titleTextView: TextView? = null

    private var assetLoader: WebViewAssetLoader? = null
    private var characterData: Map<String, Any?> = emptyMap()
    private var currentAnimation: String = "idle"
    private val activeAnimators = mutableListOf<ValueAnimator>()
    private val handler = Handler(Looper.getMainLooper())

    @SuppressLint("SetJavaScriptEnabled")
    override fun createView(context: Context): View {
        this.context = context
        val density = context.resources.displayMetrics.density

        val appDataDir = File(context.applicationInfo.dataDir)
        val appFlutterDir = File(appDataDir, "app_flutter")

        assetLoader = WebViewAssetLoader.Builder()
            .setDomain("appassets.androidplatform.net")
            .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(context))
            .addPathHandler("/internal/", WebViewAssetLoader.InternalStoragePathHandler(context, context.filesDir))
            .addPathHandler("/app_flutter/", WebViewAssetLoader.InternalStoragePathHandler(context, appFlutterDir))
            .build()

        containerView = FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                (160 * density).toInt(),
                (180 * density).toInt()
            )
            clipChildren = false
            clipToPadding = false
        }

        // 1. Subtle Ground Contact Pedestal
        val pedestalView = View(context).apply {
            val lp = FrameLayout.LayoutParams(
                (100 * density).toInt(),
                (20 * density).toInt(),
                Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            ).apply {
                bottomMargin = (8 * density).toInt()
            }
            layoutParams = lp
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#33000000"))
            }
        }

        // 2. Hardware-accelerated 3D WebView
        webView = WebView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(Color.TRANSPARENT)
            setLayerType(View.LAYER_TYPE_HARDWARE, null)

            settings.apply {
                javaScriptEnabled = true
                domStorageEnabled = true
                allowFileAccess = true
                allowContentAccess = true
                @Suppress("DEPRECATION")
                allowFileAccessFromFileURLs = true
                @Suppress("DEPRECATION")
                allowUniversalAccessFromFileURLs = true
                useWideViewPort = true
                loadWithOverviewMode = true
                cacheMode = WebSettings.LOAD_DEFAULT
            }

            webViewClient = object : WebViewClient() {
                override fun shouldInterceptRequest(
                    view: WebView?,
                    request: WebResourceRequest?
                ): WebResourceResponse? {
                    if (request == null) return null
                    return assetLoader?.shouldInterceptRequest(request.url)
                }

                override fun onPageFinished(view: WebView?, url: String?) {
                    super.onPageFinished(view, url)
                    fallbackView?.visibility = View.GONE
                    loadCurrentModel()
                    playAnimation(currentAnimation)
                }
            }

            loadUrl("https://appassets.androidplatform.net/assets/index.html")
        }

        // 3. Floating Speech Bubble
        speechBubbleTextView = TextView(context).apply {
            val lp = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.TOP or Gravity.CENTER_HORIZONTAL
            ).apply {
                topMargin = (2 * density).toInt()
            }
            layoutParams = lp
            text = "Hello! ✨"
            textSize = 10f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.WHITE)
            setPadding((10 * density).toInt(), (4 * density).toInt(), (10 * density).toInt(), (4 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E61E1E2E"))
                cornerRadius = 14 * density
                setStroke((1.5f * density).toInt(), Color.parseColor("#80FF80AB"))
            }
            visibility = View.GONE
            elevation = 10 * density
        }

        // 4. Subtle fallback badge while 3D engine is booting
        fallbackView = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            titleTextView = TextView(context).apply {
                text = "3D Doll"
                textSize = 11f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(Color.parseColor("#B0BEC5"))
                gravity = Gravity.CENTER
            }
            addView(titleTextView)
        }

        containerView?.addView(pedestalView)
        containerView?.addView(webView)
        containerView?.addView(fallbackView)
        containerView?.addView(speechBubbleTextView)

        return containerView!!
    }

    override fun updateCharacter(characterData: Map<String, Any?>) {
        this.characterData = characterData
        val name = characterData["name"] as? String ?: "3D Companion"
        titleTextView?.text = name
        loadCurrentModel()
        showSpeechBubble("Hi! I'm $name ✨", 2500)
    }

    private fun loadCurrentModel() {
        val wv = webView ?: return
        val rawPath = characterData["assetPath"] as? String ?: "assets/characters/3d/robot_companion.glb"
        val isAsset = characterData["isAsset"] as? Boolean ?: true

        val modelUrl = if (isAsset) {
            "https://appassets.androidplatform.net/assets/flutter_assets/$rawPath"
        } else {
            // Map custom imported files from app_flutter
            if (rawPath.contains("app_flutter")) {
                val rel = rawPath.substringAfter("app_flutter/").removePrefix("/")
                "https://appassets.androidplatform.net/app_flutter/$rel"
            } else if (rawPath.contains("files")) {
                val rel = rawPath.substringAfter("files/").removePrefix("/")
                "https://appassets.androidplatform.net/internal/$rel"
            } else {
                rawPath
            }
        }

        val js = "if (typeof loadModel === 'function') { loadModel('$modelUrl', '$currentAnimation'); }"
        wv.evaluateJavascript(js, null)
    }

    override fun playAnimation(animation: String) {
        currentAnimation = animation
        val target = containerView ?: return

        stopActiveAnimators()

        // 1. Tell 3D model-viewer component to switch animation clip
        val js = "if (typeof setAnim === 'function') { setAnim('$animation'); }"
        webView?.evaluateJavascript(js, null)

        // 2. Apply physical micro-motion & speech reactions
        when (animation.lowercase()) {
            "walk" -> {
                showSpeechBubble("Walking on foot! 🐾", 1800)
                // Skeletal 3D leg motion handles stepping. Container stays steady for grounded foot placement.
            }
            "run" -> {
                showSpeechBubble("Running! ⚡", 1800)
            }
            "dance" -> {
                showSpeechBubble("Yay, dancing! 🎵✨", 3000)
                val spin = ObjectAnimator.ofFloat(target, "rotation", -12f, 12f).apply {
                    duration = 300
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = 8
                    interpolator = AccelerateDecelerateInterpolator()
                }
                val bounce = ObjectAnimator.ofFloat(target, "translationY", 0f, -18f, 0f).apply {
                    duration = 300
                    repeatMode = ValueAnimator.RESTART
                    repeatCount = 8
                }
                activeAnimators.addAll(listOf(spin, bounce))
                spin.start()
                bounce.start()
            }
            "jump" -> {
                showSpeechBubble("Wheee! 🚀", 1500)
                val jump = ObjectAnimator.ofFloat(target, "translationY", 0f, -40f, 0f).apply {
                    duration = 500
                    interpolator = BounceInterpolator()
                }
                activeAnimators.add(jump)
                jump.start()
            }
            "fall" -> {
                showSpeechBubble("Whoa! Falling! 😱", 2000)
                val tumble = ObjectAnimator.ofFloat(target, "rotation", 0f, 25f, -15f, 0f).apply {
                    duration = 600
                    interpolator = AccelerateDecelerateInterpolator()
                }
                activeAnimators.add(tumble)
                tumble.start()
            }
            "land" -> {
                showSpeechBubble("Safe landing! 🌟", 1500)
                val squash = ObjectAnimator.ofFloat(target, "scaleY", 1f, 0.82f, 1f).apply {
                    duration = 300
                    interpolator = BounceInterpolator()
                }
                val stretch = ObjectAnimator.ofFloat(target, "scaleX", 1f, 1.15f, 1f).apply {
                    duration = 300
                    interpolator = BounceInterpolator()
                }
                activeAnimators.addAll(listOf(squash, stretch))
                squash.start()
                stretch.start()
            }
            "sit" -> {
                showSpeechBubble("Taking a rest 🪑", 2500)
                val lower = ObjectAnimator.ofFloat(target, "translationY", 0f, 10f).apply {
                    duration = 400
                }
                activeAnimators.add(lower)
                lower.start()
            }
            "sleep" -> {
                showSpeechBubble("Zzz... 💤", 3000)
                val sleepTilt = ObjectAnimator.ofFloat(target, "rotation", 0f, 12f).apply {
                    duration = 800
                }
                activeAnimators.add(sleepTilt)
                sleepTilt.start()
            }
            "wakeup" -> {
                showSpeechBubble("Good morning! ☀️", 2000)
                val wake = ObjectAnimator.ofFloat(target, "scaleY", 0.9f, 1.05f, 1f).apply {
                    duration = 600
                }
                activeAnimators.add(wake)
                wake.start()
            }
            "think" -> {
                showSpeechBubble("Hmm... 🤔", 2500)
                val tilt = ObjectAnimator.ofFloat(target, "rotation", 0f, -8f).apply {
                    duration = 500
                }
                activeAnimators.add(tilt)
                tilt.start()
            }
            "tap" -> {
                showSpeechBubble("Hehe! ✨💖", 1800)
                val pop = ObjectAnimator.ofFloat(target, "scaleY", 1f, 1.12f, 1f).apply {
                    duration = 250
                    interpolator = BounceInterpolator()
                }
                val popX = ObjectAnimator.ofFloat(target, "scaleX", 1f, 1.12f, 1f).apply {
                    duration = 250
                    interpolator = BounceInterpolator()
                }
                activeAnimators.addAll(listOf(pop, popX))
                pop.start()
                popX.start()
            }
            "drag" -> {
                showSpeechBubble("Flying with you! 🎈", 1500)
                val dangle = ObjectAnimator.ofFloat(target, "rotation", -5f, 5f).apply {
                    duration = 200
                    repeatMode = ValueAnimator.REVERSE
                    repeatCount = ValueAnimator.INFINITE
                }
                activeAnimators.add(dangle)
                dangle.start()
            }
            "idle" -> {
                // Gentle breathing micro-bobbing
                val breath = ObjectAnimator.ofFloat(target, "translationY", 0f, -2.5f, 0f).apply {
                    duration = 1400
                    repeatMode = ValueAnimator.RESTART
                    repeatCount = ValueAnimator.INFINITE
                    interpolator = AccelerateDecelerateInterpolator()
                }
                activeAnimators.add(breath)
                breath.start()
            }
        }
    }

    private fun showSpeechBubble(message: String, durationMs: Long) {
        val bubble = speechBubbleTextView ?: return
        bubble.text = message
        bubble.alpha = 0f
        bubble.visibility = View.VISIBLE
        bubble.animate()
            .alpha(1f)
            .setDuration(200)
            .start()

        handler.removeCallbacksAndMessages("bubble_tag")

        val hideRunnable = Runnable {
            bubble.animate()
                .alpha(0f)
                .setDuration(300)
                .withEndAction {
                    bubble.visibility = View.GONE
                }
                .start()
        }
        handler.postAtTime(hideRunnable, "bubble_tag", SystemClockUptimeMillis() + durationMs)
    }

    private fun SystemClockUptimeMillis(): Long {
        return android.os.SystemClock.uptimeMillis()
    }

    private fun stopActiveAnimators() {
        for (anim in activeAnimators) {
            anim.cancel()
        }
        activeAnimators.clear()
        containerView?.apply {
            rotation = 0f
            scaleX = 1f
            scaleY = 1f
            translationY = 0f
        }
    }

    fun setFacingDirection(direction: Int) {
        webView?.post {
            webView?.evaluateJavascript("if (typeof setFacing === 'function') setFacing($direction);", null)
        }
    }

    fun rotate360(degrees: Float = 45f) {
        webView?.post {
            webView?.evaluateJavascript("if (typeof rotate360 === 'function') rotate360($degrees);", null)
        }
    }

    override fun getOverlayType(): String = "3D"

    override fun onDestroy() {
        stopActiveAnimators()
        handler.removeCallbacksAndMessages(null)
        webView?.destroy()
        webView = null
        containerView = null
        speechBubbleTextView = null
        fallbackView = null
        titleTextView = null
        context = null
    }
}
