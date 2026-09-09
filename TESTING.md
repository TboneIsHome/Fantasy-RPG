# Prüfungen und bekannte Grenzen

Stand: Prototyp 0.1, Godot 4.5.1.stable.official.f62fdbde1, Linux x86_64.

Ergebnis dieser Iteration: **50/50 Funktionsprüfungen und 11/11 UI-Prüfungen bestanden**, ohne Scriptfehler im abschließenden Durchlauf. Der Funktionstest dauerte rund 11 Sekunden. Zusätzlich wurden sechs Spielansichten gerendert und kontrolliert.

Der native Linux-Export startete ebenfalls erfolgreich. Damit ist zusätzlich zum Editorlauf das Laden der exportierten Ressourcen geprüft.

Im 60-Sekunden-Test mit rein softwarebasiertem OpenGL wurden 2.864 Frames gezeichnet: im Mittel 20,96 ms pro Frame, 95. Perzentil 36,38 ms. Die Szene begann mit 4.538 Nodes, erreichte maximal 4.542 und endete mit 4.529. Das zeigt in diesem kurzen Lauf keine anwachsende Objektzahl; es ist kein Nachweis für Langzeitstabilität oder Leistung auf anderen Geräten. Der virtuelle Grafiktreiber unterstützt keine VSync-Umschaltung und meldet das beim Start.

## Automatisch geprüft

`tests/test_suite.gd` prüft 50 Bedingungen, darunter:

- identische Welt bei identischem Seed; Unterschiede bei anderem Seed; Unicode;
- 100 verschiedene Seeds: sämtliche Landmarken und Gegnerlichtungen erreichbar;
- Kartenrand, Bewegung über echte Eingaben und physische Kollisionen;
- Mana, Abklingzeiten, Ausdauer, Ausweichschutz und Schutz gegen Mehrfachtreffer;
- bewegte Projektile, Hindernisse, Flächenzauber, Verlangsamung und Splitterschaden;
- alle drei Talente mit ihren tatsächlichen Kampfauswirkungen;
- Ankündigung, Ausweichen und Schaden beim Wolf; Fernprojektil des Irrlichts;
- einmalige Ortsbelohnungen, Aufstieg, Talentregeln und vollständiger Erkundungsauftrag;
- Speichern/Laden, persistente besiegte Gegner, Tod und Rückkehr zum Lager;
- ungültige Datentypen, NaN, doppelte IDs, inkompatible Versionen und beschädigte JSON-Dateien;
- Sicherungsrückfall ohne stilles Downgrade eines Spielstands aus einer neueren Generatorversion.

Die Tests verwenden eigene Dateinamen und löschen ihre Testspielstände. Sie überschreiben keinen normalen Spielstand.

`tests/ui_smoke.gd` prüft Menü-Buttons, Tab/M/Esc-Eingaben, Dialogannahme, Pausenzustände sowie die Grenzen der Menüs bei 640 × 360 Pixeln.

`tests/capture.gd` rendert die tatsächliche Godot-Szene als Titel-, Lager-, Kampf-, Journal-, Pausen- und Kartenansicht. Diese Bilder wurden visuell kontrolliert. Das sind Spielbilder, keine Konzeptillustrationen.

`tests/soak.gd` führt einen kurzen 60-Sekunden-Lauf mit aktiven Gegnern und Zaubern im gerenderten Spiel aus. Er misst Frame-Zeiten und die Anzahl lebender Objekte. Der Spieler ist nur in diesem Test unverwundbar. Der Lauf ersetzt keine mehrstündigen Spieltests und sagt keine konkrete Leistung auf Tims PC voraus.

## Tests wiederholen

Zuerst den Projektimport durchführen. `godot` steht hier für die ausführbare Datei von Godot 4.5.1:

```bash
godot --headless --path . --editor --import --quit
godot --headless --audio-driver Dummy --path . --script res://tests/test_suite.gd
godot --headless --audio-driver Dummy --path . --script res://tests/ui_smoke.gd
godot --path . --script res://tests/capture.gd
godot --path . --script res://tests/soak.gd
```

Die letzten zwei Befehle benötigen eine grafische Sitzung. Ergebnisse liegen anschließend in `test-output/`; dieser Ordner wird nicht in den Spiel-Export übernommen.

## Für Tims ersten Spieltest

1. Eine Runde mit dem Standard-Seed beginnen, Edda ansprechen und einen Pfad wählen.
2. Im ersten Kampf erst nur Lichtfunken, dann Frost + Lichtfunken verwenden.
3. Einen Wolf bewusst ins Leere springen lassen und Ausweichen ausprobieren.
4. Ein Waldlicht entzünden, speichern, neu laden und die Veränderung prüfen.
5. Einen Talentpunkt ausgeben und die Wirkung im nächsten Kampf beobachten.
6. Die drei Lichter wecken, Eddas Belohnung erhalten und an einem Waldlicht rasten.

Wichtigstes Feedback: Ist die Figur gut sichtbar? Sind Angriffe fair? Fühlt sich Magie kraftvoll an? Reicht die Orientierung? Was war interessant und was war langweilig?

## Bekannte Grenzen

- Der Windows-Export wurde erstellt, aber hier nicht nativ unter Windows ausgeführt. Die Laufzeitprüfung erfolgt unter Linux.
- Kohärente Platzhaltergrafik; kleine Schritt-/Schwebeanimationen, noch keine finalen Richtungsanimationen oder umfangreiche Musik.
- Eine begrenzte Region, zwei normale Gegnertypen, ein handgeschriebener NPC und ein einfacher Erkundungsauftrag. Dungeon, Boss und zwei ausgearbeitete Questlösungen fehlen.
- Lokale Gegnersteuerung kann an komplexen Hindernissen hängen bleiben; systematische Wegfindung kommt mit dem Dungeon.
- Der Spieler wird bei Frostkreisen bislang nicht durch eine Reichweitenvorschau vor dem Auslösen unterstützt.
- Ein Beutel mit Lichtstaub und Relikt, noch kein Ausrüstungs-/Händlersystem. Lichtstaub hat vorerst keine Verwendung.
- Drei Talente sind noch kein großer Skill Tree. Keine anderen spielbaren Klassen.
- Die Karte zeigt das Gelände von Beginn an; unbekannte Orte sind mit Fragezeichen markiert. Keine vollständige Sichtnebelkarte.
- Keine frei belegbaren Tasten, Controller-Unterstützung, Textskalierung oder mobile Oberfläche in 0.1.
- Lebende Gegner und Abklingzeiten werden beim Laden zurückgesetzt. Kein Chunk-Streaming und keine langfristige Regionssimulation.

## Fehler, die in dieser Iteration behoben wurden

- GDScript-Typableitung an dynamischen Schleifenvariablen explizit gemacht.
- Tab-Tastendruck wird im Journal nicht mehr von der Schaltflächen-Fokusnavigation abgefangen.
- Menüklick löst beim Zurückkehren ins Spiel keinen ungewollten Zauber aus.
- Beschädigte Spielstände erzeugen eine verständliche Meldung statt eines technischen JSON-Fehlers.
- Irrlicht-Projektile zielen vom tatsächlichen Abschusspunkt auf die angekündigte Zielposition.
- Audio-Stimmen werden beim Szenenabbau freigegeben.
- Magierkontrast, Verdeckung durch Baumkronen und Lesbarkeit der Steuerungshinweise verbessert.
