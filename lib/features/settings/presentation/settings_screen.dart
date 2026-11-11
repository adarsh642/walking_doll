import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../characters/presentation/controllers/doll_provider.dart';
import '../../characters/presentation/controllers/overlay_provider.dart';
import 'settings_provider.dart';

/// Redesigned, comprehensive Settings Screen featuring categorized sections:
/// Overlay Controls, Smoothness & Performance, Behavior & Physics,
/// Appearance, and Diagnostics.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final overlayProvider = context.watch<OverlayProvider>();
    final dollProvider = context.watch<DollProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset all settings to defaults',
            onPressed: () => _confirmReset(context, settingsProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout.constrainedContainer(
          maxWidth: 800,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // 1. Overlay Permission Status Card
              _buildPermissionCard(context, overlayProvider),
              const SizedBox(height: 20),

              // 2. Floating Companion Overlay Section
              _buildSectionHeader(context, 'Floating Companion Overlay', Icons.open_in_new_rounded),
              _buildSettingsCard(
                context,
                children: [
                  // Quick Overlay Toggle
                  SwitchListTile(
                    title: const Text(
                      'Floating Overlay Active',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: Text(
                      overlayProvider.isOverlayActive
                          ? 'Companion is walking across other applications'
                          : 'Turn on to let companion walk on top of your screen',
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    value: overlayProvider.isOverlayActive,
                    activeThumbColor: AppColors.mintGreen,
                    onChanged: (val) {
                      if (dollProvider.activeDoll != null) {
                        overlayProvider.toggleOverlay(dollProvider.activeDoll!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a doll from Gallery first.')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),

                  // Auto Start Overlay
                  SwitchListTile(
                    title: const Text(
                      'Auto-Start on Launch',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Automatically launch the floating companion when app opens',
                      style: TextStyle(fontSize: 11.5),
                    ),
                    value: settingsProvider.autoStartOverlay,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setAutoStartOverlay(val),
                  ),
                  const Divider(height: 1),

                  // Overlay Companion Scale
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Companion Size Scale',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(settingsProvider.overlayScale * 100).toInt()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: settingsProvider.overlayScale,
                    min: 0.7,
                    max: 1.4,
                    divisions: 7,
                    activeColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setOverlayScale(val),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Smoothness & Performance Section
              _buildSectionHeader(context, 'Smoothness & Performance', Icons.speed_rounded),
              _buildSettingsCard(
                context,
                children: [
                  SwitchListTile(
                    title: const Text(
                      'High-Performance Smooth Mode',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Maximizes frame rate and disables heavy shadow blur for silky 60 FPS rendering',
                      style: TextStyle(fontSize: 11.5),
                    ),
                    value: settingsProvider.highPerformanceMode,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setHighPerformanceMode(val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'Haptic Feedback',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Gentle vibration when interacting with your companion',
                      style: TextStyle(fontSize: 11.5),
                    ),
                    value: settingsProvider.hapticFeedback,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setHapticFeedback(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.primaryPink, size: 22),
                    title: const Text(
                      'Clear Engine Cache',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Frees graphics memory and reloads assets cleanly',
                      style: TextStyle(fontSize: 11.5),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Graphics cache cleared successfully.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. Behavior & Physics Section
              _buildSectionHeader(context, 'Behavior & Micro-Interactions', Icons.psychology_rounded),
              _buildSettingsCard(
                context,
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Screen Boundary Roaming',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Companion patrols across screen edges with natural turns',
                      style: TextStyle(fontSize: 11.5),
                    ),
                    value: settingsProvider.boundaryPatrol,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setBoundaryPatrol(val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'Touch Reactions & Speech Bubbles',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Show cute thoughts and bounce physics on tap',
                      style: TextStyle(fontSize: 11.5),
                    ),
                    value: settingsProvider.enableTouchInteractions,
                    activeThumbColor: AppColors.primaryPink,
                    onChanged: (val) => settingsProvider.setEnableTouchInteractions(val),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Locomotion & Animation Speed',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
              const SizedBox(height: 20),

              // 5. Appearance Section
              _buildSectionHeader(context, 'Appearance', Icons.palette_rounded),
              _buildSettingsCard(
                context,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Theme Mode',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 6. About & Information
              _buildSectionHeader(context, 'About Companion', Icons.info_outline_rounded),
              _buildSettingsCard(
                context,
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.cuteHeroGradient,
                      ),
                      child: const Center(
                        child: Text('🎀', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    title: const Text('Living Doll Companion', style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: const Text('Version 1.0.0 • High-Performance 3D Engine', style: TextStyle(fontSize: 11)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Living Doll brings real-time 3D game-quality characters directly to your mobile screen with autonomous roaming, physical boundaries, and interactive micro-animations.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                        height: 1.4,
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.primaryPink,
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
            ),
          ),
        ],
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
                  'Display Over Other Apps',
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
                  isGranted ? 'READY' : 'ACTION REQUIRED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isGranted
                ? 'Overlay permission is active. Your doll can walk freely on top of any app!'
                : 'Android requires "Display over other apps" permission so your virtual doll can float over other applications.',
            style: const TextStyle(fontSize: 12),
          ),
          if (!isGranted) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => overlayProvider.requestPermission(),
              icon: const Icon(Icons.verified_user_rounded),
              label: const Text('Grant Overlay Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text('This will restore all preferences and controls to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings restored to defaults.')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
