import 'package:flutter/widgets.dart';
import 'character_animation.dart';
import 'character_model.dart';

/// Common abstraction for character engines.
/// Screens interact exclusively through this interface and CharacterModel,
/// keeping 2D and 3D rendering pipelines strictly segregated.
abstract class CharacterEngine {
  /// Loads character assets and initializes render pipeline
  Future<void> loadCharacter(CharacterModel character);

  /// Renders responsive interactive preview widget
  Widget buildPreview(BuildContext context);

  /// Switches active character animation (idle, walk, dance, tap, drag)
  Future<void> playAnimation(CharacterAnimation animation);

  /// Releases tickers, animators, and texture/webview resources
  Future<void> dispose();
}

