import 'package:equatable/equatable.dart';

enum CalculationFailureType {
  divisionByZero,
  overflow,
}

class CalculationFailure extends Equatable {
  final CalculationFailureType type;

  const CalculationFailure(this.type);

  @override
  List<Object?> get props => [type];
}
