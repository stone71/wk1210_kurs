import 'package:decimal/decimal.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/result/result.dart';
import '../entities/calculation_expression.dart';
import '../entities/operator_type.dart';
import '../failures/parse_failure.dart';

/// Domain-Komponente zum Parsen formatierter Ausdrücke.
///
/// Erwartet Eingaben im Format `{Operand1} {Operator} {Operand2}`
/// (durch Leerzeichen getrennt). Unterstützte Operatoren: +, −, ×, ÷.
class ExpressionParser {
  /// Operator-Symbole auf [OperatorType] abbilden.
  static const _operatorMap = <String, OperatorType>{
    '+': OperatorType.addition,
    '−': OperatorType.subtraction, // U+2212
    '×': OperatorType.multiplication,
    '÷': OperatorType.division,
  };

  /// Parst einen Ausdruck im Format `{Operand1} {Operator} {Operand2}`.
  ///
  /// Gibt [ParseSuccess] bei gültigem Ausdruck zurück,
  /// oder [ParseError] mit passendem [ParseFailure] bei ungültiger Eingabe.
  ParseResult parse(String input) {
    // Eingabe in Teile aufteilen
    final parts = input.split(' ');

    // Leere Eingabe oder nur Leerzeichen → fehlender Operand
    if (parts.isEmpty || (parts.length == 1 && parts[0].isEmpty)) {
      return const ParseError(
        ParseFailure(ParseFailureType.missingOperand),
      );
    }

    // Genau ein Teil → fehlender Operator oder fehlender Operand
    if (parts.length == 1) {
      // Wenn der einzelne Teil ein Operator ist → fehlender Operand
      if (_operatorMap.containsKey(parts[0])) {
        return const ParseError(
          ParseFailure(ParseFailureType.missingOperand),
        );
      }
      // Prüfen ob der einzelne Teil ein gültiger Operand ist
      final validationError = _validateOperandCharacters(parts[0]);
      if (validationError != null) return validationError;
      return const ParseError(
        ParseFailure(ParseFailureType.missingOperator),
      );
    }

    // Genau zwei Teile → entweder fehlender Operand oder fehlender Operator
    if (parts.length == 2) {
      // Prüfen ob einer der Teile ein Operator ist
      if (_operatorMap.containsKey(parts[0])) {
        // Operator am Anfang → fehlender erster Operand
        return const ParseError(
          ParseFailure(ParseFailureType.missingOperand),
        );
      }
      if (_operatorMap.containsKey(parts[1])) {
        // Operator am Ende → fehlender zweiter Operand
        return const ParseError(
          ParseFailure(ParseFailureType.missingOperand),
        );
      }
      // Zwei Operanden ohne Operator
      final validationError1 = _validateOperandCharacters(parts[0]);
      if (validationError1 != null) return validationError1;
      final validationError2 = _validateOperandCharacters(parts[1]);
      if (validationError2 != null) return validationError2;
      return const ParseError(
        ParseFailure(ParseFailureType.missingOperator),
      );
    }

    // Drei oder mehr Teile → Operator identifizieren
    // Suche den Operator unter den Teilen
    int? operatorIndex;
    OperatorType? operatorType;

    for (var i = 0; i < parts.length; i++) {
      if (_operatorMap.containsKey(parts[i])) {
        operatorIndex = i;
        operatorType = _operatorMap[parts[i]];
        break;
      }
    }

    // Kein Operator gefunden
    if (operatorIndex == null || operatorType == null) {
      // Prüfe auf ungültige Zeichen in allen Teilen
      for (final part in parts) {
        final validationError = _validateOperandCharacters(part);
        if (validationError != null) return validationError;
      }
      return const ParseError(
        ParseFailure(ParseFailureType.missingOperator),
      );
    }

    // Operator am Anfang → fehlender erster Operand
    if (operatorIndex == 0) {
      return const ParseError(
        ParseFailure(ParseFailureType.missingOperand),
      );
    }

    // Operator am Ende → fehlender zweiter Operand
    if (operatorIndex == parts.length - 1) {
      return const ParseError(
        ParseFailure(ParseFailureType.missingOperand),
      );
    }

    // Erwartetes Format: genau 3 Teile (Operand1, Operator, Operand2)
    if (parts.length != 3) {
      // Mehr als 3 Teile → ungültiges Zeichen (zusätzliche Leerzeichen/Teile)
      return const ParseError(
        ParseFailure(ParseFailureType.invalidCharacter),
      );
    }

    final operand1Str = parts[0];
    final operand2Str = parts[2];

    // Zeichenvalidierung der Operanden
    final validationError1 = _validateOperandCharacters(operand1Str);
    if (validationError1 != null) return validationError1;

    final validationError2 = _validateOperandCharacters(operand2Str);
    if (validationError2 != null) return validationError2;

    // Operandenlänge prüfen (max 12 sichtbare Ziffern)
    if (_countVisibleDigits(operand1Str) > AppConstants.maxDigits) {
      return const ParseError(
        ParseFailure(ParseFailureType.operandTooLong),
      );
    }

    if (_countVisibleDigits(operand2Str) > AppConstants.maxDigits) {
      return const ParseError(
        ParseFailure(ParseFailureType.operandTooLong),
      );
    }

    // Operanden parsen
    final firstOperand = Decimal.tryParse(operand1Str);
    final secondOperand = Decimal.tryParse(operand2Str);

    if (firstOperand == null || secondOperand == null) {
      return const ParseError(
        ParseFailure(ParseFailureType.invalidCharacter),
      );
    }

    return ParseSuccess(
      CalculationExpression(
        firstOperand: firstOperand,
        operator: operatorType,
        secondOperand: secondOperand,
      ),
    );
  }

  /// Zählt die sichtbaren Ziffern eines Operanden.
  /// Dezimalpunkt und Minuszeichen zählen nicht.
  int _countVisibleDigits(String operand) {
    var count = 0;
    for (final char in operand.split('')) {
      if (RegExp(r'[0-9]').hasMatch(char)) {
        count++;
      }
    }
    return count;
  }

  /// Prüft ob ein Operand nur gültige Zeichen enthält (Ziffern, Dezimalpunkt, Minus).
  /// Gibt [ParseError] zurück bei ungültigen Zeichen, sonst null.
  ParseResult? _validateOperandCharacters(String operand) {
    if (operand.isEmpty) {
      return const ParseError(
        ParseFailure(ParseFailureType.missingOperand),
      );
    }
    for (final char in operand.split('')) {
      if (!RegExp(r'[0-9.\-]').hasMatch(char)) {
        return const ParseError(
          ParseFailure(ParseFailureType.invalidCharacter),
        );
      }
    }
    return null;
  }
}
