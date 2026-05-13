import 'package:calculator_app/core/result/result.dart';
import 'package:calculator_app/features/calculator/domain/entities/calculation_expression.dart';
import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/domain/failures/calculation_failure.dart';
import 'package:calculator_app/features/calculator/domain/usecases/calculator_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CalculatorEngine engine;

  setUp(() {
    engine = CalculatorEngine();
  });

  group('Addition', () {
    test('berechnet 2 + 3 = 5', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(2),
        operator: OperatorType.addition,
        secondOperand: Decimal.fromInt(3),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(5));
    });

    test('berechnet 0.1 + 0.2 korrekt mit Decimal', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('0.1'),
        operator: OperatorType.addition,
        secondOperand: Decimal.parse('0.2'),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.parse('0.3'));
    });

    test('berechnet Addition mit negativen Operanden: -5 + 3 = -2', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(-5),
        operator: OperatorType.addition,
        secondOperand: Decimal.fromInt(3),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(-2));
    });

    test('berechnet Addition zweier negativer Zahlen: -4 + (-6) = -10', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(-4),
        operator: OperatorType.addition,
        secondOperand: Decimal.fromInt(-6),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(-10));
    });
  });

  group('Subtraktion', () {
    test('berechnet 10 - 4 = 6', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(10),
        operator: OperatorType.subtraction,
        secondOperand: Decimal.fromInt(4),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(6));
    });

    test('berechnet negatives Ergebnis: 3 - 7 = -4', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(3),
        operator: OperatorType.subtraction,
        secondOperand: Decimal.fromInt(7),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(-4));
    });

    test('berechnet Dezimal-Subtraktion: 5.5 - 2.3 = 3.2', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('5.5'),
        operator: OperatorType.subtraction,
        secondOperand: Decimal.parse('2.3'),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.parse('3.2'));
    });
  });

  group('Multiplikation', () {
    test('berechnet 6 × 7 = 42', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(6),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(7),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(42));
    });

    test('berechnet Multiplikation mit Null: 5 × 0 = 0', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(5),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.zero,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.zero);
    });

    test('berechnet Dezimal-Multiplikation: 2.5 × 4 = 10', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('2.5'),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(4),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(10));
    });

    test('berechnet Multiplikation mit negativem Operand: -3 × 5 = -15', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(-3),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(5),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(-15));
    });
  });

  group('Division', () {
    test('berechnet 10 ÷ 2 = 5', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(10),
        operator: OperatorType.division,
        secondOperand: Decimal.fromInt(2),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(5));
    });

    test('berechnet 7 ÷ 2 = 3.5', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(7),
        operator: OperatorType.division,
        secondOperand: Decimal.fromInt(2),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.parse('3.5'));
    });

    test('berechnet Division mit negativem Ergebnis: -15 ÷ 3 = -5', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(-15),
        operator: OperatorType.division,
        secondOperand: Decimal.fromInt(3),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.fromInt(-5));
    });

    test('berechnet 22 ÷ 8 = 2.75', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(22),
        operator: OperatorType.division,
        secondOperand: Decimal.fromInt(8),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect((result as CalculationSuccess).value, Decimal.parse('2.75'));
    });
  });

  group('Division durch Null', () {
    test('gibt divisionByZero-Fehler zurück', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(5),
        operator: OperatorType.division,
        secondOperand: Decimal.zero,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.divisionByZero,
      );
    });

    test('gibt divisionByZero auch bei negativem Dividend', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(-10),
        operator: OperatorType.division,
        secondOperand: Decimal.zero,
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.divisionByZero,
      );
    });
  });

  group('Overflow', () {
    test('gibt overflow bei Ergebnis über maxValue', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('999999999999'),
        operator: OperatorType.addition,
        secondOperand: Decimal.fromInt(1),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.overflow,
      );
    });

    test('gibt overflow bei Ergebnis unter minValue', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('-999999999999'),
        operator: OperatorType.subtraction,
        secondOperand: Decimal.fromInt(1),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.overflow,
      );
    });

    test('akzeptiert Ergebnis genau am maxValue', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('999999999998'),
        operator: OperatorType.addition,
        secondOperand: Decimal.fromInt(1),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect(
        (result as CalculationSuccess).value,
        Decimal.parse('999999999999'),
      );
    });

    test('akzeptiert Ergebnis genau am minValue', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('-999999999998'),
        operator: OperatorType.subtraction,
        secondOperand: Decimal.fromInt(1),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect(
        (result as CalculationSuccess).value,
        Decimal.parse('-999999999999'),
      );
    });

    test('gibt overflow bei großer Multiplikation', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('999999999999'),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(2),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.overflow,
      );
    });

    test('gibt overflow bei negativer Multiplikation unter minValue', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('-999999999999'),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(2),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.overflow,
      );
    });
  });

  group('Grenzwerte', () {
    test('akzeptiert Ergebnis exakt bei maxValue (999999999999)', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('999999999999'),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(1),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect(
        (result as CalculationSuccess).value,
        Decimal.parse('999999999999'),
      );
    });

    test('akzeptiert Ergebnis exakt bei minValue (-999999999999)', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('-999999999999'),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(1),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationSuccess>());
      expect(
        (result as CalculationSuccess).value,
        Decimal.parse('-999999999999'),
      );
    });

    test('Ergebnis knapp über maxValue ist overflow', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('999999999999'),
        operator: OperatorType.addition,
        secondOperand: Decimal.parse('0.001'),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.overflow,
      );
    });

    test('Ergebnis knapp unter minValue ist overflow', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('-999999999999'),
        operator: OperatorType.subtraction,
        secondOperand: Decimal.parse('0.001'),
      );

      final result = engine.calculate(expression);

      expect(result, isA<CalculationError>());
      expect(
        (result as CalculationError).failure.type,
        CalculationFailureType.overflow,
      );
    });
  });
}
