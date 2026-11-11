import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../characters/domain/character_model.dart';
import '../../characters/presentation/controllers/overlay_provider.dart';
import 'settings_provider.dart';

/// Settings Screen providing overlay permission handling, app preferences,
/// theme selection, animation speed configuration, and system information.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final overlayProvider = context.watch<OverlayProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
      ),
      body: SafeArea(
        child: ResponsiveLayout.constrainedContainer(
          maxWidth: 800,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // 1. Overlay Permission Status Card
              _buildPermissionCard(context, overlayProvider),
              const SizedBox(height: 16),

              // 2. Overlay Behavior Section
              _buildSectionHeader(context, 'Overlay Companion Behavior'),
              _buildSettingsCard(
                context,
                children: [
                  SwitchListTile(
                    title: const Text(AppStrings.autoStartTitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: const Text(
                      'Automatically launch the floating companion when app starts.',
                      style: TextStyle(fontSize: 11),
                    ),
                    value: settingsProvider.autoStartOverlay,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setAutoStartOverlay(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Default Character Engine', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: const Text('Preferred engine type for new companion overlays', style: TextStyle(fontSize: 11)),
                    trailing: SegmentedButton<CharacterType>(
                      segments: const [
                        ButtonSegment(value: CharacterType.twoD, label: Text('2D')),
                        ButtonSegment(value: CharacterType.threeD, label: Text('3D')),
                      ],
                      selected: {settingsProvider.defaultCharacterType},
                      onSelectionChanged: (set) {
                        if (set.isNotEmpty) {
                          settingsProvider.setDefaultCharacterType(set.first);
                        }
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Animation & Physics Section
              _buildSectionHeader(context, 'Animation & Micro-Interactions'),
              _buildSettingsCard(
                context,
                children: [
                  SwitchListTile(
                    title: const Text(AppStrings.touchInteractionTitle, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    subtitle: const Text('Show speech bubbles and bounce physics on tap', style: TextStyle(fontSize: 11)),
                    value: settingsProvider.enableTouchInteractions,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setEnableTouchInteractions(val),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.animSpeedTitle,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                        Text(
                          '${settingsProvider.animationSpeed.toStringAsFixed(1)}x',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryPink),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: settingsProvider.animationSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: AppColors.primaryPink,
                    onChanged: (v) => settingsProvider.setAnimationSpeed(v),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Appearance / Theme
              _buildSectionHeader(context, 'Appearance'),
              _buildSettingsCard(
                context,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.themeTitle,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_rounded),
                              label: Text('System'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_rounded),
                              label: Text('Light'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_rounded),
                              label: Text('Dark'),
                            ),
                          ],
                          selected: {settingsProvider.themeMode},
                          onSelectionChanged: (set) {
                            if (set.isNotEmpty) {
                              settingsProvider.setThemeMode(set.first);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. About & Version Section
              _buildSectionHeader(context, 'About & Architecture'),
              _buildSettingsCard(
                context,
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.cuteHeroGradient,
                      ),
                      child: const Text('🎀', style: TextStyle(fontSize: 18)),
                    ),
                    title: const Text('Walking Doll MVP', style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('Version 1.0.0 • Production Build', style: TextStyle(fontSize: 11)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      AppStrings.aboutDesc,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, OverlayProvider overlayProvider) {
    final isGranted = overlayProvider.hasPermission;
    final color = isGranted ? AppColors.mintGreen : const Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(100), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle_rounded : Icons.security_rounded,
                color: color,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.overlayPermissionTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isGranted ? 'GRANTED' : 'REQUIRED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isGranted
                ? AppStrings.overlayPermissionGranted
                : AppStrings.overlayPermissionRequired,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'Android requires the "Display over other apps" permission so your virtual doll can float and accompany you across all applications.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (!isGranted) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => overlayProvider.requestPermission(),
              icon: const Icon(Icons.verified_user_rounded),
              label: const Text(AppStrings.grantPermissionBtn),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
