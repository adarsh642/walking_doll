import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/character_model.dart';

/// Cute pill badge indicating 2D or 3D engine type.
class DollTypeBadge extends StatelessWidget {
  final CharacterType type;
  final bool isMini;

  const DollTypeBadge({
    super.key,
    required this.type,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    final is2D = type == CharacterType.twoD;
    final color = is2D ? AppColors.twoDBadge : AppColors.threeDBadge;
    final icon = is2D ? Icons.auto_awesome_rounded : Icons.view_in_ar_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMini ? 6 : 10,
        vertical: isMini ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(90), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMini ? 11 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: isMini ? 10 : 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

