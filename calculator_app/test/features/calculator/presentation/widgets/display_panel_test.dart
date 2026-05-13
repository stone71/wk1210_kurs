import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/features/calculator/presentation/widgets/display_panel.dart';

void main() {
  Widget buildTestWidget({
    required String displayText,
    String? expressionText,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DisplayPanel(
          displayText: displayText,
          expressionText: expressionText,
        ),
      ),
    );
  }

  group('DisplayPanel', () {
    testWidgets('shows displayText as main display',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(displayText: '42'));

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows expressionText when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        displayText: '3',
        expressionText: '5 +',
      ));

      expect(find.text('5 +'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('does not show expressionText when null',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        displayText: '0',
        expressionText: null,
      ));

      // Only the main display text should be present
      // Should find only the displayText '0'
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shows error text correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(displayText: 'Fehler'));

      expect(find.text('Fehler'), findsOneWidget);
    });
  });
}
