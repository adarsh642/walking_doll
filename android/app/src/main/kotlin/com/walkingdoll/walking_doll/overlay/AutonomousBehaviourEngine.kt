package com.walkingdoll.walking_doll.overlay

import android.os.Handler
import android.os.Looper
import java.util.Random

enum class BehaviourState {
    IDLE,
    WALKING,
    RUNNING,
    DANCING,
    THINKING,
    EXPLORING,
    SITTING,
    SLEEPING,
    WAKING,
    CURIOUS,
    EXCITED,
    BORED,
    FALLING,
    RECOVERING,
    INTERACTING
}

/**
 * Autonomous Personality Engine.
 * Governs the 3D doll's living autonomous behaviors when the user is not touching the screen.
 * Implements a Weighted Random Behaviour State Machine driven by personality attributes:
 * Energy level, Sleepiness, Mood, Curiosity, and Interaction History.
 */
class AutonomousBehaviourEngine(
    private val onStateChanged: (BehaviourState, String) -> Unit,
    private val onMoveRequest: (speedPxPerSec: Float, direction: Int) -> Unit,
    private val onStopMoveRequest: () -> Unit
) {
    private val handler = Handler(Looper.getMainLooper())
    private val random = Random()

    var currentState: BehaviourState = BehaviourState.IDLE
        private set

    // Personality attributes (0-100)
    var energyLevel: Int = 85
    var sleepiness: Int = 10
    var curiosity: Int = 80
    var mood: String = "Joyful ✨"
    var isAutonomousEnabled: Boolean = true

    private var tickRunnable: Runnable? = null
    private var isUserInteracting: Boolean = false

    fun start() {
        scheduleNextTick(2500)
    }

    fun stop() {
        tickRunnable?.let { handler.removeCallbacks(it) }
        onStopMoveRequest()
    }

    fun onUserInteractionStart() {
        isUserInteracting = true
        tickRunnable?.let { handler.removeCallbacks(it) }
        currentState = BehaviourState.INTERACTING
        energyLevel = (energyLevel + 6).coerceAtMost(100)
        sleepiness = (sleepiness - 15).coerceAtLeast(0)
    }

    fun onUserInteractionEnd() {
        isUserInteracting = false
        currentState = BehaviourState.IDLE
        scheduleNextTick(3500)
    }

    fun triggerFall() {
        isUserInteracting = false
        tickRunnable?.let { handler.removeCallbacks(it) }
        currentState = BehaviourState.FALLING
        onStopMoveRequest()
        onStateChanged(BehaviourState.FALLING, "fall")
    }

    fun onLanded() {
        currentState = BehaviourState.RECOVERING
        onStopMoveRequest()
        onStateChanged(BehaviourState.RECOVERING, "fall")

        // Impact & recovery sequence
        handler.postDelayed({
            currentState = BehaviourState.WAKING
            onStateChanged(BehaviourState.WAKING, "wakeup")

            handler.postDelayed({
                currentState = BehaviourState.IDLE
                onStateChanged(BehaviourState.IDLE, "idle")
                scheduleNextTick(3000)
            }, 1200)
        }, 1200)
    }

    private fun scheduleNextTick(delayMs: Long) {
        if (!isAutonomousEnabled || isUserInteracting) return
        tickRunnable?.let { handler.removeCallbacks(it) }
        tickRunnable = Runnable {
            evaluateNextState()
        }
        handler.postDelayed(tickRunnable!!, delayMs)
    }

    private fun evaluateNextState() {
        if (!isAutonomousEnabled || isUserInteracting) return

        // Slowly consume energy & adjust sleepiness
        energyLevel = (energyLevel - 1).coerceAtLeast(10)
        sleepiness = (sleepiness + 1).coerceAtMost(100)

        // Select state based on weighted attributes
        val nextState = when {
            sleepiness > 80 && energyLevel < 25 -> BehaviourState.SLEEPING
            sleepiness > 55 && random.nextInt(100) < 30 -> BehaviourState.SITTING
            energyLevel > 50 && curiosity > 45 && random.nextInt(100) < 40 -> BehaviourState.EXPLORING
            energyLevel > 65 && random.nextInt(100) < 25 -> BehaviourState.DANCING
            random.nextInt(100) < 30 -> BehaviourState.THINKING
            random.nextInt(100) < 55 -> BehaviourState.WALKING
            else -> BehaviourState.IDLE
        }

        currentState = nextState
        var stateDurationMs = 4000L

        when (nextState) {
            BehaviourState.IDLE -> {
                onStopMoveRequest()
                onStateChanged(BehaviourState.IDLE, "idle")
                stateDurationMs = 3500L + random.nextInt(2500)
            }
            BehaviourState.WALKING -> {
                val dir = if (random.nextBoolean()) 1 else -1
                onMoveRequest(40f, dir)
                onStateChanged(BehaviourState.WALKING, "walk")
                stateDurationMs = 3500L + random.nextInt(4000)
            }
            BehaviourState.RUNNING, BehaviourState.EXPLORING -> {
                val dir = if (random.nextBoolean()) 1 else -1
                onMoveRequest(70f, dir)
                onStateChanged(BehaviourState.RUNNING, "run")
                stateDurationMs = 3000L + random.nextInt(3000)
            }
            BehaviourState.DANCING -> {
                onStopMoveRequest()
                onStateChanged(BehaviourState.DANCING, "dance")
                stateDurationMs = 4500L + random.nextInt(2500)
            }
            BehaviourState.THINKING -> {
                onStopMoveRequest()
                onStateChanged(BehaviourState.THINKING, "think")
                stateDurationMs = 3500L + random.nextInt(2000)
            }
            BehaviourState.SITTING -> {
                onStopMoveRequest()
                onStateChanged(BehaviourState.SITTING, "sit")
                stateDurationMs = 5500L + random.nextInt(3500)
            }
            BehaviourState.SLEEPING -> {
                onStopMoveRequest()
                onStateChanged(BehaviourState.SLEEPING, "sleep")
                stateDurationMs = 7000L + random.nextInt(5000)
                energyLevel = (energyLevel + 30).coerceAtMost(100)
                sleepiness = (sleepiness - 45).coerceAtLeast(0)
            }
            else -> {
                onStopMoveRequest()
                onStateChanged(BehaviourState.IDLE, "idle")
                stateDurationMs = 3500L
            }
        }

        scheduleNextTick(stateDurationMs)
    }
}

