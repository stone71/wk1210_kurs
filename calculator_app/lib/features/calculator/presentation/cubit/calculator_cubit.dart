import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/calculation_expression.dart';
import '../../domain/entities/operator_type.dart';
import '../../domain/usecases/calculator_engine.dart';
import '../../domain/usecases/expression_formatter.dart';
import 'calculator_state.dart';
import 'calculator_status.dart';

/// Cubit für die Zustandsverwaltung des Taschenrechners.
///
/// Verwaltet Benutzereingaben (Ziffern, Dezimalpunkt, Operatoren),
/// löst Berechnungen aus und steuert die Zustandsübergänge
/// gemäß der definierten State-Machine.
class CalculatorCubit extends Cubit<CalculatorState> {
  final CalculatorEngine _engine;
  final ExpressionFormatter _formatter;

  CalculatorCubit({
    required CalculatorEngine engine,
    required ExpressionFormatter formatter,
  })  : _engine = engine,
        _formatter = formatter,
        super(CalculatorState.initial);

  /// Gibt eine Ziffer ein (0–9).
  ///
  /// - Im Fehlerzustand oder nach angezeigtem Ergebnis: neue Berechnung starten.
  /// - Im Status operatorSelected: zweiten Operanden beginnen.
  /// - Führende Nullen werden unterdrückt.
  /// - Maximal 12 sichtbare Ziffern erlaubt.
  void inputDigit(String digit) {
    if (state.status == CalculatorStatus.error) {
      // Fehlerzustand verlassen, neue Berechnung starten
      emit(CalculatorState(
        currentInput: digit == '0' ? '0' : digit,
        status: CalculatorStatus.input,
      ));
      return;
    }

    if (state.status == CalculatorStatus.resultShown) {
      // Neue Berechnung starten, Ergebnis verwerfen
      emit(CalculatorState(
        currentInput: digit == '0' ? '0' : digit,
        status: CalculatorStatus.input,
      ));
      return;
    }

    if (state.status == CalculatorStatus.operatorSelected) {
      // Zweiten Operanden beginnen
      emit(state.copyWith(
        currentInput: digit == '0' ? '0' : digit,
        status: CalculatorStatus.input,
      ));
      return;
    }

    // Normaler Eingabemodus
    final currentInput = state.currentInput;

    // Maximale Ziffernanzahl prüfen
    if (_countVisibleDigits(currentInput) >= AppConstants.maxDigits) {
      return;
    }

    // Führende Nullen unterdrücken
    if (currentInput == '0') {
      if (digit == '0') {
        // 0 bleibt 0
        return;
      }
      // Ziffer 1-9 ersetzt die führende 0
      emit(state.copyWith(currentInput: digit));
      return;
    }

    // Ziffer anhängen
    emit(state.copyWith(currentInput: currentInput + digit));
  }

  /// Gibt einen Dezimalpunkt ein.
  ///
  /// - Im Fehlerzustand oder nach angezeigtem Ergebnis: neue Berechnung mit '0.' starten.
  /// - Im Status operatorSelected: zweiten Operanden mit '0.' beginnen.
  /// - Wenn bereits ein Dezimalpunkt vorhanden ist: ignorieren.
  void inputDecimalPoint() {
    if (state.status == CalculatorStatus.error) {
      emit(const CalculatorState(
        currentInput: '0.',
        status: CalculatorStatus.input,
      ));
      return;
    }

    if (state.status == CalculatorStatus.resultShown) {
      emit(const CalculatorState(
        currentInput: '0.',
        status: CalculatorStatus.input,
      ));
      return;
    }

    if (state.status == CalculatorStatus.operatorSelected) {
      emit(state.copyWith(
        currentInput: '0.',
        status: CalculatorStatus.input,
      ));
      return;
    }

    // Bereits ein Dezimalpunkt vorhanden → ignorieren
    if (state.currentInput.contains('.')) {
      return;
    }

    // Dezimalpunkt anhängen
    final currentInput = state.currentInput;
    if (currentInput.isEmpty || currentInput == '0') {
      emit(state.copyWith(currentInput: '0.'));
    } else {
      emit(state.copyWith(currentInput: '$currentInput.'));
    }
  }

  /// Wählt einen Operator aus.
  ///
  /// - Im Status operatorSelected: Operator ersetzen (Req 9.1).
  ///   Falls bereits ein zweiter Operand eingegeben wurde (status == input
  ///   mit firstOperand und selectedOperator), wird zuerst das Zwischenergebnis
  ///   berechnet (sequenzielle Auswertung).
  /// - Im Status resultShown: Ergebnis als firstOperand verwenden.
  /// - Sonst: currentInput als firstOperand parsen.
  void selectOperator(OperatorType operator) {
    if (state.status == CalculatorStatus.error) {
      return;
    }

    if (state.status == CalculatorStatus.operatorSelected) {
      // Operator ersetzen, firstOperand bleibt
      emit(state.copyWith(selectedOperator: operator));
      return;
    }

    if (state.status == CalculatorStatus.resultShown) {
      // Ergebnis als firstOperand verwenden
      emit(CalculatorState(
        currentInput: '0',
        selectedOperator: operator,
        firstOperand: state.result,
        status: CalculatorStatus.operatorSelected,
      ));
      return;
    }

    // Status == input
    // Sequenzielle Auswertung: wenn bereits ein firstOperand und Operator
    // vorhanden sind, berechne das Zwischenergebnis
    if (state.firstOperand != null && state.selectedOperator != null) {
      final secondOperand = Decimal.parse(state.currentInput);
      final expression = CalculationExpression(
        firstOperand: state.firstOperand!,
        operator: state.selectedOperator!,
        secondOperand: secondOperand,
      );

      final result = _engine.calculate(expression);

      switch (result) {
        case CalculationSuccess(:final value):
          emit(CalculatorState(
            currentInput: '0',
            selectedOperator: operator,
            firstOperand: value,
            status: CalculatorStatus.operatorSelected,
          ));
        case CalculationError():
          emit(const CalculatorState(
            currentInput: '0',
            status: CalculatorStatus.error,
          ));
      }
      return;
    }

    // Normaler Fall: currentInput als firstOperand setzen
    final firstOperand = Decimal.parse(state.currentInput);
    emit(CalculatorState(
      currentInput: '0',
      selectedOperator: operator,
      firstOperand: firstOperand,
      status: CalculatorStatus.operatorSelected,
    ));
  }

  /// Führt die Berechnung aus (Gleichheits-Taste).
  ///
  /// - Ohne selectedOperator oder ohne firstOperand: ignorieren (Req 9.2, 9.3).
  /// - Im Status operatorSelected ohne zweiten Operanden: ignorieren.
  /// - Baut CalculationExpression, ruft engine.calculate() auf.
  /// - Bei Erfolg: Ergebnis formatieren, status = resultShown.
  /// - Bei Fehler: status = error.
  void calculate() {
    // Kein Operator oder kein erster Operand → ignorieren
    if (state.selectedOperator == null || state.firstOperand == null) {
      return;
    }

    // Im Status operatorSelected wurde noch kein zweiter Operand eingegeben
    if (state.status == CalculatorStatus.operatorSelected) {
      return;
    }

    // Zweiten Operanden parsen
    final secondOperand = Decimal.parse(state.currentInput);

    final expression = CalculationExpression(
      firstOperand: state.firstOperand!,
      operator: state.selectedOperator!,
      secondOperand: secondOperand,
    );

    final result = _engine.calculate(expression);

    switch (result) {
      case CalculationSuccess(:final value):
        final formattedResult = _formatter.formatNumber(value);
        emit(CalculatorState(
          currentInput: formattedResult,
          result: value,
          status: CalculatorStatus.resultShown,
        ));
      case CalculationError():
        emit(const CalculatorState(
          currentInput: '0',
          status: CalculatorStatus.error,
        ));
    }
  }

  /// Setzt den Zustand auf den Initialzustand zurück (C-Taste).
  void clear() {
    emit(CalculatorState.initial);
  }

  /// Entfernt das letzte Zeichen der aktuellen Eingabe (⌫-Taste).
  ///
  /// - Im Fehlerzustand: auf Initialzustand zurücksetzen (Req 3.6).
  /// - Im Status resultShown: formatiertes Ergebnis als currentInput
  ///   übernehmen und letztes Zeichen entfernen (Req 3.5).
  /// - Bei einstelliger Eingabe: auf '0' setzen.
  /// - Wenn currentInput '0' ist und status == input: ignorieren (Req 3.4).
  void backspace() {
    if (state.status == CalculatorStatus.error) {
      emit(CalculatorState.initial);
      return;
    }

    if (state.status == CalculatorStatus.resultShown) {
      // Ergebnis als Eingabe übernehmen und letztes Zeichen entfernen
      final resultText = state.result != null
          ? _formatter.formatNumber(state.result!)
          : state.currentInput;

      if (resultText.length <= 1) {
        emit(const CalculatorState(
          currentInput: '0',
          status: CalculatorStatus.input,
        ));
      } else {
        final newInput = resultText.substring(0, resultText.length - 1);
        // Wenn nach dem Entfernen nur ein Minus übrig bleibt, auf '0' setzen
        final effectiveInput = newInput == '-' ? '0' : newInput;
        emit(CalculatorState(
          currentInput: effectiveInput,
          status: CalculatorStatus.input,
        ));
      }
      return;
    }

    // Im normalen Eingabemodus
    final currentInput = state.currentInput;

    // Wenn currentInput '0' ist: ignorieren (Req 3.4)
    if (currentInput == '0') {
      return;
    }

    // Letztes Zeichen entfernen
    if (currentInput.length <= 1) {
      emit(state.copyWith(currentInput: '0'));
    } else {
      final newInput = currentInput.substring(0, currentInput.length - 1);
      // Wenn nach dem Entfernen nur ein Minus übrig bleibt, auf '0' setzen
      final effectiveInput = newInput == '-' ? '0' : newInput;
      emit(state.copyWith(currentInput: effectiveInput));
    }
  }

  /// Zählt die sichtbaren Ziffern in einer Zahlendarstellung.
  /// Dezimalpunkt und Minuszeichen werden nicht mitgezählt.
  int _countVisibleDigits(String input) {
    var count = 0;
    for (final char in input.split('')) {
      if (char != '.' && char != '-') {
        count++;
      }
    }
    return count;
  }
}
