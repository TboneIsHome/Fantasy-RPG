# Prüfungen und bekannte Grenzen

Stand: Version 0.3, Godot 4.5.1.stable.official.f62fdbde1, Linux x86_64; 2026-09-10.

**132/132 Prüfungen bestanden:** 50 Spiel-/Speicherprüfungen, 14 UI-Prüfungen, 8 Prüfungen eines originalen 0.1-Spielstands, 48 Dungeon-Prüfungen und 12 Migrationsprüfungen mit einem originalen abgeschlossenen 0.2-Spielstand. Der abschließende lokale Prüfablauf meldet keine Scriptfehler. Die 100 Wald-Seeds und die 100 Dungeon-Seeds sind jeweils in diesen Prüfgruppen enthalten, keine zusätzlichen Spielstunden.

15 tatsächliche Godot-Spielansichten wurden gerendert: Titel, Lager tagsüber/abends, Waldkampf, Fluss, Journal, Pause, Waldkarte sowie Dungeonzugang, Wurzelschwelle, Zisterne, Dungeonkampf, Geheimraum, Entdeckungsjournal und Dungeonkarte. Kontrolliert wurden Texte, Menüränder, Figurenkontrast, Raumgestaltung und Kampfmarkierungen. Es handelt sich um Spielaufnahmen, nicht um Konzeptbilder.

Der gerenderte 60-Sekunden-Kampf in der Gruft lief mit aktiven Dornkobold- und Irrlichtangriffen sowie wiederholten Magierzaubern: 3.591 Frames, Mittel 16,71 ms, 95. Perzentil 16,98 ms. Objektzahlen: anfangs 359, maximal 366, am Ende 362. Nach drei Hin- und Rückreisen waren jeweils 4.557 Nodes im Wald und 359 in der Gruft aktiv. Keine anwachsende Objektzahl in diesem geprüften Umfang. Software-OpenGL über Mesa llvmpipe, Obergrenze 60 FPS; keine Aussage zur Leistung auf anderen Geräten oder mehrstündiger Stabilität. Der virtuelle Treiber meldet erwartungsgemäß keine Unterstützung für das Umschalten von VSync.

Windows- und Linux-Release wurden mit offiziellen 4.5.1-Vorlagen exportiert. Der native Linux-Export und das eingebettete Ressourcenpaket des Windows-Exports wurden unter Linux gestartet und haben die Gruft tatsächlich betreten. Geprüft wurden Version, Raum-/Gegnerzahl, Fundtexte und Speicherung aus den exportierten Ressourcen. Das ersetzt keinen nativen Windows-Test. Das Windows-Archiv besteht zusätzlich die ZIP-Prüfsummenprüfung; PE-Header und x86_64-Architektur wurden geprüft.

**Menschlicher Spieltest:** Tim hat 0.1 gespielt, den Prototyp positiv beurteilt und deutlich schönere Grafik gewünscht. Eine menschliche Beurteilung von 0.2 und 0.3 steht noch aus. Die Ergebnisse unter `qa/` belegen automatisierte Prüfungen, kein Urteil über mehrstündigen Spielspaß.

## Geprüfter Umfang

| Prüfung | Wesentliche Abdeckung |
|---|---|
| `test_suite.gd` | Reproduzierbarer Wald, 100 Seeds, echte Bewegung/Kollision, Zauber/Ressourcen, drei Talente, Gegnerankündigung, erster Auftrag, Tod, Speicherung, beschädigte Daten und Versionsgrenzen |
| `ui_smoke.gd` | Echte Tasten und Menüaktionen, Pause, Dialogannahme, Menügrenzen bei 640 × 360, Entdeckungstab mit allen Texten, Scrollen bis zum letzten Fund, Tab zum Schließen |
| `save_compatibility.gd` | Originales 0.1-JSON, Terrain-SHA über alle Waldzellen, genaue Position/Ressourcen, Talent, Beutel, Quest, Tageszeit, Einstellungen und dauerhafte Gegner-/Lichtänderungen; Originalbytes unverändert |
| `dungeon_suite.gd` | 100 Seeds mit Ein-/Ausgang, Hauptorten, Gegnern und geheimem Zugang; physische Torsperre und kürzerer Rückweg; echte Navigation um eine Ecke; Übergänge ohne Heilung/Doppelspieler; einmalige Funde, Quelle, Eddas Reaktion, Speichern/Laden/Tod; Kobold-Ankündigung, festes Ziel, Ausweichen, Schaden, Verlangsamung und Effektabbau |
| `migration_suite.gd` | Tatsächlicher abgeschlossener 0.2-Stand, genauer Fortschritt, erster Dungeonzugang, Schema 2, unveränderte permanente Sicherung auch bei beschädigter Hauptdatei und Wiederherstellung aus `.bak`; Weltzeit unter Tage und Pause; Ablehnung zukünftiger Dungeonversionen |
| `soak_vault.gd` | Gerenderter 60-Sekunden-Kampf, aktive Dornenflächen, Framezeiten und Objektzahlen, drei Regions-Rundreisen mit vollständigem Szenenabbau |
| `export_smoke.gd` | Zusätzlich als externes Skript gegen beide Release-Pakete ausgeführt: Dungeonaufbau, enthaltene JSON-Daten, richtige Version und Speicherbarkeit |

Die Tests verwenden eigene Dateinamen und löschen ihre Testspielstände. Sie überschreiben keinen normalen Spielstand. Das aktuelle Paket enthält keine Testskripte.

## Wiederholen

`godot` steht für die ausführbare Datei von Godot 4.5.1. Der lokale Prüfablauf importiert das Projekt und führt alle fünf Testgruppen nacheinander aus. Er wertet zusätzlich Fehlermeldungen im Log aus, da Godot bei manchen Scriptfehlern Exitcode 0 zurückgeben kann.

```bash
python3 tools/verify.py /absoluter/pfad/zu/godot
godot --audio-driver Dummy --path . --script res://tests/capture.gd
godot --audio-driver Dummy --path . --script res://tests/capture_vault.gd
godot --audio-driver Dummy --path . --script res://tests/soak_vault.gd
```

Die letzten drei Befehle benötigen eine grafische Sitzung. `tests/soak.gd` bleibt als optionaler Wald-Kampflauf aus 0.2 erhalten. Neue Ergebnisse landen in `test-output/`, freigegebene maschinenlesbare Berichte in `qa/`. Herkunft der eingefrorenen Spielstände: `tests/fixtures/README.md`. Vorversions-Fixtures niemals mit neuem Code regenerieren.

## Nächster menschlicher Spieltest

1. Den bisherigen Spielstand fortsetzen und bekannte Talente, Waldlichter und Funde kontrollieren.
2. Falls nötig Eddas ersten Auftrag abschließen; danach zum Eingang südöstlich des Waldlichts im alten Sternengarten gehen.
3. Die Gruft ohne Lösungshinweise erkunden: Sind Raumrollen, Türen, Erinnerungen und die nächste Richtung verständlich?
4. Beim Dornkobold den markierten Bereich verlassen, danach bewusst einen Angriff abwarten: Sind Ankündigung und Gefahrenfläche gut lesbar?
5. Abkürzung öffnen, speichern, neu laden und die Veränderung kontrollieren. Die Sternenkarte zu Edda bringen.
6. Einschätzen, ob Lichtstaubkosten, Gegnermischung und Raumgröße spannende Entscheidungen ergeben. Optional nach übersehenen Hinweisen suchen.

## Bekannte Grenzen

- Windows-Export hier nicht nativ unter Windows ausgeführt; Laufzeitprüfung unter Linux.
- Eine begrenzte Waldregion und eine kleine Gruft, drei Gegnertypen, ein NPC. Boss, zwei vollständige Questlösungen und allgemeine NPC-Erinnerungen folgen später.
- Dungeon-Raumgraph und Geschichten bleiben gleich; der Seed variiert Größen und Begegnungspositionen. Keine unendlichen oder mehrstündig validierten Inhalte.
- Eigene Pixelgrafik mit begrenzten Animationen, ohne vollständige Richtungsatlanten, dynamische Schatten oder umfangreiche Musik.
- Raster-Wegfindung gilt für die Gruft. Waldgegner können an komplexen Hindernissen hängen bleiben.
- Beutel und drei Talente, noch kein Ausrüstungs-/Händlersystem oder großer Talentbaum. Neue Funde haben noch keine Ausrüstungswerte.
- Die Waldkarte zeigt Gelände von Beginn an; unbekannte Orte sind markiert. Die Dungeonkarte zeigt besuchte Räume, keinen vollständigen Sichtnebel.
- Lebende Gegner und Abklingzeiten werden beim Laden oder erneuten Betreten einer Region zurückgesetzt. Die Region wird komplett ausgetauscht; kein Streaming oder langfristige Weltsimulation.
- Keine frei belegbaren Tasten, Controller-Unterstützung, Textskalierung oder Frostkreis-Reichweitenvorschau.
- Nach dem ersten Speichern in 0.3 können ältere Builds die neue Hauptdatei nicht lesen. Der unveränderte Altstand bleibt zusätzlich als `.pre-v03` erhalten.
