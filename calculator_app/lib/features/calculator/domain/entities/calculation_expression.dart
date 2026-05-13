import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'operator_type.dart';

class CalculationExpression extends Equatable {
  final Decimal firstOperand;
  final OperatorType operator;
  final Decimal secondOperand;

  const CalculationExpression({
    required this.firstOperand,
    required this.operator,
    required this.secondOperand,
  });

  @override
  List<Object?> get props => [firstOperand, operator, secondOperand];
}
