import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/main.dart';

void main() {
  testWidgets('CalculatorApp renders without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    // Verify that the calculator displays initial state '0' in the display.
    expect(find.text('0'), findsWidgets);
  });
}
