import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/operator_type.dart';
import '../../domain/usecases/calculator_engine.dart';
import '../../domain/usecases/expression_formatter.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import '../cubit/calculator_status.dart';
import '../widgets/button_grid.dart';
import '../widgets/display_panel.dart';

/// Hauptseite des Taschenrechners.
///
/// Stellt den [CalculatorCubit] via [BlocProvider] bereit,
/// entscheidet über das Layout (Hoch-/Querformat) und
/// leitet abgeleitete Anzeigeinformationen an [DisplayPanel]
/// und [ButtonGrid] weiter.
class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalculatorCubit(
        engine: CalculatorEngine(),
        formatter: ExpressionFormatter(),
      ),
      child: const _CalculatorView(),
    );
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CalculatorCubit, CalculatorState>(
          builder: (context, state) {
            final displayText = _deriveDisplayText(state);
            final expressionText = _deriveExpressionText(state);
            final activeOperator = state.status == CalculatorStatus.operatorSelected
                ? state.selectedOperator
                : null;

            final cubit = context.read<CalculatorCubit>();

            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return _buildPortraitLayout(
                    displayText: displayText,
                    expressionText: expressionText,
                    activeOperator: activeOperator,
                    cubit: cubit,
                  );
                } else {
                  return _buildLandscapeLayout(
                    displayText: displayText,
                    expressionText: expressionText,
                    activeOperator: activeOperator,
                    cubit: cubit,
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  /// Leitet den Hauptanzeigetext aus dem [CalculatorState] ab.
  ///
  /// - status == error → "Fehler"
  /// - status == resultShown && result != null → formatiertes Ergebnis
  /// - sonst → currentInput
  String _deriveDisplayText(CalculatorState state) {
    if (state.status == CalculatorStatus.error) {
      return 'Fehler';
    }
    if (state.status == CalculatorStatus.resultShown && state.result != null) {
      return ExpressionFormatter().formatNumber(state.result!);
    }
    return state.currentInput;
  }

  /// Leitet den Nebenanzeigetext (Ausdruck) aus dem [CalculatorState] ab.
  ///
  /// - firstOperand != null && selectedOperator != null → "{firstOperand} {operator}"
  /// - sonst → null
  String? _deriveExpressionText(CalculatorState state) {
    if (state.firstOperand != null && state.selectedOperator != null) {
      final formattedOperand =
          ExpressionFormatter().formatNumber(state.firstOperand!);
      final operatorSymbol = state.selectedOperator!.symbol;
      return '$formattedOperand $operatorSymbol';
    }
    return null;
  }

  /// Baut das Hochformat-Layout:
  /// DisplayPanel oben (flex 3), ButtonGrid unten (flex 7).
  Widget _buildPortraitLayout({
    required String displayText,
    required String? expressionText,
    required OperatorType? activeOperator,
    required CalculatorCubit cubit,
  }) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: DisplayPanel(
            displayText: displayText,
            expressionText: expressionText,
          ),
        ),
        Expanded(
          flex: 7,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Prüfe ob genug Platz für Mindestgröße 48x48 pro Button
              // 5 Reihen, 4 Spalten, 8px Spacing
              const minButtonSize = 48.0;
              const rows = 5;
              const spacing = 8.0;
              final minRequiredHeight =
                  (rows * minButtonSize) + ((rows - 1) * spacing);

              if (constraints.maxHeight < minRequiredHeight) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: minRequiredHeight,
                    child: _buildButtonGrid(activeOperator, cubit),
                  ),
                );
              }

              return _buildButtonGrid(activeOperator, cubit);
            },
          ),
        ),
      ],
    );
  }

  /// Baut das Querformat-Layout:
  /// DisplayPanel links (flex 3), ButtonGrid rechts (flex 7).
  Widget _buildLandscapeLayout({
    required String displayText,
    required String? expressionText,
    required OperatorType? activeOperator,
    required CalculatorCubit cubit,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DisplayPanel(
            displayText: displayText,
            expressionText: expressionText,
          ),
        ),
        Expanded(
          flex: 7,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Prüfe ob genug Platz für Mindestgröße 48x48 pro Button
              const minButtonSize = 48.0;
              const rows = 5;
              const spacing = 8.0;
              final minRequiredHeight =
                  (rows * minButtonSize) + ((rows - 1) * spacing);

              if (constraints.maxHeight < minRequiredHeight) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: minRequiredHeight,
                    child: _buildButtonGrid(activeOperator, cubit),
                  ),
                );
              }

              return _buildButtonGrid(activeOperator, cubit);
            },
          ),
        ),
      ],
    );
  }

  /// Erstellt das ButtonGrid mit den Callbacks zum Cubit.
  Widget _buildButtonGrid(OperatorType? activeOperator, CalculatorCubit cubit) {
    return ButtonGrid(
      onDigitPressed: cubit.inputDigit,
      onDecimalPressed: cubit.inputDecimalPoint,
      onOperatorPressed: cubit.selectOperator,
      onEqualsPressed: cubit.calculate,
      onClearPressed: cubit.clear,
      onBackspacePressed: cubit.backspace,
      activeOperator: activeOperator,
    );
  }
}
