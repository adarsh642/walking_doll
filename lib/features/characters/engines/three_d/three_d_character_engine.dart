import 'package:flutter/widgets.dart';
import '../../domain/character_animation.dart';
import '../../domain/character_engine.dart';
import '../../domain/character_model.dart';
import 'three_d_model_view.dart';

/// 3D Character Engine.
/// Encapsulates GLB/GLTF model rendering, 3D animations, and interactive camera controls
/// behind the CharacterEngine interface.
class ThreeDCharacterEngine implements CharacterEngine {
  CharacterModel? _character;
  CharacterAnimation _currentAnimation = CharacterAnimation.idle;
  bool _enableControls = true;
  bool _autoRotate = true;

  final ValueNotifier<CharacterAnimation> _animationNotifier =
      ValueNotifier<CharacterAnimation>(CharacterAnimation.idle);

  CharacterModel? get currentCharacter => _character;
  CharacterAnimation get currentAnimation => _currentAnimation;

  void setControlsEnabled(bool enabled) {
    _enableControls = enabled;
  }

  void setAutoRotate(bool enabled) {
    _autoRotate = enabled;
  }

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
        return ThreeDModelView(
          character: _character!,
          currentAnimation: anim,
          enableControls: _enableControls,
          autoRotate: _autoRotate,
        );
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

