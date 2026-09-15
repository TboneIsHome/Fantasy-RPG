# Prüfungen und bekannte Grenzen

Stand: Version 0.4, Godot 4.5.1.stable.official.f62fdbde1, Linux x86_64; 2026-09-13.

**197/197 Prüfungen bestanden:** 50 Spiel-/Speicherprüfungen, 14 UI-Prüfungen, 8 Prüfungen eines originalen 0.1-Spielstands, 48 Dungeon-Prüfungen, 12 Migrationsprüfungen mit einem originalen abgeschlossenen 0.2-Spielstand und 65 Quellenprüfungen einschließlich eines originalen 0.3-Spielstands. Der abschließende lokale Prüfablauf meldet keine Scriptfehler. Die jeweils 100 Seeds in Wald-, Dungeon- und Quellenprüfungen zählen innerhalb dieser Gruppen, nicht als zusätzliche Spielstunden.

16 tatsächliche Godot-Spielansichten wurden gerendert: Titel, Lager tagsüber/abends, Waldkampf, Fluss, Journal, Pause, Waldkarte sowie ruhender Hüter, Quellenentscheidung, Zeichenfolge, Quellengarten, Reliktplatz, Hüterkampf, Sieg und Erzader. Kontrolliert wurden Texte, Menüränder, Figurenkontrast, Raumgestaltung und Kampfmarkierungen. Es handelt sich um Spielaufnahmen, nicht um Konzeptbilder.

Der gerenderte 60-Sekunden-Hüterkampf lief mit aktiven Schlägen, Projektilfächern und Magierzaubern: 3.559 Frames, Mittel 16,86 ms, 95. Perzentil 17,67 ms. Objektzahlen: anfangs 368, maximal 383, am Ende 379; höchstens fünf Hütergeschosse gleichzeitig. Nach drei Hin- und Rückreisen waren jeweils 4.558 Nodes im Wald und 368 in der Gruft aktiv. Keine anwachsende Objektzahl in diesem geprüften Umfang. Software-OpenGL über Mesa llvmpipe, Obergrenze 60 FPS; keine Aussage zur Leistung auf anderen Geräten oder mehrstündiger Stabilität. Der virtuelle Treiber meldet erwartungsgemäß keine Unterstützung für das Umschalten von VSync.

Windows- und Linux-Release wurden mit offiziellen 4.5.1-Vorlagen exportiert. Der native Linux-Export und das eingebettete Ressourcenpaket des Windows-Exports wurden unter Linux gestartet. Geprüft wurden Version, Raum-/Gegnerzahl, enthaltene Fundtexte, Hüteraufbau und der vollständige Untersuchungsabschluss einschließlich Quellengarten, ausgerüstetem Quellenherz und gespeichertem Format 3. Das ersetzt keinen nativen Windows-Test. Das Windows-Archiv besteht zusätzlich die ZIP-Prüfsummenprüfung; PE-Header und x86_64-Architektur wurden geprüft.

**Menschlicher Spieltest:** Tim hat 0.1 gespielt, den Prototyp positiv beurteilt und deutlich schönere Grafik gewünscht. Eine menschliche Beurteilung von 0.2–0.4 steht noch aus. Die Ergebnisse unter `qa/` belegen automatisierte Prüfungen, kein Urteil über mehrstündigen Spielspaß.

## Geprüfter Umfang

| Prüfung | Wesentliche Abdeckung |
|---|---|
| `test_suite.gd` | 50 Checks: reproduzierbarer Wald, 100 Seeds, echte Bewegung/Kollision, Zauber/Ressourcen, Talente, Gegnerankündigung, erster Auftrag, Tod, Speicherung und Versionsgrenzen |
| `ui_smoke.gd` | 14 Checks: echte Tasten und Menüaktionen, Pause, Dialogannahme, Menügrenzen bei 640 × 360, Entdeckungstab, Scrollen, Tab zum Schließen |
| `save_compatibility.gd` | 8 Checks: originales 0.1-JSON, Terrain-SHA, genaue Position/Ressourcen, Talent, Beutel, Quest, Tageszeit, Einstellungen und dauerhafte Weltänderungen; Originalbytes unverändert |
| `dungeon_suite.gd` | 48 Checks: 100 Seeds, Torsperre/Abkürzung, echte Navigation, Übergänge ohne Heilung/Doppelspieler, einmalige Funde, Quelle, Edda, Speichern/Laden/Tod; Kobold-Ankündigung, Ausweichen, Schaden und Effektabbau |
| `migration_suite.gd` | 12 Checks: tatsächlicher 0.2-Stand, genauer Fortschritt, Dungeonzugang, aktuelles Schema, unveränderte permanente Sicherung auch bei Wiederherstellung aus `.bak`; Weltzeit/Pause und zukünftige Dungeonversionen |
| `source_suite.gd` | 65 Checks: originales 0.3-JSON und Sicherungsbytes, 100 Seeds mit erreichbarer Fassung/Hüter, echter Queststart, fehlende Hinweise, unmittelbare Hinweisspeicherung, falsche/gespeicherte Zeichenfolge, beide vollständigen Lösungen, einmalige Belohnungen, Edda, realer Hüterkampf, Ankündigung/Schaden/Ausweichen/Fächer/Rückzug, Laden mitten im Kampf, Gartenschutz/Rast/Erz, Tod und Ausrüstung; tatsächliche Manarückgabe nur mit angelegtem Relikt und Treffer, auch bei mehreren Zielen nur einmal |
| `soak_source.gd` | Gerenderter 60-Sekunden-Hüterkampf, aktive Einschläge und Geschosse, Framezeiten und Objektzahlen, drei Regions-Rundreisen |
| `export_smoke.gd` | Zusätzlich extern gegen beide Release-Pakete ausgeführt: Dungeonaufbau, enthaltene Daten, Version, Untersuchungsabschluss, Ort/Relikt und Format 3 |

Der automatisierte vollständige Kampf nutzt echte Zauber, Manakosten und Abklingzeiten. Nur der Bot ist gegen Schaden geschützt, damit dieser Ablauf die Gewinnbedingung zuverlässig erreicht. Schaden und Ausweichen werden separat ohne diesen Schutz geprüft. Der Ressourcenvergleich nach JSON-Speicherung nutzt eine kleine numerische Toleranz; gemessene Differenz: 0 LP und ungefähr 0,00000000000001 MP.

Die Tests verwenden eigene Dateinamen und löschen ihre Testspielstände. Sie überschreiben keinen normalen Spielstand. Das aktuelle Paket enthält keine Testskripte.

## Wiederholen

`godot` steht für Godot 4.5.1. Der lokale Prüfablauf importiert das Projekt und führt alle sechs Testgruppen nacheinander aus. Er wertet zusätzlich Fehlermeldungen im Log aus, da Godot bei manchen Scriptfehlern Exitcode 0 zurückgeben kann.

```bash
python3 tools/verify.py /absoluter/pfad/zu/godot
godot --audio-driver Dummy --path . --script res://tests/capture.gd
godot --audio-driver Dummy --path . --script res://tests/capture_source.gd
godot --audio-driver Dummy --path . --script res://tests/soak_source.gd
```

Die letzten drei Befehle benötigen eine grafische Sitzung. Frühere Capture-/Kampfläufe bleiben für gezielte Regressionen erhalten. Neue Ergebnisse landen in `test-output/`, freigegebene maschinenlesbare Berichte in `qa/`. Herkunft der eingefrorenen Spielstände: `tests/fixtures/README.md`. Vorversions-Fixtures niemals mit neuem Code regenerieren.

## Nächster menschlicher Spieltest

1. Den bisherigen Spielstand fortsetzen und bekannte Talente, Waldlichter und Funde kontrollieren.
2. Falls nötig Eddas ersten Auftrag abschließen; danach die Gruft im alten Sternengarten betreten und die Fassung nördlich des ruhenden Hüters untersuchen.
3. Ohne Lösungshinweise entscheiden: Sind beide Wege und die Bedeutung der Erinnerungen verständlich? Ein abgeschlossener Weg ist dauerhaft; Rückzug vor dem Abschluss lässt beide Wege offen.
4. Beim Hüter die Bodenmarkierung und den Geschossfächer lesen und ausweichen. Schwierigkeit und Erholungsfenster beurteilen.
5. Den veränderten Ort besuchen, das Quellenherz im Journal ab-/anlegen und Frostkreis mit Treffer beziehungsweise Fehlschuss vergleichen.
6. Speichern, neu laden und mit Edda sprechen: Bleiben Ort, Entscheidung und Ausrüstung nachvollziehbar? Atmosphäre, Orientierung und Kampfrhythmus beurteilen.

## Bekannte Grenzen

- Windows-Export hier nicht nativ unter Windows ausgeführt; Laufzeitprüfung unter Linux.
- Eine begrenzte Waldregion, eine kleine Gruft, drei normale Gegnertypen, ein Hüter und ein NPC. Der erste zusammenhängende Abschnitt ist implementiert; große Welt und allgemeine NPC-Erinnerungen fehlen noch.
- Dungeon-Raumgraph und Geschichten bleiben gleich; der Seed variiert Größen und Begegnungspositionen. Keine unendlichen oder mehrstündig validierten Inhalte.
- Eigene Pixelgrafik mit begrenzten Animationen, ohne vollständige Richtungsatlanten, dynamische Schatten oder umfangreiche Musik.
- Raster-Wegfindung gilt für die Gruft. Waldgegner können an komplexen Hindernissen hängen bleiben.
- Beutel, drei Talente und ein Reliktplatz; noch kein Händlersystem, umfangreicher Gegenstandspool oder großer Talentbaum.
- Die Waldkarte zeigt Gelände von Beginn an; unbekannte Orte sind markiert. Die Dungeonkarte zeigt besuchte Räume, keinen vollständigen Sichtnebel.
- Lebende Gegner und Abklingzeiten werden beim Laden oder erneuten Betreten einer Region zurückgesetzt. Ein laufender Hüterkampf beginnt erneut. Die Region wird komplett ausgetauscht; kein Streaming oder langfristige Weltsimulation.
- Keine frei belegbaren Tasten, Controller-Unterstützung, Textskalierung oder Frostkreis-Reichweitenvorschau.
- Nach dem ersten Speichern in 0.4 können ältere Builds die neue Hauptdatei nicht lesen. Der gültige Altstand bleibt zusätzlich als `.pre-v04` erhalten; eine bestehende `.pre-v03` bleibt unverändert.
