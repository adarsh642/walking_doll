import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/character_animation.dart';
import '../../domain/character_model.dart';

/// Frame-by-frame sprite sheet renderer with configurable columns, rows, and FPS.
class TwoDSpriteView extends StatefulWidget {
  final CharacterModel character;
  final CharacterAnimation currentAnimation;
  final VoidCallback? onTap;

  const TwoDSpriteView({
    super.key,
    required this.character,
    required this.currentAnimation,
    this.onTap,
  });

  @override
  State<TwoDSpriteView> createState() => _TwoDSpriteViewState();
}

class _TwoDSpriteViewState extends State<TwoDSpriteView>
    with SingleTickerProviderStateMixin {
  ui.Image? _spriteImage;
  bool _isLoading = true;
  String? _errorMessage;

  Timer? _frameTimer;
  int _currentFrame = 0;
  int _totalFrames = 1;

  late AnimationController _physicsController;

  @override
  void initState() {
    super.initState();
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _totalFrames = widget.character.columns * widget.character.rows;
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant TwoDSpriteView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character.assetPath != widget.character.assetPath ||
        oldWidget.character.columns != widget.character.columns ||
        oldWidget.character.rows != widget.character.rows) {
      _totalFrames = widget.character.columns * widget.character.rows;
      _loadImage();
    } else if (oldWidget.character.fps != widget.character.fps) {
      _startFrameTimer();
    }

    if (oldWidget.currentAnimation != widget.currentAnimation) {
      if (widget.currentAnimation == CharacterAnimation.tap) {
        _physicsController.forward(from: 0.0);
      }
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ImageProvider provider = widget.character.isAsset
          ? AssetImage(widget.character.assetPath)
          : FileImage(File(widget.character.assetPath)) as ImageProvider;

      final ImageStream stream = provider.resolve(ImageConfiguration.empty);
      late ImageStreamListener listener;
      final completer = Completer<ui.Image>();

      listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info.image);
          stream.removeListener(listener);
        },
        onError: (dynamic error, StackTrace? stack) {
          completer.completeError(error);
          stream.removeListener(listener);
        },
      );

      stream.addListener(listener);
      final img = await completer.future;

      if (mounted) {
        setState(() {
          _spriteImage = img;
          _isLoading = false;
        });
        _startFrameTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load sprite sheet: $e';
        });
      }
    }
  }

  void _startFrameTimer() {
    _frameTimer?.cancel();
    if (_totalFrames <= 1) return;

    // Adjust playback speed based on animation state
    double speedMultiplier = 1.0;
    if (widget.currentAnimation == CharacterAnimation.walk) {
      speedMultiplier = 1.3;
    } else if (widget.currentAnimation == CharacterAnimation.dance) {
      speedMultiplier = 1.8;
    } else if (widget.currentAnimation == CharacterAnimation.idle) {
      speedMultiplier = 0.8;
    }

    final int effectiveFps = (widget.character.fps * speedMultiplier).round().clamp(1, 60);
    final int intervalMs = (1000 / effectiveFps).round();

    _frameTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (mounted && _spriteImage != null) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % _totalFrames;
        });
      }
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _physicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2.5),
      );
    }

    if (_errorMessage != null || _spriteImage == null) {
      return Center(
        child: Text(
          _errorMessage ?? 'Sprite unavailable',
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _physicsController.forward(from: 0.0);
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _physicsController,
        builder: (context, child) {
          final scale = 1.0 + (0.15 * (1.0 - (_physicsController.value - 0.5).abs() * 2));
          return Transform.scale(
            scale: scale,
            child: CustomPaint(
              painter: _SpriteSheetPainter(
                image: _spriteImage!,
                frameIndex: _currentFrame,
                columns: widget.character.columns,
                rows: widget.character.rows,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class _SpriteSheetPainter extends CustomPainter {
  final ui.Image image;
  final int frameIndex;
  final int columns;
  final int rows;

  _SpriteSheetPainter({
    required this.image,
    required this.frameIndex,
    required this.columns,
    required this.rows,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int safeCols = columns.clamp(1, 100);
    final int safeRows = rows.clamp(1, 100);

    final double frameWidth = image.width / safeCols;
    final double frameHeight = image.height / safeRows;

    final int col = frameIndex % safeCols;
    final int row = (frameIndex ~/ safeCols) % safeRows;

    final Rect srcRect = Rect.fromLTWH(
      col * frameWidth,
      row * frameHeight,
      frameWidth,
      frameHeight,
    );

    // Fit inside canvas preserving aspect ratio
    final double scale = (size.width / frameWidth).clamp(0.0, size.height / frameHeight);
    final double destW = frameWidth * scale;
    final double destH = frameHeight * scale;
    final double dx = (size.width - destW) / 2;
    final double dy = (size.height - destH) / 2;

    final Rect destRect = Rect.fromLTWH(dx, dy, destW, destH);

    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    canvas.drawImageRect(image, srcRect, destRect, paint);
  }

  @override
  bool shouldRepaint(covariant _SpriteSheetPainter oldDelegate) {
    return oldDelegate.frameIndex != frameIndex ||
        oldDelegate.image != image ||
        oldDelegate.columns != columns ||
        oldDelegate.rows != rows;
  }
}

