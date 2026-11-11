package com.walkingdoll.walking_doll.overlay

import android.content.Context
import android.view.View

/**
 * Common contract for 2D and 3D overlay renderers.
 * Guarantees that the native overlay presentation remains modular
 * and allows 2D and 3D pipelines to evolve independently.
 */
interface OverlayRenderer {
    /**
     * Creates and returns the interactive overlay view to be hosted by the WindowManager.
     */
    fun createView(context: Context): View

    /**
     * Updates character payload data (assets, dimensions, sprite parameters).
     */
    fun updateCharacter(characterData: Map<String, Any?>)

    /**
     * Triggers character animation states: "idle", "walk", "dance", "tap", "drag".
     */
    fun playAnimation(animation: String)

    /**
     * Identifies renderer type ("2D" or "3D").
     */
    fun getOverlayType(): String

    /**
     * Cleans up running animators, handlers, and views.
     */
    fun onDestroy()
}

