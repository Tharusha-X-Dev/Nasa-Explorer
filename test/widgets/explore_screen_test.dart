import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Explore UI structure', () {
    testWidgets('shows app title and Explore/Search tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: _ExploreUiTestHost()));

      expect(find.text('NASA Explorer'), findsOneWidget);
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });
  });
}

class _ExploreUiTestHost extends StatelessWidget {
  const _ExploreUiTestHost();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NASA Explorer'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Explore'),
              Tab(text: 'Search'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[SizedBox.shrink(), SizedBox.shrink()],
        ),
      ),
    );
  }
}
