# 🎀 Living Doll — Game-Quality 3D Virtual Companion

> **A premium Android Virtual Companion featuring a fully interactive, autonomous, game-quality 3D humanoid character living directly on top of your screen.**

---

## 🌟 Overview & Key Principles

Living Doll is built with **Flutter & Dart** and integrated with an advanced native **Kotlin Android Overlay Engine**. Unlike flat image sprites, GIFs, or fake 2.5D pictures, Living Doll uses **real-time 3D game characters with complete geometry, humanoid skeletal rigging, physically based rendering (PBR) materials, and motion-captured skeletal animations**.

### 🎮 Game Character Quality Standard
- **Complete 3D Geometry**: Modeled head, neck, shoulders, chest, torso, waist, dual arms, elbows, wrists, hands, individual fingers, dual legs, knees, ankles, feet, and stylized shoes & layered clothing.
- **Humanoid Skeletal Hierarchy**: Root bone, pelvis, spine, chest, neck, head, left/right shoulders, upper & lower arms, hands, fingers, hips, upper & lower legs, feet.
- **Standard glTF 2.0 / GLB Format**: Bundled models with embedded bone transforms, skinning weights, normal maps, and animation clips.
- **Real-Time PBR GPU Rendering**: True perspective camera, dynamic exposure, contact ground shadows, ambient lighting presets (Studio Daylight, Golden Sunset, Cyber Neon, Soft Porcelain), and 360° interactive orbit/zoom.

---

## 🎭 Bundled 3D Game Characters

1. **Nexus Spark (3D Living Doll)** (`assets/characters/3d/robot_companion.glb`):
   - 74-bone rigged humanoid skeleton with articulated fingers.
   - 14 full-body skeletal animations: `Idle`, `Walking`, `Running`, `Dance`, `Jump`, `Sitting`, `Standing`, `Death` (falling/knockdown impact), `Wave`, `ThumbsUp`, `Punch`, `Yes`, `No`.
2. **Aria Chibi (3D Anime Game Doll)** (`assets/characters/3d/anime_chibi_doll.glb`):
   - High-quality stylized 3D anime doll with a 230-node humanoid skeleton.
   - 3D anime facial features, individual hair strand meshes, pleated skirt physics, and 19 PBR materials.
3. **Aria Couture (Realistic 3D Doll)** (`assets/characters/3d/realistic_doll_brunette.glb`):
   - Ultra-lifelike 3D fashion companion with porcelain skin, flowing brunette hair, tailored layered dress, and shoes.
4. **Kitsune (3D Spirit Fox)** (`assets/characters/3d/spirit_fox.glb`):
   - Mythical quadruped companion with fluid natural walking, running, and curious surveying locomotion.
5. **Stella Nova (3D Spacesuit)** (`assets/characters/3d/astronaut_doll.glb`):
   - Photorealistic 3D spacefarer with authentic suit cloth weave, gold reflective visor, and life-support exploration pack.

---

## 🧠 Autonomous Personality Engine

The companion feels alive even when the user is not touching the screen.
- **Behaviour State Machine**:
  - `IDLE`: Natural breathing, weight shifting, and looking around.
  - `WALKING`: Alternating leg locomotion and arm swinging across the screen.
  - `RUNNING`: Faster locomotion with forward body inclination.
  - `DANCING`: Energetic full-body choreography.
  - `THINKING`: Hand to chin with curious head tilt.
  - `EXPLORING`: Patrolling screen corners and edges.
  - `SITTING`: Resting posture with natural breathing.
  - `SLEEPING`: Peaceful nap posture with deep breathing cycles.
  - `WAKING`: Stretching arms and standing up.
  - `FALLING`: Loss of balance and gravity-driven descent.
  - `RECOVERING`: Standing up after landing impact.
  - `INTERACTING`: Active response to user touch.
- **Attributes**: Energy Level (0–100), Sleepiness (0–100), Curiosity (0–100), Mood, and Interaction History.
- **Weighted Selection**: Dynamically selects the next state based on personality and energy state.

---

## 📱 Phone Screen as a Physical World

- **Screen-Coordinate Physics**:
  - Real screen boundaries ($X_{\min}=0, X_{\max}=\text{screenWidth}-\text{dollWidth}$, floor $Y_{\max}=\text{screenHeight}-\text{dollHeight}$).
  - Gravity ($g = 2200 \text{ px/s}^2$) and vertical velocity ($v_y$).
  - Walking locomotion moves coordinates smoothly across the screen at 50 px/s.
  - Edge detection: Turns around upon reaching screen borders.
  - Drag-and-Release Falling: If lifted high and dropped in mid-air, the doll accelerates downward under gravity, hits the floor with landing impact animation, recovers, and stands back up!

---

## 👆 Touch & User Interactions

- **Tap Head** (top 38% of doll): Happy expression and friendly waving emote (`wave`).
- **Tap Body** (lower 62% of doll): Surprise reaction and jump (`jump`).
- **Drag**: Doll follows finger smoothly in mid-air (`drag`).
- **Release in Mid-Air**: Triggers physical gravity fall, floor impact, and standing recovery.
- **Double Tap**: Triggers dance choreography (`dance`).
- **Quick Action Bar**: Floating buttons to directly trigger `💤 Idle`, `🐾 Walk`, `⚡ Run`, `🎵 Dance`, `🪑 Sit`, or close the overlay.

---

## 🛠️ Architecture

```text
walking_doll/
├── android/app/src/main/kotlin/com/walkingdoll/walking_doll/
│   ├── MainActivity.kt                      # Flutter MethodChannel bridge
│   └── overlay/
│       ├── DollOverlayService.kt            # Android Foreground Service & Notification
│       ├── OverlayWindowManager.kt         # WindowManager, touch routing & physics coordination
│       ├── ThreeDOverlayRenderer.kt        # Real-time hardware-accelerated 3D overlay renderer
│       ├── AutonomousBehaviourEngine.kt    # Autonomous personality state machine
│       ├── ScreenPhysicsEngine.kt          # Gravity, boundaries, landing & walking physics
│       ├── TwoDOverlayRenderer.kt          # Optional modular 2D renderer
│       └── OverlayPermissionManager.kt     # SYSTEM_ALERT_WINDOW handler
├── assets/characters/3d/
│   ├── robot_companion.glb                 # 74-bone humanoid with 14 skeletal animations
│   ├── anime_chibi_doll.glb                # 230-node anime game character
│   ├── realistic_doll_brunette.glb         # Realistic fashion doll with PBR materials
│   ├── spirit_fox.glb                      # 3D spirit fox companion
│   └── astronaut_doll.glb                  # Photorealistic PBR spacesuit companion
├── lib/
│   ├── core/
│   │   ├── constants/ (app_colors, app_strings, app_theme)
│   │   ├── native/overlay_channel.dart     # MethodChannel bridge
│   │   └── utils/responsive_layout.dart
│   └── features/
│       ├── characters/
│       │   ├── domain/ (character_model, character_animation, character_engine)
│       │   ├── data/ (demo_characters, character_repository)
│       │   ├── engines/three_d/ (three_d_model_view, three_d_character_engine)
│       │   └── presentation/ (doll_provider, overlay_provider, animation_action_bar, doll_card, doll_stats_card)
│       ├── gallery/ (gallery_screen, character_detail_sheet)
│       ├── home/ (home_screen)
│       └── import/ (import_screen, import_3d_tab, import_2d_tab)
```

---

## 🚀 Running the App

### Requirements
- Android SDK (API 26+ recommended, Android 8.0 Oreo or newer)
- Flutter 3.13+
- Java 17+ (e.g. Android Studio JBR)

### Commands
```bash
# Analyze Dart codebase
flutter analyze

# Build Debug APK
flutter build apk --debug

# Run directly on connected Android device or emulator
flutter run
```
