/// Classification for all virtual dolls.
enum CharacterType {
  twoD,
  threeD,
}

extension CharacterTypeX on CharacterType {
  String get label {
    switch (this) {
      case CharacterType.twoD:
        return '2D';
      case CharacterType.threeD:
        return '3D';
    }
  }

  bool get isTwoD => this == CharacterType.twoD;
  bool get isThreeD => this == CharacterType.threeD;
}

/// Core domain entity for Walking Doll characters.
/// Designed for current 2D/3D models and prepared for future AI-generated models.
class CharacterModel {
  final String id;
  final String name;
  final CharacterType type;
  final String assetPath;
  final bool isAsset;
  final String description;
  final String? avatarThumbnailPath;

  // 2D Sprite-sheet attributes
  final bool isSpriteSheet;
  final int columns;
  final int rows;
  final int fps;

  // 3D Model attributes
  final bool hasEmbeddedAnimations;
  final List<String> availableAnimations;

  // Gamification & Companion mood
  final String mood;
  final int level;
  final double experience; // 0.0 to 1.0

  // Origin & AI readiness
  final bool isImported;
  final bool isAiGenerated;
  final String? aiPrompt;
  final DateTime createdAt;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.type,
    required this.assetPath,
    this.isAsset = true,
    this.description = '',
    this.avatarThumbnailPath,
    this.isSpriteSheet = false,
    this.columns = 1,
    this.rows = 1,
    this.fps = 8,
    this.hasEmbeddedAnimations = false,
    this.availableAnimations = const [],
    this.mood = 'Joyful ⭐',
    this.level = 1,
    this.experience = 0.5,
    this.isImported = false,
    this.isAiGenerated = false,
    this.aiPrompt,
    required this.createdAt,
  });

  CharacterModel copyWith({
    String? id,
    String? name,
    CharacterType? type,
    String? assetPath,
    bool? isAsset,
    String? description,
    String? avatarThumbnailPath,
    bool? isSpriteSheet,
    int? columns,
    int? rows,
    int? fps,
    bool? hasEmbeddedAnimations,
    List<String>? availableAnimations,
    String? mood,
    int? level,
    double? experience,
    bool? isImported,
    bool? isAiGenerated,
    String? aiPrompt,
    DateTime? createdAt,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      assetPath: assetPath ?? this.assetPath,
      isAsset: isAsset ?? this.isAsset,
      description: description ?? this.description,
      avatarThumbnailPath: avatarThumbnailPath ?? this.avatarThumbnailPath,
      isSpriteSheet: isSpriteSheet ?? this.isSpriteSheet,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      fps: fps ?? this.fps,
      hasEmbeddedAnimations: hasEmbeddedAnimations ?? this.hasEmbeddedAnimations,
      availableAnimations: availableAnimations ?? this.availableAnimations,
      mood: mood ?? this.mood,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      isImported: isImported ?? this.isImported,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'assetPath': assetPath,
      'isAsset': isAsset,
      'description': description,
      'avatarThumbnailPath': avatarThumbnailPath,
      'isSpriteSheet': isSpriteSheet,
      'columns': columns,
      'rows': rows,
      'fps': fps,
      'hasEmbeddedAnimations': hasEmbeddedAnimations,
      'availableAnimations': availableAnimations,
      'mood': mood,
      'level': level,
      'experience': experience,
      'isImported': isImported,
      'isAiGenerated': isAiGenerated,
      'aiPrompt': aiPrompt,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] == 'threeD' ? CharacterType.threeD : CharacterType.twoD,
      assetPath: json['assetPath'] as String,
      isAsset: json['isAsset'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      avatarThumbnailPath: json['avatarThumbnailPath'] as String?,
      isSpriteSheet: json['isSpriteSheet'] as bool? ?? false,
      columns: json['columns'] as int? ?? 1,
      rows: json['rows'] as int? ?? 1,
      fps: json['fps'] as int? ?? 8,
      hasEmbeddedAnimations: json['hasEmbeddedAnimations'] as bool? ?? false,
      availableAnimations: (json['availableAnimations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      mood: json['mood'] as String? ?? 'Joyful ⭐',
      level: json['level'] as int? ?? 1,
      experience: (json['experience'] as num?)?.toDouble() ?? 0.5,
      isImported: json['isImported'] as bool? ?? false,
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      aiPrompt: json['aiPrompt'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Map payload sent to Kotlin native overlay service
  Map<String, dynamic> toNativePayload() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'assetPath': assetPath,
      'isAsset': isAsset,
      'isSpriteSheet': isSpriteSheet,
      'columns': columns,
      'rows': rows,
      'fps': fps,
      'hasEmbeddedAnimations': hasEmbeddedAnimations,
      'availableAnimations': availableAnimations,
    };
  }
}

