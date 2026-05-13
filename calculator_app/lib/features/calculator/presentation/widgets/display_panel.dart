import 'package:flutter/material.dart';

/// Widget zur Anzeige der aktuellen Eingabe und des optionalen Zwischenausdrucks.
///
/// Zeigt [displayText] als Hauptanzeige (groß, rechtsbündig) und optional
/// [expressionText] als kleinere Nebenanzeige darüber.
///
/// Dieses Widget ist unabhängig von Cubit oder Domain-Use-Cases und kann
/// direkt in Widget-Tests instanziiert werden.
class DisplayPanel extends StatelessWidget {
  /// Der Hauptanzeigetext (aktuelle Eingabe oder Ergebnis).
  final String displayText;

  /// Optionaler Nebenanzeigetext (z. B. "5 +").
  final String? expressionText;

  const DisplayPanel({
    required this.displayText,
    this.expressionText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (expressionText != null && expressionText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                expressionText!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              displayText,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
