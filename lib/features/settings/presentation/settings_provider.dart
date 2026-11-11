import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../characters/domain/character_model.dart';

/// Manages user preferences: theme, performance, overlay behavior,
/// animation speed, and interactive controls.
class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'walking_doll_theme_mode';
  static const String _autoStartKey = 'walking_doll_auto_start';
  static const String _defaultTypeKey = 'walking_doll_default_type';
  static const String _animSpeedKey = 'walking_doll_anim_speed';
  static const String _touchReactionsKey = 'walking_doll_touch_reactions';
  static const String _highPerfKey = 'walking_doll_high_perf';
  static const String _hapticsKey = 'walking_doll_haptics';
  static const String _overlayScaleKey = 'walking_doll_overlay_scale';
  static const String _boundaryPatrolKey = 'walking_doll_boundary_patrol';

  ThemeMode _themeMode = ThemeMode.system;
  bool _autoStartOverlay = false;
  CharacterType _defaultCharacterType = CharacterType.threeD;
  double _animationSpeed = 1.0;
  bool _enableTouchInteractions = true;
  bool _highPerformanceMode = true;
  bool _hapticFeedback = true;
  double _overlayScale = 1.0;
  bool _boundaryPatrol = true;

  ThemeMode get themeMode => _themeMode;
  bool get autoStartOverlay => _autoStartOverlay;
  CharacterType get defaultCharacterType => _defaultCharacterType;
  double get animationSpeed => _animationSpeed;
  bool get enableTouchInteractions => _enableTouchInteractions;
  bool get highPerformanceMode => _highPerformanceMode;
  bool get hapticFeedback => _hapticFeedback;
  double get overlayScale => _overlayScale;
  bool get boundaryPatrol => _boundaryPatrol;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final themeStr = prefs.getString(_themeKey);
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    _autoStartOverlay = prefs.getBool(_autoStartKey) ?? false;
    final typeStr = prefs.getString(_defaultTypeKey);
    _defaultCharacterType = typeStr == 'twoD' ? CharacterType.twoD : CharacterType.threeD;
    _animationSpeed = prefs.getDouble(_animSpeedKey) ?? 1.0;
    _enableTouchInteractions = prefs.getBool(_touchReactionsKey) ?? true;
    _highPerformanceMode = prefs.getBool(_highPerfKey) ?? true;
    _hapticFeedback = prefs.getBool(_hapticsKey) ?? true;
    _overlayScale = prefs.getDouble(_overlayScaleKey) ?? 1.0;
    _boundaryPatrol = prefs.getBool(_boundaryPatrolKey) ?? true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setAutoStartOverlay(bool value) async {
    _autoStartOverlay = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartKey, value);
  }

  Future<void> setDefaultCharacterType(CharacterType type) async {
    _defaultCharacterType = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultTypeKey, type.name);
  }

  Future<void> setAnimationSpeed(double speed) async {
    _animationSpeed = speed;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_animSpeedKey, speed);
  }

  Future<void> setEnableTouchInteractions(bool value) async {
    _enableTouchInteractions = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_touchReactionsKey, value);
  }

  Future<void> setHighPerformanceMode(bool value) async {
    _highPerformanceMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_highPerfKey, value);
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, value);
  }

  Future<void> setOverlayScale(double scale) async {
    _overlayScale = scale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_overlayScaleKey, scale);
  }

  Future<void> setBoundaryPatrol(bool value) async {
    _boundaryPatrol = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_boundaryPatrolKey, value);
  }

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _autoStartOverlay = false;
    _defaultCharacterType = CharacterType.threeD;
    _animationSpeed = 1.0;
    _enableTouchInteractions = true;
    _highPerformanceMode = true;
    _hapticFeedback = true;
    _overlayScale = 1.0;
    _boundaryPatrol = true;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_autoStartKey);
    await prefs.remove(_defaultTypeKey);
    await prefs.remove(_animSpeedKey);
    await prefs.remove(_touchReactionsKey);
    await prefs.remove(_highPerfKey);
    await prefs.remove(_hapticsKey);
    await prefs.remove(_overlayScaleKey);
    await prefs.remove(_boundaryPatrolKey);
  }
}
