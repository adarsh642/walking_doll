import 'package:flutter/foundation.dart';
import '../../../../core/native/overlay_channel.dart';
import '../../domain/character_animation.dart';
import '../../domain/character_model.dart';

/// State management for the native Android overlay layer.
class OverlayProvider extends ChangeNotifier {
  bool _hasPermission = false;
  bool _isOverlayActive = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get hasPermission => _hasPermission;
  bool get isOverlayActive => _isOverlayActive;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> checkPermission() async {
    _hasPermission = await OverlayChannel.checkOverlayPermission();
    _isOverlayActive = await OverlayChannel.isOverlayActive();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    await OverlayChannel.requestOverlayPermission();
    // After returning from system settings, re-check
    await Future.delayed(const Duration(milliseconds: 500));
    await checkPermission();
  }

  Future<bool> startOverlay(CharacterModel doll) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _hasPermission = await OverlayChannel.checkOverlayPermission();
    if (!_hasPermission) {
      _isLoading = false;
      _errorMessage = 'Overlay permission is required.';
      notifyListeners();
      return false;
    }

    final success = await OverlayChannel.startOverlay(doll);
    _isOverlayActive = success;
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> stopOverlay() async {
    _isLoading = true;
    notifyListeners();

    final success = await OverlayChannel.stopOverlay();
    _isOverlayActive = !success;
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> toggleOverlay(CharacterModel doll) async {
    if (_isOverlayActive) {
      await stopOverlay();
    } else {
      await startOverlay(doll);
    }
  }

  Future<void> updateCharacter(CharacterModel doll) async {
    if (_isOverlayActive) {
      await OverlayChannel.updateCharacter(doll);
    }
  }

  Future<void> updateAnimation(CharacterAnimation animation) async {
    if (_isOverlayActive) {
      await OverlayChannel.updateAnimation(animation);
    }
  }
}

