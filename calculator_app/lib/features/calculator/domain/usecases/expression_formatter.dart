import 'package:decimal/decimal.dart';

import '../../../../core/constants/app_constants.dart';
import '../entities/calculation_expression.dart';
import '../entities/operator_type.dart';

/// Domain-Komponente zur Formatierung von Berechnungsausdrücken
/// und numerischen Werten.
///
/// Formatiert [CalculationExpression]-Instanzen in lesbare Zeichenketten
/// und stellt numerische Werte mit maximal [AppConstants.maxDigits]
/// sichtbaren Ziffern dar.
class ExpressionFormatter {
  /// Formatiert eine [CalculationExpression] im Format
  /// `{Operand1} {Operator} {Operand2}`.
  String formatExpression(CalculationExpression expression) {
    final first = formatNumber(expression.firstOperand);
    final op = expression.operator.symbol;
    final second = formatNumber(expression.secondOperand);
    return '$first $op $second';
  }

  /// Formatiert einen [Decimal]-Wert als Zeichenkette.
  ///
  /// Regeln:
  /// - Führende Nullen werden entfernt (außer `0` vor Dezimalpunkt bei Werten < 1).
  /// - Nachgestellte Nullen nach dem Dezimalpunkt werden entfernt.
  /// - Maximal [AppConstants.maxDigits] sichtbare Ziffern.
  /// - Bei Bedarf wird auf [AppConstants.maxDigits] signifikante Ziffern gerundet.
  String formatNumber(Decimal value) {
    final maxDigits = AppConstants.maxDigits;

    // Vorzeichen separat behandeln
    final isNegative = value < Decimal.zero;
    final absValue = isNegative ? -value : value;

    // In String konvertieren
    var str = absValue.toString();

    // Sichtbare Ziffern zählen (alle Ziffern, ohne Dezimalpunkt)
    final visibleDigits = _countVisibleDigits(str);

    // Wenn mehr als maxDigits sichtbare Ziffern, runden
    if (visibleDigits > maxDigits) {
      str = _roundToSignificantDigits(absValue, maxDigits);
    }

    // Nachgestellte Nullen nach Dezimalpunkt entfernen
    str = _removeTrailingZeros(str);

    // Nachgestellten Dezimalpunkt entfernen
    if (str.endsWith('.')) {
      str = str.substring(0, str.length - 1);
    }

    // Vorzeichen wieder hinzufügen
    if (isNegative && str != '0') {
      str = '-$str';
    }

    return str;
  }

  /// Zählt die sichtbaren Ziffern in einer Zahlendarstellung.
  /// Dezimalpunkt wird nicht mitgezählt.
  int _countVisibleDigits(String str) {
    var count = 0;
    for (final char in str.split('')) {
      if (char != '.' && char != '-') {
        count++;
      }
    }
    return count;
  }

  /// Rundet einen Wert auf die angegebene Anzahl signifikanter Ziffern.
  String _roundToSignificantDigits(Decimal absValue, int significantDigits) {
    final str = absValue.toString();

    // Position des Dezimalpunkts finden
    final dotIndex = str.indexOf('.');

    if (dotIndex == -1) {
      // Ganzzahl: Wenn mehr Ziffern als erlaubt, runden
      if (str.length > significantDigits) {
        final excessDigits = str.length - significantDigits;
        // Auf die entsprechende Zehnerpotenz runden
        final divisor = Decimal.parse('1${'0' * excessDigits}');
        final rounded =
            (absValue / divisor).round().toDecimal() * divisor;
        return rounded.toString();
      }
      return str;
    }

    // Dezimalzahl: Signifikante Ziffern bestimmen
    final integerPart = str.substring(0, dotIndex);
    final fractionalPart = str.substring(dotIndex + 1);

    // Ganzzahl-Ziffern (bei "0" vor Dezimalpunkt zählen wir 0)
    final intDigits = integerPart == '0' ? 0 : integerPart.length;

    if (intDigits >= significantDigits) {
      // Ganzzahlteil hat bereits genug oder zu viele Ziffern
      final excessDigits = intDigits - significantDigits;
      if (excessDigits > 0) {
        final divisor = Decimal.parse('1${'0' * excessDigits}');
        final rounded =
            (absValue / divisor).round().toDecimal() * divisor;
        return rounded.toString();
      }
      // Genau richtig viele Ganzzahl-Ziffern, Dezimalteil abschneiden
      return absValue.round().toString();
    }

    // Dezimalstellen, die wir behalten dürfen
    final allowedFractionalDigits = significantDigits - intDigits;

    // Führende Nullen im Dezimalteil zählen (bei Werten < 1 wie 0.00123)
    var leadingZerosInFraction = 0;
    if (integerPart == '0') {
      for (final char in fractionalPart.split('')) {
        if (char == '0') {
          leadingZerosInFraction++;
        } else {
          break;
        }
      }
    }

    // Gesamte erlaubte Dezimalstellen (führende Nullen + signifikante Stellen)
    final totalFractionalPlaces =
        integerPart == '0'
            ? leadingZerosInFraction + significantDigits
            : allowedFractionalDigits;

    // Runden mit Decimal.round(scale: ...)
    final rounded = absValue.round(scale: totalFractionalPlaces);

    return rounded.toString();
  }

  /// Entfernt nachgestellte Nullen nach dem Dezimalpunkt.
  String _removeTrailingZeros(String str) {
    if (!str.contains('.')) return str;

    var result = str;
    while (result.endsWith('0')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
}
