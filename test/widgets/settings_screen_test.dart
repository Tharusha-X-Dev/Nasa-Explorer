import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Settings UI structure', () {
    testWidgets('shows Settings title, Dark Mode, Language and About options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: _SettingsUiTestHost()));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}

class _SettingsUiTestHost extends StatefulWidget {
  const _SettingsUiTestHost();

  @override
  State<_SettingsUiTestHost> createState() => _SettingsUiTestHostState();
}

class _SettingsUiTestHostState extends State<_SettingsUiTestHost> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (bool value) {
              setState(() {
                isDarkMode = value;
              });
            },
          ),
          const ListTile(title: Text('Language')),
          const ListTile(title: Text('About')),
        ],
      ),
    );
  }
}
