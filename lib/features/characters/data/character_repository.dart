import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/character_model.dart';
import 'demo_characters.dart';

/// Repository responsible for characters persistence, demo dolls,
/// file imports storage in app documents, and active character preference.
class CharacterRepository {
  static const String _importedKey = 'walking_doll_imported_characters';
  static const String _activeDollIdKey = 'walking_doll_active_id';

  Future<List<CharacterModel>> getAllCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawJsonList = prefs.getStringList(_importedKey) ?? [];

    final List<CharacterModel> imported = [];
    for (final raw in rawJsonList) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        imported.add(CharacterModel.fromJson(map));
      } catch (e) {
        // Skip corrupted entries
      }
    }

    return [...DemoCharacters.all, ...imported];
  }

  Future<String?> getActiveDollId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeDollIdKey);
  }

  Future<void> setActiveDollId(String dollId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeDollIdKey, dollId);
  }

  /// Copies an imported source file into the persistent local app directory
  /// and stores metadata in SharedPreferences.
  Future<CharacterModel> saveImportedCharacter({
    required String name,
    required CharacterType type,
    required String sourceFilePath,
    required bool isSpriteSheet,
    int columns = 1,
    int rows = 1,
    int fps = 8,
    String? aiPrompt,
    bool isAiGenerated = false,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dollDir = Directory('${docsDir.path}/walking_doll_imports');
    if (!await dollDir.exists()) {
      await dollDir.create(recursive: true);
    }

    final sourceFile = File(sourceFilePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${sourceFile.uri.pathSegments.last}';
    final destinationFile = File('${dollDir.path}/$fileName');
    await sourceFile.copy(destinationFile.path);

    final newDoll = CharacterModel(
      id: 'import_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'My Custom Doll' : name.trim(),
      type: type,
      assetPath: destinationFile.path,
      isAsset: false,
      isImported: true,
      description: 'Custom imported ${type.label} doll companion.',
      isSpriteSheet: isSpriteSheet,
      columns: columns,
      rows: rows,
      fps: fps,
      hasEmbeddedAnimations: type == CharacterType.threeD,
      availableAnimations: type == CharacterType.threeD ? ['idle', 'walk', 'dance'] : const [],
      mood: 'Excited ✨',
      level: 1,
      experience: 0.1,
      isAiGenerated: isAiGenerated,
      aiPrompt: aiPrompt,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_importedKey) ?? [];
    currentList.add(jsonEncode(newDoll.toJson()));
    await prefs.setStringList(_importedKey, currentList);

    return newDoll;
  }

  Future<void> deleteImportedCharacter(String dollId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_importedKey) ?? [];

    final updated = currentList.where((raw) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return map['id'] != dollId;
      } catch (_) {
        return false;
      }
    }).toList();

    await prefs.setStringList(_importedKey, updated);
  }
}

