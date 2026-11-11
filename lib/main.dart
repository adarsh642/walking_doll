import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'features/characters/presentation/controllers/doll_provider.dart';
import 'features/characters/presentation/controllers/overlay_provider.dart';
import 'features/navigation/presentation/main_scaffold.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadPreferences();

  final dollProvider = DollProvider();
  await dollProvider.initialize();

  final overlayProvider = OverlayProvider();
  await overlayProvider.checkPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<DollProvider>.value(value: dollProvider),
        ChangeNotifierProvider<OverlayProvider>.value(value: overlayProvider),
      ],
      child: const WalkingDollApp(),
    ),
  );
}

class WalkingDollApp extends StatelessWidget {
  const WalkingDollApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const SplashScreen(),
    );
  }
}
