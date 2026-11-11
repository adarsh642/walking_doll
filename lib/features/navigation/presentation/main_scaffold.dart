import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../characters/presentation/controllers/doll_provider.dart';
import '../../characters/presentation/controllers/overlay_provider.dart';
import '../../gallery/presentation/gallery_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../settings/presentation/settings_screen.dart';

/// Clean, responsive Application Shell with a streamlined 3-tab layout:
/// Home (Stage & Overlay), Gallery (Companions & Import), and Settings.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoStartOverlay();
    });
  }

  Future<void> _checkAutoStartOverlay() async {
    final settings = context.read<SettingsProvider>();
    final overlay = context.read<OverlayProvider>();
    final doll = context.read<DollProvider>();

    await overlay.checkPermission();

    if (settings.autoStartOverlay && overlay.hasPermission && doll.activeDoll != null) {
      await overlay.startOverlay(doll.activeDoll!);
    }
  }

  void _navigateToIndex(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToGallery: () => _navigateToIndex(1)),
      const GalleryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: AppColors.primaryPink),
            label: 'Companion',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primaryPink),
            label: 'Gallery',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primaryPink),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
