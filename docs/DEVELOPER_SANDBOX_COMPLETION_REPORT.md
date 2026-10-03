# DEVELOPER SANDBOX FOUNDATION — COMPLETION REPORT

Prüfstand: **30.09.2026**. Übergabe: **03.10.2026**. Technische Umsetzung und automatisierte Abnahme abgeschlossen; die eigene manuelle Windows-Abnahme der Sandbox steht aus.

| Status | Tatsächlicher Stand |
| --- | --- |
| IMPLEMENTED | Arena, validierte Presets, echte Combat-/Defense-Controls, Diagnose, Reset, endliche Wellen und A01–A12 |
| AUTOMATED TESTED | **1.186/1.186** Checks; zusätzlich **16/16** gerenderte Bedienprüfungen, **8/8** Produktions- und **5/5** Developer-Export-Gates |
| MANUAL WINDOWS TESTED | **NOT TESTED** für diese Sandbox; separates Testpaket und Prüfliste liegen vor |
| NOT TESTED | Lange menschliche Spielrunden, Geräte-/Performancevergleich, Controller und andere Auflösungen |

Getesteter Quellstand: `5bd7554bafb34c8e0ea4872fd91aa89ad6f10e63`, Branch `foundation/developer-sandbox`. Nach diesem Stand werden nur Abschlussdokumente und Prüfnachweise ergänzt, kein Runtime-Code. M07-Referenz: `3b8ce33d6a3c48545636cbd61fa368f81a23494c`.

Die Umsetzung entspricht dem genehmigten Work Order V1.0 und dem Future Systems Blueprint V1.0. M07 ist von Tim nach erfolgreichem Windows-Spieltest abgenommen. Dieser eigenständige Schritt liefert nur das Entwicklerlabor und stoppt vor M08.

## Architektur und Zustandsbesitzer

Die tatsächliche Schnittstelle ist in [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md) dokumentiert. Sandbox-Session und Fixture sind lokal; die spezialisierte RegionInstance verwendet echte Player, Gegner und CombatSystem. RunState bleibt transienter Fortschrittsbesitzer der Testsession. Die normalen Produktionssysteme bleiben unverändert.

ActionTimeline/AttackInstance/ContactContext/CombatContact liefern Kontakt und Defense; M06 berechnet Damage/Impact, Actor/Vitals übernehmen Health und Reaktionen. Beobachtende Unterklassen delegieren unverändert an super. Keine eigene Combat-Formel, globale Registry oder Eventbus-Lösung.

Reset deaktiviert den alten Combat-Scope, entfernt den Baum, erhöht die Generation und erzeugt neue Actors, Ressourcen, Cooldowns, Payload-Besitzer, Wellen und Telemetrie. Pausierte Proben bewegen explizit nur Uhren. Spielerwaffen werden nicht vorweggenommen.

## Umfang und Dateien

- `developer/sandbox.tscn`, `sandbox.gd`: getrennte Arena-Oberfläche und Controls.
- `developer/session.gd`, `fixture.gd`, `waves.gd`: lokaler Lebenszyklus und endliche Begegnungen.
- `developer/catalog.gd`, `presets.json`: validierte, schreibgeschützte Testdaten.
- `developer/observed_player.gd`, `observed_enemy.gd`, `telemetry.gd`: tatsächliche Ergebnisbeobachtung, begrenztes Live-Protokoll.
- `developer/scenarios.gd`: A01–A12.
- `tests/sandbox_suite.gd`, `sandbox_visual_smoke.gd`, `sandbox_export_boundary.gd`: Funktion, Isolation, Oberfläche und Packgrenze.
- `tools/verify_sandbox.py`, `export_sandbox.py`, Ergänzungen an `verify.py`/`verify_exports.py`: reproduzierbare Gates und eigene Pakete.
- `export_presets.cfg`: Sandbox-Ausschluss in Produktions-Exports.
- TECHNICAL_DESIGN, TESTING, ROADMAP, README, TASKS, DECISIONS, CHANGELOG, AGENTS und M07-Abnahmenachtrag; neue Vorgaben/Review/Windows-Prüfliste unter docs.

## Implementierte Szenarien

| ID | Reproduzierbare Prüfung |
| --- | --- |
| A01 | Startup, Commit, Active, Recovery, Completed; ein Kontakt je Phase |
| A02 | Reichweite, bewegter Actor/Target, Facing, Sichtbedingung |
| A03 | Dodge-Schutz und tatsächliche Bewegung, Schutzende |
| A04 | Aktiver Frontblock, reduzierte Mobilität, M06-Restwirkung, Rückentreffer |
| A05 | Parade zu früh, passend und zu spät; kein Stacking, Counter Opportunity |
| A06 | Magierprofil gegen Nahkontakt/Geschoss, vorhandener Frostkreis |
| A07 | Payload nach Caster-Freigabe, kein wiederholter Kontakt |
| A08 | Reale AoE auf mehrere Ziele, explizite neue Hit-Phase |
| A09 | Normal/Interrupt/Stagger, Stability genau einmal, Recovery-Grenze |
| A10 | Abbruch vor Commit, Unterbrechung danach, kein nachträglicher Treffer |
| A11 | Mehrfachreset, alte Projectile-/Timer-Callbacks, ein Player/keine Duplikate |
| A12 | Drei endliche Waves mit echten Kontakten und steigenden Testwerten |

## Persistenz und Produktionsgrenze

Kein normaler Save wird geladen oder geschrieben. Optionaler Diagnosebericht nur unter `user://developer_sandbox/last_report.json`. Developer-Pakete besitzen den eigenen Benutzerordner `Lichterhain_DeveloperSandbox`; normale Projektdatei und Saveformat 3 bleiben erhalten. Die Produktions-Presets schließen den gesamten Developer-Ordner aus.

**139 geschützte Dateien sind bytegleich zu M07:** sämtliche vorhandenen Produktionsscripts, Daten, Szenen, Assets, `project.godot` und eingefrorenen Save-Fixtures. [SHA-256-Manifest](../qa/sandbox_reference_manifest.json). Nur Export-Ausschluss, Prüfrunner, neue Developer-Dateien und Dokumentation erweitern das Projekt.

## Tests und Exportnachweise

| Prüfung | Ergebnis und Grenze |
| --- | --- |
| Vollständige Regression | **26/26 Stufen**, **1.186/1.186 Checks**: bisherige 1.070 plus 116 Sandbox-Checks. Enthält alle Legacy-Saves, Migrationen, State-/Region-/Content-/Interaction-/Combat-Tests, Release-Fehlerstarts und den zusätzlichen echten Linux-Schreibfehler |
| Sandbox | A01–A12, ungültige Presets/Anfragen, echte Buttons, private schreibgeschützte Definitionen, Reset, alte Actors/Callbacks, Wellen, begrenzte Telemetrie und Diagnosepfad |
| Save-Isolation | Kopierte Produktions-Sentinels für Hauptdatei, `.bak`, `.pre-v03`, `.pre-v04` bleiben unverändert; keine neuen Produktionssaves. Separate temporäre Profile, keine persönlichen Spielstände |
| Gerenderte Bedienung | **16/16**, tatsächliche 1280×720-Oberfläche unter Linux/Xvfb/Mesa. Bewegung, F-Block, Eingabefokus, kein versehentliches Zaubern über Controls, Probe, Diagnose, A01–A12, Wellen/Stop/Reset. Vier Aufnahmen visuell geprüft; drei davon dauerhaft gesichert |
| Produktions-Exporte | **8/8 Gates**: Windows/Linux exportiert, bestehende Spiel-/Fehlerstart-Prüfungen plus tatsächlicher Sandbox-Ausschluss aus beiden Packs |
| Developer-Exporte | **5/5 Gates**: Import, Windows/Linux exportiert, je **118/118** Checks gegen nativen Linux-Release und Windows-Ressourcenpaket unter Linux. Zwei zusätzliche Exportchecks prüfen Startszene und eigenen Benutzerordner |
| Windows-Paket | Exakte geprüfte Developer-EXE, Anleitung, Windows-Prüfliste, Completion Report, Build-Information und Lizenzen. ZIP-CRC, EXE-Hash und PE-x86_64-Header geprüft |

Assertions mit parametrisierten Fällen sind keine Feature-Anzahl. Wiederholungen in den Exporten werden nicht zur Summe 1.186 addiert. Windows-Pack-Prüfungen unter Linux ersetzen keine native Windows-Ausführung. Der virtuelle Mesa-Treiber meldet die fehlende Möglichkeit, VSync umzuschalten; keine Performance-Aussage wird daraus abgeleitet.

Nachweise: [Gesamtergebnis](../qa/sandbox_results.json), [Szenarien mit tatsächlichen Ereignissen](../qa/sandbox_scenario_results.json), [Save-Isolation](../qa/sandbox_isolation.json), [Exporte und Binärprüfsummen](../qa/sandbox_export_results.json), [Bedienprüfung](../qa/sandbox_visual_results.json), [Logs](../qa/sandbox_logs), [Screenshots](../qa/sandbox_images), [Paketprüfung](../qa/sandbox_package_results.json). Reproduktion: [TESTING.md](../TESTING.md).

**Nachweisaufbewahrung:** Die automatische Arbeitsbereichsbereinigung entfernte vor der endgültigen GitHub-Sicherung lokale Detailprotokolle. Quellstand und dieses Windows-Paket waren bereits dauerhaft gesichert. Regression und die unveränderte Windows-EXE wurden anschließend erneut geprüft; ihre vollständigen Protokolle liegen unter `qa/sandbox_logs/`. Die zuvor tatsächlich bestandenen Produktions-/Developer-Export-Gates und 16 gerenderten Checks sind aus den aufgezeichneten Tool-Ergebnissen und `BUILD_INFO.json` übernommen und in den zugehörigen JSONs ausdrücklich als früherer Lauf gekennzeichnet. Deren vollständige Export-/Render-Logs sind nicht mehr vorhanden; drei zuvor hochgeladene Bilder sind erhalten. Der Paketinhalt und seine Prüfsumme bleiben unverändert.

## Übergabe — Binärteile vom 03.10.2026

Ausgeliefert werden **neun Binärteile** des unveränderten, bereits geprüften `Lichterhain_DeveloperSandbox_Windows.zip`: `.part001` bis `.part009`. Die Teile 001–008 sind jeweils **4.194.304 Bytes (4 MiB)** groß; Teil 009 hat **574.451 Bytes**. Auch jede Begleitdatei bleibt unter dieser Obergrenze. Die Teile sind keine einzeln entpackbaren ZIP-Archive.

1. Alle neun Teile und `JOIN_WINDOWS_PACKAGE.bat` in denselben Ordner herunterladen; Namen/Endungen beibehalten.
2. `JOIN_WINDOWS_PACKAGE.bat` starten. Sie prüft die Teilgrößen, verbindet die Dateien in expliziter Reihenfolge mit `copy /b` und kontrolliert Gesamtgröße und SHA-256 mit Windows PowerShell.
3. Nach der Erfolgsmeldung `Lichterhain_DeveloperSandbox_Windows_full.zip` vollständig entpacken.
4. `Lichterhain_DeveloperSandbox.exe` starten und `WINDOWS_TEST.md` im entpackten Paket durchgehen.

Die äußere `START_HIER.txt` erklärt diese Schritte. `SHA256SUMS.txt` enthält Hashes für die vollständige ZIP, alle Teile, die BAT und die Anleitung. Eine bereits vorhandene fertige ZIP wird geprüft und nicht überschrieben; bei fehlenden/beschädigten Teilen wird keine neue ZIP als erfolgreich freigegeben. Windows PowerShell wird für die Hashprüfung benötigt; Godot muss nicht installiert sein.

**Vollständige ZIP:** 34.128.883 Bytes. **SHA-256:**

```text
699245a36f6710e7c05c87f4ddc4ce506008f654c40b553c0fee8aaf6a580d13
```

**AUTOMATED TESTED am 03.10.2026:** Original-ZIP vollständig extrahiert (9 Dateien), ZIP-CRC und sämtliche 8 in `BUILD_INFO.json` aufgeführten Datei-Hashes geprüft. Die Reihenfolge wurde aus der tatsächlichen `copy /b`-Zeile übernommen und lokal binär zusammengesetzt: byteweise identisch, gleiche SHA-256, erneut vollständig extrahiert, alle extrahierten Bytes identisch. Größen und Hashes der auszuliefernden Artefakte stehen im [Paketnachweis](../qa/sandbox_split_package_results.json).

**BAT unter nativem Windows: NOT TESTED.** Die BAT wurde statisch geprüft; die lokale Binärzusammensetzung wurde unter Linux verifiziert. Das ist keine native Ausführung von `cmd.exe` oder PowerShell. Auch die manuelle Sandbox-Windows-Abnahme steht weiterhin aus.

Die ZIP bleibt einschließlich ihres ursprünglichen Build-Berichts bytegleich zur geprüften Referenz. Dieser externe Completion Report dokumentiert den aktualisierten Liefermechanismus. Diese Paketlieferung ändert weder Runtime-Code, Sandbox-Logik, M07 noch Produktionsdateien. Das Archiv startet weiterhin direkt im Entwicklerlabor; normale Spielstände werden nicht importiert.

Der Diagnosebericht wird nur auf ausdrücklichen Buttondruck unter `%APPDATA%\Lichterhain_DeveloperSandbox\developer_sandbox\last_report.json` gespeichert. Für eine Fehlermeldung Szenario/Preset, Schritte, tatsächliches Ergebnis und nach Möglichkeit diesen Bericht angeben.

## Bewusste Einschränkungen und Risiken

- **MANUAL WINDOWS TESTED: NOT TESTED.** Prüfliste: [SANDBOX_WINDOWS_TEST.md](SANDBOX_WINDOWS_TEST.md).
- Vollständige Kontaktablehnungsgründe gibt es bei gezielten Proben/Szenarien; freie Combat-Adapter melden nicht jeden Miss. Die Anzeige erfindet keine fehlenden Ergebnisse.
- Nahdistanz-Profil nutzt vorhandenen Magier und Defense. Keine Spielerwaffen/Loadouts vor M08, keine neue Magie-/Status-/Umweltlogik.
- Explizite Fixture-Zustandsänderungen werden protokolliert. Zeitproben sind keine vollständige Welt-/Physiksimulation; freie Bewegungen bleiben eingabe-/physikabhängig.
- Instanz-IDs ändern sich pro Lauf; Szenario-/Preset-IDs sind stabil. Keine persistente Weltidentität oder Welt-Deltas in der Sandbox.
- Keine Behauptung über finale Balance, lange menschliche Spielrunden, Controller, andere Auflösungen oder native Windows-Treiber.

**STOP vor M08.** Erst Sandbox-Bericht und Windows-Test gemeinsam abnehmen; anschließend nächste genehmigte Spezifikation planen.
