import '../domain/character_model.dart';

/// Bundled genuine game-character 3D dolls available out of the box in Walking Doll.
/// Powered by rigged humanoid skeletons, physically based materials,
/// and real-time skeletal animations.
class DemoCharacters {
  DemoCharacters._();

  static final List<CharacterModel> all = [
    // 1. Shiroko - Flagship 3D Stylized Anime Game Character
    CharacterModel(
      id: 'demo_3d_shiroko_anime',
      name: 'Shiroko (3D Anime Doll)',
      type: CharacterType.threeD,
      assetPath: 'assets/characters/3d/shiroko_anime.glb',
      description: 'Game-quality 3D stylized anime character from modern 3D games with a 170-bone humanoid skeleton, 6 skins, detailed anime hair strands, pleated skirt, scarf, shoes, and 44 real skeletal animations (Idle, Walk, Run, Jump, Dance, Kneel, Death/Fall, Victory, Pickup).',
      hasEmbeddedAnimations: true,
      availableAnimations: const [
        'Formation_Idle',
        'Cafe_Idle',
        'Stand_Idle',
        'Kneel_Idle',
        'Cafe_Walk',
        'Move_Ing',
        'Move_Jump',
        'Vital_Death',
        'Vital_Panic',
        'Formation_Pickup',
        'Cafe_Reaction',
        'Victory_Start',
        'Victory_End',
        'Exs',
      ],
      mood: 'Calm & Loyal 🌟',
      level: 18,
      experience: 0.98,
      createdAt: DateTime(2026, 1, 1),
    ),

    // 2. Airi - Stylized 3D Chibi Humanoid Character
    CharacterModel(
      id: 'demo_3d_airi_anime',
      name: 'Airi (3D Chibi Doll)',
      type: CharacterType.threeD,
      assetPath: 'assets/characters/3d/airi_anime.glb',
      description: 'Stylized 3D chibi humanoid game character with 133 bones, articulated limbs, hair ribbons, school uniform, and 7 real skeletal animations (Idle, Walk, Pickup, Reaction, Dance).',
      hasEmbeddedAnimations: true,
      availableAnimations: const [
        'Formation_Idle',
        'Cafe_Idle',
        'Cafe_Walk',
        'Formation_Pickup',
        'Cafe_Reaction',
        'Exs',
        'Tactical_Start',
      ],
      mood: 'Sweet & Cheerful 🍡',
      level: 14,
      experience: 0.89,
      createdAt: DateTime(2026, 1, 2),
    ),

    // 3. Nexus Spark - Fully Animated 3D Game Companion Doll
    CharacterModel(
      id: 'demo_3d_nexus_robot',
      name: 'Nexus Spark (3D Living Doll)',
      type: CharacterType.threeD,
      assetPath: 'assets/characters/3d/robot_companion.glb',
      description: 'Game-quality 3D humanoid companion with complete 74-bone skeletal rigging, articulated fingers, and 14 full-body skeletal animations (Idle, Walk, Run, Dance, Jump, Sit, Fall, Wave).',
      hasEmbeddedAnimations: true,
      availableAnimations: const [
        'Idle',
        'Walking',
        'Running',
        'Dance',
        'Jump',
        'Sitting',
        'Standing',
        'Death',
        'Wave',
        'ThumbsUp',
        'Punch',
        'Yes',
        'No',
      ],
      mood: 'Autonomous & Lively ✨',
      level: 15,
      experience: 0.95,
      createdAt: DateTime(2026, 1, 3),
    ),

    // 4. Soldier Vanguard - Skinned Humanoid Operative
    CharacterModel(
      id: 'demo_3d_soldier',
      name: 'Vanguard (3D Humanoid)',
      type: CharacterType.threeD,
      assetPath: 'assets/characters/3d/soldier.glb',
      description: 'Skinned 68-bone 3D humanoid operative with combat gear, boots, articulated limbs, and natural locomotion clips (Idle, Walk, Run).',
      hasEmbeddedAnimations: true,
      availableAnimations: const [
        'Idle',
        'Walk',
        'Run',
      ],
      mood: 'Steadfast & Disciplined 🛡️',
      level: 12,
      experience: 0.85,
      createdAt: DateTime(2026, 1, 4),
    ),

    // 5. Kitsune - 3D Celestial Spirit Fox Doll
    CharacterModel(
      id: 'demo_3d_spirit_fox',
      name: 'Kitsune (3D Spirit Companion)',
      type: CharacterType.threeD,
      assetPath: 'assets/characters/3d/spirit_fox.glb',
      description: 'Graceful 3D mythical fox companion with fluid natural locomotion cycles, skeletal running, and curious surveying locomotion.',
      hasEmbeddedAnimations: true,
      availableAnimations: const ['Survey', 'Walk', 'Run'],
      mood: 'Curious & Alert 🦊',
      level: 8,
      experience: 0.70,
      createdAt: DateTime(2026, 1, 5),
    ),

    // 6. Aria Couture - Realistic 3D Humanoid Fashion Doll
    CharacterModel(
      id: 'demo_3d_aria_doll',
      name: 'Aria Couture (Realistic 3D Doll)',
      type: CharacterType.threeD,
      assetPath: 'assets/characters/3d/realistic_doll_brunette.glb',
      description: 'Ultra-lifelike 3D fashion doll companion with porcelain skin, flowing brunette hair, tailored layered dress, shoes, and real-time PBR material rendering.',
      hasEmbeddedAnimations: false,
      availableAnimations: const [
        'idle',
        'walk',
        'run',
        'dance',
        'jump',
        'sit',
        'sleep',
        'think',
      ],
      mood: 'Refined & Lifelike 👗',
      level: 16,
      experience: 0.94,
      createdAt: DateTime(2026, 1, 6),
    ),
  ];
}
