# DEVELOPER SANDBOX FOUNDATION — COMPLETION REPORT

**DRAFT — Abschlussprüfung und Paketnachweise werden gerade aktualisiert.**

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

## Bewusste Einschränkungen und Risiken

- **MANUAL WINDOWS TESTED: NOT TESTED.** Prüfliste: [SANDBOX_WINDOWS_TEST.md](SANDBOX_WINDOWS_TEST.md).
- Vollständige Kontaktablehnungsgründe gibt es bei gezielten Proben/Szenarien; freie Combat-Adapter melden nicht jeden Miss. Die Anzeige erfindet keine fehlenden Ergebnisse.
- Nahdistanz-Profil nutzt vorhandenen Magier und Defense. Keine Spielerwaffen/Loadouts vor M08, keine neue Magie-/Status-/Umweltlogik.
- Explizite Fixture-Zustandsänderungen werden protokolliert. Zeitproben sind keine vollständige Welt-/Physiksimulation; freie Bewegungen bleiben eingabe-/physikabhängig.
- Instanz-IDs ändern sich pro Lauf; Szenario-/Preset-IDs sind stabil. Keine persistente Weltidentität oder Welt-Deltas in der Sandbox.
- Keine Behauptung über finale Balance, lange menschliche Spielrunden, Controller, andere Auflösungen oder native Windows-Treiber.

**STOP vor M08.** Erst Sandbox-Bericht und Windows-Test gemeinsam abnehmen; anschließend nächste genehmigte Spezifikation planen.
