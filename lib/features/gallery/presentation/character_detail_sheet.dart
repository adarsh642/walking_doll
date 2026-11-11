import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../characters/domain/character_model.dart';
import '../../characters/engines/two_d/two_d_character_engine.dart';
import '../../characters/presentation/controllers/doll_provider.dart';
import '../../characters/presentation/controllers/overlay_provider.dart';
import '../../characters/presentation/widgets/doll_stats_card.dart';

/// Detailed view modal sheet for character inspection.
/// Displays character lore, 3D skeletal specifications, animation capabilities,
/// and activation controls without overloading Mali GPU with concurrent WebViews.
class CharacterDetailSheet extends StatefulWidget {
  final CharacterModel doll;

  const CharacterDetailSheet({
    super.key,
    required this.doll,
  });

  static Future<void> show(BuildContext context, CharacterModel doll) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CharacterDetailSheet(doll: doll),
    );
  }

  @override
  State<CharacterDetailSheet> createState() => _CharacterDetailSheetState();
}

class _CharacterDetailSheetState extends State<CharacterDetailSheet> {
  TwoDCharacterEngine? _twoDEngine;

  @override
  void initState() {
    super.initState();
    if (widget.doll.type == CharacterType.twoD) {
      _twoDEngine = TwoDCharacterEngine();
      _twoDEngine!.loadCharacter(widget.doll);
    }
  }

  @override
  void dispose() {
    _twoDEngine?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final dollProvider = context.watch<DollProvider>();
    final overlayProvider = context.watch<OverlayProvider>();
    final isActive = dollProvider.activeDoll?.id == widget.doll.id;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preview Header Area
              _buildShowcaseHeader(context, isLight),
              const SizedBox(height: 16),

              // Metadata & Stats
              DollStatsCard(doll: widget.doll),
              const SizedBox(height: 16),

              // Animation Clips Tag Grid (if available)
              if (widget.doll.availableAnimations.isNotEmpty) ...[
                Text(
                  'SKELETAL ANIMATION CLIPS (${widget.doll.availableAnimations.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isLight
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.doll.availableAnimations.map((anim) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLight
                            ? AppColors.lightCardSubtle
                            : AppColors.darkCardSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.softLavender.withAlpha(80),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.motion_photos_on_rounded,
                              size: 13, color: AppColors.primaryPink),
                          const SizedBox(width: 4),
                          Text(
                            anim,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isLight
                                  ? AppColors.lightTextPrimary
                                  : AppColors.darkTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        await dollProvider.selectDoll(widget.doll);
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Selected "${widget.doll.name}" in 3D Stage!'),
                            backgroundColor: AppColors.primaryPurple,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(isActive
                          ? Icons.check_circle_rounded
                          : Icons.view_in_ar_rounded),
                      label: Text(isActive ? 'Current Active' : 'Interact in 3D'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive
                            ? AppColors.mintGreen
                            : AppColors.primaryPink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        await dollProvider.selectDoll(widget.doll);
                        await overlayProvider.startOverlay(widget.doll);
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Activated "${widget.doll.name}" on screen!'),
                            backgroundColor: AppColors.primaryPink,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_in_picture_alt_rounded),
                      label: const Text('Walk on Screen'),
                    ),
                  ),
                ],
              ),

              // Delete button if imported
              if (widget.doll.isImported) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      await dollProvider.deleteCharacter(widget.doll.id);
                      navigator.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Custom doll removed'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 18),
                    label: const Text('Remove Imported Doll',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShowcaseHeader(BuildContext context, bool isLight) {
    if (widget.doll.type == CharacterType.twoD && _twoDEngine != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightCard : AppColors.darkCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
            width: 1.2,
          ),
        ),
        child: _twoDEngine!.buildPreview(context),
      );
    }

    // 3D Character Hero Showcase Card
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPink.withAlpha(40),
            AppColors.primaryPurple.withAlpha(70),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.softLavender.withAlpha(100),
          width: 1.4,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 20,
            child: Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withAlpha(40),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getEmojiForDoll(),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(140),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.view_in_ar_rounded,
                        size: 13, color: AppColors.threeDBadge),
                    const SizedBox(width: 5),
                    Text(
                      widget.doll.hasEmbeddedAnimations
                          ? '3D Humanoid • ${widget.doll.availableAnimations.length} Skeletal Clips'
                          : '3D Humanoid Skeleton • PBR Shaders',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmojiForDoll() {
    final lower = '${widget.doll.id} ${widget.doll.name}'.toLowerCase();
    if (lower.contains('robot') || lower.contains('nexus')) return '🤖';
    if (lower.contains('anime') || lower.contains('chibi')) return '🌸';
    if (lower.contains('aria') || lower.contains('couture')) return '👗';
    if (lower.contains('fox') || lower.contains('spirit')) return '🦊';
    if (lower.contains('astro') || lower.contains('stella')) return '🚀';
    return '💎';
  }
}
