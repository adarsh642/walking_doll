import 'package:flutter_test/flutter_test.dart';
import 'package:walking_doll/features/characters/data/demo_characters.dart';
import 'package:walking_doll/features/characters/domain/character_animation.dart';
import 'package:walking_doll/features/characters/domain/character_model.dart';
import 'package:walking_doll/features/characters/engines/three_d/three_d_character_engine.dart';
import 'package:walking_doll/features/characters/engines/two_d/two_d_character_engine.dart';

void main() {
  group('Character Domain & Engines Tests', () {
    test('CharacterModel serialization and deserialization matches', () {
      final doll = CharacterModel(
        id: 'test_doll_01',
        name: 'Test Chibi',
        type: CharacterType.twoD,
        assetPath: 'assets/characters/2d/sakura_idle.png',
        isSpriteSheet: true,
        columns: 4,
        rows: 2,
        fps: 12,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = doll.toJson();
      final revived = CharacterModel.fromJson(json);

      expect(revived.id, doll.id);
      expect(revived.name, doll.name);
      expect(revived.type, CharacterType.twoD);
      expect(revived.isSpriteSheet, isTrue);
      expect(revived.columns, 4);
      expect(revived.rows, 2);
      expect(revived.fps, 12);
    });

    test('3D CharacterModel holds animation and GLB capabilities', () {
      final doll3d = CharacterModel(
        id: 'test_3d_01',
        name: 'Cyber Mascot',
        type: CharacterType.threeD,
        assetPath: 'assets/characters/3d/astro_doll.glb',
        hasEmbeddedAnimations: true,
        availableAnimations: ['idle', 'walk', 'dance'],
        createdAt: DateTime(2026, 1, 1),
      );

      expect(doll3d.type.isThreeD, isTrue);
      expect(doll3d.type.isTwoD, isFalse);
      expect(doll3d.availableAnimations.length, 3);
    });

    test('TwoDCharacterEngine loads 2D character and switches animations', () async {
      final engine = TwoDCharacterEngine();
      final sakura = DemoCharacters.all.first;

      await engine.loadCharacter(sakura);
      expect(engine.currentCharacter?.id, sakura.id);
      expect(engine.currentAnimation, CharacterAnimation.idle);

      await engine.playAnimation(CharacterAnimation.walk);
      expect(engine.currentAnimation, CharacterAnimation.walk);

      await engine.playAnimation(CharacterAnimation.dance);
      expect(engine.currentAnimation, CharacterAnimation.dance);

      await engine.dispose();
    });

    test('ThreeDCharacterEngine loads 3D character and maintains engine contract', () async {
      final engine = ThreeDCharacterEngine();
      final astro = DemoCharacters.all.firstWhere((d) => d.type == CharacterType.threeD);

      await engine.loadCharacter(astro);
      expect(engine.currentCharacter?.id, astro.id);

      await engine.playAnimation(CharacterAnimation.walk);
      expect(engine.currentAnimation, CharacterAnimation.walk);

      await engine.dispose();
    });
  });
}
