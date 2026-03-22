import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  const SplashScreen({required this.onThemeChanged, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future.delayed(const Duration(seconds: 6));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            HomeScreen(onThemeChanged: widget.onThemeChanged),
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
                  'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
                  height: 150,
                  width: 150,
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
                  'Preparing the Cosmos...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 40),
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
