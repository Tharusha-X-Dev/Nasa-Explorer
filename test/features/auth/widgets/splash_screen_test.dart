import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_1_0/features/auth/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashScreen UI', () {
    testWidgets('shows NASA Explorer and Launch button', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'isFirstLaunch': true,
      });

      await tester.pumpWidget(
        MaterialApp(home: SplashScreen(onThemeChanged: (_) {})),
      );

      await tester.pump();

      expect(find.text('NASA Explorer'), findsOneWidget);
      expect(find.text('Launch'), findsOneWidget);
    });
  });
}
