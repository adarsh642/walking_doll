import 'package:flutter/material.dart';

/// Supported game-character animation interaction states for 3D living dolls.
enum CharacterAnimation {
  idle,
  walk,
  run,
  jump,
  fall,
  sit,
  sleep,
  wakeUp,
  think,
  dance,
  drag,
  tap,
}

extension CharacterAnimationX on CharacterAnimation {
  String get label {
    switch (this) {
      case CharacterAnimation.idle:
        return 'Idle';
      case CharacterAnimation.walk:
        return 'Walk';
      case CharacterAnimation.run:
        return 'Run';
      case CharacterAnimation.jump:
        return 'Jump';
      case CharacterAnimation.fall:
        return 'Fall';
      case CharacterAnimation.sit:
        return 'Sit';
      case CharacterAnimation.sleep:
        return 'Sleep';
      case CharacterAnimation.wakeUp:
        return 'Wake Up';
      case CharacterAnimation.think:
        return 'Think';
      case CharacterAnimation.dance:
        return 'Dance';
      case CharacterAnimation.drag:
        return 'Floating';
      case CharacterAnimation.tap:
        return 'Wave';
    }
  }

  IconData get icon {
    switch (this) {
      case CharacterAnimation.idle:
        return Icons.spa_rounded;
      case CharacterAnimation.walk:
        return Icons.directions_walk_rounded;
      case CharacterAnimation.run:
        return Icons.directions_run_rounded;
      case CharacterAnimation.jump:
        return Icons.flight_takeoff_rounded;
      case CharacterAnimation.fall:
        return Icons.arrow_downward_rounded;
      case CharacterAnimation.sit:
        return Icons.chair_rounded;
      case CharacterAnimation.sleep:
        return Icons.bedtime_rounded;
      case CharacterAnimation.wakeUp:
        return Icons.wb_sunny_rounded;
      case CharacterAnimation.think:
        return Icons.psychology_rounded;
      case CharacterAnimation.dance:
        return Icons.music_note_rounded;
      case CharacterAnimation.drag:
        return Icons.open_with_rounded;
      case CharacterAnimation.tap:
        return Icons.waving_hand_rounded;
    }
  }

  String get description {
    switch (this) {
      case CharacterAnimation.idle:
        return 'Natural breathing, weight shifting & looking around';
      case CharacterAnimation.walk:
        return 'Natural alternating leg movement & arm swinging';
      case CharacterAnimation.run:
        return 'Faster locomotion with forward body inclination';
      case CharacterAnimation.jump:
        return 'Squatting, airborne extension & natural landing';
      case CharacterAnimation.fall:
        return 'Loss of balance, tumbling descent & impact recovery';
      case CharacterAnimation.sit:
        return 'Comfortable resting posture with natural small movements';
      case CharacterAnimation.sleep:
        return 'Peaceful lying down posture with deep breathing';
      case CharacterAnimation.wakeUp:
        return 'Stretching arms, rubbing eyes and standing up';
      case CharacterAnimation.think:
        return 'Hand to chin with curious head tilt';
      case CharacterAnimation.dance:
        return 'Choreographed full-body dance moves';
      case CharacterAnimation.drag:
        return 'Held in mid-air following touch coordinates';
      case CharacterAnimation.tap:
        return 'Friendly waving gesture with happy expression';
    }
  }
}
