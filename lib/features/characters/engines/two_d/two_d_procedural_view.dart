import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/character_animation.dart';
import '../../domain/character_model.dart';

/// Interactive procedural 2D doll view supporting PNG/GIF characters
/// with micro-physics, tap reactions, particle effects, and gesture physics.
class TwoDProceduralView extends StatefulWidget {
  final CharacterModel character;
  final CharacterAnimation currentAnimation;
  final VoidCallback? onTap;

  const TwoDProceduralView({
    super.key,
    required this.character,
    required this.currentAnimation,
    this.onTap,
  });

  @override
  State<TwoDProceduralView> createState() => _TwoDProceduralViewState();
}

class _TwoDProceduralViewState extends State<TwoDProceduralView>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _walkController;
  late AnimationController _danceController;
  late AnimationController _tapController;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  String? _speechBubbleText;
  DateTime? _speechBubbleExpiry;

  final List<Offset> _particleOffsets = [];

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _danceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _updateAnimationControllers(widget.currentAnimation);
  }

  @override
  void didUpdateWidget(covariant TwoDProceduralView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAnimation != widget.currentAnimation) {
      _updateAnimationControllers(widget.currentAnimation);
    }
  }

  void _updateAnimationControllers(CharacterAnimation anim) {
    _walkController.stop();
    _danceController.stop();

    switch (anim) {
      case CharacterAnimation.walk:
        _walkController.repeat(reverse: true);
        break;
      case CharacterAnimation.dance:
        _danceController.repeat(reverse: true);
        break;
      case CharacterAnimation.tap:
        _triggerTapReaction();
        break;
      case CharacterAnimation.drag:
      case CharacterAnimation.idle:
      default:
        break;
    }
  }

  void _triggerTapReaction() {
    _tapController.forward(from: 0.0);
    final cutePhrases = [
      '♥ Hi friend!',
      '(◕‿◕) Yay!',
      '✨ Let\'s walk!',
      '⭐ You\'re awesome!',
      '♫ Happy day!',
    ];
    setState(() {
      _speechBubbleText = cutePhrases[math.Random().nextInt(cutePhrases.length)];
      _speechBubbleExpiry = DateTime.now().add(const Duration(seconds: 2));

      // Spawn heart particles
      _particleOffsets.clear();
      for (int i = 0; i < 5; i++) {
        _particleOffsets.add(Offset(
          (math.Random().nextDouble() - 0.5) * 80,
          -20 - math.Random().nextDouble() * 60,
        ));
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && DateTime.now().isAfter(_speechBubbleExpiry ?? DateTime.now())) {
        setState(() {
          _speechBubbleText = null;
          _particleOffsets.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _idleController.dispose();
    _walkController.dispose();
    _danceController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _idleController,
        _walkController,
        _danceController,
        _tapController,
      ]),
      builder: (context, child) {
        double translationY = 0.0;
        double rotation = 0.0;
        double scaleX = 1.0;
        double scaleY = 1.0;

        // Base Idle breathing
        translationY += math.sin(_idleController.value * math.pi) * -8.0;
        scaleY += (_idleController.value - 0.5) * 0.04;

        // Walk mode
        if (_walkController.isAnimating) {
          translationY += math.sin(_walkController.value * math.pi * 2) * -12.0;
          rotation += math.sin(_walkController.value * math.pi * 2) * 0.12;
        }

        // Dance mode
        if (_danceController.isAnimating) {
          translationY += math.sin(_danceController.value * math.pi * 2) * -26.0;
          rotation += math.sin(_danceController.value * math.pi * 2) * 0.28;
          scaleX += math.sin(_danceController.value * math.pi * 2) * 0.12;
          scaleY -= math.sin(_danceController.value * math.pi * 2) * 0.12;
        }

        // Tap mode
        if (_tapController.isAnimating) {
          final t = _tapController.value;
          scaleX = 1.0 + (math.sin(t * math.pi) * 0.25);
          scaleY = 1.0 + (math.sin(t * math.pi) * 0.25);
          translationY -= math.sin(t * math.pi) * 16.0;
        }

        // Drag displacement
        if (_isDragging) {
          translationY += _dragOffset.dy;
          rotation += (_dragOffset.dx * 0.003).clamp(-0.25, 0.25);
        }

        return GestureDetector(
          onTap: () {
            _triggerTapReaction();
            widget.onTap?.call();
          },
          onPanStart: (_) {
            setState(() {
              _isDragging = true;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              _dragOffset += details.delta;
            });
          },
          onPanEnd: (_) {
            setState(() {
              _isDragging = false;
              _dragOffset = Offset.zero;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Dynamic Drop Shadow
              Positioned(
                bottom: 24,
                child: Container(
                  width: 80 * scaleX * (_isDragging ? 0.7 : 1.0),
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((40 * (1.0 - (translationY.abs() / 100).clamp(0.0, 0.6))).toInt()),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),

              // Doll Character
              Transform.translate(
                offset: Offset(_isDragging ? _dragOffset.dx : 0.0, translationY),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: scaleY,
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: widget.character.isAsset
                          ? Image.asset(
                              widget.character.assetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildErrorPlaceholder(),
                            )
                          : Image.file(
                              File(widget.character.assetPath),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildErrorPlaceholder(),
                            ),
                    ),
                  ),
                ),
              ),

              // Speech Bubble
              if (_speechBubbleText != null)
                Positioned(
                  top: 20 + translationY,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _speechBubbleText != null ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryPink, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withAlpha(50),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        _speechBubbleText!,
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),

              // Heart & Sparkle Particles
              ..._particleOffsets.map((offset) {
                return Positioned(
                  top: 80 + offset.dy + translationY,
                  left: 100 + offset.dx,
                  child: const Text('✨', style: TextStyle(fontSize: 16)),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPink.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, color: AppColors.primaryPink, size: 38),
            SizedBox(height: 6),
            Text('Image not found', style: TextStyle(fontSize: 11, color: AppColors.primaryPink)),
          ],
        ),
      ),
    );
  }
}

