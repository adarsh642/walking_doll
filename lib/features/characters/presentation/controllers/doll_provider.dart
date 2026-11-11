import 'package:flutter/foundation.dart';
import '../../data/character_repository.dart';
import '../../data/demo_characters.dart';
import '../../domain/character_animation.dart';
import '../../domain/character_engine.dart';
import '../../domain/character_model.dart';
import '../../engines/three_d/three_d_character_engine.dart';
import '../../engines/two_d/two_d_character_engine.dart';

enum CharacterFilter {
  all,
  twoD,
  threeD,
  imported,
}

/// Central state manager for Characters and the active CharacterEngine.
/// Screens communicate through this provider without knowing the underlying
/// 2D or 3D rendering implementation.
class DollProvider extends ChangeNotifier {
  final CharacterRepository _repository = CharacterRepository();

  List<CharacterModel> _characters = [];
  CharacterModel? _activeDoll;
  CharacterFilter _currentFilter = CharacterFilter.threeD;
  CharacterAnimation _currentAnimation = CharacterAnimation.idle;
  bool _isLoading = true;

  CharacterEngine? _activeEngine;

  List<CharacterModel> get characters => _characters;
  CharacterModel? get activeDoll => _activeDoll;
  CharacterFilter get currentFilter => _currentFilter;
  CharacterAnimation get currentAnimation => _currentAnimation;
  bool get isLoading => _isLoading;
  CharacterEngine? get activeEngine => _activeEngine;

  List<CharacterModel> get filteredCharacters {
    switch (_currentFilter) {
      case CharacterFilter.all:
        return _characters;
      case CharacterFilter.twoD:
        return _characters.where((d) => d.type == CharacterType.twoD).toList();
      case CharacterFilter.threeD:
        return _characters.where((d) => d.type == CharacterType.threeD).toList();
      case CharacterFilter.imported:
        return _characters.where((d) => d.isImported).toList();
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _characters = await _repository.getAllCharacters();
    final savedId = await _repository.getActiveDollId();

    if (savedId != null && !savedId.startsWith('demo_2d_')) {
      _activeDoll = _characters.firstWhere(
        (c) => c.id == savedId,
        orElse: () => _characters.first,
      );
      // Auto-upgrade to Shiroko (flagship 3D animated game companion) if saved doll has no animation clips
      if (_activeDoll != null && !_activeDoll!.hasEmbeddedAnimations && _characters.first.hasEmbeddedAnimations) {
        _activeDoll = _characters.first;
      }
    } else if (_characters.isNotEmpty) {
      _activeDoll = _characters.first;
    }

    if (_activeDoll != null) {
      await _setupEngineForDoll(_activeDoll!);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setFilter(CharacterFilter filter) async {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> selectDoll(CharacterModel doll) async {
    _activeDoll = doll;
    await _repository.setActiveDollId(doll.id);
    await _setupEngineForDoll(doll);
    notifyListeners();
  }

  Future<void> playAnimation(CharacterAnimation animation) async {
    _currentAnimation = animation;
    await _activeEngine?.playAnimation(animation);
    notifyListeners();
  }

  Future<void> _setupEngineForDoll(CharacterModel doll) async {
    await _activeEngine?.dispose();

    if (doll.type == CharacterType.threeD) {
      _activeEngine = ThreeDCharacterEngine();
    } else {
      _activeEngine = TwoDCharacterEngine();
    }

    await _activeEngine!.loadCharacter(doll);
    await _activeEngine!.playAnimation(_currentAnimation);
  }

  Future<CharacterModel> importNewCharacter({
    required String name,
    required CharacterType type,
    required String filePath,
    required bool isSpriteSheet,
    int columns = 1,
    int rows = 1,
    int fps = 8,
  }) async {
    final imported = await _repository.saveImportedCharacter(
      name: name,
      type: type,
      sourceFilePath: filePath,
      isSpriteSheet: isSpriteSheet,
      columns: columns,
      rows: rows,
      fps: fps,
    );

    _characters = await _repository.getAllCharacters();
    await selectDoll(imported);
    return imported;
  }

  Future<void> deleteCharacter(String dollId) async {
    await _repository.deleteImportedCharacter(dollId);
    _characters = await _repository.getAllCharacters();

    if (_activeDoll?.id == dollId) {
      _activeDoll = _characters.isNotEmpty ? _characters.first : null;
      if (_activeDoll != null) {
        await _setupEngineForDoll(_activeDoll!);
      }
    }
    notifyListeners();
  }

  static CharacterModel get demoCharactersFallback => DemoCharacters.all.first;

  @override
  void dispose() {
    _activeEngine?.dispose();
    super.dispose();
  }
}
