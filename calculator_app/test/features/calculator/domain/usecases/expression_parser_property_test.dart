import 'package:calculator_app/core/result/result.dart';
import 'package:calculator_app/features/calculator/domain/failures/parse_failure.dart';
import 'package:calculator_app/features/calculator/domain/usecases/expression_parser.dart';
import 'package:glados/glados.dart';

/// **Validates: Requirements 6**
///
/// Property 14: Parser erkennt ungültige Eingaben
/// Für jede ungültige Eingabe soll ExpressionParser einen ParseFailure
/// mit dem passenden Fehlertyp zurückgeben.

/// Generator for operator symbols used by the parser.
final _operatorSymbol = any.intInRange(0, 4).map((i) {
  const symbols = ['+', '−', '×', '÷'];
  return symbols[i];
});

/// Generator for inputs with a missing operand.
/// Produces patterns like: "+", "+ 3", "5 +"
final _missingOperandInput = any.combine2(
  _operatorSymbol,
  any.intInRange(0, 3),
  (String op, int variant) {
    switch (variant) {
      case 0:
        // Only operator, no operands
        return op;
      case 1:
        // Operator at start, operand after: "+ 3"
        return '$op 3';
      default:
        // Operand before, operator at end: "5 +"
        return '5 $op';
    }
  },
);

/// Generator for inputs with two numbers but no operator between them.
/// Produces patterns like: "5 3", "12 45"
final _missingOperatorInput = any.combine2(
  any.intInRange(1, 9999),
  any.intInRange(1, 9999),
  (int a, int b) => '$a $b',
);

/// Generator for inputs where an operand exceeds 12 visible digits.
/// Places the long operand in a valid expression structure.
final _operandTooLongInput = any.combine3(
  any.intInRange(13, 20),
  _operatorSymbol,
  any.intInRange(0, 2),
  (int digitCount, String op, int position) {
    // Generate a number string with exactly digitCount digits
    final buffer = StringBuffer();
    buffer.write('1'); // Start with 1 to avoid leading zero
    for (var i = 1; i < digitCount; i++) {
      buffer.write('0');
    }
    final longOperand = buffer.toString();

    if (position == 0) {
      // Long operand as first operand
      return '$longOperand $op 1';
    } else {
      // Long operand as second operand
      return '1 $op $longOperand';
    }
  },
);

/// Generator for inputs containing invalid characters mixed into
/// a valid expression structure.
final _invalidCharacterInput = any.combine3(
  any.intInRange(0, 10),
  any.intInRange(1, 99),
  _operatorSymbol,
  (int charIndex, int num, String op) {
    const invalidChars = ['a', 'b', 'x', 'z', '#', '@', '!', '%', '&', 'π'];
    final invalidChar = invalidChars[charIndex];
    // Mix invalid character into an operand
    return '$num$invalidChar $op 1';
  },
);

void main() {
  late ExpressionParser parser;

  setUp(() {
    parser = ExpressionParser();
  });

  group('Property 14: Parser erkennt ungültige Eingaben', () {
    /// **Validates: Requirements 6**
    ///
    /// Property 14: Parser erkennt ungültige Eingaben – Missing Operand
    Glados(_missingOperandInput).test(
      'returns ParseError with missingOperand for inputs missing an operand',
      (input) {
        final result = parser.parse(input);

        expect(result, isA<ParseError>());
        expect(
          (result as ParseError).failure.type,
          ParseFailureType.missingOperand,
        );
      },
    );

    /// **Validates: Requirements 6**
    ///
    /// Property 14: Parser erkennt ungültige Eingaben – Missing Operator
    Glados(_missingOperatorInput).test(
      'returns ParseError with missingOperator for inputs missing an operator',
      (input) {
        final result = parser.parse(input);

        expect(result, isA<ParseError>());
        expect(
          (result as ParseError).failure.type,
          ParseFailureType.missingOperator,
        );
      },
    );

    /// **Validates: Requirements 6**
    ///
    /// Property 14: Parser erkennt ungültige Eingaben – Operand Too Long
    Glados(_operandTooLongInput).test(
      'returns ParseError with operandTooLong for operands exceeding 12 digits',
      (input) {
        final result = parser.parse(input);

        expect(result, isA<ParseError>());
        expect(
          (result as ParseError).failure.type,
          ParseFailureType.operandTooLong,
        );
      },
    );

    /// **Validates: Requirements 6**
    ///
    /// Property 14: Parser erkennt ungültige Eingaben – Invalid Characters
    Glados(_invalidCharacterInput).test(
      'returns ParseError with invalidCharacter for inputs with invalid characters',
      (input) {
        final result = parser.parse(input);

        expect(result, isA<ParseError>());
        expect(
          (result as ParseError).failure.type,
          ParseFailureType.invalidCharacter,
        );
      },
    );
  });
}
