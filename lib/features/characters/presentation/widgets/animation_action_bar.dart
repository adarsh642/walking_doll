import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/character_animation.dart';

/// Interactive game-character animation action bar with primary states
/// and secondary locomotion/emotes (Run, Jump, Sit, Sleep, Think, Fall).
class AnimationActionBar extends StatelessWidget {
  final CharacterAnimation currentAnimation;
  final ValueChanged<CharacterAnimation> onAnimationSelected;

  const AnimationActionBar({
    super.key,
    required this.currentAnimation,
    required this.onAnimationSelected,
  });

  @override
  Widget build(BuildContext context) {
    const primaryActions = [
      CharacterAnimation.idle,
      CharacterAnimation.walk,
      CharacterAnimation.dance,
      CharacterAnimation.tap,
    ];

    const extendedActions = [
      CharacterAnimation.run,
      CharacterAnimation.jump,
      CharacterAnimation.sit,
      CharacterAnimation.think,
      CharacterAnimation.sleep,
      CharacterAnimation.fall,
    ];

    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isLight ? 12 : 35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Actions Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: primaryActions.map((anim) {
              final isSelected = currentAnimation == anim;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.cuteHeroGradient : null,
                      color: isSelected
                          ? null
                          : (isLight
                              ? AppColors.lightCardSubtle
                              : AppColors.darkCardSubtle),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryPink.withAlpha(70),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onAnimationSelected(anim),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                anim.icon,
                                size: 19,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.softLavender,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                anim.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : (isLight
                                          ? AppColors.lightTextPrimary
                                          : AppColors.darkTextPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Extended Quick Emotes Scroll Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: extendedActions.map((anim) {
                final isSelected = currentAnimation == anim;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onAnimationSelected(anim),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : (isLight
                                ? AppColors.lightCardSubtle
                                : AppColors.darkCardSubtle),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : (isLight
                                  ? AppColors.lightBorder
                                  : AppColors.darkBorder),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            anim.icon,
                            size: 13,
                            color: isSelected ? Colors.white : AppColors.softLavender,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            anim.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isLight
                                      ? AppColors.lightTextSecondary
                                      : AppColors.darkTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
