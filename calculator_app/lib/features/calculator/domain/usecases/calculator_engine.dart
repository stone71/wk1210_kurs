import 'package:decimal/decimal.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/result/result.dart';
import '../entities/calculation_expression.dart';
import '../entities/operator_type.dart';
import '../failures/calculation_failure.dart';

/// Domain Use Case für arithmetische Berechnungen.
///
/// Führt Addition, Subtraktion, Multiplikation und Division
/// mit dem `Decimal`-Paket durch und prüft auf Division durch Null
/// sowie Overflow.
class CalculatorEngine {
  /// Berechnet das Ergebnis einer [CalculationExpression].
  ///
  /// Gibt [CalculationSuccess] bei gültigem Ergebnis zurück,
  /// oder [CalculationError] bei Division durch Null oder Overflow.
  CalculationResult calculate(CalculationExpression expression) {
    final first = expression.firstOperand;
    final second = expression.secondOperand;

    // Division durch Null prüfen
    if (expression.operator == OperatorType.division &&
        second == Decimal.zero) {
      return const CalculationError(
        CalculationFailure(CalculationFailureType.divisionByZero),
      );
    }

    // Berechnung durchführen
    final Decimal result;
    switch (expression.operator) {
      case OperatorType.addition:
        result = first + second;
      case OperatorType.subtraction:
        result = first - second;
      case OperatorType.multiplication:
        result = first * second;
      case OperatorType.division:
        result = (first / second).toDecimal();
    }

    // Overflow-Prüfung
    final maxValue = Decimal.fromInt(AppConstants.maxValue);
    final minValue = Decimal.fromInt(AppConstants.minValue);

    if (result > maxValue || result < minValue) {
      return const CalculationError(
        CalculationFailure(CalculationFailureType.overflow),
      );
    }

    return CalculationSuccess(result);
  }
}
