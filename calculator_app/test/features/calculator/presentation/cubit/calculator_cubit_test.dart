import 'package:bloc_test/bloc_test.dart';
import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/domain/usecases/calculator_engine.dart';
import 'package:calculator_app/features/calculator/domain/usecases/expression_formatter.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_status.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculatorEngine engine;
  late ExpressionFormatter formatter;
  late CalculatorCubit cubit;

  setUp(() {
    engine = CalculatorEngine();
    formatter = ExpressionFormatter();
    cubit = CalculatorCubit(engine: engine, formatter: formatter);
  });

  tearDown(() {
    cubit.close();
  });

  group('CalculatorCubit', () {
    test('initial state is CalculatorState.initial', () {
      expect(cubit.state, CalculatorState.initial);
    });

    // =========================================================
    // Zifferneingabe (Req 2.1–2.7)
    // =========================================================
    group('Zifferneingabe', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Ziffer wird an Display angehängt',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.inputDigit('5');
        },
        expect: () => [
          const CalculatorState(
            currentInput: '5',
            status: CalculatorStatus.input,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Führende Null wird unterdrückt: 0 dann 5 → "5"',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.inputDigit('0');
          cubit.inputDigit('5');
        },
        expect: () => [
          // inputDigit('0') → currentInput bleibt '0', kein emit
          // inputDigit('5') → '5'
          const CalculatorState(
            currentInput: '5',
            status: CalculatorStatus.input,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Mehrere Nullen bleiben als "0"',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.inputDigit('0');
          cubit.inputDigit('0');
          cubit.inputDigit('0');
        },
        expect: () => const <CalculatorState>[],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Mehrere Ziffern werden angehängt',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.inputDigit('1');
          cubit.inputDigit('2');
          cubit.inputDigit('3');
        },
        expect: () => [
          const CalculatorState(currentInput: '1'),
          const CalculatorState(currentInput: '12'),
          const CalculatorState(currentInput: '123'),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Maximal 12 Ziffern werden erzwungen',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '123456789012'),
        act: (cubit) {
          cubit.inputDigit('9');
        },
        expect: () => const <CalculatorState>[],
      );
    });

    // =========================================================
    // Dezimalpunkt (Req 2.3–2.5)
    // =========================================================
    group('Dezimalpunkt', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Dezimalpunkt auf "0" → "0."',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.inputDecimalPoint();
        },
        expect: () => [
          const CalculatorState(currentInput: '0.'),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Dezimalpunkt wird an bestehende Zahl angehängt',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '42'),
        act: (cubit) {
          cubit.inputDecimalPoint();
        },
        expect: () => [
          const CalculatorState(currentInput: '42.'),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Doppelter Dezimalpunkt wird ignoriert',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '3.14'),
        act: (cubit) {
          cubit.inputDecimalPoint();
        },
        expect: () => const <CalculatorState>[],
      );
    });

    // =========================================================
    // Operatorwahl (Req 9.1)
    // =========================================================
    group('Operatorwahl', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Operator setzt Status auf operatorSelected',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '5'),
        act: (cubit) {
          cubit.selectOperator(OperatorType.addition);
        },
        expect: () => [
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(5),
            status: CalculatorStatus.operatorSelected,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Operator-Ersetzung wenn bereits operatorSelected',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '0',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.fromInt(5),
          status: CalculatorStatus.operatorSelected,
        ),
        act: (cubit) {
          cubit.selectOperator(OperatorType.subtraction);
        },
        expect: () => [
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.subtraction,
            firstOperand: Decimal.fromInt(5),
            status: CalculatorStatus.operatorSelected,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Nach Ergebnis: Operator verwendet Ergebnis als firstOperand',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '8',
          result: Decimal.fromInt(8),
          status: CalculatorStatus.resultShown,
        ),
        act: (cubit) {
          cubit.selectOperator(OperatorType.multiplication);
        },
        expect: () => [
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.multiplication,
            firstOperand: Decimal.fromInt(8),
            status: CalculatorStatus.operatorSelected,
          ),
        ],
      );
    });

    // =========================================================
    // Gleichheit / Calculate (Req 1.1, 9.2, 9.3)
    // =========================================================
    group('Calculate / Gleichheit', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Einfache Berechnung: 5 + 3 = 8',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.inputDigit('5');
          cubit.selectOperator(OperatorType.addition);
          cubit.inputDigit('3');
          cubit.calculate();
        },
        expect: () => [
          const CalculatorState(currentInput: '5'),
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(5),
            status: CalculatorStatus.operatorSelected,
          ),
          CalculatorState(
            currentInput: '3',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(5),
            status: CalculatorStatus.input,
          ),
          CalculatorState(
            currentInput: '8',
            result: Decimal.fromInt(8),
            status: CalculatorStatus.resultShown,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Gleichheit ohne Operator → ignoriert',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '5'),
        act: (cubit) {
          cubit.calculate();
        },
        expect: () => const <CalculatorState>[],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Gleichheit ohne zweiten Operanden → ignoriert',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '0',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.fromInt(5),
          status: CalculatorStatus.operatorSelected,
        ),
        act: (cubit) {
          cubit.calculate();
        },
        expect: () => const <CalculatorState>[],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Division durch Null → Fehlerzustand',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '0',
          selectedOperator: OperatorType.division,
          firstOperand: Decimal.fromInt(5),
          status: CalculatorStatus.input,
        ),
        act: (cubit) {
          cubit.calculate();
        },
        expect: () => [
          const CalculatorState(
            currentInput: '0',
            status: CalculatorStatus.error,
          ),
        ],
      );
    });

    // =========================================================
    // Clear (Req 3.1)
    // =========================================================
    group('Clear', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Clear setzt auf Initialzustand zurück',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '42',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.fromInt(10),
          status: CalculatorStatus.operatorSelected,
        ),
        act: (cubit) {
          cubit.clear();
        },
        expect: () => [CalculatorState.initial],
      );
    });

    // =========================================================
    // Backspace (Req 3.2–3.6)
    // =========================================================
    group('Backspace', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Entfernt letztes Zeichen',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '123'),
        act: (cubit) {
          cubit.backspace();
        },
        expect: () => [
          const CalculatorState(currentInput: '12'),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Einstellige Eingabe → "0"',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '5'),
        act: (cubit) {
          cubit.backspace();
        },
        expect: () => [
          const CalculatorState(currentInput: '0'),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Im Fehlerzustand → setzt auf Initialzustand zurück',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(
          currentInput: '0',
          status: CalculatorStatus.error,
        ),
        act: (cubit) {
          cubit.backspace();
        },
        expect: () => [CalculatorState.initial],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Im resultShown → Ergebnis als Eingabe, letztes Zeichen entfernt',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '42',
          result: Decimal.fromInt(42),
          status: CalculatorStatus.resultShown,
        ),
        act: (cubit) {
          cubit.backspace();
        },
        expect: () => [
          const CalculatorState(
            currentInput: '4',
            status: CalculatorStatus.input,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Wenn "0" → ignoriert',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '0'),
        act: (cubit) {
          cubit.backspace();
        },
        expect: () => const <CalculatorState>[],
      );
    });

    // =========================================================
    // Fehler-Recovery (Req 1.8)
    // =========================================================
    group('Fehler-Recovery', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Ziffer nach Fehler startet neue Berechnung',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(
          currentInput: '0',
          status: CalculatorStatus.error,
        ),
        act: (cubit) {
          cubit.inputDigit('7');
        },
        expect: () => [
          const CalculatorState(
            currentInput: '7',
            status: CalculatorStatus.input,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Dezimalpunkt nach Fehler startet mit "0."',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(
          currentInput: '0',
          status: CalculatorStatus.error,
        ),
        act: (cubit) {
          cubit.inputDecimalPoint();
        },
        expect: () => [
          const CalculatorState(
            currentInput: '0.',
            status: CalculatorStatus.input,
          ),
        ],
      );
    });

    // =========================================================
    // Ergebnis als Operand (Req 1.9, 1.10, 9.4–9.6)
    // =========================================================
    group('Ergebnis als Operand', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Operator nach Ergebnis rechnet mit Ergebnis weiter',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '10',
          result: Decimal.fromInt(10),
          status: CalculatorStatus.resultShown,
        ),
        act: (cubit) {
          cubit.selectOperator(OperatorType.addition);
        },
        expect: () => [
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(10),
            status: CalculatorStatus.operatorSelected,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Ziffer nach Ergebnis startet neue Berechnung',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '10',
          result: Decimal.fromInt(10),
          status: CalculatorStatus.resultShown,
        ),
        act: (cubit) {
          cubit.inputDigit('3');
        },
        expect: () => [
          const CalculatorState(
            currentInput: '3',
            status: CalculatorStatus.input,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Dezimalpunkt nach Ergebnis startet neue Berechnung mit "0."',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '10',
          result: Decimal.fromInt(10),
          status: CalculatorStatus.resultShown,
        ),
        act: (cubit) {
          cubit.inputDecimalPoint();
        },
        expect: () => [
          const CalculatorState(
            currentInput: '0.',
            status: CalculatorStatus.input,
          ),
        ],
      );
    });

    // =========================================================
    // Sequenzielle Auswertung (Req 1.5, 1.6)
    // =========================================================
    group('Sequenzielle Auswertung', () {
      blocTest<CalculatorCubit, CalculatorState>(
        '2 + 3 + löst Zwischenergebnis aus → firstOperand = 5',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.inputDigit('2');
          cubit.selectOperator(OperatorType.addition);
          cubit.inputDigit('3');
          cubit.selectOperator(OperatorType.addition);
        },
        expect: () => [
          const CalculatorState(currentInput: '2'),
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(2),
            status: CalculatorStatus.operatorSelected,
          ),
          CalculatorState(
            currentInput: '3',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(2),
            status: CalculatorStatus.input,
          ),
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(5),
            status: CalculatorStatus.operatorSelected,
          ),
        ],
      );
    });

    // =========================================================
    // Besondere Eingabefälle (Req 9)
    // =========================================================
    group('Besondere Eingabefälle (Req 9)', () {
      blocTest<CalculatorCubit, CalculatorState>(
        'Operator im Fehlerzustand wird ignoriert',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(
          currentInput: '0',
          status: CalculatorStatus.error,
        ),
        act: (cubit) {
          cubit.selectOperator(OperatorType.addition);
        },
        expect: () => const <CalculatorState>[],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Clear nach Fehlerzustand stellt Initialzustand wieder her (Req 9.7)',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(
          currentInput: '0',
          status: CalculatorStatus.error,
        ),
        act: (cubit) {
          cubit.clear();
        },
        expect: () => [CalculatorState.initial],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Operator mit "0" als Eingabe setzt firstOperand = 0',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        act: (cubit) {
          cubit.selectOperator(OperatorType.addition);
        },
        expect: () => [
          CalculatorState(
            currentInput: '0',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.zero,
            status: CalculatorStatus.operatorSelected,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Dezimalpunkt im operatorSelected startet zweiten Operanden mit "0."',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '0',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.fromInt(5),
          status: CalculatorStatus.operatorSelected,
        ),
        act: (cubit) {
          cubit.inputDecimalPoint();
        },
        expect: () => [
          CalculatorState(
            currentInput: '0.',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(5),
            status: CalculatorStatus.input,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Ziffer im operatorSelected startet zweiten Operanden',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => CalculatorState(
          currentInput: '0',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.fromInt(5),
          status: CalculatorStatus.operatorSelected,
        ),
        act: (cubit) {
          cubit.inputDigit('7');
        },
        expect: () => [
          CalculatorState(
            currentInput: '7',
            selectedOperator: OperatorType.addition,
            firstOperand: Decimal.fromInt(5),
            status: CalculatorStatus.input,
          ),
        ],
      );

      blocTest<CalculatorCubit, CalculatorState>(
        'Max-Ziffern-Limit gilt auch mit Dezimalpunkt (12 Ziffern + Punkt)',
        build: () => CalculatorCubit(engine: engine, formatter: formatter),
        seed: () => const CalculatorState(currentInput: '12345.6789012'),
        act: (cubit) {
          // 12345.6789012 hat 12 sichtbare Ziffern, weitere werden ignoriert
          cubit.inputDigit('3');
        },
        expect: () => const <CalculatorState>[],
      );
    });
  });
}
