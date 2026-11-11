import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/character_model.dart';
import 'doll_type_badge.dart';

/// Card widget displayed in the Gallery grid.
/// Shows preview thumbnail, doll name, type badge, active status,
/// and animation capabilities (e.g. "Sprite Sheet", "GLB 3D", "Procedural 2D").
class DollCard extends StatelessWidget {
  final CharacterModel doll;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  const DollCard({
    super.key,
    required this.doll,
    required this.isActive,
    required this.onTap,
    required this.onSelect,
  });

  String _getCapabilityText() {
    if (doll.type == CharacterType.threeD) {
      if (doll.hasEmbeddedAnimations) {
        return '3D • ${doll.availableAnimations.length} Anims';
      }
      return '3D GLB • Orbit Idle';
    } else {
      if (doll.isSpriteSheet) {
        return 'Sprite-Sheet (${doll.columns}x${doll.rows})';
      }
      return '2D Physics • Tap Pop';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? AppColors.primaryPink
              : (isLight ? AppColors.lightBorder : AppColors.darkBorder),
          width: isActive ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppColors.primaryPink.withAlpha(45)
                : Colors.black.withAlpha(isLight ? 8 : 25),
            blurRadius: isActive ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Type Badge + Active Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DollTypeBadge(type: doll.type, isMini: true),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else if (doll.isImported)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.softLavender.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'IMPORTED',
                          style: TextStyle(
                            color: AppColors.softLavender,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Preview Thumbnail Area
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'doll_preview_${doll.id}',
                      child: _buildThumbnail(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Doll Name
                Text(
                  doll.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 3),

                // Capability Indicator
                Row(
                  children: [
                    Icon(
                      doll.type == CharacterType.threeD
                          ? Icons.view_in_ar_rounded
                          : Icons.animation_rounded,
                      size: 12,
                      color: AppColors.softLavender,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getCapabilityText(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _Doll3DVisuals _get3DCardVisuals() {
    final lower = '${doll.id} ${doll.name}'.toLowerCase();
    if (lower.contains('anime') || lower.contains('chibi')) {
      return const _Doll3DVisuals(
        emoji: '🌸',
        badge: '3D ANIME GAME',
        gradientColors: [Color(0xFFFF80AB), Color(0xFF7C4DFF)],
        glowColor: Color(0xFFFF4081),
      );
    }
    if (lower.contains('aria') || lower.contains('couture') || lower.contains('brunette')) {
      return const _Doll3DVisuals(
        emoji: '👗',
        badge: 'REALISTIC 3D',
        gradientColors: [Color(0xFFF3C68F), Color(0xFF8E24AA)],
        glowColor: Color(0xFFAB47BC),
      );
    }
    if (lower.contains('robot') || lower.contains('nexus')) {
      return const _Doll3DVisuals(
        emoji: '🤖',
        badge: '14 ANIMS',
        gradientColors: [Color(0xFF00E5FF), Color(0xFF1565C0)],
        glowColor: Color(0xFF00E5FF),
      );
    }
    if (lower.contains('fox') || lower.contains('kitsune') || lower.contains('spirit')) {
      return const _Doll3DVisuals(
        emoji: '🦊',
        badge: 'RIGGED 3D',
        gradientColors: [Color(0xFFFF9100), Color(0xFFD81B60)],
        glowColor: Color(0xFFFF9100),
      );
    }
    if (lower.contains('astro') || lower.contains('stella')) {
      return const _Doll3DVisuals(
        emoji: '🚀',
        badge: 'PBR SUIT',
        gradientColors: [Color(0xFF536DFE), Color(0xFFFFB300)],
        glowColor: Color(0xFF536DFE),
      );
    }
    if (lower.contains('avaturn') || lower.contains('nova')) {
      return const _Doll3DVisuals(
        emoji: '🌟',
        badge: 'LIFELIKE',
        gradientColors: [Color(0xFF00B0FF), Color(0xFF00BFA5)],
        glowColor: Color(0xFF00B0FF),
      );
    }
    return const _Doll3DVisuals(
      emoji: '💎',
      badge: '3D GLB',
      gradientColors: [Color(0xFF64B5F6), Color(0xFFBA68C8)],
      glowColor: Color(0xFF64B5F6),
    );
  }

  Widget _buildThumbnail() {
    if (doll.type == CharacterType.threeD) {
      final visual = _get3DCardVisuals();
      return Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: visual.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: visual.glowColor.withAlpha(85),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pedestal rim
            Positioned(
              bottom: 12,
              child: Container(
                width: 48,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(65),
                ),
              ),
            ),
            // Character visual emoji
            Text(visual.emoji, style: const TextStyle(fontSize: 34)),
            // 3D Tag Pill
            Positioned(
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visual.badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (doll.isAsset) {
      return Image.asset(
        doll.assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(Icons.pets_rounded, size: 40, color: AppColors.primaryPink),
      );
    } else {
      return Image.file(
        File(doll.assetPath),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported_rounded, size: 40, color: AppColors.primaryPink),
      );
    }
  }
}

class _Doll3DVisuals {
  final String emoji;
  final String badge;
  final List<Color> gradientColors;
  final Color glowColor;

  const _Doll3DVisuals({
    required this.emoji,
    required this.badge,
    required this.gradientColors,
    required this.glowColor,
  });
}
