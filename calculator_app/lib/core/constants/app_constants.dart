/// App-weite Konstanten für den Taschenrechner.
abstract final class AppConstants {
  /// Maximale Anzahl sichtbarer Ziffern pro Operand.
  /// Dezimalpunkt und Minuszeichen zählen nicht als Ziffern.
  static const int maxDigits = 12;

  /// Obere Grenze des unterstützten numerischen Bereichs.
  static const int maxValue = 999999999999;

  /// Untere Grenze des unterstützten numerischen Bereichs.
  static const int minValue = -999999999999;
}
