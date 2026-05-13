import 'package:calculator_app/core/constants/app_constants.dart';
import 'package:calculator_app/core/result/result.dart';
import 'package:calculator_app/features/calculator/domain/entities/calculation_expression.dart';
import 'package:calculator_app/features/calculator/domain/entities/operator_type.dart';
import 'package:calculator_app/features/calculator/domain/usecases/expression_formatter.dart';
import 'package:calculator_app/features/calculator/domain/usecases/expression_parser.dart';
import 'package:decimal/decimal.dart';
import 'package:glados/glados.dart';

/// Custom generator for Decimal values in the supported operand range.
/// Generates integer-based Decimals.
final _decimalInRange = any.int.map(
  (i) => Decimal.fromInt(i),
);

/// Generator for Decimal values with fractional parts.
final _decimalWithFraction = any.combine2(
  any.int,
  any.intInRange(1, 999999999),
  (int intPart, int fracPart) {
    final sign = intPart < 0 ? '-' : '';
    final absInt = intPart.abs() % 999999999999;
    return Decimal.parse('$sign$absInt.$fracPart');
  },
);

/// Generator for OperatorType values.
final _operatorType = any.intInRange(0, OperatorType.values.length).map(
  (i) => OperatorType.values[i],
);

/// Generator for valid CalculationExpression instances with integer operands.
final _calculationExpression = any.combine3(
  _decimalInRange,
  _operatorType,
  _decimalInRange,
  (Decimal first, OperatorType op, Decimal second) => CalculationExpression(
    firstOperand: first,
    operator: op,
    secondOperand: second,
  ),
);

/// Generator for CalculationExpression with fractional operands.
final _calculationExpressionWithFractions = any.combine3(
  _decimalWithFraction,
  _operatorType,
  _decimalWithFraction,
  (Decimal first, OperatorType op, Decimal second) => CalculationExpression(
    firstOperand: first,
    operator: op,
    secondOperand: second,
  ),
);

/// Checks that an operand string has no disallowed leading zeros.
/// Allowed patterns: "0", "0.xxx", "-0", "-0.xxx"
/// Disallowed: "01", "00", "012", "-01", "-00", etc.
bool hasNoDisallowedLeadingZeros(String operand) {
  // Remove leading minus sign for analysis
  final str = operand.startsWith('-') ? operand.substring(1) : operand;

  // If it starts with '0', the next character must be '.' or there is no next character
  if (str.length > 1 && str.startsWith('0')) {
    if (str[1] != '.') {
      return false;
    }
  }
  return true;
}

/// Counts only digit characters in an operand string.
/// Excludes decimal point and minus sign.
int countVisibleDigits(String operand) {
  var count = 0;
  for (final char in operand.split('')) {
    if (char != '.' && char != '-') {
      count++;
    }
  }
  return count;
}

/// Valid operator symbols used in formatted output.
const _validOperatorSymbols = {'+', '−', '×', '÷'};

/// Generator for Decimal values with ≤ 12 visible digits (integers).
/// Constrains to values within the supported operand range.
final _decimalWithinDigitLimit = any.intInRange(
  AppConstants.minValue,
  AppConstants.maxValue + 1,
).map((i) => Decimal.fromInt(i));

/// Generator for Decimal values with fractional parts and ≤ 12 visible digits.
/// Generates values like "123.456" where total digit count ≤ 12.
final _decimalFractionWithinDigitLimit = any.combine3(
  any.intInRange(0, 999999),
  any.intInRange(1, 999999),
  any.intInRange(0, 2),
  (int intPart, int fracPart, int signFlag) {
    final negative = signFlag == 1;
    final intStr = intPart.toString();
    final fracStr = fracPart.toString();
    final totalDigits = intStr.length + fracStr.length;
    // Ensure total visible digits ≤ 12
    final trimmedFrac = totalDigits > AppConstants.maxDigits
        ? fracStr.substring(0, fracStr.length - (totalDigits - AppConstants.maxDigits))
        : fracStr;
    if (trimmedFrac.isEmpty) {
      final sign = negative ? '-' : '';
      return Decimal.parse('$sign$intPart');
    }
    final sign = negative ? '-' : '';
    return Decimal.parse('$sign$intPart.$trimmedFrac');
  },
);

/// Generator for CalculationExpression with integer operands ≤ 12 digits.
final _expressionForRoundTrip = any.combine3(
  _decimalWithinDigitLimit,
  _operatorType,
  _decimalWithinDigitLimit,
  (Decimal first, OperatorType op, Decimal second) => CalculationExpression(
    firstOperand: first,
    operator: op,
    secondOperand: second,
  ),
);

/// Generator for CalculationExpression with fractional operands ≤ 12 digits.
final _expressionFractionForRoundTrip = any.combine3(
  _decimalFractionWithinDigitLimit,
  _operatorType,
  _decimalFractionWithinDigitLimit,
  (Decimal first, OperatorType op, Decimal second) => CalculationExpression(
    firstOperand: first,
    operator: op,
    secondOperand: second,
  ),
);

void main() {
  late ExpressionFormatter formatter;
  late ExpressionParser parser;

  setUp(() {
    formatter = ExpressionFormatter();
    parser = ExpressionParser();
  });

  group('Property 12: Round-Trip Parser/Formatter', () {
    /// **Validates: Requirement 6**
    ///
    /// Property 12: Round-Trip Parser/Formatter
    /// Für jede gültige CalculationExpression mit Operanden ≤ 12 sichtbare Ziffern:
    /// formatieren → parsen → numerisch gleiche Operanden und identischer Operator.
    Glados(_expressionForRoundTrip).test(
      'round-trip with integer operands: format → parse yields same expression',
      (expression) {
        final formatted = formatter.formatExpression(expression);
        final parseResult = parser.parse(formatted);

        expect(parseResult, isA<ParseSuccess>(),
            reason: 'Parsing formatted expression "$formatted" should succeed');

        final parsed = (parseResult as ParseSuccess).expression;

        expect(parsed.operator, equals(expression.operator),
            reason:
                'Operator should be identical after round-trip. '
                'Original: ${expression.operator}, Parsed: ${parsed.operator}');
        expect(parsed.firstOperand, equals(expression.firstOperand),
            reason:
                'First operand should be numerically equal after round-trip. '
                'Original: ${expression.firstOperand}, Parsed: ${parsed.firstOperand}');
        expect(parsed.secondOperand, equals(expression.secondOperand),
            reason:
                'Second operand should be numerically equal after round-trip. '
                'Original: ${expression.secondOperand}, Parsed: ${parsed.secondOperand}');
      },
    );

    /// **Validates: Requirement 6**
    ///
    /// Property 12: Round-Trip Parser/Formatter
    /// Für jede gültige CalculationExpression mit Dezimaloperanden ≤ 12 sichtbare Ziffern:
    /// formatieren → parsen → numerisch gleiche Operanden und identischer Operator.
    Glados(_expressionFractionForRoundTrip).test(
      'round-trip with fractional operands: format → parse yields same expression',
      (expression) {
        final formatted = formatter.formatExpression(expression);
        final parseResult = parser.parse(formatted);

        expect(parseResult, isA<ParseSuccess>(),
            reason: 'Parsing formatted expression "$formatted" should succeed');

        final parsed = (parseResult as ParseSuccess).expression;

        expect(parsed.operator, equals(expression.operator),
            reason:
                'Operator should be identical after round-trip. '
                'Original: ${expression.operator}, Parsed: ${parsed.operator}');
        expect(parsed.firstOperand, equals(expression.firstOperand),
            reason:
                'First operand should be numerically equal after round-trip. '
                'Original: ${expression.firstOperand}, Parsed: ${parsed.firstOperand}');
        expect(parsed.secondOperand, equals(expression.secondOperand),
            reason:
                'Second operand should be numerically equal after round-trip. '
                'Original: ${expression.secondOperand}, Parsed: ${parsed.secondOperand}');
      },
    );
  });

  group('Property 13: Formatter-Invarianten', () {
    /// **Validates: Requirement 6**
    ///
    /// Property 13: Formatter-Invarianten
    /// Für jede gültige CalculationExpression soll die formatierte Ausgabe
    /// dem Format `{Operand1} {Operator} {Operand2}` folgen (space-separated, 3 parts).
    Glados(_calculationExpression).test(
      'formatted output matches pattern {Operand1} {Operator} {Operand2}',
      (expression) {
        final output = formatter.formatExpression(expression);
        final parts = output.split(' ');

        expect(parts.length, 3,
            reason:
                'Formatted output must have exactly 3 space-separated parts: '
                '"$output"');
      },
    );

    /// **Validates: Requirement 6**
    ///
    /// Property 13: Formatter-Invarianten
    /// Der Operator in der Ausgabe ist einer von +, −, ×, ÷.
    Glados(_calculationExpression).test(
      'operator in output is one of +, −, ×, ÷',
      (expression) {
        final output = formatter.formatExpression(expression);
        final parts = output.split(' ');
        final operatorPart = parts[1];

        expect(_validOperatorSymbols.contains(operatorPart), isTrue,
            reason:
                'Operator "$operatorPart" must be one of +, −, ×, ÷');
      },
    );

    /// **Validates: Requirement 6**
    ///
    /// Property 13: Formatter-Invarianten
    /// Jeder formatierte Operand hat keine unerlaubten führenden Nullen
    /// (integer operands).
    Glados(_calculationExpression).test(
      'no disallowed leading zeros in formatted operands (integer operands)',
      (expression) {
        final output = formatter.formatExpression(expression);
        final parts = output.split(' ');
        final firstOperand = parts[0];
        final secondOperand = parts[2];

        expect(hasNoDisallowedLeadingZeros(firstOperand), isTrue,
            reason:
                'First operand "$firstOperand" has disallowed leading zeros');
        expect(hasNoDisallowedLeadingZeros(secondOperand), isTrue,
            reason:
                'Second operand "$secondOperand" has disallowed leading zeros');
      },
    );

    /// **Validates: Requirement 6**
    ///
    /// Property 13: Formatter-Invarianten
    /// Jeder formatierte Operand hat keine unerlaubten führenden Nullen
    /// (fractional operands).
    Glados(_calculationExpressionWithFractions).test(
      'no disallowed leading zeros in formatted operands (fractional operands)',
      (expression) {
        final output = formatter.formatExpression(expression);
        final parts = output.split(' ');
        final firstOperand = parts[0];
        final secondOperand = parts[2];

        expect(hasNoDisallowedLeadingZeros(firstOperand), isTrue,
            reason:
                'First operand "$firstOperand" has disallowed leading zeros');
        expect(hasNoDisallowedLeadingZeros(secondOperand), isTrue,
            reason:
                'Second operand "$secondOperand" has disallowed leading zeros');
      },
    );

    /// **Validates: Requirement 6**
    ///
    /// Property 13: Formatter-Invarianten
    /// Jeder formatierte Operand hat maximal 12 sichtbare Ziffern
    /// (integer operands).
    Glados(_calculationExpression).test(
      'each formatted operand has at most ${AppConstants.maxDigits} visible digits (integer operands)',
      (expression) {
        final output = formatter.formatExpression(expression);
        final parts = output.split(' ');
        final firstOperand = parts[0];
        final secondOperand = parts[2];

        expect(countVisibleDigits(firstOperand),
            lessThanOrEqualTo(AppConstants.maxDigits),
            reason:
                'First operand "$firstOperand" has ${countVisibleDigits(firstOperand)} visible digits, max is ${AppConstants.maxDigits}');
        expect(countVisibleDigits(secondOperand),
            lessThanOrEqualTo(AppConstants.maxDigits),
            reason:
                'Second operand "$secondOperand" has ${countVisibleDigits(secondOperand)} visible digits, max is ${AppConstants.maxDigits}');
      },
    );

    /// **Validates: Requirement 6**
    ///
    /// Property 13: Formatter-Invarianten
    /// Jeder formatierte Operand hat maximal 12 sichtbare Ziffern
    /// (fractional operands).
    Glados(_calculationExpressionWithFractions).test(
      'each formatted operand has at most ${AppConstants.maxDigits} visible digits (fractional operands)',
      (expression) {
        final output = formatter.formatExpression(expression);
        final parts = output.split(' ');
        final firstOperand = parts[0];
        final secondOperand = parts[2];

        expect(countVisibleDigits(firstOperand),
            lessThanOrEqualTo(AppConstants.maxDigits),
            reason:
                'First operand "$firstOperand" has ${countVisibleDigits(firstOperand)} visible digits, max is ${AppConstants.maxDigits}');
        expect(countVisibleDigits(secondOperand),
            lessThanOrEqualTo(AppConstants.maxDigits),
            reason:
                'Second operand "$secondOperand" has ${countVisibleDigits(secondOperand)} visible digits, max is ${AppConstants.maxDigits}');
      },
    );
  });
}
