// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:version_1_0/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders first launch splash', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'isFirstLaunch': true,
    });

    await tester.pumpWidget(const NasaExplorerApp());
    await tester.pump();

    expect(find.text('NASA Explorer'), findsOneWidget);
    expect(
      find.text("Explore the universe using NASA's images and videos."),
      findsOneWidget,
    );
    expect(find.text('Launch'), findsOneWidget);
  });
}
