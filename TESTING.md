# Prüfungen und bekannte Grenzen

## Foundation M04 — aktueller Nachweis vom 21.09.2026

**IMPLEMENTED / PARTIALLY TESTED.** Der finale isolierte Gesamtlauf besteht **707/707 Checks**: 504 bisherige und 203 neue. Zusätzlich bestehen der echte Linux-Schreibfehler und die Release-Prüfungen. **Eigener manueller M04-Windows-Spieltest: NOT TESTED.** Tims ausdrückliche M03-Abnahme deckt den neuen Build nicht ab. Nach M04 ist Stop vor einer weiteren Entwicklungsphase.

[Foundation Completion Report](docs/FOUNDATION_COMPLETION_REPORT.md) · [Ergebnisse](qa/m04_results.json) · [Logs](qa/m04_logs/) · [Prüfsummen](qa/m04_reference_manifest.json).

| Prüfgruppe | Nachweis |
| --- | --- |
| Alle vierzehn bisherigen Gruppen | 504/504; alle Assertions erhalten. Der alte Test für eine fehlende Quellenbelohnung injiziert den Fehler jetzt in eine ausdrücklich isolierte Content-Kopie, weil der veröffentlichte Cache schreibgeschützt ist |
| `content_validation_suite.gd` | 88/88; echte JSONs, fehlende Pflichtfelder, falsche Typen einschließlich Bool/Zahlstring, unbekannte Felder/IDs/Enums, NaN/±Infinity, negative/gebrochene Zahlen, Referenzen, Räume/Links/Spawns/Discovery, Tokenprüfung und Zahlenformatierung |
| `data_consistency_suite.gd` | 89/89; gültige geänderte Testdefinitionen erreichen Player/Vitals, Zauber/Dash, HUD, Journal, Dialoge, tatsächliche Projektile, Schaden/Boni, Belohnungen und Brunnen. Einmalige Vergabe; alte Save-Ressourcen über niedrigeren Maxima, sechs Original-Fixtures, erneutes Save/Load und Backup-Recovery |
| `content_startup_probe.gd` / `verify_content_startup.py` | 26/26 in vier eigenen Prozessen: defektes JSON, fehlende Reliktreferenz, ungültige Raumgeometrie, gültiger Cache trotz nachträglich defekter Datei. Test-PCKs überlagern nur den jeweiligen Prüfprozess; keine Quelldatenänderung. Fehleransicht, kein Run/Player/Teilbundle, kein Save-Schreiben, unveränderte Dateibytes |
| `export_smoke.gd` | Linux nativ und Windows-Pack unter Linux: Datenkonsistenz, vollständiger Quellenabschluss, Belohnungs-Replay, Regionslebenszyklus, Save-Recovery und Schreibfehler |
| Release-Startschutz | Dieselben vier Startproben zusätzlich mit jedem Release-Pack bestanden; die jeweils 26 werden nicht doppelt zur 707-Summe gezählt |

Der finale Runner umfasst 19 Stufen: Import, 16 GDScript-Gruppen, Startup-Proben und echter Linux-Dateifehler. `Content` validiert nur einmal je Prozess, nicht pro Frame. Die Ladezeit aus dem Prüflog steht in `qa/m04_results.json`; sie ist eine einzelne lokale Headless-Messung, keine Performance-Garantie.

Ein früher paralleler Gesamt-/Exportlauf meldete drei Fehler in der 95er-Regionssuite. Zwei isolierte Nachprüfungen und der abschließende serielle Gesamtlauf bestanden. Die Ursache dieser einmaligen Abweichung wurde nicht eindeutig reproduziert; sie wird nicht als behobener Spielfehler ausgegeben. Die Suite meldet nun den genauen Save-/Load-Fehler, falls er erneut auftritt. Die fehlgeschlagene Ausgabe bleibt archiviert. Weitere Tests und Exporte werden in getrennten Profilen nacheinander ausgeführt.

Der erste zusätzliche Release-Datentest erkannte „6.0 Mana“ im aus JSON formatierten Text. Der Formatter erhält nun die bisherigen Ganzzahltexte und tatsächliche Bruchteile; vier zusätzliche Assertions und beide Release-Smokes prüfen das. Neue grafische M04-Aufnahmen sind **NOT TESTED**: Xvfb konnte keine Display-Sockets öffnen. Die Daten der tatsächlichen UI-Nodes sind automatisch geprüft; eine neue visuelle/Windows-Prüfung wird nicht behauptet.

### Reproduzieren

Die bestehende Befehlsfolge unten gilt weiter. Alle Läufe erhalten getrennte `XDG_DATA_HOME`-/`XDG_CONFIG_HOME`-Verzeichnisse; keine Prüfungen gegen persönliche Save-Ordner durchführen. `tools/verify.py` speichert auch bei einem Timeout das Teillog und meldet einen Fehlschlag. Erwartete Content-Diagnosen werden ausschließlich in den dafür vorgesehenen Startup-Proben erlaubt; Scriptfehler bleiben Fehler.

```bash
XDG_DATA_HOME=/absoluter/testpfad/data XDG_CONFIG_HOME=/absoluter/testpfad/config python3 tools/verify.py /absoluter/pfad/zu/godot
python3 tools/verify_content_startup.py /absoluter/pfad/zum/linux-release
python3 tools/verify_content_startup.py /absoluter/pfad/zu/godot /absoluter/pfad/zu/Lichterhain.exe
```

Die zweite und dritte Zeile verwenden eigene temporäre Benutzerprofile. Testskripte/Reports werden nicht in das Spielpaket ausgeliefert; Exportproben laufen von außen gegen den jeweiligen Pack. Original-Fixtures niemals neu erzeugen, um einen Test bestehen zu lassen.

### M04 unter Windows abnehmen — NOT TESTED

Vorher den gesamten bisherigen Ordner `%APPDATA%\Godot\app_userdata\Lichterhain\` separat sichern. Das neue Paket verwendet denselben Speicherort. `Lichterhain_0.4_M04_Windows.zip` vollständig entpacken und `Spielen/Lichterhain.exe` starten.

1. Bestehenden M03-Spielstand fortsetzen: Ressourcen, Fortschritt, Talente, Quelle/Relikt und Funde prüfen.
2. Lichtfunke/Frostkreis/Ausweichen benutzen: Kosten, Regeneration, Cooldownanzeige und Ressourcenbalken müssen zum tatsächlichen Verhalten passen. Talent- und Relikttexte im Journal lesen; bisherige Werte sind erhalten.
3. Mit vorhandenen Talenten Fließenden Schritt/Heilung prüfen. Quellenherz an-/ablegen: Nova mit Treffer gibt einmal 6 MP, ohne Treffer keinen Refund. Keine doppelten Boni bei mehreren Gegnern.
4. Am Lager, Waldlicht und in der Gruft rasten. Die Sickerquelle kostet weiterhin 2 Lichtstaub; vollständig erholt wird nichts abgezogen.
5. Wald → Gruft → Wald, normaler Kampf, Speichern/Beenden/Fortsetzen. Einmalige Funde/Belohnungen dürfen nicht wiederholt vergeben werden.
6. Ergebnis und gegebenenfalls Windows-Version, Auffälligkeiten und EXE-Hash aus `START_HIER.txt` festhalten. Danach Report gemeinsam prüfen; keine Folgephase automatisch beginnen.



## Foundation M03 — historischer Nachweis vom 16.09.2026

**IMPLEMENTED**, automatisch **TESTED**, insgesamt **PARTIALLY TESTED**. 504/504 Checks: alle 405 bisherigen plus 99 neue. Zusätzlich der unveränderte echte Linux-OS-Schreibfehler. Beide Release-Packs bestanden; native Windows-Ausführung und menschlicher Spieltest des **M03-Builds** sind **NOT TESTED**. Tims bestätigte M02-Abnahme wird nicht auf eine neue EXE übertragen.

Bericht: [FOUNDATION_M03.md](docs/FOUNDATION_M03.md); Ergebnisse: [qa/m03_results.json](qa/m03_results.json); Rohlogs: [qa/m03_logs/](qa/m03_logs/); Dateihashes: [qa/m03_reference_manifest.json](qa/m03_reference_manifest.json). Isoliertes Benutzerprofil; keine persönlichen oder eingefrorenen Saves überschrieben. Archivierte Textlogs wurden nur um Terminal-Farbcodes und Leerzeichen an Zeilenenden bereinigt; Prüfaussagen sind unverändert.

| Prüfung | Ergebnis |
| --- | --- |
| `region_replay_reproduction.gd` | Auf unverändertem M02 **1/4**, nach Fix **4/4**. Echter Hütertod, dann Gruft–Wald–Gruft ohne Zwischenframe: alter Abschluss darf neue Gruft weder lösen noch belohnen oder deren Hüter entfernen |
| `region_lifecycle_suite.gd` | **95/95**: beide Richtungen, gesperrte/ungültige Reise, sofortiger Referenzabbau, Ressourcen, Gruppen/IDs, alte Signale/Interaktionen/UI, echte Timer, Projektile/Einschläge/Dornen, aktuelle gültige Hüterbelohnung, Load/neuer Run, zwölf schnelle Wechsel, Savefehler/Retry, Tod/Camp und wiederholtes Unload |
| Bestehende zwölf Gruppen | **405/405**, einschließlich echtem Zauberkampf gegen Hüter, beiden Questwegen, Legacy-Saves und M01/M02-Fehlerpfaden |
| `measure_region_lifecycle.gd` | Identischer Lauf auf M02/M03: 14 Wechsel, davon 12 gemessen nach Aufwärmen. Je 14 Player, Views und CombatSysteme; ein aktiver Player, stabile Objekt-/Node-Zahlen. [Rohmessungen](qa/m03_region_measurements.json) |
| `export_smoke.gd` | Beide Release-Packs: `EXPORT REGION LIFECYCLE PASS`, zusätzlich bestehende State-Replay-/Recovery-/Savefehler-Prüfungen und `EXPORT SMOKE PASS`. Linux nativ; Windows-Pack mit Linux-Engine |
| Grafische M03-Aufnahmen | **NOT TESTED**: X11-Server konnte lokale Sockets nicht öffnen. Es wurden keine neuen Spielbilder erzeugt. UI-Signale wurden headless geprüft; keine Layout-/Grafikänderung |

Die 95 Lifecycle-Checks enthalten wiederholte Invarianten je Wechsel; sie sind keine 95 verschiedenen Gameplay-Features oder Spielstunden. Der Timer-Test erzeugt bewusst einen außerhalb des alten Baums wartenden SceneTreeTimer mit gebundener Herkunft. Für aktuelle Hüterabschlüsse und bestehenden echten Kampf bleiben positive Tests erhalten, damit die Absicherung nicht einfach alle Abschlüsse blockiert.

Der zuerst versuchte Export fand im frischen Prüfprofil die bereits vorhandenen Vorlagen nicht. Nach Verknüpfung derselben offiziellen 4.5.1-Vorlagen bestanden beide Exporte; kein Produktcode wurde dafür geändert. Der Ausgangsfehler ist separat archiviert. Die Runtime blieb nach dem vollständigen Gate unverändert.

**Nachtrag 20.09.2026:** Tim hat M03 im M04-Auftrag ausdrücklich als abgeschlossen und manuell unter Windows bestätigt bezeichnet. Die damalige Abnahmelücke ist geschlossen; die darunterstehende Prüfliste ist kein nachträgliches Einzelprotokoll.

### M03 unter Windows abnehmen (historische Prüfliste)

Vorher den bisherigen Ordner `%APPDATA%\Godot\app_userdata\Lichterhain\` separat sichern. Das M03-Paket benutzt denselben Pfad wie M02. Archiv vollständig entpacken; `Spielen/Lichterhain.exe` starten und den alten Stand fortsetzen.

1. Wald → Gruft → Wald mehrfach spielen, auch direkt zurückkehren. Genau ein Magier, passende Gegner, Kamera/HUD und Interaktionen prüfen.
2. Während gegnerischer Geschosse wechseln; Hüter herausfordern, zurückziehen, Region verlassen und erneut betreten. Alte Angriffe oder ein alter Abschluss dürfen die neue Region nicht treffen.
3. Nach beiden Wechselrichtungen speichern, Anwendung schließen, laden; Position, Ressourcen, Quest/Funde/Tore und Relikt prüfen.
4. In der Gruft sterben und zum Lager zurückkehren. Normalen Kampf und Steuerung kurz prüfen.
5. Ergebnis und möglichst Windows-Version sowie Buildhash festhalten; der Hash der ausgelieferten EXE steht im Paket und Referenzmanifest. Bis dahin bleibt M03 **PARTIALLY TESTED**, M04 **PLANNED**.


## Foundation M02 — historischer Nachweis vom 16.09.2026

**IMPLEMENTED**, automatisierte Regression **TESTED**, insgesamt **PARTIALLY TESTED**. 405/405 Checks (290 unverändert erhaltene + 115 neue), zusätzlicher echter OS-Schreibfehler, beide Release-Exporte und Pack-Smokes bestanden. Linux lief nativ; das eingebettete Windows-Spielpaket wurde unter Linux geprüft. Native Windows-Ausführung, persönliche Windows-Spielstände und menschliche Smoke-Runde bleiben **NOT TESTED**.

Bericht: [FOUNDATION_M02.md](docs/FOUNDATION_M02.md); strukturierte Ergebnisse: [qa/m02_results.json](qa/m02_results.json); Rohlogs: [qa/m02_logs/](qa/m02_logs/); geprüfte Dateihashes: [qa/m02_reference_manifest.json](qa/m02_reference_manifest.json). M00-/M01-Reports und eingefrorene Spielstände bleiben historische Referenzen.

| Neue Prüfgruppe | Ergebnis und Aussage |
| --- | --- |
| `state_replay_reproduction.gd` | 3/3; eine zweite inaktive Truhenansicht kann den bereits gespeicherten Fund nicht erneut vergeben oder den Save ungültig machen. Vor dem Fix auf M01: 1/3, beide Fehler im Baseline-Log dokumentiert |
| `state_actions_suite.gd` | 100/100; ID-/Voraussetzungsprüfung, einheitliche komplette Belohnungen, Wiederholungen, Reentranz aus Signalhandlern, Meldung unmittelbar speicherbarer Zustände, beide Quellenwege, Kosten, Relikte und unabhängige Snapshots |
| `state_actions_scene.gd` | 12/12; echter Questabschluss und Erzernte bei blockierter Temp-Datei, vorige Dateibytes erhalten, Wiederholung ohne zweite Belohnung, erneutes Speichern und Laden |
| Erweiterter Export-Smoke | Zusätzlich `EXPORT STATE REPLAY PASS` aus beiden kompilierten Spielpaketen; M01-Recovery-/Schreibfehler-Smokes bleiben erhalten |

`python3 tools/verify.py /absoluter/pfad/zu/godot` führt nun zwölf Gruppen plus unter Linux den echten Schreibfehler aus. Weiterhin ein isoliertes Prüfprofil verwenden; Details unten. Nach dem vollständigen Gate wurde ausschließlich im neuen Szenentest die bereits im M01-Test bewährte kurze Wartezeit für die Freigabe des Audio-Playbacks ergänzt. Der finale Szenentest wurde separat erneut mit `--verbose` bestanden; kein Audio-Objekt blieb beim Prozessende offen. Diese Test-Aufräumänderung verändert weder Runtime noch Assertions.

Acht Ansichten wurden mit `tests/capture_source.gd` unter X11/Mesa erzeugt. Drei wurden tatsächlich visuell kontrolliert: Quellengarten, Kampfabschlussdialog und Reliktausrüstung; archiviert unter [qa/m02_images/](qa/m02_images/). Die übliche VSync-Warnung des virtuellen Treibers ist im Capture-Log erfasst. Der Capture-Ablauf stellt den Kampfabschluss direkt her; der echte Kampf bleibt in `source_suite.gd` geprüft. Kein menschlicher Spieltest wird daraus abgeleitet.

### M02-Windows-Spieltest — nachträglich bestätigt

Zuerst den bisherigen Benutzerordner vollständig separat sichern (Pfad in der M01-Anleitung unten); das M02-Testpaket benutzt denselben Speicherort. Einen bestehenden Stand laden, Erinnerungen/Funde erneut aufsuchen und bei Edda sprechen. Bereits erhaltene Funde und abgeschlossene Questbelohnungen dürfen keine weiteren XP erzeugen. Relikt ab-/anlegen, Wald/Gruft wechseln, speichern und neu starten. Auf einem separaten passenden Teststand Erz zweimal ansprechen: nur der erste Fund gibt vier Lichtstaub. Den gewohnten Kampf und die Steuerung kurz prüfen; Ergebnis mit Windows-Version und Buildhash festhalten. Tim hat vor M03 ausdrücklich einen erfolgreichen manuellen Windows-Spieltest bestätigt (**TESTED — Nutzerbericht**, M02 abgeschlossen). Die konkrete Windows-Unterversion, Schrittfolge und Buildhash wurden nicht genannt; die obige Prüfliste wird damit nicht rückwirkend als einzeln protokolliert ausgegeben.


## Foundation M01 — historischer Nachweis vom 16.09.2026

**IMPLEMENTED**, automatisierte Regression **TESTED**, Meilenstein insgesamt **PARTIALLY TESTED**: 290/290 Checks (197 bestehende + 93 neue), zusätzlich ein echter Betriebssystem-Schreibfehler. Beide Release-Exporte wurden erstellt und geprüft: Linux nativ, Windows-Ressourcenpaket unter Linux. Native Windows-Ausführung, persönliche Windows-Spielstände und eine menschliche Smoke-Runde sind **NOT TESTED**.

Aktueller Bericht: [docs/FOUNDATION_M01.md](docs/FOUNDATION_M01.md); maschinenlesbare Ergebnisse: [qa/m01_results.json](qa/m01_results.json); Rohlogs: [qa/m01_logs/](qa/m01_logs/); geprüfte Dateihashes: [qa/m01_reference_manifest.json](qa/m01_reference_manifest.json). Diese Nachweise stammen aus der erneuten Verifikation des wiederhergestellten Arbeitsstands. Frühere lokale M01-Logs gingen bei der Bereinigung verloren und werden nicht als gespeicherte Belege ausgegeben.

Der historische M00-Nachweis bleibt unverändert unter [qa/m00_results.json](qa/m00_results.json), [qa/m00_logs/](qa/m00_logs/) und im [M00-Bericht](docs/FOUNDATION_M00.md). Die sechs eingefrorenen Save-Dateien und ihre Herkunft bleiben unverändert; zentrale Quelle: [tests/fixtures/README.md](tests/fixtures/README.md). Persönliche Saves wurden nicht bereitgestellt.

### M01-Prüfgruppen

| Prüfung | Umfang / Ergebnis |
| --- | --- |
| Sechs bestehende Gruppen unten | 197/197; Welt, Kampf, UI, Regionen, Quellenquest, Relikt und Migrationen |
| `save_io_reproduction.gd` | 8/8; beschädigte Hauptdatei + gültige 0.4-Sicherung, Speichern nach Recovery, real blockierter temporärer Pfad |
| `save_fault_suite.gd` | 71/71; Write/Flush, Kurzschreiben, falsche Bytes trotz Erfolg, Copy/Rename, real blockierte Umbenennung, Fehlermeldungen ohne erfundene Sicherung, Legacy-Kopien/Migrationen, ungültige/beschädigte/zu große Daten, Zukunftsversionen, unveränderte Fixtures |
| `save_scene_smoke.gd` | 14/14 headless; echte Szene mit drei 0.4-Zuständen, Fehler beim Speichern/Schließen/Titelwechsel, erneuter Versuch, lesbare Meldung im Pausefenster, Recovery |
| `tools/reproduce_save_write_error.py` | **TESTED**, zusätzlich zu den 290 Checks: Linux-Kindprozess mit 64-Byte-Dateigrenze; geöffnetes Schreiben meldet intern Erfolg, Datei ist trotzdem unvollständig; SaveSystem erkennt den Fehler, Sicherung bleibt unverändert und ladbar |
| `export_smoke.gd` | **TESTED** gegen beide Release-Packs; bestehender Questabschluss plus beschädigte Hauptdatei/Recovery und fehlgeschlagenes Speichern |
| Grafische Save-Szene | **TESTED**, 16/16 unter X11/Mesa: dieselben 14 Szenenchecks plus zwei PNG-Ausgaben. Beide tatsächlichen Spielansichten visuell kontrolliert; Pausefehlermeldung vollständig lesbar, Panel innerhalb 640 × 360, Recovery-Hinweis sichtbar |

Die beiden kontrollierten Aufnahmen liegen unter [qa/m01_images/](qa/m01_images/). Der virtuelle Treiber unterstützt keinen VSync-Wechsel; die entsprechende Warnung ist protokolliert. Dies ist eine automatisiert gesteuerte Szene mit visueller Kontrolle, keine menschliche Spielrunde.

Injizierte Windows-Rename-Semantik (Ziel vor Fehlschlag entfernt) ist keine native Windows-Ausführung. Der echte Schreibfehler-Test setzt das Dateilimit ausschließlich im kurzlebigen Testprozess und arbeitet in einem eigenen temporären Benutzerprofil. Unter anderen Betriebssystemen wird dieser einzelne Test ausdrücklich als nicht getestet ausgewiesen; die portable Fehlersuite bleibt ausführbar.

### Reproduzierbarer Prüfablauf

Godot 4.5.1 Standard und offizielle Exportvorlagen derselben Version verwenden. In einer Arbeitskopie mit isoliertem Benutzerprofil ausführen; `test-output/` besitzt nur neue Ergebnisse. Vorhandene `qa/`-Referenznachweise nicht überschreiben.

```bash
XDG_DATA_HOME=/absoluter/pruefpfad/data XDG_CONFIG_HOME=/absoluter/pruefpfad/config python3 tools/verify.py /absoluter/pfad/zu/godot
```

Seit M03 laufen vierzehn Testgruppen nach dem Import nacheinander; unter Linux folgt der echte Schreibfehler. Der Runner prüft Exitcodes, Scriptfehler und den Abschlussmarker des Szenentests. Exportprüfung: beide Presets mit `--export-release` in neue Ausgabepfade exportieren; `tests/export_smoke.gd` extern gegen den Linux-Build und mit dem Linux-Editor über `--main-pack` gegen die Windows-EXE ausführen. Tests, Reports und Dokumentation sind vom Spielpaket ausgeschlossen.

Die grafische Variante von `tests/save_scene_smoke.gd` benötigt eine grafische Sitzung. Sie ergänzt zwei Capture-Prüfungen (16 statt 14); diese sind kein zweiter Satz von 14 zusätzlichen Regressionstests. Frühere Capture-/Kampfläufe bleiben für gezielte Regressionen erhalten.

### Offene native Windows-/manuelle Abnahme

1. Spiel schließen und den gesamten Ordner `%APPDATA%\Godot\app_userdata\Lichterhain\` separat kopieren. Das M01-Paket benutzt denselben Speicherort. Originale 0.4-Dateien außerhalb des Testordners aufbewahren.
2. M01-Archiv vollständig entpacken, EXE starten, bisherigen Speicherpunkt fortsetzen; Questlösung, Relikt, Talente, Waldlichter und Funde prüfen.
3. Wald/Gruft wechseln, speichern, beenden, erneut laden; Steuerung, Kampf und sichtbare Folgen kurz prüfen.
4. Nur in einer entbehrlichen Testkopie: eine gültige Hauptdatei nach `.bak` kopieren, Hauptdatei beschädigen, Recovery-Hinweis und erneutes Speichern prüfen. Anschließend `.bak` auf unveränderte Bytes kontrollieren.
5. Nur im Testprofil vor dem Speichern einen Ordner `lichtpfad_v1.json.tmp` anlegen. F5, „Speichern und zum Titel“ und Fensterschließen müssen einen sichtbaren Fehler zeigen und die Sitzung erhalten. Den Testordner entfernen, erneut speichern und laden.
6. Resultat mit Windows-Version, Buildhash und konkreten Beobachtungen protokollieren. Bis dahin bleibt diese Abnahme **NOT TESTED**.

## Historische Releaseprüfung 0.4

Stand: Version 0.4, Godot 4.5.1.stable.official.f62fdbde1, Linux x86_64; 2026-09-13.

**197/197 Prüfungen bestanden:** 50 Spiel-/Speicherprüfungen, 14 UI-Prüfungen, 8 Prüfungen eines originalen 0.1-Spielstands, 48 Dungeon-Prüfungen, 12 Migrationsprüfungen mit einem originalen abgeschlossenen 0.2-Spielstand und 65 Quellenprüfungen einschließlich eines originalen 0.3-Spielstands. Der abschließende lokale Prüfablauf meldet keine Scriptfehler. Die jeweils 100 Seeds in Wald-, Dungeon- und Quellenprüfungen zählen innerhalb dieser Gruppen, nicht als zusätzliche Spielstunden.

16 tatsächliche Godot-Spielansichten wurden gerendert: Titel, Lager tagsüber/abends, Waldkampf, Fluss, Journal, Pause, Waldkarte sowie ruhender Hüter, Quellenentscheidung, Zeichenfolge, Quellengarten, Reliktplatz, Hüterkampf, Sieg und Erzader. Kontrolliert wurden Texte, Menüränder, Figurenkontrast, Raumgestaltung und Kampfmarkierungen. Es handelt sich um Spielaufnahmen, nicht um Konzeptbilder.

Der gerenderte 60-Sekunden-Hüterkampf lief mit aktiven Schlägen, Projektilfächern und Magierzaubern: 3.559 Frames, Mittel 16,86 ms, 95. Perzentil 17,67 ms. Objektzahlen: anfangs 368, maximal 383, am Ende 379; höchstens fünf Hütergeschosse gleichzeitig. Nach drei Hin- und Rückreisen waren jeweils 4.558 Nodes im Wald und 368 in der Gruft aktiv. Keine anwachsende Objektzahl in diesem geprüften Umfang. Software-OpenGL über Mesa llvmpipe, Obergrenze 60 FPS; keine Aussage zur Leistung auf anderen Geräten oder mehrstündiger Stabilität. Der virtuelle Treiber meldet erwartungsgemäß keine Unterstützung für das Umschalten von VSync.

Windows- und Linux-Release wurden mit offiziellen 4.5.1-Vorlagen exportiert. Der native Linux-Export und das eingebettete Ressourcenpaket des Windows-Exports wurden unter Linux gestartet. Geprüft wurden Version, Raum-/Gegnerzahl, enthaltene Fundtexte, Hüteraufbau und der vollständige Untersuchungsabschluss einschließlich Quellengarten, ausgerüstetem Quellenherz und gespeichertem Format 3. Das ersetzt keinen nativen Windows-Test. Das Windows-Archiv besteht zusätzlich die ZIP-Prüfsummenprüfung; PE-Header und x86_64-Architektur wurden geprüft.

**Menschlicher Spieltest zum damaligen Bericht:** Tim hatte 0.1 gespielt, den Prototyp positiv beurteilt und deutlich schönere Grafik gewünscht. Die spätere positive Rückmeldung zur neuen Version ist im M00-Nachtrag oben aufgenommen. Die Ergebnisse unter `qa/` belegen automatisierte Prüfungen, kein Urteil über mehrstündigen Spielspaß.

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

`godot` steht für Godot 4.5.1. Der lokale Prüfablauf importiert das Projekt und führt die oben beschriebenen vierzehn Testgruppen nacheinander aus; unter Linux folgt der echte Schreibfehler-Test. Er wertet zusätzlich Fehlermeldungen im Log aus, da Godot bei manchen Scriptfehlern Exitcode 0 zurückgeben kann.

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
