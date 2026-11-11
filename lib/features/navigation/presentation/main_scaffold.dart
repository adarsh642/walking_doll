import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../characters/presentation/controllers/doll_provider.dart';
import '../../characters/presentation/controllers/overlay_provider.dart';
import '../../gallery/presentation/gallery_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../import/presentation/import_screen.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../settings/presentation/settings_screen.dart';

/// Main Application Shell hosting Material 3 NavigationBar and tabs.
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
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToGallery: () => _navigateToIndex(1)),
      const GalleryScreen(),
      ImportScreen(onImportSuccess: () => _navigateToIndex(0)),
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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryPink),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_outlined),
            selectedIcon: Icon(Icons.collections_rounded, color: AppColors.primaryPink),
            label: AppStrings.navGallery,
          ),
          NavigationDestination(
            icon: Icon(Icons.add_photo_alternate_outlined),
            selectedIcon: Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryPink),
            label: AppStrings.navImport,
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded, color: AppColors.primaryPink),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}

