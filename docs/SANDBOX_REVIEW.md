# Developer Sandbox — Review vor Umsetzung

Referenz: akzeptierter M07-Commit `3b8ce33d6a3c48545636cbd61fa368f81a23494c`, Godot 4.5.1. Work Order und Future Systems Blueprint V1.0 sind gelesen. Auftrag: ausschließlich Entwickler-Testinfrastruktur; STOP vor M08.

## Wiederverwendung und Grenzen

- Eigene Szene unter `developer/`, kein Einstieg über `game.gd`, kein Autoload. Die normale Session lädt keine Sandbox. Produktions-Exporte schließen den Ordner aus.
- Eine lokale Fixture spezialisiert RegionInstance für eine begrenzte Arena. Sie verwendet activate/deactivate, CombatSystem und dessen Generation-Grenzen. Der normale RegionLifecycle bleibt unverändert.
- Jeder Reset deaktiviert und entfernt den alten Baum, verwirft referenzierte Actions und erstellt Player, Gegner, Combat, Payloads und einen neuen transienten RunState. Ein monotoner Generation-Zähler gehört der Sandbox-Session.
- MagePlayer/WildEnemy bleiben Health-/Response-Owner. Beobachtende lokale Unterklassen reichen receive_hit/combat_defense unverändert an super weiter und kopieren Ergebnisse ins begrenzte Diagnoseprotokoll. Keine zweite Formel oder Defense-Logik.
- Live-Steuerung nutzt request_cast, try_dash, request_block, try_parry und bestehende Gegneraktionen. Diagnoseproben nutzen CombatContact/ContactContext/AttackInstance und danach genau dieselben Actor-/M06-Pfade.
- Die bestehenden Adapter publizieren nicht jeden verworfenen Live-Kontakt. Vollständige Ablehnungsgründe stehen deshalb nur bei der ausdrücklich bezeichneten Kontaktprobe zur Verfügung. Keine erfundenen Live-Ereignisse und keine M07-Änderung nur für Telemetrie.
- Nahdistanz-Profil bedeutet vor M08 Magier in Nahdistanz mit aktiver Defense; es gibt noch keine neue Spielerwaffe. Fern- und Magieprofile verwenden die vorhandenen zwei Zauber und Talente. Globale Content-Definitionen bleiben unverändert und schreibgeschützt.
- Lokale Enemy-Presets dürfen private Kopien der bestehenden Definitionen konfigurieren. Testwerte sind keine neue Produktionsbalance. Keine frei veränderbaren globalen Player-Stats, kein Loadout-Framework vor M08.
- SaveSystem wird weder geladen noch aufgerufen. Optionaler Diagnosebericht schreibt ausschließlich `user://developer_sandbox/last_report.json`. Developer-Exports besitzen einen separaten App-Benutzerordner.

## Arbeitspakete und Prüfung

1. Arena/Reset/Presets; Zustand und Eingaben lokal kapseln.
2. Bedienung, echte Angriffe/Defense, endliche datenbasierte Waves, Diagnose.
3. Reproduzierbare Szenarien A01–A12 samt Isolation, Validierungs- und Reset-Tests.
4. Vollständige bestehende Regression, unveränderte Produktionsverträge per Bytevergleich, Release- und Entwickler-Pack-Prüfungen, gerenderte UI.
5. Developer-Windows-Paket, tatsächliche Dokumentation und Completion Report. Native Windows-Sandbox-Abnahme bleibt beim Nutzer.

## Risiken und bewusste Grenzen

Ein Szenario ist eine kontrollierte Fixture, kein Ersatz für frei gespielte Combat-Integration. Zeitproben schreiten explizit Gameplay-Uhren voran und behaupten keine vollständige Physik-Einzelschrittsimulation. Verweildauer/Positionen freier Kämpfe hängen weiterhin von Eingaben und Physik ab. Godot-Instanz-IDs ändern sich zwischen Läufen; Preset-/Szenario-IDs bleiben stabil. Keine Environmental-Reactions, Welt-Deltas, globale Telemetrie oder M08–M10-Verträge vorziehen. Künftige Profile/Szenarien konsumieren erst dann genehmigte neue Systeme.
