import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/domain/usecases/calculator_engine.dart';
import 'package:calculator_app/features/calculator/domain/usecases/expression_formatter.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_status.dart';
import 'package:glados/glados.dart';

extension AnyCubitPropertyGenerators on Any {
  Generator<List<String>> get digitSequence =>
      any.intInRange(1, 20).bind((length) =>
          any.listWithLength(length, any.intInRange(0, 9).map((i) => '$i')));

  Generator<String> get digitOrDecimalPoint => any.choose([
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.',
      ]);

  Generator<List<String>> get digitAndDecimalSequence =>
      any.intInRange(1, 30).bind((length) =>
          any.listWithLength(length, any.digitOrDecimalPoint));

  Generator<List<int>> get actionCodeSequence =>
      any.intInRange(1, 20).bind((length) =>
          any.listWithLength(length, any.intInRange(0, 4)));

  Generator<List<String>> digitSequenceMin(int minLength) =>
      any.intInRange(minLength, 12).bind((length) =>
          any.listWithLength(length, any.intInRange(0, 9).map((i) => '$i')));
}

bool _hasNoLeadingZeros(String input) {
  if (input.isEmpty) return true;
  if (input == '0') return true;
  if (input.startsWith('0.')) return true;
  if (input.startsWith('0')) return false;
  return true;
}

void _applyCubitAction(CalculatorCubit cubit, int actionCode, int index) {
  try {
    final actionType = actionCode % 5;
    switch (actionType) {
      case 0:
        final digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
        cubit.inputDigit(digits[(actionCode + index) % digits.length]);
      case 1:
        cubit.inputDecimalPoint();
      case 2:
        final operators = OperatorType.values;
        cubit.selectOperator(operators[(actionCode + index) % operators.length]);
      case 3:
        cubit.calculate();
      case 4:
        cubit.backspace();
    }
  } catch (_) {
    // Some action sequences can trigger errors in the Decimal package
    // (e.g. infinite precision division). We ignore these since the
    // property under test is about clear()/backspace() behavior.
  }
}

void main() {
  /// **Validates: Requirement 2**
  ///
  /// Property 6: Keine fuehrenden Nullen
  group('Property 6: Keine fuehrenden Nullen', () {
    Glados(any.digitSequence).test(
      'currentInput enthaelt nach jeder Zifferneingabe keine fuehrenden Nullen',
      (digits) {
        final cubit = CalculatorCubit(
          engine: CalculatorEngine(),
          formatter: ExpressionFormatter(),
        );
        for (final digit in digits) {
          cubit.inputDigit(digit);
          expect(
            _hasNoLeadingZeros(cubit.state.currentInput),
            isTrue,
            reason: 'currentInput has leading zeros',
          );
        }
        cubit.close();
      },
    );
  });

  /// **Validates: Requirement 2**
  ///
  /// Property 7: Dezimalpunkt-Invariante
  group('Property 7: Dezimalpunkt-Invariante', () {
    Glados(any.digitAndDecimalSequence).test(
      'currentInput enthaelt nach jeder Eingabe maximal einen Dezimalpunkt',
      (inputs) {
        final cubit = CalculatorCubit(
          engine: CalculatorEngine(),
          formatter: ExpressionFormatter(),
        );
        for (final input in inputs) {
          if (input == '.') {
            cubit.inputDecimalPoint();
          } else {
            cubit.inputDigit(input);
          }
          final dotCount = '.'.allMatches(cubit.state.currentInput).length;
          expect(dotCount, lessThanOrEqualTo(1));
        }
        cubit.close();
      },
    );
  });

  /// **Validates: Requirement 3, Requirement 5**
  ///
  /// Property 9: Clear setzt auf Initialzustand
  group('Property 9: Clear setzt auf Initialzustand', () {
    Glados(any.actionCodeSequence).test(
      'Nach beliebiger Aktionssequenz setzt clear() den Zustand auf CalculatorState.initial',
      (actionCodes) {
        final cubit = CalculatorCubit(
          engine: CalculatorEngine(),
          formatter: ExpressionFormatter(),
        );
        for (var i = 0; i < actionCodes.length; i++) {
          _applyCubitAction(cubit, actionCodes[i], i);
        }
        cubit.clear();
        expect(cubit.state, equals(CalculatorState.initial));
        cubit.close();
      },
    );
  });

  /// **Validates: Requirement 3**
  ///
  /// Property 10: Backspace entfernt letztes Zeichen
  /// Fuer Eingabe mit mehr als einem Zeichen entfernt backspace() das letzte
  /// Zeichen; bei einstelliger Eingabe wird currentInput auf "0" gesetzt.
  group('Property 10: Backspace entfernt letztes Zeichen', () {
    Glados(any.digitSequenceMin(2)).test(
      'Fuer Eingabe mit mehr als einem Zeichen entfernt backspace() das letzte Zeichen',
      (digits) {
        final cubit = CalculatorCubit(
          engine: CalculatorEngine(),
          formatter: ExpressionFormatter(),
        );

        for (final digit in digits) {
          cubit.inputDigit(digit);
        }

        final inputBefore = cubit.state.currentInput;

        if (inputBefore.length > 1) {
          cubit.backspace();
          final expected = inputBefore.substring(0, inputBefore.length - 1);
          expect(cubit.state.currentInput, equals(expected));
          expect(cubit.state.status, equals(CalculatorStatus.input));
        }

        cubit.close();
      },
    );

    Glados(any.intInRange(1, 9)).test(
      'Bei einstelliger Eingabe wird currentInput auf 0 gesetzt',
      (digitValue) {
        final cubit = CalculatorCubit(
          engine: CalculatorEngine(),
          formatter: ExpressionFormatter(),
        );

        final digit = digitValue.toString();
        cubit.inputDigit(digit);
        expect(cubit.state.currentInput, equals(digit));

        cubit.backspace();
        expect(cubit.state.currentInput, equals('0'));
        expect(cubit.state.status, equals(CalculatorStatus.input));

        cubit.close();
      },
    );

    Glados(any.digitSequenceMin(2)).test(
      'Backspace auf 0 wird ignoriert (Req 3.4)',
      (digits) {
        final cubit = CalculatorCubit(
          engine: CalculatorEngine(),
          formatter: ExpressionFormatter(),
        );

        expect(cubit.state.currentInput, equals('0'));
        cubit.backspace();
        expect(cubit.state.currentInput, equals('0'));
        expect(cubit.state.status, equals(CalculatorStatus.input));

        cubit.close();
      },
    );
  });
}
