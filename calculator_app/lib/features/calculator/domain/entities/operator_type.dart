enum OperatorType {
  addition,
  subtraction,
  multiplication,
  division,
}

extension OperatorTypeSymbol on OperatorType {
  String get symbol => switch (this) {
    OperatorType.addition => '+',
    OperatorType.subtraction => '−',
    OperatorType.multiplication => '×',
    OperatorType.division => '÷',
  };
}
