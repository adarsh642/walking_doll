import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/character_animation.dart';
import '../../domain/character_model.dart';

/// Available realistic studio lighting presets for the 3D viewport
enum StudioLightingPreset {
  studio('Studio', Icons.wb_sunny_rounded, 1.05, 0.95, 0.75),
  goldenHour('Golden', Icons.wb_twilight_rounded, 1.20, 1.00, 0.85),
  cyberNeon('Neon', Icons.nightlife_rounded, 0.90, 0.65, 0.50),
  porcelainSoft('Soft PBR', Icons.auto_awesome_rounded, 1.12, 0.50, 0.90);

  final String label;
  final IconData icon;
  final double exposure;
  final double shadowIntensity;
  final double shadowSoftness;

  const StudioLightingPreset(
    this.label,
    this.icon,
    this.exposure,
    this.shadowIntensity,
    this.shadowSoftness,
  );
}

/// Interactive photorealistic 3D GLB/GLTF renderer with realistic PBR lighting,
/// contact ground shadows, camera orbit/zoom controls, fuzzy animation mapping,
/// studio lighting environment switcher, and GPU-safe zero-alloc platform view stability.
class ThreeDModelView extends StatefulWidget {
  final CharacterModel character;
  final CharacterAnimation currentAnimation;
  final bool enableControls;
  final bool autoRotate;

  const ThreeDModelView({
    super.key,
    required this.character,
    required this.currentAnimation,
    this.enableControls = true,
    this.autoRotate = true,
  });

  @override
  State<ThreeDModelView> createState() => _ThreeDModelViewState();
}

class _ThreeDModelViewState extends State<ThreeDModelView> {
  WebViewController? _webViewController;
  StudioLightingPreset _activeLighting = StudioLightingPreset.studio;
  String _cameraOrbit = '0deg 75deg 105%';
  bool _isAutoRotateActive = true;

  @override
  void initState() {
    super.initState();
    _isAutoRotateActive = widget.autoRotate;
  }

  @override
  void didUpdateWidget(covariant ThreeDModelView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAnimation != widget.currentAnimation ||
        oldWidget.character.id != widget.character.id) {
      _updateModelViewerJs();
    }
  }

  /// Maps generic CharacterAnimation to specific named animation in the GLB
  String? _resolveAnimationName() {
    final available = widget.character.availableAnimations;
    if (available.isEmpty) return null;

    final targetName = widget.currentAnimation.name.toLowerCase();

    // 1. Walk & Run mappings
    if (targetName == 'walk') {
      final walkMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('walk') ||
            a.toLowerCase().contains('move_ing') ||
            a.toLowerCase().contains('run'),
        orElse: () => '',
      );
      if (walkMatch.isNotEmpty) return walkMatch;
    }
    if (targetName == 'run') {
      final runMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('run') ||
            a.toLowerCase().contains('move_ing') ||
            a.toLowerCase().contains('walk'),
        orElse: () => '',
      );
      if (runMatch.isNotEmpty) return runMatch;
    }

    // 2. Jump mappings
    if (targetName == 'jump') {
      final jumpMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('move_jump') ||
            a.toLowerCase().contains('jump'),
        orElse: () => '',
      );
      if (jumpMatch.isNotEmpty) return jumpMatch;
    }

    // 3. Fall & Impact mappings
    if (targetName == 'fall') {
      final fallMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('panic') ||
            a.toLowerCase().contains('vital_death') ||
            a.toLowerCase().contains('death') ||
            a.toLowerCase().contains('fall') ||
            a.toLowerCase().contains('kneel') ||
            a.toLowerCase().contains('sit'),
        orElse: () => '',
      );
      if (fallMatch.isNotEmpty) return fallMatch;
    }

    // 4. Sit & Sleep mappings
    if (targetName == 'sit') {
      final sitMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('kneel_idle') ||
            a.toLowerCase().contains('kneel') ||
            a.toLowerCase().contains('sit'),
        orElse: () => '',
      );
      if (sitMatch.isNotEmpty) return sitMatch;
    }
    if (targetName == 'sleep') {
      final sleepMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('kneel_idle') ||
            a.toLowerCase().contains('kneel') ||
            a.toLowerCase().contains('sit') ||
            a.toLowerCase().contains('death') ||
            a.toLowerCase().contains('idle'),
        orElse: () => '',
      );
      if (sleepMatch.isNotEmpty) return sleepMatch;
    }
    if (targetName == 'wakeup') {
      final wakeMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('stand') ||
            a.toLowerCase().contains('idle'),
        orElse: () => '',
      );
      if (wakeMatch.isNotEmpty) return wakeMatch;
    }

    // 5. Think mappings
    if (targetName == 'think') {
      final thinkMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('callsign') ||
            a.toLowerCase().contains('yes') ||
            a.toLowerCase().contains('no') ||
            a.toLowerCase().contains('idle'),
        orElse: () => '',
      );
      if (thinkMatch.isNotEmpty) return thinkMatch;
    }

    // 6. Dance mappings
    if (targetName == 'dance') {
      final danceMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('victory') ||
            a.toLowerCase().contains('exs') ||
            a.toLowerCase().contains('dance') ||
            a.toLowerCase().contains('jump'),
        orElse: () => '',
      );
      if (danceMatch.isNotEmpty) return danceMatch;
    }

    // 7. Idle mappings
    if (targetName == 'idle') {
      final idleMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('formation_idle') ||
            a.toLowerCase().contains('cafe_idle') ||
            a.toLowerCase().contains('stand_idle') ||
            a.toLowerCase().contains('idle') ||
            a.toLowerCase().contains('stand') ||
            a.toLowerCase().contains('survey'),
        orElse: () => '',
      );
      if (idleMatch.isNotEmpty) return idleMatch;
    }

    // 8. Tap / Reaction / Drag mappings
    if (targetName == 'tap' || targetName == 'drag') {
      final tapMatch = available.firstWhere(
        (a) =>
            a.toLowerCase().contains('pickup') ||
            a.toLowerCase().contains('reaction') ||
            a.toLowerCase().contains('wave') ||
            a.toLowerCase().contains('thumbsup') ||
            a.toLowerCase().contains('jump') ||
            a.toLowerCase().contains('yes'),
        orElse: () => '',
      );
      if (tapMatch.isNotEmpty) return tapMatch;
    }

    // 9. General substring match
    for (final anim in available) {
      final a = anim.toLowerCase();
      if (a == targetName || a.contains(targetName) || targetName.contains(a)) {
        return anim;
      }
    }

    return available.first;
  }

  void _updateModelViewerJs() {
    final animName = _resolveAnimationName();
    if (animName == null) return;
    _webViewController?.runJavaScript("""
      (function() {
        const mv = document.querySelector('model-viewer');
        if (mv) {
          mv.animationName = '$animName';
          mv.play();
        }
      })();
    """);
  }

  void _setCameraOrbit(String orbit) {
    setState(() {
      _cameraOrbit = orbit;
    });
    _webViewController?.runJavaScript("""
      (function() {
        const mv = document.querySelector('model-viewer');
        if (mv) {
          mv.cameraOrbit = '$orbit';
        }
      })();
    """);
  }

  void _setLighting(StudioLightingPreset preset) {
    setState(() {
      _activeLighting = preset;
    });
    _webViewController?.runJavaScript("""
      (function() {
        const mv = document.querySelector('model-viewer');
        if (mv) {
          mv.exposure = ${preset.exposure};
          mv.shadowIntensity = ${preset.shadowIntensity};
          mv.shadowSoftness = ${preset.shadowSoftness};
        }
      })();
    """);
  }

  void _toggleAutoRotate() {
    setState(() {
      _isAutoRotateActive = !_isAutoRotateActive;
    });
    _webViewController?.runJavaScript("""
      (function() {
        const mv = document.querySelector('model-viewer');
        if (mv) {
          mv.autoRotate = $_isAutoRotateActive;
        }
      })();
    """);
  }

  String _resolveSourcePath() {
    if (widget.character.isAsset) {
      return widget.character.assetPath;
    }
    final path = widget.character.assetPath;
    if (path.startsWith('file://')) {
      return path;
    }
    return File(path).uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAnimName = _resolveAnimationName();
    final hasAnimations =
        widget.character.hasEmbeddedAnimations && resolvedAnimName != null;
    final src = _resolveSourcePath();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Elegant Studio Backdrop Gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _getStudioGlowColor().withAlpha(45),
                  Colors.transparent,
                ],
                radius: 0.95,
              ),
            ),
          ),

          // Ground Contact Shadow & Pedestal Ring
          Positioned(
            bottom: 22,
            child: Container(
              width: 140,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // 3D Model Viewer with stable key and zero Mali alloc churn
          ModelViewer(
            key: ValueKey(widget.character.id),
            src: src,
            alt: widget.character.name,
            autoRotate: _isAutoRotateActive,
            autoRotateDelay: 0,
            rotationPerSecond: '16deg',
            cameraControls: widget.enableControls,
            ar: false,
            backgroundColor: Colors.transparent,
            exposure: _activeLighting.exposure,
            cameraOrbit: _cameraOrbit,
            animationName: resolvedAnimName,
            autoPlay: hasAnimations,
            animationCrossfadeDuration: 350,
            interactionPrompt: InteractionPrompt.none,
            loading: Loading.eager,
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _updateModelViewerJs();
            },
          ),

          // Top Floating Bar: Camera Controls & 360 Toggle (Overflow-Safe)
          if (widget.enableControls)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  // Interaction Hint Chip (Constrained to prevent overflow)
                  Flexible(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded,
                              color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              hasAnimations
                                  ? '3D • $resolvedAnimName'
                                  : '3D Realistic PBR',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Camera Angle & Orbit Quick Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCameraQuickBtn(
                        icon: Icons.person_outline_rounded,
                        tooltip: 'Portrait Close-Up',
                        onTap: () => _setCameraOrbit('0deg 85deg 70%'),
                      ),
                      const SizedBox(width: 6),
                      _buildCameraQuickBtn(
                        icon: Icons.accessibility_new_rounded,
                        tooltip: 'Full Body View',
                        onTap: () => _setCameraOrbit('0deg 75deg 110%'),
                      ),
                      const SizedBox(width: 6),
                      _buildCameraQuickBtn(
                        icon: _isAutoRotateActive
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_filled_rounded,
                        tooltip: _isAutoRotateActive
                            ? 'Pause Orbit'
                            : 'Resume 360° Orbit',
                        isActive: _isAutoRotateActive,
                        onTap: _toggleAutoRotate,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Bottom Bar: Realistic Studio Lighting Switcher (Overflow-Safe)
          Positioned(
            bottom: 8,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10, width: 0.8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: StudioLightingPreset.values.map((preset) {
                    final isSelected = _activeLighting == preset;
                    return InkWell(
                      onTap: () => _setLighting(preset),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              preset.icon,
                              size: 13,
                              color: isSelected
                                  ? AppColors.primaryPink
                                  : Colors.white60,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              preset.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white60,
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStudioGlowColor() {
    switch (_activeLighting) {
      case StudioLightingPreset.studio:
        return const Color(0xFF64B5F6);
      case StudioLightingPreset.goldenHour:
        return const Color(0xFFFFB74D);
      case StudioLightingPreset.cyberNeon:
        return const Color(0xFFE040FB);
      case StudioLightingPreset.porcelainSoft:
        return const Color(0xFFFF80AB);
    }
  }

  Widget _buildCameraQuickBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryPink : Colors.black.withAlpha(140),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white12, width: 0.8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 15,
        icon: Icon(icon, color: Colors.white),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
