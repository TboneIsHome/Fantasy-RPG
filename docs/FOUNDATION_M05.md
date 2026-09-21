# LICHTERHAIN — M05 COMPLETION REPORT

Stand: 21.09.2026 · Quellstand 0.4.0 / Interaction Foundation M05 · Godot 4.5.1 · dauerhaft 2D-isometrisch.

**Späterer Nachtrag:** Tim hat anschließend M06 durch die Spezifikation V1.1 ausdrücklich zur Implementierung freigegeben. Dieser Auftrag hebt den damaligen Entwicklungsstop auf; eine eigene M05-Windows-Spielprüfung wurde damit nicht als bestanden gemeldet. Der folgende Bericht bleibt der historische M05-Auslieferungsstand. Aktuelle Iteration: [M06](FOUNDATION_M06.md).

**IMPLEMENTED**, automatisiert **TESTED**, insgesamt **PARTIALLY TESTED** bis zum eigenen manuellen M05-Windows-Spieltest. **789/789 Checks** und beide Release-Exporte samt Pack-Prüfungen bestanden. Windows-Testpaket bereit. **Stop nach M05**; Stats, Waffen, Magie und spätere Systeme wurden nicht begonnen.

## 1. Ausgangslage und verbindlicher Umfang

Tim hat Foundation M00–M04, ihre 707 Checks, die manuelle Windows-Abnahme und die gemeinsame Prüfung ausdrücklich bestätigt. Ausgangspunkt ist der unveränderte M04-Commit `d43a0dbcabd3a4a20df95b433101508084512bcb`. Vor Änderungen bestand dieser erneut 707/707 Checks; ein vollständiges Git-Archiv und Dateihashes sichern den Vergleich.

Verbindliche Grundlage waren das ausdrücklich genehmigte Interaction Design Proposal V1.0 (`Gameplay-SystemsDesignProposalV01.txt`) und der M05 Implementation Prompt. Der Hash der gelesenen Datei steht im [Referenzmanifest](../qa/m05_reference_manifest.json). Die Creative Bible bleibt unverändert. Der Auftrag betrifft einen kleinen Interaktionsvertrag und einige reale Verbraucher, kein allgemeines Gameplay-, Quest-, Loot- oder Dialogsystem.

## 2. Architektur und Zustandsbesitzer

Die Sitzung besitzt einen `InteractionCore`. Vorhandene Weltobjekte halten kleine `InteractionTarget`-Adapter. Ein Request erfasst Actor, Target und gewählten Intent sowie die Herkunft der Region. Der Core prüft Lebensdauer, aktualisiert das Angebot, lässt die konkreten Bedingungen prüfen und gibt erst nach der fachlichen Auflösung ein bestätigtes Ergebnis zurück. Anschließend ruft die Sitzung die Präsentation des Verbrauchers auf, sofern die Anfrage weiterhin zur aktuellen Region gehört.

| Besitzer | Verantwortung nach M05 |
| --- | --- |
| InteractionCore / Request / Context / Result | Synchroner Ablauf, aktuelle Referenzen, gewählter Intent, Ergebnis. Keine Gameplayregeln, Belohnungen, VFX oder Savezugriffe |
| DungeonInteraction / SourceInteraction | Konkrete Angebote und Nah-/Actor-/Zustandsbedingungen; Anfragen an bestehende Fachsysteme; anschließend bestehende Darstellung und Speicherpunkte |
| RunState / DungeonProgress / SourceQuest / Vitals | Unveränderte Fortschritts-, Kosten-, Ressourcen-, Wiederholungs- und Belohnungsregeln |
| SourceStory | Bestehende Dialogauswahl, Zeichenfolge, Herausforderung, Hüterabschluss und Darstellung der Quellenfolge |
| RegionLifecycle / RegionInstance | Unveränderter einzelner austauschbarer 2D-Regionsbaum und seine Generation |

Discovery und Validation verändern keinen Zustand und warten nicht. Execution vergleicht den **ausgewählten** Intent erneut; sie wählt keinen inzwischen anderen Intent. Ein Ergebnis kann bestätigt sein, ohne die Welt zu ändern: Das erlaubte Untersuchen eines noch unverständlichen Zeichens liefert den bisherigen Reaktionstext. `consequences` beschreibt bereits angewandte Folgen und enthält keine später abzuspielenden Befehle.

Der exakte Vertrag und seine Grenzen stehen ausschließlich ausführlich in [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md#interaktionsvertrag--m05). Es gibt keine Autoloads, globale Registry, universelle Condition-Engine, globale Verb-Taxonomie oder Broadcast-Kette.

## 3. Reale Verbraucher und Migration

| Vorhandenes Target | Intent / Verhalten | Erhaltene Regel |
| --- | --- | --- |
| Sternenkarte und Bernsteinsamen | `open`; Fund plus XP, danach Grafik/Klang/Journal/Save | Dauerhafter Besitz verhindert Wiederholung und zweite Belohnung; bestehende 40/25 XP |
| Sickerquelle | `rest`; Kosten und Ressourcen unmittelbar prüfen, dann bezahlen und auffüllen | Weiterhin 2 Lichtstaub; vollständig erholt oder ohne ausreichenden Betrag keine Zahlung |
| Stein mit Wasserspuren | `inspect`; unverständliche Reaktion oder geheimer Durchgang | Derselbe Wasserhinweis und bestehende Tor-/Navigationsänderung; keine neue Türmechanik |
| Quellenfassung, Quellengarten, Erzader | Je nach bestehendem SourceQuest `inspect`, `rest` oder `gather` | Hüter sperrt Nutzung; Garten kostenlos, Erz einmalig 4 Lichtstaub; Dialoge und beide Questwege erhalten |

Die Migration erfolgte in dieser Reihenfolge: Vertrag und Funde, vollständige alte Regression; Sickerquelle und Tests, Regression; Steindurchgang und Tests, Regression; Quellenadapter und finaler Gesamtlauf. NPC/Edda, Lager/Waldlichter, Erinnerungen, Wurzelwinde, Hauptgitter und Reisen bleiben bewusst bei ihren bisherigen Pfaden.

Der Core unterstützt mehrere Angebote pro Target. Die bestehende E-Bedienung zeigt weiterhin eine erste Aktion; eine neue Auswahloberfläche wurde nicht eingeführt. Auswahlradius 36 Pixel und bestehende Quellen-Ausführungsgrenze 42 Pixel bleiben erhalten. Die Ausführung prüft nun auch die tatsächliche aktuelle Entfernung und Sicht, wenn sich seit der Auswahl etwas geändert hat.

## 4. Konkrete Dateien

Alle folgenden Pfade sind relativ zum Repository; zu neuen GDScript-Dateien gehören ihre Godot-UID-Dateien.

| Dateien | Änderung |
| --- | --- |
| `scripts/interaction/interaction_core.gd`, `interaction_target.gd`, `interaction_request.gd`, `interaction_context.gd`, `interaction_result.gd` | Neuer kleiner synchroner Vertrag |
| `scripts/dungeon/dungeon_interaction.gd`, `source_interaction.gd` | Zwei Adapter für die ausgewählten vorhandenen Ziele |
| `scripts/dungeon/dungeon_object.gd` | Optionaler Adapterbezug; kein zusätzlicher Prozess oder Node |
| `scripts/game.gd` | Adapter nach Regionsaktivierung verbinden, Anfrage beim Scannen erfassen, bei Deaktivierung löschen; Core aufrufen und Ergebnis präsentieren |
| `scripts/progression/source_story.gd` | Quellen-Einstieg über Adapter; vorhandene Reichweite benennen und für Dialogbedingungen behalten |
| `tests/interaction_contract_suite.gd`, `interaction_scene_suite.gd` | 29 Vertrags-/Integrationschecks und 53 Szenenchecks |
| `tests/state_replay_reproduction.gd`, `data_consistency_suite.gd` | Echte Nähe und Adapter beim bestehenden Testaufbau; alle alten Assertions erhalten |
| `tests/export_smoke.gd`, `tools/verify.py` | Reale M05-Verbraucher im Release-Pack prüfen; neue Suites und Abschlussmarker im Gate |
| `TECHNICAL_DESIGN.md`, `TESTING.md`, `ROADMAP.md` | Tatsächlicher Contract, Tests/Abnahme und aktuelle Reihenfolge |
| README, TASKS, AGENTS, DECISIONS, CHANGELOG, dieser Bericht und M04-Berichtsnachtrag | Genehmigung, aktueller Stand, historische Abnahme und Stop-Punkt konsistent festhalten |
| `qa/m05_results.json`, `qa/m05_reference_manifest.json`, `qa/m05_logs/` | Prüfergebnisse, Hashes, finale und inkrementelle Nachweise einschließlich früher Fehlversuche |

Unverändert sind insbesondere JSON-Definitionen und Balance, Projekt-/Exportkonfiguration, Assets, SaveSystem/SaveFileIO, RunState und seine Teilmodelle, RegionLifecycle/RegionInstance sowie Combat. Die originalen Save-Fixtures bleiben bytegleich. Es gibt keine neue Saveversion und keine Requests, Contexts oder Ergebnisse im Save.

## 5. Regionen, verzögerte Aktionen und Wiederholung

Eine Anfrage trägt die **bei ihrer Entstehung** erfasste Generation und die Instanz-ID ihres RegionLifecycle. Beide sind transient und vom gespeicherten Regionsnamen getrennt. Schwache Referenzen halten alte Player/Targets nicht am Leben. Alte, entfernte, zur Freigabe vorgemerkte oder bereits freigegebene Ziele werden abgewiesen. Auch die Rückkehr in dieselbe Gruft mit denselben stabilen Objekt-IDs macht einen alten Request nicht gültig.

Die Sitzung verwirft ihre aktuelle Auswahl beim Regionsabbau. Ein außerhalb des alten Baums weiterlaufender Timer kann dennoch einen alten Request liefern; der Core weist ihn ab. Ein nach der Auflösung nicht mehr aktuelles Ergebnis wird nicht in der neuen Region präsentiert. Der M03-Lebenszyklus wurde dafür nicht umgebaut.

Während einer synchronen Auflösung lehnt der Core verschachtelte Requests mit `busy` ab. Nach dem Ergebnis entscheiden wieder die vorhandenen Fachregeln über Wiederholung. Ein Fund bleibt einmalig; kostenlose Gartenrast darf erneut erfolgen. Das ist kein generisches Reservierungs-, Cooldown- oder Mehrakteursystem.

Bestätigung bezeichnet den vollständigen Zustand im Arbeitsspeicher. Scheitert der anschließende Save, bleiben die Änderung und der bisherige gültige Dateistand erhalten. Eine Wiederholungsanfrage darf keine zweite Belohnung vergeben; F5 kann denselben Zustand erneut sichern. Die vorhandene Fehlermeldung bleibt sichtbar.

## 6. Tests und Regression

| Nachweis | Ergebnis |
| --- | --- |
| Baseline und drei Zwischenstände | Jeweils alle bisherigen **707/707** Checks bestanden |
| Interaction Contract | **29/29**: Angebote, lokale/mehrere Intents, geänderte Bedingungen, frischer Kontext, mehrere Folgen, Wiederholung/Reentranz, ungültige/stale Referenzen, echte Funde, Save/Load |
| Reale Interaction-Szenen | **53/53**: Kosten, volle Ressourcen, Reichweite/Sichtänderung, Tod, Quelle/Hüter/Erz/Garten, Tor/Navigation, Savefehler/Retry, eingefrorene Saves, verzögerte Anfrage und HUD-/E-Auswahl |
| Finaler vollständiger Lauf | **789/789**; unter Linux 21 bestandene Runner-Stufen einschließlich Import und zusätzlichem echtem OS-Schreibfehler |
| Release-Export und Pack-Smoke | Windows und Linux exportiert; beide Packs bestehen neue Interaction- und bisherige State-/Region-/Save-/Content-Prüfungen |
| Release-Startschutz | Vier vorhandene Content-Startfälle pro Pack bestanden; nicht nochmals zur 789-Summe addiert |
| M05 nativ unter Windows / menschlicher Spieltest | **NOT TESTED**; eigener Test des neuen Pakets erforderlich |

Der neue Timer-Test liefert eine alte Anfrage nach schnellem Hin-/Rückwechsel. Der echte Eingabepfad prüft, dass eine ursprünglich gewählte Untersuchung nach Quellenabschluss nicht automatisch Erz sammelt. Die instrumentierte Sickerquelle wird bei 120 direkten Prozessschritten zu je 0,01 s nur 9–11-mal entdeckt; der vorhandene 0,12-s-Takt bleibt wirksam. Das belegt diesen Ablauf, keine allgemeine Performance-Garantie.

Frühe Fehler wurden korrigiert und erneut geprüft: gegenseitige Script-Konstruktionsabhängigkeit mit Ressourcenleaks durch Verdrahtung in der Sitzung beseitigt; explizite Typen in neuen Tests ergänzt; Testaufbau an den bereits abgeernteten Originalstand angepasst, ohne ihn zu verändern. Fehlversuche bleiben nachvollziehbar archiviert. Die alte einmalige M04-Abweichung eines parallelen Testlaufs wird nicht als durch M05 behoben ausgegeben. Die M05-Prüfungen liefen seriell mit getrennten Benutzerprofilen.

Vollständige Nachweise: [Ergebnisse](../qa/m05_results.json), [Logs](../qa/m05_logs/), [Referenz-/Dateihashes](../qa/m05_reference_manifest.json). Befehle und Windows-Prüfliste: [TESTING.md](../TESTING.md). Neue grafische Aufnahmen wurden nicht erstellt; Layout und Grafikassets wurden nicht geändert.

## 7. Export und Windows-Paket

`Lichterhain_0.4_M05_Windows.zip` enthält die eigenständige x86_64-Anwendung, `START_HIER.txt` mit Prüfliste sowie bestehende Credits/Lizenzen. ZIP-CRC, PE-Architektur und Übereinstimmung der enthaltenen EXE mit dem geprüften Export sind kontrolliert.

- Paket: 34.040.548 Bytes; SHA-256 `e8ac2db3a45e592df5e166a3b79babd9ccf469e7c841031e5bd0429766ccff4a`.
- EXE: SHA-256 `687a1eca7985b6ae040c41eeabf92fb74a132d30498061cbd53d3573394c5dc9`.

Linux lief nativ. Das eingebettete Windows-Spielpaket lief mit der Linux-Engine, **nicht als Windows-Prozess**. Vor dem manuellen Test den bisherigen Ordner `%APPDATA%\Godot\app_userdata\Lichterhain\` vollständig separat sichern; M05 verwendet denselben Speicherort. Persönliche Windows-Spielstände wurden hier weder ausgeführt noch verändert.

## 8. Risiken und verbleibende Einschränkungen

- Der neue native Windows-Spieltest fehlt noch. Die bestätigte M04-Abnahme deckt diese neue EXE nicht ab; native Windows-Dateifehlerinjektion bleibt ebenfalls offen.
- Nur die ausgewählten Interaktionen verwenden den Vertrag. Andere vorhandene Pfade bleiben technische Schulden für spätere, ausdrücklich priorisierte Migrationen.
- Aktuelle Adapter benötigen den vorhandenen Player und seine Fachsysteme. Der Core kann andere Actors aufnehmen; NPC-Aktionen und Konkurrenz sind nicht implementiert.
- Discovery-/Validation-/Resolution-Callbacks sind synchron und vertrauenswürdiger Projektcode. Kein `await`, keine lange Animation, keine Netzwerktransaktion, keine allgemeine Rückabwicklung. Reaktive Regionswechsel mitten in einer fachlichen Mutation sind kein unterstützter Ablauf.
- Adapter und Angebote bleiben kleine GDScript-Verträge, kein datengetriebener Interaktionseditor. Neue Mechaniken benötigen einen passenden Verbraucher; neue Werte müssen weiterhin aus den geprüften Definitionen stammen.
- `InteractionResult.consequences` ist kopiert und außen schreibgeschützt; aktuelle Werte sind einfache Werte. Eine beliebig verschachtelte unveränderliche Ergebnisstruktur oder ein serialisierbares Ereignisprotokoll wird nicht behauptet.
- Offen laut genehmigtem Proposal bleiben Mehrfachauswahl-UX, Entdeckung verborgener Möglichkeiten, Dauer/Abbruch/Commitment und mehrere konkurrierende Actors. Diese Entscheidungen wurden nicht vorweggenommen.

## 9. Stop-Punkt

Die technische M05-Umsetzung ist abgeschlossen und überprüfbar auf `foundation/m05-interaction`. Als nächster Schritt steht ausschließlich der manuelle Windows-Test mit gemeinsamer Prüfung dieses Berichts an. **Keine automatische Weiterarbeit an M06 oder anderen Systemen.** Ein zukünftiger Milestone braucht sein eigenes genehmigtes Design, die Abhängigkeits-/Risikoanalyse und eine neue Freigabe.
