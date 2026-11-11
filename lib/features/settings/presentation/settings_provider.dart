import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../characters/domain/character_model.dart';

/// Manages user preferences: theme, overlay auto-start, default doll type,
/// animation speed, and touch reactions.
class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'walking_doll_theme_mode';
  static const String _autoStartKey = 'walking_doll_auto_start';
  static const String _defaultTypeKey = 'walking_doll_default_type';
  static const String _animSpeedKey = 'walking_doll_anim_speed';
  static const String _touchReactionsKey = 'walking_doll_touch_reactions';

  ThemeMode _themeMode = ThemeMode.system;
  bool _autoStartOverlay = false;
  CharacterType _defaultCharacterType = CharacterType.twoD;
  double _animationSpeed = 1.0;
  bool _enableTouchInteractions = true;

  ThemeMode get themeMode => _themeMode;
  bool get autoStartOverlay => _autoStartOverlay;
  CharacterType get defaultCharacterType => _defaultCharacterType;
  double get animationSpeed => _animationSpeed;
  bool get enableTouchInteractions => _enableTouchInteractions;

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
    _defaultCharacterType = typeStr == 'threeD' ? CharacterType.threeD : CharacterType.twoD;
    _animationSpeed = prefs.getDouble(_animSpeedKey) ?? 1.0;
    _enableTouchInteractions = prefs.getBool(_touchReactionsKey) ?? true;

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
}

