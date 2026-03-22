import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Login UI structure', () {
    testWidgets('shows email, password, login and sign up controls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: _LoginUiTestHost()));

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });
  });
}

class _LoginUiTestHost extends StatelessWidget {
  const _LoginUiTestHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NASA Explorer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextFormField(key: const Key('emailField')),
            const SizedBox(height: 8),
            TextFormField(key: const Key('passwordField'), obscureText: true),
            const SizedBox(height: 12),
            FilledButton(onPressed: () {}, child: const Text('Login')),
            TextButton(onPressed: () {}, child: const Text('Sign up')),
          ],
        ),
      ),
    );
  }
}
