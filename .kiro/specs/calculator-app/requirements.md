# Requirements Document

## Einleitung

Dieses Dokument beschreibt die Anforderungen für eine Taschenrechner-App, die als Flutter-Anwendung mit Clean Architecture umgesetzt wird. Die App ersetzt das bestehende Counter-Template und bietet grundlegende arithmetische Operationen mit einer übersichtlichen, responsiven Benutzeroberfläche. Die Architektur folgt dem Prinzip der Schichtentrennung zwischen Domain und Presentation. Eine Data-Schicht ist für diese App nur erforderlich, wenn später Persistenz, Konfiguration oder externe Datenquellen ergänzt werden.

Die Anwendung verwendet wiederverwendbare, in separate Dateien ausgelagerte Widgets und eine einheitliche, testbare Zustandsverwaltung.

## Glossar

- **CalculatorApp**: Die Flutter-Taschenrechner-Anwendung als Gesamtsystem.
- **CalculatorEngine**: Domain-Komponente bzw. Use Case, die arithmetische Berechnungen durchführt.
- **CalculationFailure**: Domain-Fehlerobjekt, das einen Berechnungsfehler beschreibt, ohne UI-Texte zu enthalten.
- **DisplayPanel**: Widget zur Anzeige der aktuellen Eingabe, des Zwischenausdrucks und des Ergebnisses.
- **ButtonGrid**: Widget-Raster, das alle Taschenrechner-Tasten enthält.
- **CalculatorButton**: Einzelnes, wiederverwendbares Button-Widget für Ziffern, Operatoren und Steuerfunktionen.
- **CalculatorState**: Immutable Zustand des Taschenrechners.
- **CalculatorStatus**: Status des Taschenrechners, z. B. `input`, `operatorSelected`, `resultShown` oder `error`.
- **ExpressionParser**: Komponente, die formatierte Benutzereingaben in berechenbare Ausdrücke umwandelt.
- **ExpressionFormatter**: Komponente, die berechnete Ergebnisse oder Ausdrücke in darstellbare Zeichenketten formatiert.
- **Operator**: Eine arithmetische Operation: Addition (+), Subtraktion (−), Multiplikation (×) oder Division (÷).
- **Operand**: Numerischer Wert, der in eine Berechnung eingeht.

## Requirements

### Requirement 1: Grundlegende arithmetische Berechnungen

**User Story:** Als Benutzer möchte ich grundlegende arithmetische Berechnungen durchführen können, damit ich Addition, Subtraktion, Multiplikation und Division schnell erledigen kann.

#### Acceptance Criteria

1. WHEN der Benutzer zwei gültige Operanden und einen Operator eingibt und die Gleichheits-Taste drückt, THE CalculatorEngine SHALL das mathematisch korrekte Ergebnis für die gewählte Operation berechnen.
2. THE CalculatorEngine SHALL die Operationen Addition (+), Subtraktion (−), Multiplikation (×) und Division (÷) unterstützen.
3. IF eine Division durch Null angefordert wird, THEN THE CalculatorEngine SHALL einen CalculationFailure vom Typ `divisionByZero` zurückgeben und keinen Absturz auslösen.
4. THE CalculatorEngine SHALL Dezimalzahlen als Operanden im Bereich von -999999999999 bis 999999999999 akzeptieren.
5. THE CalculatorApp SHALL Operationen sequenziell in Eingabereihenfolge auswerten und keine Operatorpräzedenz anwenden.
6. WHEN mehrere Operationen hintereinander eingegeben werden, THE CalculatorApp SHALL das Zwischenergebnis als ersten Operanden der nächsten Operation verwenden.
7. IF ein CalculationFailure vorliegt, THEN THE CalculatorApp SHALL in den Fehlerzustand wechseln und THE DisplayPanel SHALL den Text „Fehler" anzeigen.
8. IF eine neue Ziffern- oder Dezimalpunkt-Eingabe nach einem Fehlerzustand erfolgt, THEN THE CalculatorApp SHALL den Fehlerzustand zurücksetzen und die neue Eingabe als Beginn einer neuen Berechnung behandeln.
9. IF ein Operator nach einem angezeigten Ergebnis eingegeben wird, THEN THE CalculatorApp SHALL das Ergebnis als ersten Operanden der nächsten Berechnung verwenden.
10. IF eine Ziffern- oder Dezimalpunkt-Eingabe nach einem angezeigten Ergebnis erfolgt, THEN THE CalculatorApp SHALL eine neue Berechnung beginnen und das vorherige Ergebnis verwerfen.

### Requirement 2: Zahleneingabe und Anzeige

**User Story:** Als Benutzer möchte ich Zahlen über ein Tastenfeld eingeben und die aktuelle Eingabe sowie das Ergebnis auf einem Display sehen, damit ich den Berechnungsverlauf nachvollziehen kann.

#### Acceptance Criteria

1. WHEN der Benutzer eine Zifferntaste (0–9) drückt, THE DisplayPanel SHALL die gedrückte Ziffer an die aktuelle Eingabe anhängen und anzeigen, wobei führende Nullen unterdrückt werden.
2. IF die aktuelle Eingabe „0" ist und der Benutzer eine Ziffer von 1 bis 9 eingibt, THEN THE CalculatorApp SHALL die „0" durch die neue Ziffer ersetzen.
3. WHEN der Benutzer die Dezimalpunkt-Taste drückt und die aktuelle Eingabe leer ist oder nur „0" enthält, THE DisplayPanel SHALL „0." anzeigen.
4. WHEN der Benutzer die Dezimalpunkt-Taste drückt und die aktuelle Eingabe noch keinen Dezimalpunkt enthält, THE DisplayPanel SHALL einen Dezimalpunkt an die aktuelle Eingabe anhängen.
5. WHILE bereits ein Dezimalpunkt in der aktuellen Eingabe vorhanden ist, THE CalculatorApp SHALL weitere Dezimalpunkt-Eingaben ignorieren.
6. THE DisplayPanel SHALL maximal 12 sichtbare Ziffern pro Operand anzeigen, wobei Dezimalpunkt und optionales Minuszeichen nicht als Ziffern zählen.
7. WHILE die aktuelle Eingabe bereits 12 sichtbare Ziffern enthält, THE CalculatorApp SHALL weitere Zifferneingaben ignorieren.
8. WHEN das Ergebnis berechnet wurde, THE DisplayPanel SHALL das Ergebnis in der Hauptanzeige darstellen.
9. IF ein berechnetes Ergebnis mehr als 12 sichtbare Ziffern benötigt, THEN THE DisplayPanel SHALL das Ergebnis auf maximal 12 signifikante Ziffern runden.
10. IF ein berechnetes Ergebnis nicht endlich ist oder außerhalb des unterstützten numerischen Bereichs liegt, THEN THE CalculatorApp SHALL in den Fehlerzustand wechseln und THE DisplayPanel SHALL „Fehler" anzeigen.

### Requirement 3: Lösch- und Korrekturfunktionen

**User Story:** Als Benutzer möchte ich meine Eingaben korrigieren oder den Taschenrechner zurücksetzen können, damit ich Tippfehler beheben kann, ohne die App neu starten zu müssen.

#### Acceptance Criteria

1. WHEN der Benutzer die „C"-Taste (Clear) drückt, THE CalculatorApp SHALL den gesamten Zustand zurücksetzen und THE DisplayPanel SHALL „0" anzeigen.
2. WHEN der Benutzer die Rücktaste (⌫) drückt, THE CalculatorApp SHALL das letzte Zeichen aus der aktuellen Eingabe entfernen.
3. IF nach dem Entfernen eines Zeichens keine Zeichen mehr in der aktuellen Eingabe vorhanden sind, THEN THE DisplayPanel SHALL „0" anzeigen.
4. WHILE die Anzeige „0" ist und kein Ergebnis angezeigt wird, THE CalculatorApp SHALL weitere Rücktasten-Eingaben ignorieren.
5. IF ein Ergebnis angezeigt wird und der Benutzer die Rücktaste (⌫) drückt, THEN THE CalculatorApp SHALL das Ergebnis als neue aktuelle Eingabe übernehmen und das letzte Zeichen daraus entfernen.
6. IF ein Fehlerzustand aktiv ist und der Benutzer die Rücktaste (⌫) drückt, THEN THE CalculatorApp SHALL den Fehlerzustand zurücksetzen und THE DisplayPanel SHALL „0" anzeigen.

### Requirement 4: Wiederverwendbare Widget-Architektur

**User Story:** Als Entwickler möchte ich, dass die UI-Komponenten in separate, wiederverwendbare Widgets aufgeteilt sind, damit der Code wartbar und erweiterbar bleibt.

#### Acceptance Criteria

1. THE CalculatorButton SHALL als eigenständiges Widget in einer separaten Datei implementiert sein.
2. THE CalculatorButton SHALL über erforderliche Parameter für Beschriftung (String), Hintergrundfarbe (Color) und onPressed-Callback (VoidCallback) konfigurierbar sein.
3. THE DisplayPanel SHALL als eigenständiges Widget in einer separaten Datei implementiert sein.
4. THE DisplayPanel SHALL den aktuellen Eingabetext, einen optionalen Zwischenausdruck und einen optionalen Fehlertext als String-Parameter entgegennehmen.
5. THE ButtonGrid SHALL als eigenständiges Widget in einer separaten Datei implementiert sein.
6. THE ButtonGrid SHALL CalculatorButton-Instanzen in einem Raster-Layout mit 4 Spalten anordnen.
7. THE ButtonGrid SHALL Tasten für die Ziffern 0–9, Dezimalpunkt, Addition, Subtraktion, Multiplikation, Division, Gleichheit, Clear und Rücktaste enthalten.
8. THE CalculatorApp SHALL die Clean-Architecture-Schichtentrennung einhalten: Widgets im Presentation-Layer dürfen Use-Case-Klassen aus dem Domain-Layer aufrufen und keine Data-Layer-Klassen direkt importieren.
9. THE CalculatorButton, THE DisplayPanel und THE ButtonGrid SHALL jeweils unabhängig voneinander in einem Widget-Test instanziierbar sein, ohne dass der vollständige App-Zustand initialisiert werden muss.

### Requirement 5: Zustandsverwaltung

**User Story:** Als Entwickler möchte ich eine klare Zustandsverwaltung, damit der UI-State konsistent und testbar bleibt.

#### Acceptance Criteria

1. THE CalculatorState SHALL immutable sein und folgende Felder mit definierten Initialwerten enthalten: `currentInput` (String, initial „0"), `selectedOperator` (Operator?, initial null), `firstOperand` (Decimal?, initial null), `result` (Decimal?, initial null) und `status` (CalculatorStatus, initial `input`).
2. THE CalculatorStatus SHALL mindestens die Werte `input`, `operatorSelected`, `resultShown` und `error` unterstützen.
3. WHEN eine Benutzeraktion erfolgt, THE CalculatorApp SHALL einen neuen CalculatorState erzeugen, anstatt den bestehenden Zustand zu mutieren.
4. THE CalculatorApp SHALL eine konsistente State-Management-Lösung verwenden, z. B. Cubit/Bloc, Riverpod oder Provider, die in der gesamten App einheitlich eingesetzt wird.
5. THE CalculatorState SHALL Wertgleichheit (value equality) unterstützen, sodass zwei Instanzen mit identischen Feldwerten als gleich gelten.
6. WHEN die CalculatorApp gestartet oder über die „C"-Taste zurückgesetzt wird, THE CalculatorApp SHALL den CalculatorState auf den definierten Initialzustand setzen.
7. WHILE `status` den Wert `error` hat, THE DisplayPanel SHALL „Fehler" anzeigen.
8. WHILE `status` den Wert `operatorSelected` hat, THE CalculatorApp SHALL die aktive Operator-Taste visuell hervorheben.
9. WHILE `status` den Wert `resultShown` hat, THE CalculatorApp SHALL entscheiden können, ob die nächste Eingabe eine neue Berechnung startet oder mit dem Ergebnis weiterrechnet.

### Requirement 6: Ausdruck-Parsing und Formatierung (Round-Trip)

**User Story:** Als Entwickler möchte ich, dass die Umwandlung zwischen Benutzereingabe und internem Berechnungsmodell zuverlässig funktioniert, damit keine Daten bei der Konvertierung verloren gehen.

#### Acceptance Criteria

1. WHEN eine gültige Benutzereingabe vorliegt, bestehend aus einem ersten Operanden, einem Operator aus +, −, ×, ÷ und einem zweiten Operanden, THE ExpressionParser SHALL die Eingabe in eine interne Berechnungsstruktur umwandeln.
2. THE ExpressionParser SHALL Operanden mit maximal 12 sichtbaren Ziffern und optionalem Dezimalpunkt akzeptieren.
3. IF eine ungültige Eingabe vorliegt, THEN THE ExpressionParser SHALL einen Parse-Fehler zurückgeben, der die Art der Ungültigkeit benennt.
4. THE ExpressionParser SHALL mindestens die Fehlerarten `missingOperand`, `missingOperator`, `invalidCharacter` und `operandTooLong` unterscheiden.
5. THE ExpressionFormatter SHALL eine interne Berechnungsstruktur in eine Zeichenkette im Format „{Operand1} {Operator} {Operand2}" formatieren.
6. THE ExpressionFormatter SHALL Operanden ohne führende Nullen darstellen, außer bei Werten kleiner als 1.
7. THE ExpressionFormatter SHALL Operanden mit maximal 12 sichtbaren Ziffern darstellen, wobei Dezimalpunkt und optionales Minuszeichen nicht als Ziffern zählen.
8. THE ExpressionParser und THE ExpressionFormatter SHALL die Round-Trip-Eigenschaft erfüllen: Wird eine gültige Berechnungsstruktur formatiert und das Ergebnis erneut geparst, so sind die Operandenwerte numerisch gleich und der Operator-Typ identisch zur ursprünglichen Struktur.
9. IF der ExpressionFormatter eine Berechnungsstruktur mit einem Operanden erhält, der mehr als 12 sichtbare Ziffern enthält, THEN THE ExpressionFormatter SHALL den Operanden auf 12 signifikante Ziffern runden, bevor die Zeichenkette erzeugt wird.

### Requirement 7: Responsives Layout

**User Story:** Als Benutzer möchte ich die Taschenrechner-App auf verschiedenen Bildschirmgrößen komfortabel nutzen können, damit die App auf Smartphones und Tablets gleichermaßen gut funktioniert.

#### Acceptance Criteria

1. THE CalculatorApp SHALL das ButtonGrid und das DisplayPanel so skalieren, dass beide Komponenten den verfügbaren Bildschirmbereich vollständig ausfüllen, ohne horizontalen Überlauf zu erzeugen, auf Geräten mit einer Bildschirmbreite zwischen 320 und 1024 logischen Pixeln.
2. THE CalculatorButton SHALL eine Mindestgröße von 48x48 logischen Pixeln einhalten, um Barrierefreiheits-Richtlinien für Touch-Ziele zu erfüllen.
3. WHILE die App im Hochformat angezeigt wird, THE CalculatorApp SHALL das DisplayPanel im oberen Drittel (30–36 % der Bildschirmhöhe) und das ButtonGrid in den unteren zwei Dritteln (64–70 % der Bildschirmhöhe) des Bildschirms platzieren.
4. WHILE die App im Querformat angezeigt wird, THE CalculatorApp SHALL das DisplayPanel auf der linken Seite (30–40 % der Bildschirmbreite) und das ButtonGrid auf der rechten Seite (60–70 % der Bildschirmbreite) nebeneinander platzieren.
5. IF die verfügbare Bildschirmfläche nicht ausreicht, um alle CalculatorButton-Instanzen mit der Mindestgröße von 48x48 logischen Pixeln darzustellen, THEN THE CalculatorApp SHALL das ButtonGrid scrollbar machen, sodass alle Tasten erreichbar bleiben.

### Requirement 8: Visuelles Feedback

**User Story:** Als Benutzer möchte ich visuelles Feedback bei Tastendruck erhalten, damit ich sicher bin, dass meine Eingabe registriert wurde.

#### Acceptance Criteria

1. WHEN der Benutzer einen CalculatorButton drückt, THE CalculatorButton SHALL eine visuelle Zustandsänderung anzeigen, z. B. Farbänderung, Pressed-State oder Ripple-Effekt.
2. THE CalculatorApp SHALL Operator-Tasten durch eine andere Hintergrundfarbe von Ziffern-Tasten unterscheiden.
3. THE CalculatorApp SHALL für den Farbunterschied zwischen Operator-Tasten und Ziffern-Tasten ein Mindest-Kontrastverhältnis von 3:1 zwischen den Hintergrundfarben der beiden Tastengruppen einhalten.
4. WHILE ein Operator ausgewählt ist und noch kein zweiter Operand eingegeben wurde, THE CalculatorApp SHALL die aktive Operator-Taste durch eine visuell unterscheidbare Hintergrundfarbe gegenüber den nicht-aktiven Operator-Tasten hervorheben.
5. WHEN der Benutzer einen anderen Operator auswählt, während bereits ein Operator aktiv ist, THE CalculatorApp SHALL die Hervorhebung der vorherigen Operator-Taste entfernen und die neu gewählte Operator-Taste hervorheben.

### Requirement 9: Besondere Eingabefälle

**User Story:** Als Benutzer möchte ich, dass der Taschenrechner sich bei unvollständigen oder ungewöhnlichen Eingabefolgen vorhersehbar verhält, damit ich keine unerwarteten Ergebnisse erhalte.

#### Acceptance Criteria

1. IF der Benutzer einen Operator direkt nach einem anderen Operator drückt, THEN THE CalculatorApp SHALL den vorherigen Operator durch den neu gewählten Operator ersetzen.
2. IF der Benutzer die Gleichheits-Taste drückt, ohne dass ein zweiter Operand eingegeben wurde, THEN THE CalculatorApp SHALL die Eingabe ignorieren und den aktuellen Zustand unverändert lassen.
3. IF der Benutzer die Gleichheits-Taste drückt, ohne dass ein Operator ausgewählt wurde, THEN THE CalculatorApp SHALL die Eingabe ignorieren und den aktuellen Zustand unverändert lassen.
4. IF der Benutzer nach einem angezeigten Ergebnis eine Ziffer eingibt, THEN THE CalculatorApp SHALL eine neue Berechnung mit dieser Ziffer beginnen.
5. IF der Benutzer nach einem angezeigten Ergebnis einen Operator eingibt, THEN THE CalculatorApp SHALL mit dem angezeigten Ergebnis als erstem Operanden weiterrechnen.
6. IF der Benutzer nach einem angezeigten Ergebnis die Dezimalpunkt-Taste drückt, THEN THE CalculatorApp SHALL eine neue Berechnung mit der Eingabe „0." beginnen.
7. IF der Benutzer nach einem Fehlerzustand die Clear-Taste drückt, THEN THE CalculatorApp SHALL den definierten Initialzustand wiederherstellen.
