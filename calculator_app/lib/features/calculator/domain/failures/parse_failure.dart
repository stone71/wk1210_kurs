import 'package:equatable/equatable.dart';

enum ParseFailureType {
  missingOperand,
  missingOperator,
  invalidCharacter,
  operandTooLong,
}

class ParseFailure extends Equatable {
  final ParseFailureType type;

  const ParseFailure(this.type);

  @override
  List<Object?> get props => [type];
}
