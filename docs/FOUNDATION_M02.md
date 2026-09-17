# LICHTERHAIN — FOUNDATION M02

Stand: 16.09.2026 · Basis M01 `fd77854ccadec7ba885ff3b77f60565502fc19ce` · Godot 4.5.1.stable.official.f62fdbde1.

**IMPLEMENTED**, automatisiert **TESTED**, insgesamt **PARTIALLY TESTED**. M02 bündelt die vorhandenen dauerhaften Fortschrittsaktionen und ihre Belohnungen. 405 Checks und die Export-Packs sind bestanden; native Windows-/manuelle Abnahme bleibt offen. Tims Fortsetzungsauftrag autorisiert diesen nächsten Schritt, ist aber kein nachträglicher Spieltestnachweis. M03/M04 sind nicht begonnen.

## Abgleich und kleinster zusammenhängender Umfang

Der lokale Stand war sauber und entsprach GitHub-Main mit dem gesicherten M01-Abschluss. Der M00-Befund zu direkten Fortschrittsänderungen bestand weiterhin: `game.gd`, `CombatSystem` und `SourceStory` bearbeiteten Flags, Arrays und zugehörige XP/Lichtstaub teilweise selbst. SourceQuest und RelicInventory besaßen bereits lokale Schutzregeln; diese wurden erhalten.

| Bisherige Schreibstelle | Änderung in M02 |
| --- | --- |
| `game.handle_action()` | Questannahme/-abschluss und Reliktwechsel über RunState; vollständige erste Questbelohnung vor dem Signal |
| `game._scan_landmarks()` | Raumfund über `visit_room()` mit bekannter ID und Wiederholungsschutz |
| `game.interact_dungeon()` | Geprüfte Lichtstaubausgabe, Erinnerungen/Funde samt XP, Tor- und Berichtsaktionen beim Zustandsbesitzer |
| `CombatSystem._defeated()` | Bestätigte Gegner-ID, Art und einmalige XP-/Lichtstaubbelohnung als eine RunState-Aktion |
| `SourceStory` | Szenenablauf bleibt dort; Quellenzustände, vollständiger Abschluss mit Relikt/XP, Erz und Berichte werden von RunState mit SourceQuest/RelicInventory koordiniert |
| `SaveSystem.LIGHTS` | Kompatibler Alias auf `RunState.LIGHT_IDS`; keine Änderung am Schreibalgorithmus, Schema oder Migrationsablauf |

Die bestehende `RunState.changed`-Meldung genügt. Es gibt keinen zusätzlichen Manager, keinen globalen Eventbus und keine neuen Gameplay-Systeme. Physische Interaktionsprüfung, Kampf, Vitals, Darstellung und explizite Speicheraufrufe bleiben bei den vorhandenen Szenen/Actors. Die genaue API-Verantwortung, Rückgabesemantik und Checkpoint-Politik stehen zentral in [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md#fortschrittsaktionen-und-zustandsbesitzer--m02).

## Tatsächlich reproduzierter Fehler

Auf dem unveränderten M01-Laufzeitcode wurde ein eingefrorener gültiger 0.4-Stand mit bereits gefundener Sternenkarte geladen. Eine zweite inaktive `DungeonObject`-Ansicht derselben ID stellte erneut einen Truhenrequest. Der alte Code prüfte ihre Grafik-/Objektaktivität, fügte die gespeicherte ID nochmals hinzu und vergab XP. Der Folgezustand bestand die Save-Validierung nicht mehr.

Der identische Reproduktionstest bestand vor der Änderung **1/3**, danach **3/3**: [Baseline](../qa/m02_logs/state_replay_baseline.txt), [Fix-Nachweis](../qa/m02_logs/state_replay_reproduction.txt). Das ist ein reproduzierter Fehler bei einem gezielt wiederholten Request über eine zweite Ansicht, kein behaupteter Bericht über normale Spieler-Doppelbelohnungen. Original-Fixtures wurden dabei nur gelesen.

Die Schutzentscheidung liegt nun im gespeicherten `DungeonProgress`. Ein erneuter Request kann unabhängig vom Zustand seiner Darstellung keinen zweiten Fund oder XP erzeugen. Dieselbe Zuständigkeit gilt für die anderen einmaligen Fortschrittsaktionen.

## Bestätigter Zustand und Speicherung

Alle zusammengehörigen Fortschrittsfelder stehen vor `changed` fest. Ein Signalbeobachter kann sofort einen gültigen Save-Snapshot erhalten. Tests prüfen auch einen erneuten Request direkt aus dem Signalhandler: Eine bereits abgeschlossene Aktion gewährt keine zweite Belohnung. Der letzte Quellenzeichenschritt veröffentlicht keine Zwischenstufe `alignment=3` und keinen Ausgang ohne Relikt.

Ein erfolgreicher Request und ein erfolgreicher Datenträger-Checkpoint bleiben getrennte Ergebnisse. Bei blockierter `.tmp`-Datei bleibt die komplette Belohnung im aktuellen Lauf, der vorherige gespeicherte Stand bleibt unverändert, und die Fehlermeldung wird nicht durch den Erz-Erfolgstext überschrieben. Wiederholung der Quest/Erz-Aktion dupliziert nichts; F5 speichert beim erneuten Versuch denselben Zustand. Die echte Szenenprüfung testet beide Fälle einschließlich anschließendem Laden.

Das bisherige Checkpoint-Verhalten wird erhalten; es gibt keinen Datei-Write an jedem `changed`-Signal. Diese Änderung ist keine Zusage, dass jeder Kampf-, Scan- oder Talentschritt sofort auf Datenträger liegt.

## Nachweise und Status

| Bereich | Status | Ergebnis |
| --- | --- | --- |
| Fachaktionen und Aufrufermigration | **IMPLEMENTED** | Vorhandene Zustandsmodelle erweitert; direkte Fortschrittswrites aus den drei betroffenen Laufzeit-Aufrufern entfernt |
| Bestehende Regression einschließlich M01 | **TESTED** | 290/290; Save-/Load, Legacy-Migrationen, Wald/Gruft, echter Quellenkampf, beide Questwege, Relikt und UI |
| Wiederholter Truhenrequest | **TESTED** | 3/3 nach vorherigem reproduziertem Fehler |
| Zustandsaktionen ohne Szene | **TESTED** | 100/100; Voraussetzungen, IDs, Wiederholungen, vollständige Meldungen, Reentranz, beide Ausgänge, Ressourcen und Snapshot-Unabhängigkeit |
| Aktionen bei Savefehler in echter Szene | **TESTED** | 12/12; Quellenabschluss, Erz, Retry und Reload |
| Betriebssystem-Schreibfehler | **TESTED** | Bestehender M01-Test mit 64-Byte-Dateilimit erneut bestanden, zusätzlich zu den 405 Checks |
| Release-Exporte / Pack-Smokes | **TESTED** | Linux nativ, Windows-Spielpaket unter Linux; zusätzlich Wiederholungsprüfung der kompilierten M02-Aktionen |
| Visuelle Kontrolle | **TESTED** | Acht Ansichten gerendert, drei betrachtet: Garten, Kampfabschluss, Reliktplatz |
| Native Windows-Ausführung / persönliche Saves / menschliche Smoke-Runde | **NOT TESTED** | Offen; Fortsetzung und automatisierte Tests ersetzen diese Abnahme nicht |
| M02 insgesamt | **PARTIALLY TESTED** | Automatische Abnahme bestanden, manuelle Plattformprüfung offen |
| M03 / M04 | **PLANNED** | Keine Umsetzung in dieser Iteration |

Aktuelle Ergebnisse: [qa/m02_results.json](../qa/m02_results.json); Rohlogs: [qa/m02_logs/](../qa/m02_logs/); Prüfsummen: [qa/m02_reference_manifest.json](../qa/m02_reference_manifest.json); Befehle und offene Windows-Runde: [TESTING.md](../TESTING.md). Nach dem vollständigen Gate wurde lediglich der neue Testabschluss um 0,15 Sekunden Audio-Abbauzeit ergänzt und erneut mit `--verbose` geprüft; der Produktcode änderte sich dadurch nicht.

Kontrollierte Aufnahmen: [Quellengarten](../qa/m02_images/source_garden.png), [Kampfabschluss](../qa/m02_images/source_victory.png), [Reliktausrüstung](../qa/m02_images/source_equipment.png). Der Capture-Ablauf stellt den Kampfausgang direkt her; die tatsächliche Gewinnbedingung mit echten Zaubern bleibt separat durch die bestehende Quellen-Suite geprüft.

## Erhaltene Referenzen und Grenzen

Alle sechs eingefrorenen Spielstände, M00-/M01-Nachweise, Creative Design Bible, Inhaltsdaten, Generatoren, Projektszene und Exportkonfiguration bleiben unverändert. Speicherformat 3 und Dateiname bleiben bestehen; ein Neustart ist nicht erforderlich. Der getestete Code wurde bereits vor Dokumentationsabschluss unter `foundation/m02-state` gesichert (`85d974f0b5fbb3749e559de18bb2de5d8e29f6a9`). Das Windows-Testarchiv erhält einen eigenen M02-Dateinamen.

Die öffentlichen GDScript-Felder sind weiterhin lesbar und technisch beschreibbar; diese Iteration migriert die tatsächlichen Laufzeit-Aufrufer, keine komplette Objektimmutabilität. Wiederherstellung und Testaufbau dürfen Felder gezielt konstruieren. Seed/Region bleiben zunächst bei der bestehenden Sitzungs-/Reiselogik; Vitals bei den Actors. Das ist keine vorgezogene M03-Umsetzung.

Bekannte ID-Konventionen und teilweise harte Gameplay-Werte bleiben Gegenstand von M04. Kein Anspruch auf beliebige neue Inhalte ohne künftige Inhaltsvalidierung. Die Creative Design Bible bleibt unverändert maßgeblich; diese Zustandsverantwortung unterstützt nachvollziehbare Konsequenzen und kombinierbare Systeme, ohne offene kreative Details festzulegen.

## Nachträgliche Nutzerabnahme

Tim hat vor dem M03-Auftrag ausdrücklich bestätigt: M02 ist abgeschlossen und zusätzlich durch einen erfolgreichen manuellen Windows-Spieltest bestätigt. Damit ist die damals offene allgemeine Spielabnahme nachgeholt (**TESTED — Nutzerbericht**). Windows-Unterversion, einzelne Testschritte und Buildhash wurden dabei nicht angegeben; daraus wird keine nachträgliche Durchführung der speziellen Windows-Dateifehlerinjektionen abgeleitet. Die obigen automatisierten Belege und damaligen Grenzen bleiben historisch unverändert.
