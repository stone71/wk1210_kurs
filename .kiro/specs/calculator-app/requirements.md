# Requirements Document

## Einleitung

Dieses Dokument beschreibt die Anforderungen für eine Taschenrechner-App, die als Flutter-Anwendung mit Clean Architecture umgesetzt wird. Die App ersetzt das bestehende Counter-Template und bietet grundlegende arithmetische Operationen mit einer übersichtlichen, responsiven Benutzeroberfläche. Die Architektur folgt dem Prinzip der Schichtentrennung (Domain/Data/Presentation) und setzt auf wiederverwendbare, in separate Dateien ausgelagerte Widgets.

## Glossar

- **Calculator_App**: Die Flutter-Taschenrechner-Anwendung als Gesamtsystem
- **Calculator_Engine**: Die Domain-Schicht-Komponente, die arithmetische Berechnungen durchführt (Use Case)
- **Display_Panel**: Das Widget zur Anzeige der aktuellen Eingabe und des Ergebnisses
- **Button_Grid**: Das Widget-Raster, das alle Taschenrechner-Tasten enthält
- **Calculator_Button**: Ein einzelnes, wiederverwendbares Button-Widget für Ziffern und Operatoren
- **Calculator_State**: Der immutable Zustand des Taschenrechners (aktuelle Eingabe, Operator, Ergebnis)
- **Expression_Parser**: Die Komponente, die Benutzereingaben in berechenbare Ausdrücke umwandelt
- **Expression_Formatter**: Die Komponente, die berechnete Ergebnisse in eine darstellbare Zeichenkette formatiert
- **Operator**: Eine arithmetische Operation (+, −, ×, ÷)
- **Operand**: Ein numerischer Wert, der in eine Berechnung eingeht

## Requirements

### Requirement 1: Grundlegende arithmetische Berechnungen

**User Story:** Als Benutzer möchte ich grundlegende arithmetische Berechnungen durchführen können, damit ich Addition, Subtraktion, Multiplikation und Division schnell erledigen kann.

#### Acceptance Criteria

1. WHEN der Benutzer zwei Operanden und einen Operator eingibt und die Gleichheits-Taste drückt, THE Calculator_Engine SHALL das mathematisch korrekte arithmetische Ergebnis berechnen und zurückgeben, wobei Ergebnisse mit nicht-terminierenden Dezimalstellen auf maximal 10 signifikante Stellen gerundet werden.
2. THE Calculator_Engine SHALL die Operationen Addition (+), Subtraktion (−), Multiplikation (×) und Division (÷) unterstützen.
3. IF eine Division durch Null angefordert wird, THEN THE Calculator_Engine SHALL den Text „Fehler" als Ergebnis zurückgeben und keinen Absturz auslösen.
4. THE Calculator_Engine SHALL Dezimalzahlen als Operanden im Bereich von -999999999999 bis 999999999999 akzeptieren und Ergebnisse auf maximal 10 Dezimalstellen Genauigkeit verarbeiten.
5. WHEN mehrere Operationen hintereinander eingegeben werden, THE Calculator_Engine SHALL das Zwischenergebnis als ersten Operanden der nächsten Operation verwenden.
6. IF das Ergebnis einer Berechnung den darstellbaren Bereich von 12 Ziffern überschreitet, THEN THE Calculator_Engine SHALL den Text „Fehler" als Ergebnis zurückgeben.
7. IF eine Folgeoperation nach einem Fehlerzustand eingegeben wird, THEN THE Calculator_Engine SHALL den Fehlerzustand zurücksetzen und die neue Eingabe als Beginn einer neuen Berechnung behandeln.

### Requirement 2: Zahleneingabe und Anzeige

**User Story:** Als Benutzer möchte ich Zahlen über ein Tastenfeld eingeben und die aktuelle Eingabe sowie das Ergebnis auf einem Display sehen, damit ich den Berechnungsverlauf nachvollziehen kann.

#### Acceptance Criteria

1. WHEN der Benutzer eine Zifferntaste (0–9) drückt, THE Display_Panel SHALL die gedrückte Ziffer an die aktuelle Eingabe anhängen und anzeigen, wobei führende Nullen unterdrückt werden (Eingabe von „0" gefolgt von einer Ziffer 1–9 ersetzt die „0" durch die neue Ziffer).
2. WHEN der Benutzer die Dezimalpunkt-Taste drückt und die aktuelle Eingabe leer ist oder nur „0" enthält, THE Display_Panel SHALL „0." anzeigen.
3. WHILE bereits ein Dezimalpunkt in der aktuellen Eingabe vorhanden ist, THE Calculator_App SHALL weitere Dezimalpunkt-Eingaben ignorieren.
4. THE Display_Panel SHALL maximal 12 Ziffern pro Operand anzeigen, wobei der Dezimalpunkt und ein optionales Minuszeichen nicht als Ziffer zählen.
5. WHILE die aktuelle Eingabe bereits 12 Ziffern enthält, THE Calculator_App SHALL weitere Zifferneingaben ignorieren.
6. WHEN das Ergebnis berechnet wurde, THE Display_Panel SHALL das Ergebnis in der Hauptanzeige darstellen; IF das Ergebnis mehr als 12 Ziffern umfasst, THEN THE Display_Panel SHALL das Ergebnis auf 12 signifikante Stellen gerundet anzeigen.
7. WHEN der Benutzer die Dezimalpunkt-Taste drückt und die aktuelle Eingabe noch keinen Dezimalpunkt enthält, THE Display_Panel SHALL einen Dezimalpunkt an die aktuelle Eingabe anhängen.

### Requirement 3: Lösch- und Korrekturfunktionen

**User Story:** Als Benutzer möchte ich meine Eingaben korrigieren oder den Taschenrechner zurücksetzen können, damit ich Tippfehler beheben kann, ohne die App neu starten zu müssen.

#### Acceptance Criteria

1. WHEN der Benutzer die „C"-Taste (Clear) drückt, THE Calculator_App SHALL den gesamten Zustand zurücksetzen (Eingabe, Operator und Ergebnis löschen) und THE Display_Panel SHALL „0" anzeigen.
2. WHEN der Benutzer die Rücktaste (⌫) drückt, THE Calculator_App SHALL das letzte Zeichen (Ziffer oder Dezimalpunkt) aus der aktuellen Eingabe entfernen.
3. IF nach dem Entfernen eines Zeichens keine Zeichen mehr in der aktuellen Eingabe vorhanden sind, THEN THE Display_Panel SHALL „0" anzeigen und weitere Rücktasten-Eingaben ignorieren, solange die Anzeige „0" ist.
4. IF ein Ergebnis angezeigt wird (nach Drücken der Gleichheits-Taste) und der Benutzer die Rücktaste (⌫) drückt, THEN THE Calculator_App SHALL das Ergebnis als neue aktuelle Eingabe übernehmen und das letzte Zeichen daraus entfernen.

### Requirement 4: Wiederverwendbare Widget-Architektur

**User Story:** Als Entwickler möchte ich, dass die UI-Komponenten in separate, wiederverwendbare Widgets aufgeteilt sind, damit der Code wartbar und erweiterbar bleibt.

#### Acceptance Criteria

1. THE Calculator_Button SHALL als eigenständiges Widget in einer separaten Datei implementiert sein und über erforderliche Parameter für Beschriftung (String), Hintergrundfarbe (Color) und onPressed-Callback (VoidCallback) konfigurierbar sein.
2. THE Display_Panel SHALL als eigenständiges Widget in einer separaten Datei implementiert sein und den aktuellen Eingabetext sowie das Ergebnis als separate String-Parameter entgegennehmen.
3. THE Button_Grid SHALL als eigenständiges Widget in einer separaten Datei implementiert sein und Calculator_Button-Instanzen in einem Raster-Layout mit 4 Spalten anordnen.
4. THE Calculator_App SHALL die Clean-Architecture-Schichtentrennung einhalten: Widgets im Presentation-Layer dürfen ausschließlich Use-Case-Klassen aus dem Domain-Layer aufrufen und keine Data-Layer-Klassen direkt importieren.
5. THE Calculator_Button, THE Display_Panel und THE Button_Grid SHALL jeweils unabhängig voneinander in einem Widget-Test instanziierbar sein, ohne dass der vollständige App-Zustand initialisiert werden muss.

### Requirement 5: Zustandsverwaltung

**User Story:** Als Entwickler möchte ich eine klare Zustandsverwaltung, damit der UI-State konsistent und testbar bleibt.

#### Acceptance Criteria

1. THE Calculator_State SHALL immutable sein und folgende Felder mit definierten Initialwerten enthalten: aktuelle Eingabe (String, initial "0"), gewählter Operator (nullable, initial null), erster Operand (nullable Dezimalzahl, initial null) und Ergebnis (nullable Dezimalzahl, initial null).
2. WHEN eine Benutzeraktion erfolgt (Zifferneingabe, Dezimalpunkt, Operator-Wahl, Gleichheits-Taste, Löschen, Rücktaste), THE Calculator_App SHALL einen neuen Calculator_State erzeugen, anstatt den bestehenden zu mutieren.
3. THE Calculator_App SHALL eine konsistente State-Management-Lösung (Cubit/Bloc, Riverpod oder Provider) verwenden, die in der gesamten App einheitlich eingesetzt wird.
4. THE Calculator_State SHALL Wertgleichheit (value equality) unterstützen, sodass zwei Instanzen mit identischen Feldwerten als gleich gelten.
5. WHEN die Calculator_App gestartet oder über die „C"-Taste zurückgesetzt wird, THE Calculator_App SHALL den Calculator_State auf den definierten Initialzustand setzen (aktuelle Eingabe "0", Operator null, erster Operand null, Ergebnis null).

### Requirement 6: Ausdruck-Parsing und Formatierung (Round-Trip)

**User Story:** Als Entwickler möchte ich, dass die Umwandlung zwischen Benutzereingabe und internem Berechnungsmodell zuverlässig funktioniert, damit keine Daten bei der Konvertierung verloren gehen.

#### Acceptance Criteria

1. WHEN eine gültige Benutzereingabe vorliegt (bestehend aus einem ersten Operanden, einem Operator aus +, −, ×, ÷ und einem zweiten Operanden, wobei jeder Operand maximal 12 Ziffern mit optionalem Dezimalpunkt enthält), THE Expression_Parser SHALL die Eingabe in eine interne Berechnungsstruktur (Operand, Operator, Operand) umwandeln.
2. IF eine ungültige Eingabe vorliegt (fehlender Operand, fehlender Operator, ungültiges Zeichen oder Operand mit mehr als 12 Ziffern), THEN THE Expression_Parser SHALL einen Fehler zurückgeben, der die Art der Ungültigkeit benennt (fehlender Operand, fehlender Operator, ungültiges Zeichen oder Überlänge).
3. THE Expression_Formatter SHALL eine interne Berechnungsstruktur in eine Zeichenkette im Format „{Operand1} {Operator} {Operand2}" formatieren, wobei Operanden ohne führende Nullen (außer bei Werten kleiner 1) und mit maximal 12 signifikanten Ziffern dargestellt werden.
4. THE Expression_Parser und THE Expression_Formatter SHALL die Round-Trip-Eigenschaft erfüllen: Wird eine gültige Berechnungsstruktur formatiert und das Ergebnis erneut geparst, so sind die Operandenwerte numerisch gleich und der Operator-Typ identisch zur ursprünglichen Struktur.
5. IF der Expression_Formatter eine Berechnungsstruktur mit einem Operanden erhält, der mehr als 12 Ziffern enthält, THEN THE Expression_Formatter SHALL den Operanden auf 12 signifikante Ziffern runden, bevor die Zeichenkette erzeugt wird.

### Requirement 7: Responsives Layout

**User Story:** Als Benutzer möchte ich die Taschenrechner-App auf verschiedenen Bildschirmgrößen komfortabel nutzen können, damit die App auf Smartphones und Tablets gleichermaßen gut funktioniert.

#### Acceptance Criteria

1. THE Calculator_App SHALL das Button_Grid und das Display_Panel so skalieren, dass beide Komponenten den verfügbaren Bildschirmbereich vollständig ausfüllen, ohne horizontalen Überlauf zu erzeugen, auf Geräten mit einer Bildschirmbreite zwischen 320 und 1024 logischen Pixeln.
2. THE Calculator_Button SHALL eine Mindestgröße von 48x48 logischen Pixeln einhalten, um die Barrierefreiheits-Richtlinien für Touch-Ziele zu erfüllen.
3. WHILE die App im Hochformat angezeigt wird, THE Calculator_App SHALL das Display_Panel im oberen Drittel (30–36 % der Bildschirmhöhe) und das Button_Grid in den unteren zwei Dritteln (64–70 % der Bildschirmhöhe) des Bildschirms platzieren.
4. WHILE die App im Querformat angezeigt wird, THE Calculator_App SHALL das Display_Panel auf der linken Seite (30–40 % der Bildschirmbreite) und das Button_Grid auf der rechten Seite (60–70 % der Bildschirmbreite) nebeneinander platzieren.
5. IF die verfügbare Bildschirmfläche nicht ausreicht, um alle Calculator_Button-Instanzen mit der Mindestgröße von 48x48 logischen Pixeln darzustellen, THEN THE Calculator_App SHALL das Button_Grid scrollbar machen, sodass alle Tasten erreichbar bleiben.

### Requirement 8: Visuelles Feedback

**User Story:** Als Benutzer möchte ich visuelles Feedback bei Tastendruck erhalten, damit ich sicher bin, dass meine Eingabe registriert wurde.

#### Acceptance Criteria

1. WHEN der Benutzer einen Calculator_Button drückt, THE Calculator_Button SHALL eine visuelle Zustandsänderung (Farbänderung oder Ripple-Effekt) innerhalb von 100ms anzeigen und diese für mindestens 150ms sichtbar halten.
2. THE Calculator_App SHALL Operator-Tasten durch eine andere Hintergrundfarbe von Ziffern-Tasten unterscheiden, sodass der Farbunterschied ohne Vergleich erkennbar ist (Mindest-Kontrastverhältnis von 3:1 zwischen den Hintergrundfarben der beiden Tastengruppen).
3. WHILE ein Operator ausgewählt ist und noch kein zweiter Operand eingegeben wurde, THE Calculator_App SHALL die aktive Operator-Taste durch eine visuell unterscheidbare Hintergrundfarbe gegenüber den nicht-aktiven Operator-Tasten hervorheben.
4. WHEN der Benutzer einen anderen Operator auswählt, während bereits ein Operator aktiv ist, THE Calculator_App SHALL die Hervorhebung der vorherigen Operator-Taste entfernen und die neu gewählte Operator-Taste hervorheben.
