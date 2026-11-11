import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../characters/presentation/controllers/doll_provider.dart';
import '../../characters/presentation/controllers/overlay_provider.dart';
import '../../characters/presentation/widgets/animation_action_bar.dart';
import '../../characters/presentation/widgets/doll_stats_card.dart';
import '../../characters/presentation/widgets/doll_type_badge.dart';

/// Main Home Screen featuring active doll preview, animation triggers,
/// and overlay activation controls.
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToGallery;

  const HomeScreen({
    super.key,
    required this.onNavigateToGallery,
  });

  @override
  Widget build(BuildContext context) {
    final dollProvider = context.watch<DollProvider>();
    final overlayProvider = context.watch<OverlayProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;
    final activeDoll = dollProvider.activeDoll;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.cuteHeroGradient,
              ),
              child: const Center(
                child: Text('🎀', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(AppStrings.appName),
          ],
        ),
        actions: [
          // Overlay Status Indicator Pill
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: overlayProvider.isOverlayActive
                    ? AppColors.mintGreen.withAlpha(30)
                    : (isLight ? AppColors.lightCardSubtle : AppColors.darkCardSubtle),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: overlayProvider.isOverlayActive
                      ? AppColors.mintGreen
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: overlayProvider.isOverlayActive
                          ? AppColors.mintGreen
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    overlayProvider.isOverlayActive
                        ? 'Overlay On'
                        : 'Standby',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: overlayProvider.isOverlayActive
                          ? AppColors.mintGreen
                          : (isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: dollProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : activeDoll == null
                ? _buildEmptyState(context)
                : ResponsiveLayout.constrainedContainer(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: [
                        // Overlay Permission Alert Banner if not granted
                        if (!overlayProvider.hasPermission)
                          _buildPermissionBanner(context, overlayProvider),

                        // Active Doll Main Stage Card
                        _buildDollStage(context, dollProvider, overlayProvider),
                        const SizedBox(height: 16),

                        // Animation Triggers Bar (Idle, Walk, Dance)
                        AnimationActionBar(
                          currentAnimation: dollProvider.currentAnimation,
                          onAnimationSelected: (anim) {
                            dollProvider.playAnimation(anim);
                            overlayProvider.updateAnimation(anim);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Primary Overlay Action Toggle
                        _buildOverlayActionCard(context, dollProvider, overlayProvider),
                        const SizedBox(height: 16),

                        // Doll Mood & Stats Card
                        DollStatsCard(doll: activeDoll),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildDollStage(
    BuildContext context,
    DollProvider dollProvider,
    OverlayProvider overlayProvider,
  ) {
    final doll = dollProvider.activeDoll!;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final stageHeight = ResponsiveLayout.getDollPreviewHeight(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withAlpha(isLight ? 25 : 45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header inside stage
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doll.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
                        ),
                      ),
                      Text(
                        '${doll.mood} • Tap to interact',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
          ),

          // Doll Preview Viewport (renders 2D or 3D engine strictly through abstraction)
          SizedBox(
            height: stageHeight,
            width: double.infinity,
            child: dollProvider.activeEngine != null
                ? dollProvider.activeEngine!.buildPreview(context)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayActionCard(
    BuildContext context,
    DollProvider dollProvider,
    OverlayProvider overlayProvider,
  ) {
    final isRunning = overlayProvider.isOverlayActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isRunning
            ? const LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
              )
            : AppColors.cuteHeroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isRunning ? Colors.green : AppColors.primaryPink).withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRunning ? Icons.visibility_off_rounded : Icons.open_in_new_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRunning ? 'Overlay is Walking!' : 'Walk on Screen',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  isRunning
                    ? 'Doll is walking over other apps. Tap to hide.'
                    : 'Spawn your doll companion as a floating widget.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              overlayProvider.toggleOverlay(dollProvider.activeDoll!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: isRunning ? Colors.green.shade800 : AppColors.primaryPink,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              isRunning ? 'Hide' : 'Activate',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(BuildContext context, OverlayProvider overlayProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 26),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overlay Permission Required',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFFE65100),
                  ),
                ),
                Text(
                  'Grant permission to let your doll walk over any app.',
                  style: TextStyle(fontSize: 11, color: Color(0xFFBF360C)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => overlayProvider.requestPermission(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            child: const Text('Grant'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧸', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              AppStrings.noDollSelected,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a cute 2D or 3D doll from your gallery to start walking!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onNavigateToGallery,
              icon: const Icon(Icons.collections_rounded),
              label: const Text(AppStrings.pickFromGallery),
            ),
          ],
        ),
      ),
    );
  }
}
