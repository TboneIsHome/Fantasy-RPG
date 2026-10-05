# DEVELOPER SANDBOX FOUNDATION — COMPLETION REPORT

> **Abnahme 05.10.2026:** Tim bestätigt den erfolgreichen Windows-Nachtest des Mausfixes. Die Sandbox ist damit abgenommen (**MANUAL WINDOWS TESTED — PASSED laut Nutzer**). Die nachfolgenden offenen Windows-Vermerke beschreiben den historischen Lieferzeitpunkt. M08 wurde anschließend ausdrücklich freigegeben; die [Architekturvorprüfung](M08_ARCHITECTURE_REVIEW.md) dokumentiert den nächsten Schritt.

## Nachtrag 05.10.2026 — Maus-/Fokusfix

**IMPLEMENTED / AUTOMATED TESTED. Neuer Windows-Fix: MANUAL WINDOWS TESTED — NOT TESTED.** Tim hat den Eingabefehler im vorherigen Windows-Build gefunden. M07 bleibt abgenommen; M08 bleibt gesperrt.

Quellcommit: `056d537adb3eda058a4927ee8f9c3cf0168c2da0` auf `foundation/developer-sandbox`, ausgehend von `e9cf5645d98924fefebbfe71e0624178380166f5`. Weitere Änderungen dieses Nachtrags betreffen ausschließlich Dokumentation und Prüfnachweise.

### Belegung und geprüfter Pfad

| Gemeinsame Produktions-/Sandbox-Eingabe | Bestehende Aktion |
| --- | --- |
| Linke Maustaste / 1 | `bolt` — Lichtfunke |
| Rechte Maustaste / 2 | `nova` — Frostkreis |

Die Meldung „RMB Lichterfunke“ stimmt hinsichtlich des Zaubernamens nicht mit der tatsächlichen Produktionsbelegung überein. Die Belegung wurde beibehalten. Das Angriffs-Dropdown bestimmt nur den Button „Auf Ziel zaubern“.

Geprüft wurde InputSetup → globaler Input-Zustand → MagePlayer._physics_process → request_cast → MageAbilities-Kosten/Cooldown → cast_requested → CombatSystem.cast → bestehende M07-AttackInstance/Kontaktprüfung → M06-Auflösung/Actor-Health. Lichtfunke verwendet das bestehende Projektil, Frostkreis die bestehende Fläche. Die Tests injizieren echte InputEventMouseButton-Ereignisse statt einen direkten Cast als Mausprüfung auszugeben.

### Reproduzierte Ursache und kleinste Korrektur

`sandbox.gd.arena_input()` setzte bisher bei jedem vorhandenen Control-Fokus `cast_armed=false`. Ein Linksklick fokussierte den SubViewportContainer selbst und wurde dadurch jedes Mal gesperrt. Ein Rechtsklick nach fokussierter Dropdown-Auswahl wurde ebenso verschluckt. Ein Rechtsklick ohne diesen Fokus war bereits funktionsfähig; die Diagnose behauptet keinen allgemeinen Engine-/Windows-RMB-Ausfall.

Die Arena erhält `FOCUS_NONE`. Der Handler merkt sich vor `release_focus()`, ob tatsächlich ein `LineEdit` bearbeitet wurde, und sperrt ausschließlich dessen Austrittsklick. So bleibt der vorhandene Schutz gegen versehentliches Zaubern beim Beenden einer Zahlenbearbeitung erhalten. Der folgende Mausklick funktioniert wieder.

Runtime-Änderung ausschließlich in **`developer/sandbox.gd`**, drei ausführbare geänderte/ergänzte Zeilen. Tests in **`tests/sandbox_suite.gd`** und **`tests/sandbox_visual_smoke.gd`**. Keine Änderung an InputSetup, MagePlayer, MageAbilities, CombatSystem, M06/M07, Produktionsdaten, Saveformat oder Assets; **139 geschützte Dateien** bleiben bytegleich zum Referenzmanifest.

### Tatsächliche Prüfnachweise

| Prüfung | Ergebnis |
| --- | --- |
| Vollständige Regression | **1.190/1.190**, **26/26 Stufen**, einschließlich 120 Sandbox-Checks, Save-/Legacy-Migrationen und realem Linux-Schreibfehler |
| Alte unveränderte Windows-EXE mit neuen Fokuschecks | **121/122**; erwarteter Fehler ausschließlich „Returning from selector focus preserves mouse cast“ |
| Alte Windows-EXE, erweiterte gerenderte Bedienprüfung | **23/34**; reproduziert beide betroffenen Mauspfade und deren ausbleibende Action-/Mana-/Trefferfolgen |
| Neue Release-Sandbox-Suite | **122/122** im Linux-Release und **122/122** im Windows-Pack mit Linux-Engine; isolierte Benutzerordner, Produktions-Saves unverändert |
| Neues Windows-Pack, gerendert unter Linux/X11/Mesa | **34/34**; LMB/RMB bis M07-Action und M06-/Ziel-HP, Kosten, Loslassen/Wiederholung, gehaltene RMB, Selector-Fokus, beidseitiger Zahlenfeld-Ausstieg, Pause, Controls und bisherige UI-Szenarien |
| Release-Exporte | **8/8 Produktions-Gates**, **5/5 Developer-Gates** |
| Nativer Windows-Nachtest des Fixes | **NOT TESTED**; [gezielte Prüfliste](SANDBOX_WINDOWS_TEST.md) liegt dem Paket bei |

Alle neuen Rohprotokolle und Ergebnisse: [qa/sandbox_input_fix](../qa/sandbox_input_fix). Die erneute Erzeugung am 05.10. stellt die nach einer temporären Arbeitsbereichsbereinigung verlorenen lokalen Nachweise wieder her. Die drei Code-/Testdateien und beide Release-Binärdateien haben dieselben SHA-256 wie im zuvor bestandenen Lauf; es wurde kein weiterer Runtime-Fix hinzugefügt.

### Neue vollständige Paketlieferung

**`Lichterhain_DeveloperSandbox_InputFix_Windows.zip`** wird als vollständiges ZIP ausgeliefert. Entpacken und `Lichterhain_DeveloperSandbox.exe` starten; kein Joiner nötig. Enthalten sind Startanleitung, Windows-Prüfliste, dieser Bericht, Lizenzen, Build-Information und Testzusammenfassung. Das ZIP wird vollständig extrahiert, CRC-geprüft und gegen die SHA-256 aller enthaltenen Dateien verglichen. Die ZIP-Prüfsumme steht im [Paketnachweis](../qa/sandbox_input_fix/package_results.json), die EXE-Prüfsumme zusätzlich in `BUILD_INFO.json`.

EXE: **97.073.168 Bytes**, SHA-256 `97bc93c099eeb864513242ec3021cccfda05af666b497870b68d64c911032de7`.

Verbleibende Grenze: Die gerenderten Tests verwenden Linux und synthetisch eingespeiste Mausereignisse. Windows-Treiber, physische Maus und native Fensterfokus-Ereignisse benötigen Tims Nachtest. Die erste Arena-Betätigung nach Zahlenbearbeitung wird weiterhin bewusst nur zum Fokuswechsel verwendet. **STOP nach diesem Fix; M08 wird nicht begonnen.**

---

## Historischer Abschluss und Paketlieferung vor dem Mausfix

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
