# Calculator App

Eine Flutter-Taschenrechner-App mit Clean Architecture, die grundlegende arithmetische Operationen (Addition, Subtraktion, Multiplikation, Division) bietet. Die App verwendet Cubit (`flutter_bloc`) für die Zustandsverwaltung und das `decimal`-Paket für präzise Dezimalarithmetik ohne Floating-Point-Artefakte.

## Features

- Addition, Subtraktion, Multiplikation, Division
- Sequenzielle Auswertung (links nach rechts, keine Operatorpräzedenz)
- Dezimalzahlen-Eingabe mit maximal 12 sichtbaren Ziffern
- Fehlerbehandlung: Division durch Null, Overflow
- Responsives Layout (Hoch- und Querformat)
- Visuelles Feedback bei Tastendruck und aktive Operator-Hervorhebung
- Clear (C) und Backspace (⌫) Funktionen

## Architektur

```
lib/
├── main.dart
├── core/
│   ├── constants/app_constants.dart
│   └── result/result.dart
└── features/calculator/
    ├── domain/
    │   ├── entities/          (OperatorType, CalculationExpression)
    │   ├── failures/          (CalculationFailure, ParseFailure)
    │   └── usecases/          (CalculatorEngine, ExpressionParser, ExpressionFormatter)
    └── presentation/
        ├── cubit/             (CalculatorCubit, CalculatorState, CalculatorStatus)
        ├── pages/             (CalculatorPage)
        └── widgets/           (CalculatorButton, ButtonGrid, DisplayPanel)
```

**Domain Layer** – Fachliche Logik ohne Flutter-Abhängigkeiten: Berechnungen, Parsing, Formatierung.

**Presentation Layer** – UI-Widgets und Cubit-basierte Zustandsverwaltung.

## Voraussetzungen

- Flutter SDK ≥ 3.10.7
- Dart SDK (wird mit Flutter mitgeliefert)

## Installation & Ausführen

```bash
cd calculator_app

# Abhängigkeiten installieren
flutter pub get

# App im Debug-Modus starten
flutter run
```

## Tests ausführen

```bash
# Alle Tests (Unit, Property-Based, Widget)
flutter test

# Nur Domain-Tests
flutter test test/features/calculator/domain/

# Nur Cubit-Tests
flutter test test/features/calculator/presentation/cubit/

# Nur Widget-Tests
flutter test test/features/calculator/presentation/widgets/
flutter test test/features/calculator/presentation/pages/

# Statische Analyse
flutter analyze
```

Die Testsuite umfasst 169 Tests:

| Bereich | Typ | Beschreibung |
|---------|-----|--------------|
| CalculatorEngine | Unit + PBT | Arithmetik, Division durch Null, Overflow |
| ExpressionParser | Unit + PBT | Parsing, Fehlertypen, Round-Trip |
| ExpressionFormatter | Unit + PBT | Formatierung, Invarianten |
| CalculatorState | Unit + PBT | Wertgleichheit, copyWith |
| CalculatorCubit | Unit + PBT | Zustandsübergänge, Eingaberegeln |
| Widgets | Widget-Tests | Button, DisplayPanel, ButtonGrid, Page |

**PBT** = Property-Based Tests mit dem `glados`-Paket.

## Abhängigkeiten

| Paket | Version | Zweck |
|-------|---------|-------|
| `flutter_bloc` | ^8.1.0 | State Management (Cubit) |
| `equatable` | ^2.0.5 | Wertgleichheit für State und Entities |
| `decimal` | ^3.0.0 | Präzise Dezimalarithmetik |

### Dev-Abhängigkeiten

| Paket | Version | Zweck |
|-------|---------|-------|
| `glados` | ^1.1.1 | Property-Based Testing |
| `bloc_test` | ^9.1.0 | Cubit/Bloc Test-Utilities |
| `mocktail` | ^1.0.0 | Mocking |

## Bedienung

| Taste | Funktion |
|-------|----------|
| 0–9 | Zifferneingabe |
| . | Dezimalpunkt |
| + − × ÷ | Operator wählen |
| = | Berechnung ausführen |
| C | Alles zurücksetzen |
| ⌫ | Letztes Zeichen löschen |

- Nach einem Ergebnis: Operator-Eingabe rechnet mit dem Ergebnis weiter, Zifferneingabe startet eine neue Berechnung.
- Bei Fehler (z. B. Division durch Null): Zifferneingabe startet automatisch eine neue Berechnung.
