import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../features/characters/domain/character_animation.dart';
import '../../features/characters/domain/character_model.dart';

/// MethodChannel communication layer between Flutter and native Android Kotlin overlay.
class OverlayChannel {
  static const MethodChannel _channel = MethodChannel('com.walkingdoll/overlay');

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Checks whether Android `Settings.canDrawOverlays` is granted
  static Future<bool> checkOverlayPermission() async {
    if (!isAndroid) return true;
    try {
      final bool? granted = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return granted ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking overlay permission: ${e.message}');
      return false;
    }
  }

  /// Launches Android system overlay settings page
  static Future<void> requestOverlayPermission() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      debugPrint('Error requesting overlay permission: ${e.message}');
    }
  }

  /// Checks if the foreground overlay service is currently active
  static Future<bool> isOverlayActive() async {
    if (!isAndroid) return false;
    try {
      final bool? active = await _channel.invokeMethod<bool>('isOverlayActive');
      return active ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking overlay active status: ${e.message}');
      return false;
    }
  }

  /// Starts the Android native floating doll overlay
  static Future<bool> startOverlay(CharacterModel character) async {
    if (!isAndroid) return false;
    try {
      final Map<String, dynamic> payload = character.toNativePayload();
      final bool? success = await _channel.invokeMethod<bool>('startOverlay', payload);
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error starting overlay: ${e.message}');
      return false;
    }
  }

  /// Stops the Android native floating doll overlay
  static Future<bool> stopOverlay() async {
    if (!isAndroid) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>('stopOverlay');
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error stopping overlay: ${e.message}');
      return false;
    }
  }

  /// Updates character data on the running overlay
  static Future<bool> updateCharacter(CharacterModel character) async {
    if (!isAndroid) return false;
    try {
      final Map<String, dynamic> payload = character.toNativePayload();
      final bool? success = await _channel.invokeMethod<bool>('updateCharacter', payload);
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error updating overlay character: ${e.message}');
      return false;
    }
  }

  /// Updates current animation on the running overlay
  static Future<bool> updateAnimation(CharacterAnimation animation) async {
    if (!isAndroid) return false;
    try {
      final bool? success = await _channel.invokeMethod<bool>(
        'updateAnimation',
        {'animation': animation.name},
      );
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error updating overlay animation: ${e.message}');
      return false;
    }
  }
}

