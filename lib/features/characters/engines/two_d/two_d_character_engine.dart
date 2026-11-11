import 'package:flutter/widgets.dart';
import '../../domain/character_animation.dart';
import '../../domain/character_engine.dart';
import '../../domain/character_model.dart';
import 'two_d_procedural_view.dart';
import 'two_d_sprite_view.dart';

/// 2D Character Engine.
/// Encapsulates static PNG, GIF, and sprite-sheet rendering behind the CharacterEngine interface.
class TwoDCharacterEngine implements CharacterEngine {
  CharacterModel? _character;
  CharacterAnimation _currentAnimation = CharacterAnimation.idle;

  // Notifier to trigger reactive widget updates without rebuilding the entire screen
  final ValueNotifier<CharacterAnimation> _animationNotifier =
      ValueNotifier<CharacterAnimation>(CharacterAnimation.idle);

  CharacterModel? get currentCharacter => _character;
  CharacterAnimation get currentAnimation => _currentAnimation;

  @override
  Future<void> loadCharacter(CharacterModel character) async {
    _character = character;
    _currentAnimation = CharacterAnimation.idle;
    _animationNotifier.value = _currentAnimation;
  }

  @override
  Widget buildPreview(BuildContext context) {
    if (_character == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<CharacterAnimation>(
      valueListenable: _animationNotifier,
      builder: (context, anim, _) {
        if (_character!.isSpriteSheet) {
          return TwoDSpriteView(
            character: _character!,
            currentAnimation: anim,
            onTap: () => playAnimation(CharacterAnimation.tap),
          );
        } else {
          return TwoDProceduralView(
            character: _character!,
            currentAnimation: anim,
            onTap: () => playAnimation(CharacterAnimation.tap),
          );
        }
      },
    );
  }

  @override
  Future<void> playAnimation(CharacterAnimation animation) async {
    _currentAnimation = animation;
    _animationNotifier.value = animation;
  }

  @override
  Future<void> dispose() async {
    _animationNotifier.dispose();
  }
}

