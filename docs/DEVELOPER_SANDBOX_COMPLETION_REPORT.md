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

## Übergabe

`Lichterhain_DeveloperSandbox_Windows.zip` vollständig entpacken und `Lichterhain_DeveloperSandbox.exe` starten. Godot muss nicht installiert sein. `START_HIER.txt` erklärt die Controls; `WINDOWS_TEST.md` führt durch die eigene Sandbox-Abnahme. Das Archiv startet direkt im Entwicklerlabor. Bestehende Spielstände werden nicht importiert.

Der Diagnosebericht wird nur auf ausdrücklichen Buttondruck unter `%APPDATA%\Lichterhain_DeveloperSandbox\developer_sandbox\last_report.json` gespeichert. Für eine Fehlermeldung Szenario/Preset, Schritte, tatsächliches Ergebnis und nach Möglichkeit diesen Bericht angeben.

## Bewusste Einschränkungen und Risiken

- **MANUAL WINDOWS TESTED: NOT TESTED.** Prüfliste: [SANDBOX_WINDOWS_TEST.md](SANDBOX_WINDOWS_TEST.md).
- Vollständige Kontaktablehnungsgründe gibt es bei gezielten Proben/Szenarien; freie Combat-Adapter melden nicht jeden Miss. Die Anzeige erfindet keine fehlenden Ergebnisse.
- Nahdistanz-Profil nutzt vorhandenen Magier und Defense. Keine Spielerwaffen/Loadouts vor M08, keine neue Magie-/Status-/Umweltlogik.
- Explizite Fixture-Zustandsänderungen werden protokolliert. Zeitproben sind keine vollständige Welt-/Physiksimulation; freie Bewegungen bleiben eingabe-/physikabhängig.
- Instanz-IDs ändern sich pro Lauf; Szenario-/Preset-IDs sind stabil. Keine persistente Weltidentität oder Welt-Deltas in der Sandbox.
- Keine Behauptung über finale Balance, lange menschliche Spielrunden, Controller, andere Auflösungen oder native Windows-Treiber.

**STOP vor M08.** Erst Sandbox-Bericht und Windows-Test gemeinsam abnehmen; anschließend nächste genehmigte Spezifikation planen.
