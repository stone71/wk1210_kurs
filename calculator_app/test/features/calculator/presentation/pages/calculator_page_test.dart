import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/features/calculator/presentation/pages/calculator_page.dart';
import 'package:calculator_app/features/calculator/presentation/widgets/button_grid.dart';
import 'package:calculator_app/features/calculator/presentation/widgets/display_panel.dart';

void main() {
  Widget buildTestApp() {
    return const MaterialApp(
      home: CalculatorPage(),
    );
  }

  /// Finds text within the DisplayPanel widget only.
  Finder findDisplayText(String text) {
    return find.descendant(
      of: find.byType(DisplayPanel),
      matching: find.text(text),
    );
  }

  group('CalculatorPage - Portrait Layout', () {
    testWidgets(
      'DisplayPanel and ButtonGrid are arranged vertically in portrait',
      (WidgetTester tester) async {
        // Simulate a portrait screen: 400x800
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // In portrait, the layout uses a Column
        final columnFinder = find.byType(Column);
        expect(columnFinder, findsWidgets);

        // DisplayPanel and ButtonGrid should both be present
        expect(find.byType(DisplayPanel), findsOneWidget);
        expect(find.byType(ButtonGrid), findsOneWidget);

        // Verify vertical arrangement: DisplayPanel should be above ButtonGrid
        final displayPanelOffset = tester.getTopLeft(find.byType(DisplayPanel));
        final buttonGridOffset = tester.getTopLeft(find.byType(ButtonGrid));
        expect(displayPanelOffset.dy, lessThan(buttonGridOffset.dy));
      },
    );
  });

  group('CalculatorPage - Landscape Layout', () {
    testWidgets(
      'DisplayPanel and ButtonGrid are arranged horizontally in landscape',
      (WidgetTester tester) async {
        // Simulate a landscape screen: 800x400
        tester.view.physicalSize = const Size(800, 400);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // In landscape, the layout uses a Row
        final rowFinder = find.byType(Row);
        expect(rowFinder, findsWidgets);

        // DisplayPanel and ButtonGrid should both be present
        expect(find.byType(DisplayPanel), findsOneWidget);
        expect(find.byType(ButtonGrid), findsOneWidget);

        // Verify horizontal arrangement: DisplayPanel should be to the left of ButtonGrid
        final displayPanelOffset = tester.getTopLeft(find.byType(DisplayPanel));
        final buttonGridOffset = tester.getTopLeft(find.byType(ButtonGrid));
        expect(displayPanelOffset.dx, lessThan(buttonGridOffset.dx));
      },
    );
  });

  group('CalculatorPage - Cubit Integration', () {
    testWidgets(
      'initial state shows "0"',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // The display should show "0" on startup
        expect(findDisplayText('0'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping digit buttons updates the display',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Tap digit '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        expect(find.text('5'), findsWidgets);

        // Tap digit '3'
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Display should show '53'
        expect(find.text('53'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping operator button changes state to operatorSelected',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Tap digit '5'
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap operator '+'
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // After selecting operator, display should show '0' (ready for second operand)
        // and the expression text should show '5 +'
        expect(find.text('5 +'), findsOneWidget);
      },
    );

    testWidgets(
      'calculation flow: 5 + 3 = 8',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Input 5
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap +
        await tester.tap(find.text('+'));
        await tester.pumpAndSettle();

        // Input 3
        await tester.tap(find.text('3'));
        await tester.pumpAndSettle();

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Display should show '8'
        expect(findDisplayText('8'), findsOneWidget);
      },
    );

    testWidgets(
      'division by zero shows "Fehler"',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Input 5
        await tester.tap(find.text('5'));
        await tester.pumpAndSettle();

        // Tap ÷
        await tester.tap(find.text('÷'));
        await tester.pumpAndSettle();

        // Input 0 as second operand - find the '0' button in the ButtonGrid
        final zeroButton = find.descendant(
          of: find.byType(ButtonGrid),
          matching: find.text('0'),
        );
        await tester.tap(zeroButton);
        await tester.pumpAndSettle();

        // Tap =
        await tester.tap(find.text('='));
        await tester.pumpAndSettle();

        // Display should show 'Fehler'
        expect(findDisplayText('Fehler'), findsOneWidget);
      },
    );
  });

  group('CalculatorPage - Responsiveness', () {
    testWidgets(
      'renders correctly on small screen (320px width)',
      (WidgetTester tester) async {
        // Simulate a small phone: 320x568
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Should still render without overflow
        expect(find.byType(DisplayPanel), findsOneWidget);
        expect(find.byType(ButtonGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders correctly on large screen (1024px width)',
      (WidgetTester tester) async {
        // Simulate a tablet: 1024x768
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Should render without overflow
        expect(find.byType(DisplayPanel), findsOneWidget);
        expect(find.byType(ButtonGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'landscape layout on wide screen',
      (WidgetTester tester) async {
        // Simulate a wide landscape: 1024x400
        tester.view.physicalSize = const Size(1024, 400);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Should render in landscape mode (horizontal arrangement)
        expect(find.byType(DisplayPanel), findsOneWidget);
        expect(find.byType(ButtonGrid), findsOneWidget);

        // Verify horizontal arrangement
        final displayPanelOffset = tester.getTopLeft(find.byType(DisplayPanel));
        final buttonGridOffset = tester.getTopLeft(find.byType(ButtonGrid));
        expect(displayPanelOffset.dx, lessThan(buttonGridOffset.dx));
      },
    );
  });
}
