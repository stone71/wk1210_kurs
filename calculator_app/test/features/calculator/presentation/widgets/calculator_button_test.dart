import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/features/calculator/presentation/widgets/calculator_button.dart';

void main() {
  Widget buildTestWidget({
    String label = '5',
    Color backgroundColor = Colors.grey,
    VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: CalculatorButton(
            label: label,
            backgroundColor: backgroundColor,
            onPressed: onPressed ?? () {},
            isActive: isActive,
          ),
        ),
      ),
    );
  }

  group('CalculatorButton', () {
    testWidgets('can be instantiated with required parameters',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(label: '7'));

      expect(find.byType(CalculatorButton), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('tap triggers onPressed callback',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(buildTestWidget(
        label: '+',
        onPressed: () => tapped = true,
      ));

      await tester.tap(find.text('+'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('active state changes visual appearance',
        (WidgetTester tester) async {
      // Render inactive button
      await tester.pumpWidget(buildTestWidget(
        label: '×',
        backgroundColor: const Color(0xFFFF9500),
        isActive: false,
      ));

      final inactiveButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final inactiveStyle = inactiveButton.style!;
      final inactiveBgColor = inactiveStyle.backgroundColor!
          .resolve(<WidgetState>{});

      // Render active button
      await tester.pumpWidget(buildTestWidget(
        label: '×',
        backgroundColor: const Color(0xFFFF9500),
        isActive: true,
      ));

      final activeButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final activeStyle = activeButton.style!;
      final activeBgColor = activeStyle.backgroundColor!
          .resolve(<WidgetState>{});

      // Active and inactive should have different background colors
      expect(activeBgColor, isNot(equals(inactiveBgColor)));
    });

    testWidgets('has minimum size of at least 48x48 pixels',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(label: '0'));

      // The CalculatorButton wraps its content in a ConstrainedBox with
      // minWidth/minHeight of 48. Find the one that has those constraints.
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.descendant(
          of: find.byType(CalculatorButton),
          matching: find.byType(ConstrainedBox),
        ),
      );

      final hasMinSize = constrainedBoxes.any(
        (box) =>
            box.constraints.minWidth >= 48 &&
            box.constraints.minHeight >= 48,
      );

      expect(hasMinSize, isTrue,
          reason: 'CalculatorButton should have a ConstrainedBox with '
              'minWidth >= 48 and minHeight >= 48');
    });
  });
}
