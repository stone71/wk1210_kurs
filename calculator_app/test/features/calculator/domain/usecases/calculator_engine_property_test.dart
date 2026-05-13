import 'package:calculator_app/core/constants/app_constants.dart';
import 'package:calculator_app/core/result/result.dart';
import 'package:calculator_app/features/calculator/domain/entities/calculation_expression.dart';
import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/domain/failures/calculation_failure.dart';
import 'package:calculator_app/features/calculator/domain/usecases/calculator_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:glados/glados.dart';

/// **Validates: Requirement 1**
///
/// Property 1: Korrekte arithmetische Berechnung
/// Für jede gültige CalculationExpression mit Operanden im unterstützten Bereich
/// das mathematisch korrekte Ergebnis prüfen.
///
/// Property 2: Division durch Null ergibt Fehler
/// Für jeden gültigen ersten Operanden mit Operator Division und zweitem Operand 0
/// einen divisionByZero-Fehler prüfen.

void main() {
  final engine = CalculatorEngine();
  final maxValue = Decimal.parse('${AppConstants.maxValue}');
  final minValue = Decimal.parse('${AppConstants.minValue}');

  group('Property 1: Korrekte arithmetische Berechnung', () {
    Glados2(any.intInRange(-999999999, 999999999),
            any.intInRange(-999999999, 999999999))
        .test('Addition liefert mathematisch korrektes Ergebnis', (a, b) {
      final first = Decimal.fromInt(a);
      final second = Decimal.fromInt(b);
      final expected = first + second;

      // Skip overflow cases
      if (expected > maxValue || expected < minValue) return;

      final expression = CalculationExpression(
        firstOperand: first,
        operator: OperatorType.addition,
        secondOperand: second,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, equals(expected));
    });

    Glados2(any.intInRange(-999999999, 999999999),
            any.intInRange(-999999999, 999999999))
        .test('Subtraktion liefert mathematisch korrektes Ergebnis', (a, b) {
      final first = Decimal.fromInt(a);
      final second = Decimal.fromInt(b);
      final expected = first - second;

      // Skip overflow cases
      if (expected > maxValue || expected < minValue) return;

      final expression = CalculationExpression(
        firstOperand: first,
        operator: OperatorType.subtraction,
        secondOperand: second,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, equals(expected));
    });

    Glados2(any.intInRange(-999999, 999999), any.intInRange(-999999, 999999))
        .test('Multiplikation liefert mathematisch korrektes Ergebnis', (a, b) {
      final first = Decimal.fromInt(a);
      final second = Decimal.fromInt(b);
      final expected = first * second;

      // Skip overflow cases
      if (expected > maxValue || expected < minValue) return;

      final expression = CalculationExpression(
        firstOperand: first,
        operator: OperatorType.multiplication,
        secondOperand: second,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, equals(expected));
    });

    // For division tests, we generate quotient and divisor, then compute
    // dividend = quotient * divisor. This guarantees the division produces
    // a terminating decimal (finite precision).
    Glados2(any.intInRange(-9999, 9999), any.intInRange(1, 9999)).test(
        'Division mit positivem Divisor liefert mathematisch korrektes Ergebnis',
        (quotient, divisor) {
      final expectedResult = Decimal.fromInt(quotient);
      final second = Decimal.fromInt(divisor);
      final first = expectedResult * second;

      // Skip overflow cases for the dividend
      if (first > maxValue || first < minValue) return;

      final expression = CalculationExpression(
        firstOperand: first,
        operator: OperatorType.division,
        secondOperand: second,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, equals(expectedResult));
    });

    Glados2(any.intInRange(-9999, 9999), any.intInRange(-9999, -1)).test(
        'Division mit negativem Divisor liefert mathematisch korrektes Ergebnis',
        (quotient, divisor) {
      final expectedResult = Decimal.fromInt(quotient);
      final second = Decimal.fromInt(divisor);
      final first = expectedResult * second;

      // Skip overflow cases for the dividend
      if (first > maxValue || first < minValue) return;

      final expression = CalculationExpression(
        firstOperand: first,
        operator: OperatorType.division,
        secondOperand: second,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, equals(expectedResult));
    });
  });

  /// **Validates: Requirement 1**
  ///
  /// Property 2: Division durch Null ergibt Fehler
  /// Für jeden gültigen ersten Operanden mit Operator Division und zweitem
  /// Operand 0 einen divisionByZero-Fehler prüfen.
  group('Property 2: Division durch Null ergibt Fehler', () {
    Glados(any.intInRange(-999999999, 999999999))
        .test('Division durch Null gibt CalculationError mit divisionByZero zurück',
            (a) {
      final firstOperand = Decimal.fromInt(a);

      final expression = CalculationExpression(
        firstOperand: firstOperand,
        operator: OperatorType.division,
        secondOperand: Decimal.zero,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      final error = result as CalculationError;
      expect(
        error.failure,
        equals(const CalculationFailure(CalculationFailureType.divisionByZero)),
      );
    });
  });
}
