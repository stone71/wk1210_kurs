import 'package:flutter/material.dart';

import '../../domain/entities/operator_type.dart';
import 'calculator_button.dart';

/// A grid of calculator buttons arranged in 4 columns and 5 rows.
///
/// Layout:
/// ```
/// | C | ⌫ | ÷ | × |
/// | 7 | 8 | 9 | − |
/// | 4 | 5 | 6 | + |
/// | 1 | 2 | 3 | = |
/// | 0 | . |   |   |
/// ```
///
/// The last row contains "0" and "." as interactive buttons,
/// with two non-interactive spacers in the remaining cells.
class ButtonGrid extends StatelessWidget {
  /// Callback when a digit button (0–9) is pressed.
  final void Function(String digit) onDigitPressed;

  /// Callback when the decimal point button is pressed.
  final VoidCallback onDecimalPressed;

  /// Callback when an operator button (÷, ×, −, +) is pressed.
  final void Function(OperatorType operator) onOperatorPressed;

  /// Callback when the equals button is pressed.
  final VoidCallback onEqualsPressed;

  /// Callback when the clear (C) button is pressed.
  final VoidCallback onClearPressed;

  /// Callback when the backspace (⌫) button is pressed.
  final VoidCallback onBackspacePressed;

  /// The currently active operator for visual highlighting.
  /// When set, the matching operator button displays as active.
  final OperatorType? activeOperator;

  const ButtonGrid({
    required this.onDigitPressed,
    required this.onDecimalPressed,
    required this.onOperatorPressed,
    required this.onEqualsPressed,
    required this.onClearPressed,
    required this.onBackspacePressed,
    this.activeOperator,
    super.key,
  });

  // Color constants for button categories.
  // Operator buttons: orange (#FF9500) on digit buttons: dark gray (#333333)
  // gives a contrast ratio well above 3:1.
  static const Color _operatorColor = Color(0xFFFF9500);
  static const Color _digitColor = Color(0xFF333333);
  static const Color _functionColor = Color(0xFFA5A5A5);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.0;
        final availableWidth = constraints.maxWidth - (3 * spacing);
        final availableHeight = constraints.maxHeight - (4 * spacing);
        final buttonWidth = availableWidth / 4;
        final buttonHeight = availableHeight / 5;

        return Column(
          children: [
            // Row 1: C, ⌫, ÷, ×
            _buildRow(
              spacing: spacing,
              height: buttonHeight,
              children: [
                _buildFunctionButton('C', onClearPressed, buttonWidth),
                _buildFunctionButton('⌫', onBackspacePressed, buttonWidth),
                _buildOperatorButton(
                    '÷', OperatorType.division, buttonWidth),
                _buildOperatorButton(
                    '×', OperatorType.multiplication, buttonWidth),
              ],
            ),
            SizedBox(height: spacing),
            // Row 2: 7, 8, 9, −
            _buildRow(
              spacing: spacing,
              height: buttonHeight,
              children: [
                _buildDigitButton('7', buttonWidth),
                _buildDigitButton('8', buttonWidth),
                _buildDigitButton('9', buttonWidth),
                _buildOperatorButton(
                    '−', OperatorType.subtraction, buttonWidth),
              ],
            ),
            SizedBox(height: spacing),
            // Row 3: 4, 5, 6, +
            _buildRow(
              spacing: spacing,
              height: buttonHeight,
              children: [
                _buildDigitButton('4', buttonWidth),
                _buildDigitButton('5', buttonWidth),
                _buildDigitButton('6', buttonWidth),
                _buildOperatorButton(
                    '+', OperatorType.addition, buttonWidth),
              ],
            ),
            SizedBox(height: spacing),
            // Row 4: 1, 2, 3, =
            _buildRow(
              spacing: spacing,
              height: buttonHeight,
              children: [
                _buildDigitButton('1', buttonWidth),
                _buildDigitButton('2', buttonWidth),
                _buildDigitButton('3', buttonWidth),
                _buildEqualsButton(buttonWidth),
              ],
            ),
            SizedBox(height: spacing),
            // Row 5: 0, ., [spacer], [spacer]
            _buildRow(
              spacing: spacing,
              height: buttonHeight,
              children: [
                _buildDigitButton('0', buttonWidth),
                _buildDecimalButton(buttonWidth),
                SizedBox(width: buttonWidth),
                SizedBox(width: buttonWidth),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow({
    required double spacing,
    required double height,
    required List<Widget> children,
  }) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildDigitButton(String digit, double width) {
    return CalculatorButton(
      label: digit,
      backgroundColor: _digitColor,
      onPressed: () => onDigitPressed(digit),
    );
  }

  Widget _buildOperatorButton(
      String label, OperatorType operator, double width) {
    return CalculatorButton(
      label: label,
      backgroundColor: _operatorColor,
      onPressed: () => onOperatorPressed(operator),
      isActive: activeOperator == operator,
    );
  }

  Widget _buildFunctionButton(String label, VoidCallback onPressed, double width) {
    return CalculatorButton(
      label: label,
      backgroundColor: _functionColor,
      onPressed: onPressed,
    );
  }

  Widget _buildEqualsButton(double width) {
    return CalculatorButton(
      label: '=',
      backgroundColor: _operatorColor,
      onPressed: onEqualsPressed,
    );
  }

  Widget _buildDecimalButton(double width) {
    return CalculatorButton(
      label: '.',
      backgroundColor: _digitColor,
      onPressed: onDecimalPressed,
    );
  }
}
