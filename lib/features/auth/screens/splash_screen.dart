import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:version_1_0/features/auth/screens/login_screen.dart';
import 'package:version_1_0/core/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const SplashScreen({required this.onThemeChanged, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _firstLaunchKey = 'isFirstLaunch';

  static const List<Offset> _starPositions = <Offset>[
    Offset(0.08, 0.14),
    Offset(0.18, 0.27),
    Offset(0.31, 0.11),
    Offset(0.42, 0.21),
    Offset(0.56, 0.13),
    Offset(0.68, 0.29),
    Offset(0.79, 0.18),
    Offset(0.89, 0.24),
    Offset(0.12, 0.67),
    Offset(0.24, 0.78),
    Offset(0.46, 0.72),
    Offset(0.63, 0.84),
    Offset(0.75, 0.69),
    Offset(0.87, 0.81),
  ];

  bool _isFirstLaunch = true;
  bool _isLoadingState = true;

  @override
  void initState() {
    super.initState();
    _initializeStartupFlow();
  }

  Future<void> _initializeStartupFlow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

    if (!mounted) {
      return;
    }

    setState(() {
      _isFirstLaunch = isFirstLaunch;
      _isLoadingState = false;
    });

    if (!_isFirstLaunch) {
      _startReturningUserFlow();
    }
  }

  Future<void> _startReturningUserFlow() async {
    await Future.delayed(const Duration(seconds: 6));

    if (!mounted) {
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              MainScreen(onThemeChanged: widget.onThemeChanged),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              LoginScreen(onThemeChanged: widget.onThemeChanged),
        ),
      );
    }
  }

  Future<void> _handleLaunchPressed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            LoginScreen(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: ColoredBox(color: Color(0xFF0A192F))),
          ..._starPositions.map((Offset point) {
            return Positioned(
              left: size.width * point.dx,
              top: size.height * point.dy,
              child: Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo/app_logo.png',
                  height: 140,
                  width: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'NASA Explorer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Explore the universe using NASA's images and videos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 40),
                if (_isLoadingState)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  )
                else if (_isFirstLaunch)
                  FilledButton(
                    onPressed: _handleLaunchPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Launch'),
                  )
                else
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
