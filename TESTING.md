# Prüfungen und bekannte Grenzen

Stand: Version 0.2, Godot 4.5.1.stable.official.f62fdbde1, Linux x86_64; 2026-09-10.

**69/69 Prüfungen bestanden:** 50 Spiel-/Speicherprüfungen, 11 UI-Prüfungen und 8 Prüfungen eines originalen 0.1-Spielstands. Keine Scriptfehler im abschließenden Funktions- und UI-Durchlauf. Der Funktionstest dauerte rund 8,2 Sekunden.

Acht echte Spielansichten wurden gerendert: Titel, Lager tagsüber und abends, Wald mit Frostkreis, Fluss, Journal, Pause und Karte. Kontrolliert wurden Sichtbarkeit, lesbare Texte, die Kontur der Figur, der Umfang der neuen Beleuchtung sowie die Grenzen der Menüs. Das sind direkte Godot-Aufnahmen, keine Konzeptbilder.

Im 60-Sekunden-Kampflauf mit rein softwarebasiertem OpenGL wurden 3.569 Frames gezeichnet: Mittel 16,81 ms, 95. Perzentil 16,99 ms. Objektzahlen: anfangs 4.554, maximal 4.558, am Ende 4.546. Der Test ist auf maximal 60 FPS begrenzt und belegt keine konkrete Leistung auf anderen Geräten oder mehrstündige Stabilität. In diesem Lauf trat keine wachsende Objektzahl auf. Der virtuelle Grafiktreiber meldet beim Start, dass eine VSync-Umschaltung nicht unterstützt wird.

Die Windows- und Linux-Release-Exporte wurden mit den offiziellen 4.5.1-Vorlagen erstellt. Der native Linux-Export wurde zusätzlich gestartet. Die im Windows-Programm enthaltenen Spielressourcen wurden mit derselben Godot-Version unter Linux geladen; das ist kein nativer Windows-Test.

**Menschlicher Spieltest:** Tim hat Version 0.1 getestet, den ersten Prototyp positiv beurteilt und deutlich schönere Grafik als nächste Priorität genannt. Eine menschliche Beurteilung von 0.2 steht noch aus.

Die maschinenlesbaren Ergebnisse liegen unter `qa/`.

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

`tests/save_compatibility.gd` lädt einen eingefrorenen, vom tatsächlichen 0.1-Code erzeugten Spielstand. Geprüft werden alle Terrain-Zellen per SHA-256, genaue Position/Ressourcen, Talente, Inventar, Queststatus, Tageszeit, Einstellungen, das leuchtende Weltobjekt und das dauerhafte Entfernen des besiegten Gegners. Die ursprünglichen Spielstandbytes werden nicht verändert. Herkunft und Werte stehen unter `tests/fixtures/README.md`.

`tests/capture.gd` rendert die acht oben genannten Ansichten der tatsächlichen Godot-Szene.

`tests/soak.gd` führt einen kurzen 60-Sekunden-Lauf mit aktiven Gegnern und Zaubern im gerenderten Spiel aus. Er misst Frame-Zeiten und die Anzahl lebender Objekte. Der Spieler ist nur in diesem Test unverwundbar. Der Lauf ersetzt keine mehrstündigen Spieltests und sagt keine konkrete Leistung auf Tims PC voraus.

## Tests wiederholen

Zuerst den Projektimport durchführen. `godot` steht hier für die ausführbare Datei von Godot 4.5.1:

```bash
godot --headless --path . --editor --import --quit
godot --headless --audio-driver Dummy --path . --script res://tests/test_suite.gd
godot --headless --audio-driver Dummy --path . --script res://tests/ui_smoke.gd
godot --headless --audio-driver Dummy --path . --script res://tests/save_compatibility.gd
godot --path . --script res://tests/capture.gd
godot --path . --script res://tests/soak.gd
```

Die letzten zwei Befehle benötigen eine grafische Sitzung. Ergebnisse liegen anschließend in `test-output/`; dieser Ordner wird nicht in den Spiel-Export übernommen.

## Für Tims nächsten Spieltest

1. Eine Runde mit dem Standard-Seed beginnen, Edda ansprechen und einen Pfad wählen.
2. Im ersten Kampf erst nur Lichtfunken, dann Frost + Lichtfunken verwenden.
3. Einen Wolf bewusst ins Leere springen lassen und Ausweichen ausprobieren.
4. Ein Waldlicht entzünden, speichern, neu laden und die Veränderung prüfen.
5. Einen Talentpunkt ausgeben und die Wirkung im nächsten Kampf beobachten.
6. Die drei Lichter wecken, Eddas Belohnung erhalten und an einem Waldlicht rasten.

Besonders für 0.2: Ist der Magier auch im dichten Wald sichtbar? Bleiben Angriffsankündigungen zwischen Pflanzen und Effekten klar? Wirken Lager, Wald und Abendlicht stimmig? Anschließend den vorhandenen 0.1-Spielstand fortsetzen und bekannte Talente/Funde kontrollieren.

## Bekannte Grenzen

- Der Windows-Export wurde erstellt, aber hier nicht nativ unter Windows ausgeführt. Die Laufzeitprüfung erfolgt unter Linux.
- Eigene Pixelgrafik mit begrenzten Animationen; noch keine vollständigen Animationssätze für alle Richtungen, dynamischen Schatten oder umfangreiche Musik.
- Eine begrenzte Region, zwei normale Gegnertypen, ein handgeschriebener NPC und ein einfacher Erkundungsauftrag. Dungeon, Boss und zwei ausgearbeitete Questlösungen fehlen.
- Lokale Gegnersteuerung kann an komplexen Hindernissen hängen bleiben; systematische Wegfindung kommt mit dem Dungeon.
- Der Spieler wird bei Frostkreisen bislang nicht durch eine Reichweitenvorschau vor dem Auslösen unterstützt.
- Ein Beutel mit Lichtstaub und Relikt, noch kein Ausrüstungs-/Händlersystem. Lichtstaub hat vorerst keine Verwendung.
- Drei Talente sind noch kein großer Skill Tree. Keine anderen spielbaren Klassen.
- Die Karte zeigt das Gelände von Beginn an; unbekannte Orte sind mit Fragezeichen markiert. Keine vollständige Sichtnebelkarte.
- Keine frei belegbaren Tasten, Controller-Unterstützung, Textskalierung oder mobile Oberfläche in 0.2.
- Lebende Gegner und Abklingzeiten werden beim Laden zurückgesetzt. Kein Chunk-Streaming und keine langfristige Regionssimulation.

## Bereits im Grundprototyp behobene Fehler

- GDScript-Typableitung an dynamischen Schleifenvariablen explizit gemacht.
- Tab-Tastendruck wird im Journal nicht mehr von der Schaltflächen-Fokusnavigation abgefangen.
- Menüklick löst beim Zurückkehren ins Spiel keinen ungewollten Zauber aus.
- Beschädigte Spielstände erzeugen eine verständliche Meldung statt eines technischen JSON-Fehlers.
- Irrlicht-Projektile zielen vom tatsächlichen Abschusspunkt auf die angekündigte Zielposition.
- Audio-Stimmen werden beim Szenenabbau freigegeben.
- Magierkontrast, Verdeckung durch Baumkronen und Lesbarkeit der Steuerungshinweise verbessert.
