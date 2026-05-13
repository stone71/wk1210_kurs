---
inclusion: auto
---

# Flutter Clean Architecture & Coding Standards

## Architektur

- Verwende Clean Architecture mit klarer Schichtentrennung:
  - `lib/core/` — Shared utilities, constants, themes, error handling
  - `lib/features/<feature>/domain/` — Entities, Use Cases, Repository-Interfaces
  - `lib/features/<feature>/data/` — Repository-Implementierungen, Data Sources, Models
  - `lib/features/<feature>/presentation/` — Pages, Widgets, State Management
- Jede Schicht darf nur von der darunterliegenden abhängen (Dependency Rule).
- Business-Logik gehört in Use Cases, nicht in Widgets oder Repositories.

## Widget-Struktur & Wiederverwendbarkeit

- Jedes Widget in eine eigene Datei auslagern, sobald es wiederverwendbar ist oder mehr als ~50 Zeilen umfasst.
- Dateinamen in snake_case: `calculator_button.dart`, `display_panel.dart`
- Wiederverwendbare Widgets unter `lib/core/widgets/` oder `lib/features/<feature>/presentation/widgets/` ablegen.
- Pages (Screens) unter `lib/features/<feature>/presentation/pages/`.
- Composite Widgets (die mehrere kleinere Widgets zusammensetzen) klar von atomaren Widgets trennen.

## State Management

- State Management konsistent innerhalb des Projekts verwenden (z.B. Bloc/Cubit, Riverpod oder Provider — einmal entscheiden, dann durchziehen).
- State-Klassen immutable halten (Equatable oder freezed verwenden).
- UI-State von Business-State trennen.

## Dart/Flutter Code Style

- Dart-Analyse mit `flutter_lints` aktiv halten.
- `const` Constructors verwenden, wo möglich.
- Prefer `final` für lokale Variablen und Felder, die sich nicht ändern.
- Keine Magic Numbers — Konstanten in `lib/core/constants/` definieren.
- Typen explizit angeben bei öffentlichen APIs; `var` nur lokal verwenden.
- Fehlerbehandlung über eigene Exception-/Failure-Klassen in `lib/core/error/`.

## Testing

- Unit Tests für Use Cases und Repositories.
- Widget Tests für wiederverwendbare Widgets.
- Testdateien spiegeln die `lib/`-Struktur unter `test/`.

## Naming Conventions

- Klassen: PascalCase (`CalculatorButton`, `CalculationUseCase`)
- Dateien: snake_case (`calculator_button.dart`)
- Variablen/Methoden: camelCase (`currentResult`, `performCalculation()`)
- Private Members: mit Unterstrich (`_internalState`)

## Sonstiges

- Keine Logik in `main.dart` außer App-Initialisierung und Dependency Injection Setup.
- Routing zentral definieren (z.B. in `lib/core/router/`).
- Assets (Icons, Fonts) unter `assets/` mit Verweis in `pubspec.yaml`.
