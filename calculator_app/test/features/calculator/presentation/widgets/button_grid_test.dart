import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/presentation/widgets/button_grid.dart';
import 'package:calculator_app/features/calculator/presentation/widgets/calculator_button.dart';

void main() {
  Widget buildTestWidget({
    void Function(String digit)? onDigitPressed,
    VoidCallback? onDecimalPressed,
    void Function(OperatorType operator)? onOperatorPressed,
    VoidCallback? onEqualsPressed,
    VoidCallback? onClearPressed,
    VoidCallback? onBackspacePressed,
    OperatorType? activeOperator,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 500,
          child: ButtonGrid(
            onDigitPressed: onDigitPressed ?? (_) {},
            onDecimalPressed: onDecimalPressed ?? () {},
            onOperatorPressed: onOperatorPressed ?? (_) {},
            onEqualsPressed: onEqualsPressed ?? () {},
            onClearPressed: onClearPressed ?? () {},
            onBackspacePressed: onBackspacePressed ?? () {},
            activeOperator: activeOperator,
          ),
        ),
      ),
    );
  }

  group('ButtonGrid', () {
    testWidgets('contains all required buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Digits 0-9
      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget,
            reason: 'Digit $i should be present');
      }

      // Decimal point
      expect(find.text('.'), findsOneWidget);

      // Operators
      expect(find.text('÷'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);
      expect(find.text('−'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);

      // Equals
      expect(find.text('='), findsOneWidget);

      // Clear and backspace
      expect(find.text('C'), findsOneWidget);
      expect(find.text('⌫'), findsOneWidget);
    });

    testWidgets('digit button tap calls onDigitPressed with correct digit',
        (WidgetTester tester) async {
      String? pressedDigit;

      await tester.pumpWidget(buildTestWidget(
        onDigitPressed: (digit) => pressedDigit = digit,
      ));

      await tester.tap(find.text('7'));
      await tester.pump();
      expect(pressedDigit, equals('7'));

      await tester.tap(find.text('0'));
      await tester.pump();
      expect(pressedDigit, equals('0'));

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(pressedDigit, equals('5'));
    });

    testWidgets(
        'operator button tap calls onOperatorPressed with correct OperatorType',
        (WidgetTester tester) async {
      OperatorType? pressedOperator;

      await tester.pumpWidget(buildTestWidget(
        onOperatorPressed: (op) => pressedOperator = op,
      ));

      await tester.tap(find.text('+'));
      await tester.pump();
      expect(pressedOperator, equals(OperatorType.addition));

      await tester.tap(find.text('−'));
      await tester.pump();
      expect(pressedOperator, equals(OperatorType.subtraction));

      await tester.tap(find.text('×'));
      await tester.pump();
      expect(pressedOperator, equals(OperatorType.multiplication));

      await tester.tap(find.text('÷'));
      await tester.pump();
      expect(pressedOperator, equals(OperatorType.division));
    });

    testWidgets('active operator highlighting works',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        activeOperator: OperatorType.addition,
      ));

      // Find all CalculatorButton widgets
      final buttons = tester.widgetList<CalculatorButton>(
        find.byType(CalculatorButton),
      );

      // The addition button should be active
      final addButton = buttons.firstWhere((b) => b.label == '+');
      expect(addButton.isActive, isTrue);

      // Other operator buttons should not be active
      final subButton = buttons.firstWhere((b) => b.label == '−');
      expect(subButton.isActive, isFalse);

      final mulButton = buttons.firstWhere((b) => b.label == '×');
      expect(mulButton.isActive, isFalse);

      final divButton = buttons.firstWhere((b) => b.label == '÷');
      expect(divButton.isActive, isFalse);
    });

    testWidgets('clear button triggers onClearPressed callback',
        (WidgetTester tester) async {
      var clearPressed = false;

      await tester.pumpWidget(buildTestWidget(
        onClearPressed: () => clearPressed = true,
      ));

      await tester.tap(find.text('C'));
      await tester.pump();

      expect(clearPressed, isTrue);
    });

    testWidgets('backspace button triggers onBackspacePressed callback',
        (WidgetTester tester) async {
      var backspacePressed = false;

      await tester.pumpWidget(buildTestWidget(
        onBackspacePressed: () => backspacePressed = true,
      ));

      await tester.tap(find.text('⌫'));
      await tester.pump();

      expect(backspacePressed, isTrue);
    });
  });
}
