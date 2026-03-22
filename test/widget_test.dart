// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:version_1_0/firebase_options.dart';
import 'package:version_1_0/main.dart';

void main() {
  testWidgets('App renders main tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'isFirstLaunch': true,
    });

    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

    await tester.pumpWidget(const NasaExplorerApp());
    await tester.pump();

    expect(find.text('NASA Explorer'), findsOneWidget);
    expect(
      find.text("Explore the universe using NASA's images and videos."),
      findsOneWidget,
    );
    expect(find.text('Launch'), findsOneWidget);

    await tester.tap(find.text('Launch'));
    await tester.pump(const Duration(milliseconds: 500));

    // After first launch action, expect Login screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
