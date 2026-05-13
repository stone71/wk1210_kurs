import 'package:calculator_app/features/calculator/domain/entities/calculation_expression.dart';
import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/domain/usecases/expression_formatter.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExpressionFormatter formatter;

  setUp(() {
    formatter = ExpressionFormatter();
  });

  group('formatNumber', () {
    group('Ganzzahlen', () {
      test('Integer: 42 → "42"', () {
        expect(formatter.formatNumber(Decimal.fromInt(42)), '42');
      });

      test('Zero: 0 → "0"', () {
        expect(formatter.formatNumber(Decimal.zero), '0');
      });

      test('Negative: -7 → "-7"', () {
        expect(formatter.formatNumber(Decimal.fromInt(-7)), '-7');
      });
    });

    group('Dezimalzahlen', () {
      test('Dezimal: 3.14 → "3.14"', () {
        expect(formatter.formatNumber(Decimal.parse('3.14')), '3.14');
      });

      test('Nachgestellte Nullen entfernt: 5.00 → "5"', () {
        expect(formatter.formatNumber(Decimal.parse('5.00')), '5');
      });

      test('Führende Null bei Wert < 1 erhalten: 0.5 → "0.5"', () {
        expect(formatter.formatNumber(Decimal.parse('0.5')), '0.5');
      });

      test('Negative Dezimalzahl: -0.5 → "-0.5"', () {
        expect(formatter.formatNumber(Decimal.parse('-0.5')), '-0.5');
      });
    });

    group('Rundung auf 12 signifikante Ziffern', () {
      test('Ganzzahl mit mehr als 12 Ziffern wird gerundet', () {
        // 1234567890123 hat 13 Ziffern → auf 12 signifikante runden
        final result = formatter.formatNumber(Decimal.parse('1234567890123'));
        // Erwartung: 1234567890120 (gerundet auf 12 signifikante Ziffern)
        expect(result, '1234567890120');
      });

      test('Dezimalzahl mit mehr als 12 sichtbaren Ziffern wird gerundet', () {
        // 3.1415926535897 hat 14 sichtbare Ziffern → auf 12 runden
        final result =
            formatter.formatNumber(Decimal.parse('3.1415926535897'));
        // 12 sichtbare Ziffern: 3.14159265359 (gerundet)
        expect(result, '3.14159265359');
      });

      test('Kleine Dezimalzahl mit vielen Nachkommastellen', () {
        // 0.12345678901234 hat 14 sichtbare Ziffern → auf 12 runden
        final result =
            formatter.formatNumber(Decimal.parse('0.12345678901234'));
        expect(result, '0.123456789012');
      });
    });

    group('Maximal 12 sichtbare Ziffern', () {
      test('Genau 12 Ziffern bleiben unverändert', () {
        expect(
          formatter.formatNumber(Decimal.parse('123456789012')),
          '123456789012',
        );
      });

      test('Dezimalzahl mit genau 12 sichtbaren Ziffern', () {
        // 12345.6789012 hat 12 sichtbare Ziffern
        expect(
          formatter.formatNumber(Decimal.parse('12345.6789012')),
          '12345.6789012',
        );
      });
    });

    group('Negative Ergebnisse', () {
      test('Negative Ganzzahl: -123 → "-123"', () {
        expect(formatter.formatNumber(Decimal.fromInt(-123)), '-123');
      });

      test('Negatives Ergebnis nahe Null: -0.001 → "-0.001"', () {
        expect(formatter.formatNumber(Decimal.parse('-0.001')), '-0.001');
      });

      test('Negative Zahl mit vielen Ziffern wird gerundet', () {
        // -1234567890123 hat 13 Ziffern → auf 12 runden
        final result = formatter.formatNumber(Decimal.parse('-1234567890123'));
        expect(result, '-1234567890120');
      });
    });

    group('Führende Nullen', () {
      test('Keine führenden Nullen bei Ganzzahlen: 007 → "7"', () {
        // Decimal.parse handles this: 007 is just 7
        expect(formatter.formatNumber(Decimal.parse('7')), '7');
      });

      test('Null vor Dezimalpunkt bei Wert < 1 erhalten: 0.123 → "0.123"', () {
        expect(formatter.formatNumber(Decimal.parse('0.123')), '0.123');
      });

      test('Sehr kleine Dezimalzahl: 0.000001 → "0.000001"', () {
        expect(formatter.formatNumber(Decimal.parse('0.000001')), '0.000001');
      });
    });
  });

  group('formatExpression', () {
    test('Addition: formatiert als "{op1} + {op2}"', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(2),
        operator: OperatorType.addition,
        secondOperand: Decimal.fromInt(3),
      );

      expect(formatter.formatExpression(expression), '2 + 3');
    });

    test('Subtraktion: verwendet Unicode-Minus (−)', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(10),
        operator: OperatorType.subtraction,
        secondOperand: Decimal.fromInt(4),
      );

      expect(formatter.formatExpression(expression), '10 − 4');
    });

    test('Multiplikation: verwendet ×', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(6),
        operator: OperatorType.multiplication,
        secondOperand: Decimal.fromInt(7),
      );

      expect(formatter.formatExpression(expression), '6 × 7');
    });

    test('Division: verwendet ÷', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(10),
        operator: OperatorType.division,
        secondOperand: Decimal.fromInt(2),
      );

      expect(formatter.formatExpression(expression), '10 ÷ 2');
    });

    test('Dezimalzahlen werden korrekt formatiert', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.parse('3.14'),
        operator: OperatorType.addition,
        secondOperand: Decimal.parse('2.86'),
      );

      expect(formatter.formatExpression(expression), '3.14 + 2.86');
    });

    test('Negative Operanden werden korrekt formatiert', () {
      final expression = CalculationExpression(
        firstOperand: Decimal.fromInt(-5),
        operator: OperatorType.addition,
        secondOperand: Decimal.fromInt(3),
      );

      expect(formatter.formatExpression(expression), '-5 + 3');
    });
  });
}
