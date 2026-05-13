import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_state.dart';
import 'package:calculator_app/features/calculator/presentation/cubit/calculator_status.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculatorState', () {
    group('initial state', () {
      test('has correct default values', () {
        const state = CalculatorState();

        expect(state.currentInput, '0');
        expect(state.selectedOperator, isNull);
        expect(state.firstOperand, isNull);
        expect(state.result, isNull);
        expect(state.status, CalculatorStatus.input);
      });

      test('CalculatorState.initial equals a manually constructed default state',
          () {
        const manualState = CalculatorState(
          currentInput: '0',
          selectedOperator: null,
          firstOperand: null,
          result: null,
          status: CalculatorStatus.input,
        );

        expect(CalculatorState.initial, equals(manualState));
      });
    });

    group('copyWith', () {
      test('with no arguments returns equal state', () {
        final state = CalculatorState(
          currentInput: '42',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.parse('10'),
          result: Decimal.parse('52'),
          status: CalculatorStatus.resultShown,
        );

        final copied = state.copyWith();

        expect(copied, equals(state));
      });

      test('with changed fields returns new state with those fields changed',
          () {
        const state = CalculatorState();

        final updated = state.copyWith(
          currentInput: '123',
          selectedOperator: OperatorType.multiplication,
          firstOperand: Decimal.parse('5'),
          result: Decimal.parse('615'),
          status: CalculatorStatus.resultShown,
        );

        expect(updated.currentInput, '123');
        expect(updated.selectedOperator, OperatorType.multiplication);
        expect(updated.firstOperand, Decimal.parse('5'));
        expect(updated.result, Decimal.parse('615'));
        expect(updated.status, CalculatorStatus.resultShown);
      });

      test('with clearSelectedOperator=true sets selectedOperator to null', () {
        final state = CalculatorState(
          currentInput: '7',
          selectedOperator: OperatorType.division,
          firstOperand: Decimal.parse('14'),
          status: CalculatorStatus.operatorSelected,
        );

        final cleared = state.copyWith(clearSelectedOperator: true);

        expect(cleared.selectedOperator, isNull);
        expect(cleared.currentInput, '7');
        expect(cleared.firstOperand, Decimal.parse('14'));
        expect(cleared.status, CalculatorStatus.operatorSelected);
      });

      test('with clearFirstOperand=true sets firstOperand to null', () {
        final state = CalculatorState(
          currentInput: '3',
          firstOperand: Decimal.parse('99'),
          status: CalculatorStatus.input,
        );

        final cleared = state.copyWith(clearFirstOperand: true);

        expect(cleared.firstOperand, isNull);
        expect(cleared.currentInput, '3');
        expect(cleared.status, CalculatorStatus.input);
      });

      test('with clearResult=true sets result to null', () {
        final state = CalculatorState(
          currentInput: '0',
          result: Decimal.parse('42'),
          status: CalculatorStatus.resultShown,
        );

        final cleared = state.copyWith(clearResult: true);

        expect(cleared.result, isNull);
        expect(cleared.currentInput, '0');
        expect(cleared.status, CalculatorStatus.resultShown);
      });
    });

    group('value equality', () {
      test('two states with same fields are equal', () {
        final state1 = CalculatorState(
          currentInput: '25',
          selectedOperator: OperatorType.subtraction,
          firstOperand: Decimal.parse('50'),
          result: Decimal.parse('25'),
          status: CalculatorStatus.resultShown,
        );

        final state2 = CalculatorState(
          currentInput: '25',
          selectedOperator: OperatorType.subtraction,
          firstOperand: Decimal.parse('50'),
          result: Decimal.parse('25'),
          status: CalculatorStatus.resultShown,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different fields are not equal', () {
        final state1 = CalculatorState(
          currentInput: '10',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.parse('5'),
          status: CalculatorStatus.operatorSelected,
        );

        final state2 = CalculatorState(
          currentInput: '20',
          selectedOperator: OperatorType.addition,
          firstOperand: Decimal.parse('5'),
          status: CalculatorStatus.operatorSelected,
        );

        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
