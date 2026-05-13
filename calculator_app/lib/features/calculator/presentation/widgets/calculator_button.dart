import 'package:flutter/material.dart';

/// A reusable calculator button widget with visual pressed feedback
/// and active operator highlighting.
class CalculatorButton extends StatelessWidget {
  /// The text label displayed on the button.
  final String label;

  /// The background color of the button.
  final Color backgroundColor;

  /// Callback invoked when the button is pressed.
  final VoidCallback onPressed;

  /// Whether this button is in an active (highlighted) state,
  /// used for the currently selected operator.
  final bool isActive;

  const CalculatorButton({
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
    this.isActive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isActive
        ? Color.lerp(backgroundColor, Colors.white, 0.4)!
        : backgroundColor;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: _contrastingTextColor(effectiveColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          elevation: isActive ? 4 : 2,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Returns a contrasting text color (black or white) based on the
  /// luminance of the given background color.
  Color _contrastingTextColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
