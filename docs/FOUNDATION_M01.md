# LICHTERHAIN — FOUNDATION M01

Stand: 16.09.2026 · Basis 0.4.0 / M00 `dc7eed91771727f4b79a7789d3af80129386089b` · Godot 4.5.1.stable.official.f62fdbde1.

**M01 ist IMPLEMENTED und insgesamt PARTIALLY TESTED.** Automatisierte Regression und Exportprüfungen sind bestanden; die native Windows-/manuelle Abnahme bleibt offen. M02–M04 wurden nicht begonnen. Die Creative Design Bible ist integriert, ohne ihre späteren Gameplay-Systeme vorzuziehen.

## Wiederaufnahme und erhaltene Arbeit

Beim erneuten Einstieg war GitHub noch auf dem abgeschlossenen M00-Stand. Die lokale Arbeitsumgebung war bereinigt; der zuvor entwickelte, noch nicht hochgeladene M01-Code und seine Rohlogs/Exporte waren nicht mehr vorhanden. Deshalb wurden Repository und unveränderte Eingaben wiederhergestellt und die bereits dokumentierten M01-Änderungen rekonstruiert. Der Audit und die abgeschlossene Designanalyse wurden nicht neu begonnen.

Die vollständige Design-Bible und der Save-/UI-Kern wurden unmittelbar auf `foundation/m01-recovery` gesichert (`c38a6b34244230ad1a8408f40c32127e197bcf05`), anschließend die wiederhergestellten und bestandenen Tests (`4c47b76c8b56465c5378d1d887b3fcdb75f7aa34`). Die hier verlinkten aktuellen Prüfartefakte wurden nach der Wiederherstellung neu erzeugt. Frühere lokale Rohlogs werden nicht als wiedergefundene Belege ausgegeben.

Das ursprüngliche 0.4-Release auf `reference/v0.4-original`, die M00-Reports und alle sechs eingefrorenen Spielstände bleiben unverändert. Persönliche Windows-Spielstände lagen nicht vor. Die vollständige Referenzsicherung und die Original-DOCX stimmen mit ihren bekannten SHA-256-Werten überein.

## Creative Design Bible — Integration

Die vollständige [Creative Design Bible v1.0](CREATIVE_DESIGN_BIBLE_V1.md) besitzt die kreative Zieldefinition. Sie enthält die übertragenen Texte und Tabellen des unveränderten Originals samt Herkunftshash; keine Zusammenfassung ersetzt ihre Regeln.

1. **Architektur-relevante Prinzipien:** Neugier und Optionen statt Pflichtketten; freie Charakterentwicklung mit bedeutsamer Spezialisierung; bleibende, nachvollziehbare Konsequenzen; eine unabhängig vom Spieler glaubwürdige Welt; kombinierbare Regeln und optionale Tiefe statt unnötiger Komplexität. Daraus folgen Anforderungen an stabile Identitäten, klare Zustandsbesitzer und überprüfbare Interaktionen — keine bereits implementierte Gesamtsimulation.
2. **Später starke technische Auswirkungen:** kuratierte prozedurale Welt samt Persistenz; Region-Lifecycle und abgestufte Simulation; NPC-Routinen und Weltzeit; verzweigte/zeitabhängige Quests; Combat/Magie/Umgebung; modulare Charakter-, Gegenstands- und Progressionsregeln; regionale Wirtschaft und Crafting. Ihre Umsetzung bleibt von Priorität, Abhängigkeiten, Foundation-Reife, Architekturaufwand und Tests abhängig.
3. **Bewusst offen:** konkrete Biome/Kulturen/Fraktionen und Inhaltspools, Magieschulen, Progressionskurven, Wirtschaftsformeln, Karten-/Quest-UI, konkrete Reiseausgestaltung, machbare Umweltinteraktionen, Gegner/Bosse, Endgame-Balance und spätere Feature-Prioritäten. Maßgeblich bleibt Abschnitt 21 der Bible; neue Details sind bis zu Tims Bestätigung **PROPOSAL**.

Technische Einschränkungen werden als Design-/Architekturkonflikt benannt, wenn sie die gewünschte Spielerfahrung verhindern. Sie ändern die Vision nicht stillschweigend. Die tatsächlich implementierte Architektur bleibt in [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md), die Reihenfolge in [ROADMAP.md](../ROADMAP.md).

## Reproduzierter Fehler und kleinster Fix

Im vorherigen Lauf wurde der M00-Fehler vor der Änderung reproduziert: Eine beschädigte Hauptdatei mit gültiger Format-3-Sicherung ließ sich laden; beim anschließenden Speichern wurde die gültige Sicherung durch die beschädigte Hauptdatei ersetzt. Die neue Regressionsprüfung bestand im unveränderten Stand 7 von 8 Checks. Diese frühere Messung ist im Arbeitsverlauf dokumentiert; ihr lokales Rohlog ging bei der Bereinigung verloren.

Zusätzlich wurde dort ein tatsächlicher Fehler nach erfolgreichem Öffnen/Schreiben ausgelöst: Im isolierten Linux-Kindprozess begrenzte `RLIMIT_FSIZE` die Datei auf 64 statt 895 Bytes. Godot meldete `store=true`, `get_error=0`; die alte Implementierung meldete dennoch Speichern als erfolgreich und verlor in dieser Konstellation den letzten ladbaren Stand. Dies war ein realer, auf entbehrliche Testdateien beschränkter Schreibfehler, keine Beschädigung persönlicher Saves.

Die **aktuelle erneute Prüfung** erzeugt denselben Betriebssystemfehler. Der Fix meldet einen unvollständigen Schreibvorgang; `backup_unchanged=true` und `previous_save_loadable=true`. Das aktuelle Rohlog liegt unter [real_write_error.txt](../qa/m01_logs/real_write_error.txt).

| Geänderte Laufzeitdatei | Begründeter Umfang |
| --- | --- |
| `scripts/persistence/save_system.gd` | Temp-Datei vollständig zurücklesen; nur validierte Quellen als Sicherung übernehmen; Migrationkopien geprüft veröffentlichen; fehlgeschlagene Umbenennung ohne Verbrauch des letzten gültigen Stands behandeln |
| `scripts/persistence/save_file_io.gd` | Kleiner Dateiadapter pro Schreibaufruf für reproduzierbare Write/Flush/Copy/Rename-Fehler; kein globaler Zustand |
| `scripts/ui/game_ui.gd` | Vorhandene Speicherfehlermeldung und erfolgreichen Wiederholungsversuch auch im Pausefenster anzeigen |

`game.gd`, RunState, SourceQuest, RelicInventory, SourceStory, Combat, Szenen, Inhaltsdaten, Generatoren und Exportkonfiguration wurden nicht verändert. Das vorhandene Verhalten bei fehlgeschlagenem Speichern vor Titelwechsel/Fensterschließen wird geprüft, nicht neu geschrieben. Speicherformat 3, Dateiname und Migrationen bleiben erhalten. Die genaue Schreibfolge und ihre Grenzen haben einen zentralen Besitzer in [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md#speicherung-und-kompatibilität).

## Prüfnachweis

| Bereich | Status | Nachweis |
| --- | --- | --- |
| Save-Fix und sichtbare Fehlermeldung | **IMPLEMENTED** | Drei oben genannte Laufzeitdateien; kein Architektur-Rewrite |
| Gesamte bestehende Regression | **TESTED** | 197/197, einschließlich Save-/Load und 0.1–0.3-Migrationen |
| Neue portable Save-Prüfungen | **TESTED** | 8 + 71 + 14 = 93; insgesamt 290/290 |
| Tatsächlicher OS-Schreibfehler | **TESTED** | Zusätzlich zu 290; Fehler erkannt, Sicherungsbytes unverändert, vorheriger Stand ladbar |
| Release-Export und Pack-Smoke | **TESTED** | Offizielle 4.5.1-Vorlagen; Linux nativ, Windows-Pack unter Linux; Questabschluss, Recovery und fehlgeschlagenes Speichern |
| Betroffene Oberfläche | **TESTED** | Gerenderte Save-Szene 16/16 (14 bestehende Szenenchecks + zwei Captures); beide PNGs tatsächlich visuell geprüft: vollständige Pausefehlermeldung, Panel innerhalb 640 × 360, sichtbarer Recovery-Hinweis |
| Native Windows-Ausführung, persönliche Saves, menschliche Smoke-Runde | **NOT TESTED** | Offen; kein automatischer Test ersetzt diese Abnahme |
| M01 insgesamt | **PARTIALLY TESTED** | Automatische Abnahme bestanden, manuelle Plattformabnahme offen |
| M02–M04 | **PLANNED** | Nicht begonnen |

Prüfgruppen und reproduzierbare Befehle stehen in [TESTING.md](../TESTING.md). Aktuelle strukturierte Ergebnisse: [qa/m01_results.json](../qa/m01_results.json); Dateien und Prüfsummen: [qa/m01_reference_manifest.json](../qa/m01_reference_manifest.json); vollständige Logs: [qa/m01_logs/](../qa/m01_logs/). Das neue Windows-Testarchiv ist von den ursprünglichen 0.4-Referenzartefakten getrennt.

Kontrollierte Spielaufnahmen: [Speicherfehler im Pausefenster](../qa/m01_images/m01_save_error.png) und [Wiederherstellung aus Sicherung](../qa/m01_images/m01_save_recovered.png). Software-OpenGL/X11; keine native Windows- oder menschliche Spielabnahme.

## Grenzen und nächster Schritt

Fehlerinjektion deckt auch den Fall ab, dass eine Windows-Umbenennung zuerst das Ziel entfernt und anschließend scheitert. Die Prüfung lief unter Linux und ist ausdrücklich kein nativer Windows-Nachweis. Kein Anspruch auf Stromausfall-Dauerhaftigkeit, parallele Schreiber, mehrstündige Stabilität oder vollständig fehlerfreies Spiel.

Für die offene Windows-Runde enthält das neue Testarchiv `START_HIER.txt`; die genaue Abnahme steht in [TESTING.md](../TESTING.md#offene-native-windows-manuelle-abnahme). Vor einem Test den gesamten bisherigen Benutzerordner separat sichern, weil beide Builds denselben Speicherort nutzen. Danach erst den nächsten Foundation-Meilenstein gesondert bearbeiten.
