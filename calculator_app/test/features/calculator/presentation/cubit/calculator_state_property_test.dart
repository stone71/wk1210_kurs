import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_status.dart';
import 'package:decimal/decimal.dart';
import 'package:glados/glados.dart';

/// **Validates: Requirement 5**
///
/// Property 11: State-Wertgleichheit
/// Zwei CalculatorState-Instanzen mit identischen Feldwerten sind gleich;
/// copyWith erzeugt neue Instanz ohne Mutation.

extension AnyCalculatorStatus on Any {
  Generator<CalculatorStatus> get calculatorStatus =>
      any.choose(CalculatorStatus.values);

  Generator<OperatorType> get operatorType =>
      any.choose(OperatorType.values);

  Generator<OperatorType?> get nullableOperatorType => any.choose([
        null,
        OperatorType.addition,
        OperatorType.subtraction,
        OperatorType.multiplication,
        OperatorType.division,
      ]);

  Generator<Decimal?> get nullableDecimal =>
      any.intInRange(-999999999, 999999999).map((i) {
        if (i == 0) return null;
        return Decimal.fromInt(i);
      });

  Generator<Decimal> get decimal =>
      any.intInRange(-999999999, 999999999).map((i) => Decimal.fromInt(i));

  Generator<String> get currentInputString => any.intInRange(0, 999999999999).map((i) {
        if (i == 0) return '0';
        return i.toString();
      });
}

void main() {
  group('Property 11: State-Wertgleichheit', () {
    Glados3(
      any.currentInputString,
      any.nullableOperatorType,
      any.calculatorStatus,
    ).test(
      'Zwei CalculatorState-Instanzen mit identischen Feldwerten sind gleich',
      (currentInput, selectedOperator, status) {
        // Generate consistent nullable Decimals for firstOperand and result
        final firstOperand =
            selectedOperator != null ? Decimal.fromInt(42) : null;
        final result =
            status == CalculatorStatus.resultShown ? Decimal.fromInt(84) : null;

        final state1 = CalculatorState(
          currentInput: currentInput,
          selectedOperator: selectedOperator,
          firstOperand: firstOperand,
          result: result,
          status: status,
        );

        final state2 = CalculatorState(
          currentInput: currentInput,
          selectedOperator: selectedOperator,
          firstOperand: firstOperand,
          result: result,
          status: status,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      },
    );

    Glados2(
      any.intInRange(-999999999, 999999999),
      any.intInRange(-999999999, 999999999),
    ).test(
      'Zwei States mit identischen Decimal-Feldwerten sind gleich',
      (firstVal, resultVal) {
        final firstOperand = Decimal.fromInt(firstVal);
        final result = Decimal.fromInt(resultVal);

        final state1 = CalculatorState(
          currentInput: '123',
          selectedOperator: OperatorType.addition,
          firstOperand: firstOperand,
          result: result,
          status: CalculatorStatus.resultShown,
        );

        final state2 = CalculatorState(
          currentInput: '123',
          selectedOperator: OperatorType.addition,
          firstOperand: firstOperand,
          result: result,
          status: CalculatorStatus.resultShown,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      },
    );

    Glados2(
      any.currentInputString,
      any.calculatorStatus,
    ).test(
      'copyWith erzeugt neue Instanz ohne Mutation des Originals',
      (currentInput, newStatus) {
        final original = CalculatorState(
          currentInput: currentInput,
          selectedOperator: OperatorType.multiplication,
          firstOperand: Decimal.fromInt(7),
          result: Decimal.fromInt(21),
          status: CalculatorStatus.input,
        );

        // Save original values for later comparison
        final originalCurrentInput = original.currentInput;
        final originalSelectedOperator = original.selectedOperator;
        final originalFirstOperand = original.firstOperand;
        final originalResult = original.result;
        final originalStatus = original.status;

        // Create a copy with modified fields
        final copy = original.copyWith(
          currentInput: '999',
          status: newStatus,
        );

        // Verify original is NOT mutated
        expect(original.currentInput, equals(originalCurrentInput));
        expect(original.selectedOperator, equals(originalSelectedOperator));
        expect(original.firstOperand, equals(originalFirstOperand));
        expect(original.result, equals(originalResult));
        expect(original.status, equals(originalStatus));

        // Verify copy has the new values
        expect(copy.currentInput, equals('999'));
        expect(copy.status, equals(newStatus));

        // Verify copy retains unchanged fields from original
        expect(copy.selectedOperator, equals(original.selectedOperator));
        expect(copy.firstOperand, equals(original.firstOperand));
        expect(copy.result, equals(original.result));
      },
    );

    Glados(any.nullableOperatorType).test(
      'copyWith mit clearSelectedOperator setzt Operator auf null ohne Mutation',
      (operator) {
        final original = CalculatorState(
          currentInput: '5',
          selectedOperator: operator,
          firstOperand: Decimal.fromInt(10),
          status: CalculatorStatus.operatorSelected,
        );

        final copy = original.copyWith(clearSelectedOperator: true);

        // Original unchanged
        expect(original.selectedOperator, equals(operator));

        // Copy has null operator
        expect(copy.selectedOperator, isNull);

        // Other fields unchanged in copy
        expect(copy.currentInput, equals(original.currentInput));
        expect(copy.firstOperand, equals(original.firstOperand));
        expect(copy.status, equals(original.status));
      },
    );

    Glados(any.intInRange(-999999999, 999999999)).test(
      'copyWith mit clearResult setzt result auf null ohne Mutation',
      (value) {
        final resultDecimal = Decimal.fromInt(value);
        final original = CalculatorState(
          currentInput: '0',
          result: resultDecimal,
          status: CalculatorStatus.resultShown,
        );

        final copy = original.copyWith(clearResult: true);

        // Original unchanged
        expect(original.result, equals(resultDecimal));

        // Copy has null result
        expect(copy.result, isNull);
      },
    );
  });
}
