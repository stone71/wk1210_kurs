import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/operator_type.dart';
import 'calculator_status.dart';

class CalculatorState extends Equatable {
  final String currentInput;
  final OperatorType? selectedOperator;
  final Decimal? firstOperand;
  final Decimal? result;
  final CalculatorStatus status;

  const CalculatorState({
    this.currentInput = '0',
    this.selectedOperator,
    this.firstOperand,
    this.result,
    this.status = CalculatorStatus.input,
  });

  static const initial = CalculatorState();

  CalculatorState copyWith({
    String? currentInput,
    OperatorType? selectedOperator,
    bool clearSelectedOperator = false,
    Decimal? firstOperand,
    bool clearFirstOperand = false,
    Decimal? result,
    bool clearResult = false,
    CalculatorStatus? status,
  }) {
    return CalculatorState(
      currentInput: currentInput ?? this.currentInput,
      selectedOperator: clearSelectedOperator
          ? null
          : (selectedOperator ?? this.selectedOperator),
      firstOperand:
          clearFirstOperand ? null : (firstOperand ?? this.firstOperand),
      result: clearResult ? null : (result ?? this.result),
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        currentInput,
        selectedOperator,
        firstOperand,
        result,
        status,
      ];
}
