# Implementierungsplan: Calculator App

## Übersicht

Dieser Plan beschreibt die schrittweise Implementierung der Taschenrechner-App als Flutter-Anwendung mit Clean Architecture. Die Umsetzung erfolgt in Dart mit Cubit (flutter_bloc) als State-Management-Lösung. Jeder Schritt baut auf den vorherigen auf und endet mit der vollständigen Integration aller Komponenten.

## Tasks

- [ ] 1. Projektstruktur und Abhängigkeiten einrichten
  - [ ] 1.1 Verzeichnisstruktur und pubspec.yaml konfigurieren
    - Verzeichnisstruktur unter `lib/` und `test/` gemäß Design anlegen
    - `pubspec.yaml` um Produktions-Abhängigkeiten erweitern: `flutter_bloc: ^8.1.0`, `equatable: ^2.0.5`, `decimal: ^3.0.0`
    - `pubspec.yaml` um Test-Abhängigkeiten erweitern: `glados: ^1.1.1`, `bloc_test: ^9.1.0`, `mocktail: ^1.0.0`
    - `flutter pub get` ausführen
    - _Requirements: 4.8, 5.4_

  - [ ] 1.2 Core Result-Typen implementieren
    - `lib/core/result/result.dart` mit `sealed class CalculationResult`, `CalculationSuccess`, `CalculationError` erstellen
    - `sealed class ParseResult`, `ParseSuccess`, `ParseError` erstellen
    - Alle Klassen mit `Equatable` ausstatten
    - _Requirements: 1.3, 1.7, 6.3_

- [ ] 2. Domain-Entities und Failures implementieren
  - [ ] 2.1 OperatorType und CalculationExpression erstellen
    - `lib/features/calculator/domain/entities/operator_type.dart` mit Enum und Symbol-Extension
    - `lib/features/calculator/domain/entities/calculation_expression.dart` mit Equatable
    - _Requirements: 1.2, 6.1_

  - [ ] 2.2 Failure-Klassen erstellen
    - `lib/features/calculator/domain/failures/calculation_failure.dart` mit `CalculationFailureType` Enum und `CalculationFailure` Klasse
    - `lib/features/calculator/domain/failures/parse_failure.dart` mit `ParseFailureType` Enum und `ParseFailure` Klasse
    - _Requirements: 1.3, 6.3, 6.4_

  - [ ] 2.3 App-Konstanten definieren
    - `lib/core/constants/app_constants.dart` mit maximalem Ziffernlimit (12), numerischem Bereich (-999999999999 bis 999999999999)
    - _Requirements: 1.4, 2.6_

- [ ] 3. CalculatorEngine implementieren
  - [ ] 3.1 CalculatorEngine Use Case erstellen
    - `lib/features/calculator/domain/usecases/calculator_engine.dart` implementieren
    - Addition, Subtraktion, Multiplikation, Division mit `Decimal`-Paket
    - Division-durch-Null-Prüfung mit `CalculationFailureType.divisionByZero`
    - Overflow-Prüfung für Ergebnisse außerhalb des unterstützten Bereichs
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [ ]* 3.2 Property-Test: Korrekte arithmetische Berechnung
    - **Property 1: Korrekte arithmetische Berechnung**
    - **Validates: Requirement 1**
    - Für jede gültige CalculationExpression mit Operanden im unterstützten Bereich das mathematisch korrekte Ergebnis prüfen

  - [ ]* 3.3 Property-Test: Division durch Null ergibt Fehler
    - **Property 2: Division durch Null ergibt Fehler**
    - **Validates: Requirement 1**
    - Für jeden gültigen ersten Operanden mit Operator Division und zweitem Operand 0 einen divisionByZero-Fehler prüfen

  - [ ]* 3.4 Unit-Tests für CalculatorEngine
    - Konkrete Beispiele für Addition, Subtraktion, Multiplikation, Division
    - Edge Cases: Division durch Null, Overflow, Grenzwerte des numerischen Bereichs
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [ ] 4. ExpressionParser und ExpressionFormatter implementieren
  - [ ] 4.1 ExpressionParser implementieren
    - `lib/features/calculator/domain/usecases/expression_parser.dart` erstellen
    - Parsing im Format `{Operand1} {Operator} {Operand2}`
    - Validierung: fehlender Operand, fehlender Operator, ungültiges Zeichen, Operand zu lang
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [ ] 4.2 ExpressionFormatter implementieren
    - `lib/features/calculator/domain/usecases/expression_formatter.dart` erstellen
    - `formatExpression`: Ausgabe im Format `{Operand1} {Operator} {Operand2}`
    - `formatNumber`: Führende Nullen entfernen, nachgestellte Nullen entfernen, maximal 12 sichtbare Ziffern, Rundung bei Bedarf
    - _Requirements: 6.5, 6.6, 6.7, 6.9_

  - [ ]* 4.3 Property-Test: Round-Trip Parser/Formatter
    - **Property 12: Round-Trip Parser/Formatter**
    - **Validates: Requirement 6**
    - Für jede gültige CalculationExpression mit Operanden ≤ 12 sichtbare Ziffern: formatieren → parsen → numerisch gleiche Operanden und identischer Operator

  - [ ]* 4.4 Property-Test: Formatter-Invarianten
    - **Property 13: Formatter-Invarianten**
    - **Validates: Requirement 6**
    - Formatierte Ausgabe enthält keine unerlaubten führenden Nullen, maximal 12 sichtbare Ziffern pro Operand, korrektes Format

  - [ ]* 4.5 Property-Test: Parser erkennt ungültige Eingaben
    - **Property 14: Parser erkennt ungültige Eingaben**
    - **Validates: Requirement 6**
    - Für jede ungültige Eingabe einen ParseFailure mit passendem Fehlertyp prüfen

  - [ ]* 4.6 Unit-Tests für ExpressionParser und ExpressionFormatter
    - Parser: gültige Ausdrücke, fehlender Operand, fehlender Operator, ungültiges Zeichen, Operand zu lang
    - Formatter: führende Nullen, Dezimalzahlen, Rundung, negative Ergebnisse
    - _Requirements: 6.1–6.9_

- [ ] 5. Checkpoint – Zwischenstand prüfen
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. CalculatorState und CalculatorStatus implementieren
  - [ ] 6.1 CalculatorStatus und CalculatorState erstellen
    - `lib/features/calculator/presentation/cubit/calculator_status.dart` mit Enum
    - `lib/features/calculator/presentation/cubit/calculator_state.dart` mit Equatable, copyWith und Clear-Flags
    - Initialzustand als `static const initial`
    - _Requirements: 5.1, 5.2, 5.3, 5.5_

  - [ ]* 6.2 Property-Test: State-Wertgleichheit
    - **Property 11: State-Wertgleichheit**
    - **Validates: Requirement 5**
    - Zwei CalculatorState-Instanzen mit identischen Feldwerten sind gleich; copyWith erzeugt neue Instanz ohne Mutation

  - [ ]* 6.3 Unit-Tests für CalculatorState
    - Initialzustand prüfen, copyWith-Verhalten, Wertgleichheit, Clear-Flags
    - _Requirements: 5.1, 5.5, 5.6_

- [ ] 7. CalculatorCubit implementieren
  - [ ] 7.1 CalculatorCubit erstellen
    - `lib/features/calculator/presentation/cubit/calculator_cubit.dart` implementieren
    - Methoden: `inputDigit`, `inputDecimalPoint`, `selectOperator`, `calculate`, `clear`, `backspace`
    - Zustandsübergänge gemäß State-Machine im Design
    - Eingaberegeln: keine führenden Nullen, maximal 12 Ziffern, ein Dezimalpunkt
    - _Requirements: 1.1, 1.5, 1.6, 1.8, 1.9, 1.10, 2.1–2.7, 3.1–3.6, 5.3, 5.6, 9.1–9.7_

  - [ ]* 7.2 Property-Test: Keine führenden Nullen
    - **Property 6: Keine führenden Nullen**
    - **Validates: Requirement 2**
    - Für jede Sequenz von Zifferneingaben enthält currentInput keine führenden Nullen (außer "0" oder "0.")

  - [ ]* 7.3 Property-Test: Dezimalpunkt-Invariante
    - **Property 7: Dezimalpunkt-Invariante**
    - **Validates: Requirement 2**
    - Für jede Sequenz von Ziffern- und Dezimalpunkt-Eingaben enthält currentInput maximal einen Dezimalpunkt

  - [ ]* 7.4 Property-Test: Maximale Ziffernanzahl
    - **Property 8: Maximale Ziffernanzahl**
    - **Validates: Requirement 2**
    - Anzahl sichtbarer Ziffern in currentInput nie größer als 12

  - [ ]* 7.5 Property-Test: Clear setzt auf Initialzustand
    - **Property 9: Clear setzt auf Initialzustand**
    - **Validates: Requirement 3, Requirement 5**
    - Für jeden beliebigen CalculatorState soll nach clear() der Zustand exakt CalculatorState.initial entsprechen

  - [ ]* 7.6 Property-Test: Backspace entfernt letztes Zeichen
    - **Property 10: Backspace entfernt letztes Zeichen**
    - **Validates: Requirement 3**
    - Für Eingabe mit mehr als einem Zeichen entfernt backspace() das letzte Zeichen; bei einstelliger Eingabe wird currentInput auf "0" gesetzt

  - [ ]* 7.7 Property-Test: Fehlerzustand wird korrekt betreten und verlassen
    - **Property 4: Fehlerzustand wird korrekt betreten und verlassen**
    - **Validates: Requirement 1, Requirement 3, Requirement 5**
    - CalculationFailure → status == error; Ziffern-/Dezimalpunkt-Eingabe im error-Status startet neue Berechnung

  - [ ]* 7.8 Property-Test: Ergebnis als Operand oder neue Berechnung
    - **Property 5: Ergebnis als Operand oder neue Berechnung**
    - **Validates: Requirement 1, Requirement 5**
    - Bei resultShown: Operator-Eingabe übernimmt Ergebnis als firstOperand; Zifferneingabe startet neue Berechnung

  - [ ]* 7.9 Property-Test: Sequenzielle Auswertung ohne Operatorpräzedenz
    - **Property 3: Sequenzielle Auswertung ohne Operatorpräzedenz**
    - **Validates: Requirement 1**
    - Für Sequenzen von mindestens zwei Operationen erfolgt die Auswertung strikt von links nach rechts

  - [ ]* 7.10 Property-Test: Operator-Ersetzung
    - **Property 15: Operator-Ersetzung**
    - **Validates: Requirement 5, Requirement 8**
    - Bei status == operatorSelected und neuem Operator: selectedOperator wird ersetzt, firstOperand bleibt unverändert

  - [ ]* 7.11 Unit-Tests für CalculatorCubit
    - Zifferneingabe, Dezimalpunkt, Operatorwahl, Gleichheit, Clear, Backspace
    - Fehler-Recovery, Ergebnis als Operand, sequenzielle Auswertung
    - Besondere Eingabefälle gemäß Requirement 9
    - _Requirements: 1.1–1.10, 2.1–2.10, 3.1–3.6, 5.1–5.9, 9.1–9.7_

- [ ] 8. Checkpoint – Domain und State vollständig prüfen
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. UI-Widgets implementieren
  - [ ] 9.1 CalculatorButton Widget erstellen
    - `lib/features/calculator/presentation/widgets/calculator_button.dart` implementieren
    - Parameter: label, backgroundColor, onPressed, isActive
    - Visuelles Pressed-Feedback (InkWell/ElevatedButton)
    - Mindestgröße 48×48 logische Pixel
    - Aktive Operator-Hervorhebung über isActive
    - _Requirements: 4.1, 4.2, 7.2, 8.1, 8.4_

  - [ ] 9.2 DisplayPanel Widget erstellen
    - `lib/features/calculator/presentation/widgets/display_panel.dart` implementieren
    - Parameter: displayText, expressionText (optional)
    - Hauptanzeige und optionale Nebenanzeige
    - _Requirements: 4.3, 4.4, 2.8_

  - [ ] 9.3 ButtonGrid Widget erstellen
    - `lib/features/calculator/presentation/widgets/button_grid.dart` implementieren
    - 4 Spalten, 5 Reihen Layout gemäß Design
    - Callbacks: onDigitPressed, onDecimalPressed, onOperatorPressed, onEqualsPressed, onClearPressed, onBackspacePressed
    - activeOperator-Parameter für Hervorhebung
    - Farbliche Unterscheidung Operator-/Ziffern-Tasten (Kontrastverhältnis ≥ 3:1)
    - _Requirements: 4.5, 4.6, 4.7, 8.2, 8.3, 8.5_

  - [ ]* 9.4 Widget-Tests für CalculatorButton, DisplayPanel und ButtonGrid
    - CalculatorButton: Instanziierung, Tap-Callback, aktiver Zustand, Mindestgröße
    - DisplayPanel: Hauptanzeige, Nebenanzeige, Fehlertext
    - ButtonGrid: Vollständigkeit der Tasten, aktive Operator-Hervorhebung
    - _Requirements: 4.9, 8.1, 8.4_

- [ ] 10. CalculatorPage und Integration
  - [ ] 10.1 CalculatorPage implementieren
    - `lib/features/calculator/presentation/pages/calculator_page.dart` erstellen
    - BlocProvider für CalculatorCubit
    - Layout-Entscheidung via LayoutBuilder und OrientationBuilder
    - Hochformat: DisplayPanel oben (30–36%), ButtonGrid unten (64–70%)
    - Querformat: DisplayPanel links (30–40%), ButtonGrid rechts (60–70%)
    - Ableitung von displayText und expressionText aus CalculatorState
    - Scrollbar bei zu kleinem Bildschirm
    - _Requirements: 7.1, 7.3, 7.4, 7.5, 5.7, 5.8, 5.9_

  - [ ] 10.2 main.dart aktualisieren
    - `lib/main.dart` anpassen: Counter-Template entfernen, CalculatorPage als Home-Screen einbinden
    - _Requirements: 4.8_

  - [ ]* 10.3 Widget-Tests für CalculatorPage
    - Hochformat- und Querformat-Layout prüfen
    - Cubit-Integration testen
    - Responsivität bei verschiedenen Bildschirmgrößen
    - _Requirements: 7.1, 7.3, 7.4, 7.5_

- [ ] 11. Abschluss-Checkpoint – Alle Tests und Integration prüfen
  - Ensure all tests pass, ask the user if questions arise.

## Hinweise

- Tasks mit `*` markiert sind optional und können für ein schnelleres MVP übersprungen werden
- Jeder Task referenziert spezifische Requirements für Nachverfolgbarkeit
- Checkpoints stellen inkrementelle Validierung sicher
- Property-Tests validieren universelle Korrektheitseigenschaften aus dem Design
- Unit-Tests validieren spezifische Beispiele und Edge Cases
- Die Implementierungssprache ist Dart (Flutter), wie im Design-Dokument spezifiziert

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "2.3"] },
    { "id": 2, "tasks": ["2.1", "2.2"] },
    { "id": 3, "tasks": ["3.1", "4.1", "4.2"] },
    { "id": 4, "tasks": ["3.2", "3.3", "3.4", "4.3", "4.4", "4.5", "4.6"] },
    { "id": 5, "tasks": ["6.1"] },
    { "id": 6, "tasks": ["6.2", "6.3", "7.1"] },
    { "id": 7, "tasks": ["7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "7.10", "7.11"] },
    { "id": 8, "tasks": ["9.1", "9.2", "9.3"] },
    { "id": 9, "tasks": ["9.4", "10.1"] },
    { "id": 10, "tasks": ["10.2", "10.3"] }
  ]
}
```
