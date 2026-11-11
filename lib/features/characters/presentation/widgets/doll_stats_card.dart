import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/character_model.dart';
import 'doll_type_badge.dart';

/// Card presenting active doll metadata: level, mood, companionship meter,
/// and AI generation readiness badge.
class DollStatsCard extends StatelessWidget {
  final CharacterModel doll;

  const DollStatsCard({
    super.key,
    required this.doll,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doll.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doll.description.isNotEmpty
                          ? doll.description
                          : 'Your faithful virtual walking companion',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              DollTypeBadge(type: doll.type),
            ],
          ),
          const SizedBox(height: 14),

          // Mood & Level row
          Row(
            children: [
              _buildStatChip(
                context,
                icon: Icons.sentiment_satisfied_alt_rounded,
                label: 'Mood',
                value: doll.mood,
                color: AppColors.primaryPink,
              ),
              const SizedBox(width: 10),
              _buildStatChip(
                context,
                icon: Icons.military_tech_rounded,
                label: 'Companion Lvl',
                value: 'Lvl ${doll.level}',
                color: AppColors.pastelYellow,
              ),
            ],
          ),
          if (doll.type == CharacterType.threeD) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip(
                  context,
                  icon: Icons.accessibility_new_rounded,
                  label: 'Skeletal Rig',
                  value: doll.hasEmbeddedAnimations
                      ? '${doll.availableAnimations.length} Motion Clips'
                      : 'Humanoid Skeleton',
                  color: AppColors.skyBlue,
                ),
                const SizedBox(width: 10),
                _buildStatChip(
                  context,
                  icon: Icons.blur_linear_rounded,
                  label: '3D Materials',
                  value: 'PBR Shaders',
                  color: AppColors.threeDBadge,
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // Bond Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Affection Bond',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                ),
              ),
              Text(
                '${(doll.experience * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: doll.experience,
              minHeight: 8,
              backgroundColor: isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

