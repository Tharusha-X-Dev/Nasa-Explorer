import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/settings_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NasaExplorerApp());
}

class NasaExplorerApp extends StatelessWidget {
  const NasaExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NasaExplorerAppView();
  }
}

class _NasaExplorerAppView extends StatefulWidget {
  const _NasaExplorerAppView();

  @override
  State<_NasaExplorerAppView> createState() => _NasaExplorerAppViewState();
}

class _NasaExplorerAppViewState extends State<_NasaExplorerAppView> {
  final SettingsService _settingsService = SettingsService();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final bool value = await _settingsService.getDarkMode();

    if (!mounted) {
      return;
    }

    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _updateTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    await _settingsService.setDarkMode(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NASA Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(onThemeChanged: _updateTheme),
    );
  }
}
