import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import '../../features/calculator/domain/entities/calculation_expression.dart';
import '../../features/calculator/domain/failures/calculation_failure.dart';
import '../../features/calculator/domain/failures/parse_failure.dart';

// --- CalculationResult ---

sealed class CalculationResult extends Equatable {
  const CalculationResult();
}

class CalculationSuccess extends CalculationResult {
  final Decimal value;

  const CalculationSuccess(this.value);

  @override
  List<Object?> get props => [value];
}

class CalculationError extends CalculationResult {
  final CalculationFailure failure;

  const CalculationError(this.failure);

  @override
  List<Object?> get props => [failure];
}

// --- ParseResult ---

sealed class ParseResult extends Equatable {
  const ParseResult();
}

class ParseSuccess extends ParseResult {
  final CalculationExpression expression;

  const ParseSuccess(this.expression);

  @override
  List<Object?> get props => [expression];
}

class ParseError extends ParseResult {
  final ParseFailure failure;

  const ParseError(this.failure);

  @override
  List<Object?> get props => [failure];
}
