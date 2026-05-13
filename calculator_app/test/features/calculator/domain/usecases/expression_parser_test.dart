import 'package:calculator_app/core/result/result.dart';
import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/domain/failures/parse_failure.dart';
import 'package:calculator_app/features/calculator/domain/usecases/expression_parser.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExpressionParser parser;

  setUp(() {
    parser = ExpressionParser();
  });

  group('Gültige Ausdrücke', () {
    test('parst einfache Addition: 2 + 3', () {
      final result = parser.parse('2 + 3');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.fromInt(2));
      expect(success.expression.operator, OperatorType.addition);
      expect(success.expression.secondOperand, Decimal.fromInt(3));
    });

    test('parst Subtraktion mit Unicode-Minus: 10 − 4', () {
      final result = parser.parse('10 − 4');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.fromInt(10));
      expect(success.expression.operator, OperatorType.subtraction);
      expect(success.expression.secondOperand, Decimal.fromInt(4));
    });

    test('parst Multiplikation: 6 × 7', () {
      final result = parser.parse('6 × 7');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.fromInt(6));
      expect(success.expression.operator, OperatorType.multiplication);
      expect(success.expression.secondOperand, Decimal.fromInt(7));
    });

    test('parst Division: 10 ÷ 2', () {
      final result = parser.parse('10 ÷ 2');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.fromInt(10));
      expect(success.expression.operator, OperatorType.division);
      expect(success.expression.secondOperand, Decimal.fromInt(2));
    });

    test('parst Dezimalzahlen: 3.14 + 2.86', () {
      final result = parser.parse('3.14 + 2.86');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.parse('3.14'));
      expect(success.expression.secondOperand, Decimal.parse('2.86'));
    });

    test('parst negative Operanden: -5 + 3', () {
      final result = parser.parse('-5 + 3');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.fromInt(-5));
      expect(success.expression.secondOperand, Decimal.fromInt(3));
    });

    test('parst Operand mit genau 12 Ziffern', () {
      final result = parser.parse('123456789012 + 1');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.parse('123456789012'));
    });

    test('parst negativen Dezimaloperand mit 12 Ziffern', () {
      // -12345.6789012 hat 12 sichtbare Ziffern (Minus und Punkt zählen nicht)
      final result = parser.parse('-12345.6789012 + 1');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(
        success.expression.firstOperand,
        Decimal.parse('-12345.6789012'),
      );
    });

    test('parst Dezimalzahl kleiner als 1: 0.1 ÷ 3', () {
      final result = parser.parse('0.1 ÷ 3');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.parse('0.1'));
      expect(success.expression.operator, OperatorType.division);
      expect(success.expression.secondOperand, Decimal.fromInt(3));
    });

    test('parst Multiplikation mit Dezimalzahl: 10.5 × 2', () {
      final result = parser.parse('10.5 × 2');

      expect(result, isA<ParseSuccess>());
      final success = result as ParseSuccess;
      expect(success.expression.firstOperand, Decimal.parse('10.5'));
      expect(success.expression.operator, OperatorType.multiplication);
      expect(success.expression.secondOperand, Decimal.fromInt(2));
    });
  });

  group('Fehlender Operand', () {
    test('leere Eingabe', () {
      final result = parser.parse('');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.missingOperand,
      );
    });

    test('nur Operator: +', () {
      final result = parser.parse('+');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.missingOperand,
      );
    });

    test('Operator am Anfang mit Leerzeichen: + 3', () {
      final result = parser.parse('+ 3');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.missingOperand,
      );
    });

    test('Operator am Ende mit Leerzeichen: 5 +', () {
      final result = parser.parse('5 +');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.missingOperand,
      );
    });
  });

  group('Fehlender Operator', () {
    test('zwei Zahlen ohne Operator: 5 3', () {
      final result = parser.parse('5 3');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.missingOperator,
      );
    });

    test('einzelne Zahl ohne Operator: 42', () {
      final result = parser.parse('42');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.missingOperator,
      );
    });
  });

  group('Ungültiges Zeichen', () {
    test('Buchstabe im Operand: abc + 3', () {
      final result = parser.parse('abc + 3');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.invalidCharacter,
      );
    });

    test('Sonderzeichen im Operand: 5# + 3', () {
      final result = parser.parse('5# + 3');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.invalidCharacter,
      );
    });
  });

  group('Operand zu lang', () {
    test('erster Operand mit 13 Ziffern', () {
      final result = parser.parse('1234567890123 + 1');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.operandTooLong,
      );
    });

    test('zweiter Operand mit 13 Ziffern', () {
      final result = parser.parse('1 + 1234567890123');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.operandTooLong,
      );
    });

    test('Dezimaloperand mit 13 Ziffern (Punkt zählt nicht)', () {
      // 1234567.890123 hat 13 sichtbare Ziffern
      final result = parser.parse('1234567.890123 + 1');

      expect(result, isA<ParseError>());
      expect(
        (result as ParseError).failure.type,
        ParseFailureType.operandTooLong,
      );
    });
  });
}
