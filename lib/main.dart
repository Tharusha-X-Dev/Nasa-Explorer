import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/settings/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  static final RoundedRectangleBorder _materialButtonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: _materialButtonShape),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: _materialButtonShape),
      ),
    );
  }

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
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(onThemeChanged: _updateTheme),
    );
  }
}
