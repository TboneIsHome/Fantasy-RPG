# M08 — Architekturvorprüfung

Stand: 05.10.2026. Geprüfte Codebasis: `2c0fac89e3ed4c272091e4f7b45ec754aae257de`, Godot 4.5.1. Arbeitsbranch: `foundation/m08-weapons`.

**Status: PLANNED.** M08 ist von Tim zur Implementierung freigegeben. Der Windows-Nachtest des Sandbox-Mausfixes wurde von Tim ausdrücklich als erfolgreich bestätigt. Diese Vorprüfung ändert keinen Runtime-Code.

## Verbindliche Unterlagen und offener Eingang

Der M08 Implementation Prompt V1.0 liegt vollständig im Auftrag vor. Die verfügbare Datei `Eingefügter Text.txt` enthält denselben Implementation Prompt mit einer einleitenden Bewertung. Sie enthält nicht die separat referenzierte **„LICHTERHAIN — M08 Weapon Foundation — Gameplay / Systems Design Specification V1.0“**. Diese wurde weder in den verfügbaren Projektunterlagen noch über die Dateisuche gefunden.

Die folgende technische Vorprüfung stützt sich auf den aktuellen Code, TECHNICAL_DESIGN, Creative Bible, Future Systems Blueprint und den Implementation Prompt. Sie ersetzt nicht den noch erforderlichen Abgleich mit der genehmigten M08-Gameplay-Spezifikation. Vor diesem Abgleich werden keine Waffenprofile oder neuen Gameplay-Regeln implementiert. Eine neue Freigabe für M08 wird nicht benötigt; es fehlt das bezeichnete Referenzdokument.

## Tatsächliche vorhandene Anschlüsse

| Bestehender Code | Befund für M08 |
| --- | --- |
| `scripts/combat/action_timeline.gd` | Bereits frei parametrisierbare Startup-, Commit-, Active-Phasen- und Recovery-Zeiten. `cancel()` endet vor Commit, `interrupt()` bleibt der kontrollierte Unterbrechungspfad. Kein Rewrite nötig. |
| `scripts/combat/attack_instance.gd` | Lokale Action mit schwachen Referenzen, erfasster Region-Generation, Parent-/Payloadbezug und einer HitInstance je expliziter Phase. Wiederverwendbar für einzelne Waffen und Handzuordnung. |
| `scripts/combat/contact_context.gd` | Reichweite, Richtung, aktuelles Ziel, fester oder actorbezogener Ursprung und Sichtprüfung werden frisch geprüft. Aktuell radiale Reichweite plus Facing-Schwelle; noch keine explizite Sweep-/Korridor-Geometrie. |
| `scripts/combat/combat_contact.gd` | Einziger gemeinsamer Übergang von gültiger Action/Geometrie zu Actor-Defense und M06. Muss auch für Waffen maßgeblich bleiben. |
| `scripts/combat/active_defense.gd` | Eine deterministische Defense; Timing und Konfiguration werden bereits als Parameter übergeben. Player-Adapter lesen diese heute direkt aus der allgemeinen Definition. |
| `scripts/combat/combat_reaction.gd` | Verarbeitet bereits geminderten M06-Impact mit Interrupt-/Stagger-Grenzen und Recovery-Guard. Keine neue Waffen-Reaktionsformel erforderlich. |
| `scripts/combat/projectile.gd` | Trotz Klassenname MagicProjectile enthält der Carrier den vorhandenen regional abgesicherten Flug-/Kollisionspfad und ein `struck`-Signal. Seine Darstellung ist derzeit Lichtfunken-Grafik. |
| `scripts/combat/combat_system.gd` | `new_action()`, `released_action()` und `projectile_context()` sind vorhandene Anschlüsse. `_resolve_bolt_contact()` ist dagegen ausdrücklich Lichtfunken-/Talentlogik und darf nicht als Bogenauflösung verwendet werden. |
| `scripts/combat/attack_profile.gd`, `hit_instance.gd`, `hit_resolver.gd` | Vorhandener Damage-/Impact-Datenvertrag, Quittierung vor Seiteneffekten und reine numerische M06-Auflösung bleiben erhalten. |
| `scripts/actors/player.gd` | Actor besitzt aktuelle Actions, Defense, Reaction und Bewegung; Vitals besitzt Ressourcen. Eine Waffenintegration muss den vorhandenen Physics-Takt benutzen und doppelte Timeline-Ticks vermeiden. |
| `scripts/core/content.gd` | JSON wird einmal geladen, geprüft und rekursiv schreibgeschützt veröffentlicht. Kein Wechsel des Inhaltsformats erforderlich. |
| `developer/session.gd`, `fixture.gd`, `sandbox.gd`, `telemetry.gd` | Lokale Session und Reset mit Generation, echte Actors/Combat, getrennte Oberfläche und begrenzte Diagnose existieren. Transiente Waffenwahl kann hier angebunden werden. |

## PROPOSAL — kleinste technische Erweiterung

Die folgenden Namen beschreiben eine vorgeschlagene Implementierungsform; keine Klasse ist bereits implementiert.

1. **Weapon Definitions + Validator:** Geprüfte JSON-Definitionen mit stabilen Weapon-/Action-IDs, Family, Handedness, Pairing-Eignung, Delivery, Defense-Profil und optionalem Action-Portfolio. Actions besitzen konkrete Zeiten, Commit-Punkt, Geometrieparameter, Movement, genau ein M06-AttackProfile sowie ausdrücklich referenzierte Folgeaktionen. Keine unabhängig gepflegten Schadens-/Tempo-Kopien für UI oder Save.
2. **Actor-lokaler Weapon Actions Adapter:** Hält die aktuelle transiente Main-/Off-Hand-Konfiguration und die Auswahl einer Action; erzeugt eine bestehende M07-AttackInstance über den aktuellen CombatSystem-Scope. Er liefert Parameter und Anfragen, besitzt weder Health noch Defense-Ergebnisse oder numerische Trefferformeln. Action-Timeline und Hit-Receipts bleiben M07/M06.
3. **Gemeinsame Geometrieadapter:** Narrow/Wide/Forward/Sweep liefern Daten für die frische räumliche Prüfung im M07-Contact-Pfad. Keine Verzweigungen nach konkretem Waffennamen. Vor einer Erweiterung des ContactContext ist anhand der Gameplay-Spezifikation festzulegen, welche Formen reine Winkel-/Reichweitenparameter sind und welche zusätzliche Geometrie benötigen.
4. **Movement-/Defense-Anbindung am Actor:** Weapon Action und Weapon Defense liefern Profilparameter an vorhandene Bewegung/ActiveDefense. Der bestehende Pfad ohne Waffenprofil behält seine Defaults. Commitment muss auch bei Dodge-/Block-/Parry-/Zauberanfragen und Waffenwechsel erhalten bleiben; ein zweiter Input-Prozess darf diese Grenzen nicht umgehen.
5. **Bogen:** Draw/Aim/Release als Waffen-Action auf M07; Release erzeugt den vorhandenen Projektil-Carrier mit erfasster ursprünglicher Action und immutable Angriffsparametern. Der Kontakt geht über projectile_context/CombatContact an M06. Keine Bolt-Talente, Mana-Kosten oder Frost-/Echo-Effekte erben. Eine schlichte Pfeildarstellung wäre ein separater Präsentationsadapter, kein eigener Kollisionspfad.
6. **Dual-Wield:** Konfiguration aus zwei kompatiblen Definitionen, explizite Main-/Off-/Both-Action. Combined ist eine eigene Definition mit ausdrücklich ausgewiesenen Hit-Phasen; weder automatische Verdopplung noch Addition beider Waffenwerte. Alle Hände benutzen dieselben AttackInstance-/HitInstance-Regeln.
7. **Kleine Folgeaktionsreferenzen:** Erlaubte Nachfolger werden anhand der vorigen Action und ihrer tatsächlichen Phase geprüft. Keine neue Combo-Maschine. Ausführungs-/Abbruchzeitpunkte werden erst mit der Gameplay-Spezifikation festgelegt.
8. **Bestätigtes Ergebnis:** Action-/Weapon-/Hand-/Delivery-Identität und bestehendes CombatContact/M06-Ergebnis können lokal an Telemetrie und Presentation weitergegeben werden. Kein generischer Eventbus, keine ausgeführten Magic-/Status-/Umweltregeln, kein Force-Stat.

## State Ownership und mögliche Dateien

| Verantwortung | Geplante Änderung |
| --- | --- |
| Unveränderliche Definitionen | Neues geprüftes Waffen-JSON und kleiner Validator/Definitionsadapter; Integration in bestehenden Lade-/Validierungsablauf prüfen. Kein Autoload und keine globale Combat Registry. |
| Transiente Action-/Loadout-Auswahl | Gemeinsamer Actor-lokaler Adapter unter `scripts/combat/`; konkrete Dateien erst nach Spezifikationsabgleich festlegen. |
| Lifecycle/Contact/Defense/Reaction | Bestehende M07-Typen konsumieren; nur tatsächlich notwendige rückwärtskompatible Geometrie-/Parameteranschlüsse ergänzen. |
| Damage/Impact und Hit-Quittierung | M06 unverändert wiederverwenden. |
| Health, Bewegung und Anfragegrenzen | `scripts/actors/player.gd`; keine zusätzliche Vitals-/Health-Wahrheit. |
| Flug und bestätigter Projektilkontakt | `scripts/combat/projectile.gd` und `combat_system.gd` gezielt erweitern, falls vorhandene Anschlüsse nicht ausreichen; bestehende Zauberpfade bewahren. |
| Testauswahl und Diagnose | `developer/session.gd`, `fixture.gd`, `sandbox.gd`, `telemetry.gd`; Weapon-Vergleichsszenarien getrennt von den vorhandenen M07-Szenarien. |
| Dauerhafter Zustand | Kein M08-Loadout in RunState/SaveSystem; Schema 3 bleibt erhalten. |

## Konkrete Risiken und noch abzugleichende Regeln

- **Doppelter Takt:** Der Player tickt seine Actions bereits. Ein Waffenadapter darf dieselbe Timeline nicht noch einmal fortschreiben.
- **Commitment-Umgehung:** Der heutige Zauberpfad benutzt Cooldowns; er ist kein allgemeiner Waffen-Commitment-Owner. Action-Abbruch, Defense, Zauberanfrage und schneller Loadoutwechsel müssen dieselbe aktuelle Action berücksichtigen.
- **Defense-Profil:** ActiveDefense ist parametrisiert, MagePlayer liest heute jedoch globale Defaults. Waffenabhängige Parameter dürfen nicht durch eine zweite Defense-Auflösung im Sandbox-Observer umgesetzt werden.
- **Geometrie:** Sweep darf nicht nur ein anderer Name für denselben Kreis sein. Definition von Sweeps, Vorwärtszonen, eventueller Mindestreichweite und Richtungsbindung mit der verbindlichen Spezifikation abgleichen.
- **Bogen-Release:** Zeitpunkt und Abbruch von Draw/Aim sowie Verhalten bei vorher/nachher erfolgter Unterbrechung sind spielerische Regeln. Nicht eigenmächtig aus Lichtfunke ableiten.
- **Duale Quittierung:** Both-Action und alternierende Hände benötigen eindeutige Action-/Phasenidentität. Keine automatisch zweite HitInstance derselben Hit-Phase nur wegen einer zweiten Hand.
- **Waffenwechsel/Reset:** Neue Ausrüstung darf bereits freigegebene Projektile nicht nachträglich umdefinieren. Reset/Unload invalidieren den bisherigen Combat-Scope; alte Callbacks dürfen keine neue Fixture verwenden.
- **Eingabe:** Die inzwischen abgenommene LMB/1-Lichtfunke- und RMB/2-Frostkreis-Belegung darf nicht unbemerkt eine Sandbox-Sonderbedeutung erhalten. Eine explizite Waffensteuerung benötigt einen dokumentierten gemeinsamen Anschluss.
- **Szenario-IDs:** Die Sandbox besitzt bereits M07 A01–A12. M08 A01–A12 benötigen einen klaren Satz-/Namensraum; bestehende IDs und Tests werden nicht überschrieben.
- **Balance:** Neue Zahlen sind vorläufiges relationales Tuning. Qualitative Unterschiede müssen über Contact Shape, Bewegung, Timing, Commitment, Defense und Release-Verhalten nachgewiesen werden, nicht allein über DPS.

Diese Punkte sind Integrationsrisiken, keine bereits festgestellten unlösbaren Foundation-Konflikte. Die abschließende Konfliktprüfung ist ohne das bezeichnete M08-Gameplay-Dokument noch offen.

## Vorgesehene sichere Reihenfolge und Nachweise

1. Fehlende Gameplay-Spezifikation einlesen und diese Vorprüfung dagegen abschließen.
2. Datenvertrag/Validierung und Actor-Adapter; zunächst Dolch, Schwert, Kriegshammer, Speer, Bogen über die vorhandenen M07-/M06-Pfade.
3. Nachweise für Reichweite/Richtung und Bewegung, Commit/Cancel/Recovery, Defense, Impact-Reaction, Draw/Release sowie regionale Lebensdauer; dann vollständige bestehende Regression.
4. Zweihandschwert, beide Axtprofile, Mace und Dual-Wield über dieselben Verträge ergänzen; Hand-/Combined-/Follow-up-Tests, Duplicate-Contact-Prüfung und Mehrzieltests.
5. Developer-Auswahl, reproduzierbare M08 A01–A12 und Vergleichsmatrix für Reach, Commitment, Defense, Reaction, Multi-Target, Bow und Dual-Wield. Identity Audit mit messbaren qualitativen Unterschieden und anschließendem manuellen Vergleich.
6. Vollständige Regression, Legacy-Saves, Reset/Region/Unload, alte Projektile/Callbacks, echte Inputpfade, Produktions-/Sandbox-Exportgrenzen und Windows-Testpaket. Completion Report erst nach tatsächlicher Implementierung und Prüfung; STOP vor M09.

**Aktueller Prüfstatus:** Code-/Dokumentanalyse durchgeführt. M08-Implementierung **PLANNED**, M08-Tests/Exporte **NOT TESTED**. Die 1.190 Checks und 34 gerenderten Prüfungen im bisherigen Sandbox-Bericht sind belegte Ergebnisse des vorherigen Stands, kein neuer M08-Testlauf. Für diese reine Dokumentationsvorprüfung wurde keine erneute Gameplay-Regression behauptet.
