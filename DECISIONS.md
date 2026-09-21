# Entscheidungen

| Datum | Entscheidung | Grund |
|---|---|---|
| 2026-09-08 | Farbenreich und geheimnisvoll, mit dunklen Gefahrenorten | Von Tim ausgewählt |
| 2026-09-08 | Leicht schräge Top-down-Darstellung | Von Tim ausgewählt; klare Kampf- und Erkundungssicht |
| 2026-09-08 | Magier als erste Klasse | Von Tim ausgewählt; Fern- und Flächenmagie sind tragende Mechaniken |
| 2026-09-08 | Arbeitstitel Lichterhain | Vorläufige eigene Identität; Titel kann später geändert werden |
| 2026-09-08 | Godot 4.5.1 Standard fest pinnen | Offiziell verfügbare Version, lokal ausführbar und für diesen Stand geprüft; kein Anspruch auf neueste Version |
| 2026-09-08 | 640 × 360, 16-Pixel-Tiles, ganzzahlige Skalierung | Gut lesbare Pixel und Platz für eine einfache PC-Oberfläche |
| 2026-09-08 | Erste Lieferung als Grundprototyp 0.1 | Früh spielbarer Kern; Dungeon und alternative Questwege erhalten eine eigene Abnahme |
| 2026-09-08 | Keine Online-KI und keine fremden Grafikpakete | Offline-Spiel ohne laufende Kosten; zusammenpassende eigene Platzhalter |
| 2026-09-08 | Seed-Grundwelt plus dauerhafte Änderungs-IDs | Reproduzierbarkeit ohne Speicherung jedes Bodentiles |
| 2026-09-08 | Unbekannte Speicherversionen ablehnen | Verhindert stillen Datenverlust; echte Migration folgt mit erster Schemaänderung |
| 2026-09-08 | Bestehendes MyFire nicht als RPG-Ziel verwenden | Verbundenes Repository gehört zu einem anderen Projekt; kein RPG-Ziel benannt |
| 2026-09-08 | Lokaler Git-Stand und übertragbares Quellprojekt | Arbeit ist versioniert und überprüfbar, bis das Ziel-Repository feststeht |
| 2026-09-08 | Neues privates Repository TboneIsHome/Fantasy-RPG verwenden | Im Verlauf der Umsetzung erreichbar geworden und als leer bestätigt; getesteten Ausgangsstand hier versionieren |
| 2026-09-09 | Vollständigen Quellstand zusätzlich als prüfbares Download-Archiv bereitstellen | README auf GitHub angelegt; automatische Freigabeprüfung verlangt für den vollständigen Code-Upload eine ausdrückliche Zustimmung zu Inhalt und Ziel |
| 2026-09-09 | Vollständigen Quellcode nach ausdrücklicher Zustimmung hochladen | Tim hat den Upload in sein privates Fantasy-RPG-Repository freigegeben; Ausgangsstand 0.1 ist gesichert |
| 2026-09-10 | Grafikiteration 0.2 vor neuen Spielsystemen | Tim gefällt der erste Spieltest; er wünscht eine deutlich schönere Darstellung |
| 2026-09-10 | Generator und Speicherformat in 0.2 beibehalten | Bestehende Spielstände, Routen und Kampfbalance bleiben erhalten; nur der eigene Darstellungs-Zufallsstrom ändert sich |
| 2026-09-10 | Pixelgrafik weiter direkt im Projekt definieren | Originale, editierbare Formen und kleine Dateigröße; keine Abhängigkeit von externen Grafikpaketen |
| 2026-09-10 | DejaVu Serif für Überschriften | Ruhigere Fantasy-Typografie; lateinischer Zeichensatz reduziert, Lizenz liegt bei |
| 2026-09-10 | 0.3 vertieft die erste Region mit Quellengruft und Entdeckungsjournal | Nächster begrenzter Roadmap-Meilenstein; dauerhafte Funde vor zusätzlicher Kartenmasse |
| 2026-09-10 | Sechs Haupträume plus optionale Nische; fester Raumgraph mit begrenzter Seed-Variation | Wiedererkennbare Orte und überprüfbare Wege, ohne ungedeckte Versprechen endloser Inhalte |
| 2026-09-10 | Dornkobold mit fest angekündigter Dornenfläche; Raster-Wegfindung in der Gruft | Dritte Gegnerrolle fordert Positionierung und respektiert Wände |
| 2026-09-10 | Format 2 migriert Altstände explizit, Dateiname bleibt erhalten | Neue Ortszustände ohne Neustart; Originalstand vor dem ersten Schreiben separat aufbewahren, auch beim Laden aus Sicherung |
| 2026-09-10 | Quellenhüter, zwei Questlösungen und Ausrüstung als nächster Inhaltsmeilenstein | 0.3 zuerst als zusammenhängenden Erkundungsabschnitt abnehmen |
| 2026-09-10 | Beide Lösungen geben dasselbe Quellenherz und dieselbe Quest-Erfahrung | Die Ortsfolge entscheidet über den Weg; der Untersuchungsweg wird nicht durch eine schlechtere Hauptbelohnung bestraft |
| 2026-09-10 | Stimmfolge mit speicherbaren Zwischenschritten; falsches Zeichen setzt nur die Folge zurück | Hinweise erhalten eine konkrete Funktion, ohne unumkehrbare Sackgasse |
| 2026-09-10 | Hüterkampf beginnt ausdrücklich; Rückzug setzt ihn zurück | Verständliche Kampfentscheidung und erneute Versuche ohne Talentpflicht |
| 2026-09-10 | Eigenes SourceQuest-/RelicInventory-Modul, Speicherformat 3 | Dauerhafte Entscheidungen und Ausrüstung bleiben unabhängig vom neu aufgebauten Szenenbaum |
| 2026-09-10 | 0.4 als implementierten Slice kennzeichnen, menschliche Abnahme offenlassen | Automatisierte Vollständigkeit belegt noch keine Länge, Schwierigkeit oder Wirkung im längeren Spieltest |

## Foundation-Entscheidungen

M05-Auftrag und Umsetzung am 2026-09-21:

- Tim erklärt Foundation M00–M04 samt 707 Checks, manueller Windows-Abnahme und Reportprüfung für abgeschlossen. Die früher dokumentierten Plattformgrenzen bleiben historische Prüfnachweise, keine nachträglich ausgeführten Einzeltests.
- Das ausdrücklich genehmigte Interaction Design Proposal V1.0 und der M05-Auftrag erlauben ausschließlich die Interaction Foundation. Die Creative Bible bleibt unverändert. Nach M05 Stop; M06–M10 sind geplante Richtungen, keine automatische Implementierungsfreigabe.
- Ein sitzungsgebundener synchroner Vertrag koordiniert Angebot, Anfrage, frische Bedingungen und bestätigte Auflösung. Intents gehören den Verbrauchern. Zustandsänderungen bleiben bei RunState/Vitals; Darstellung und Save-Checkpoints folgen beim konkreten Verbraucher.
- Zunächst reale Funde, Sickerquelle, vorhandener geheimer Steindurchgang und Quellenfassung migrieren. Andere Interaktionen bleiben bestehen. Keine globale Condition-Engine, kein Eventbus, kein neues Loot-/Dialog-/Inventarsystem.
- Requests erfassen Generation und Lebenszyklus-ID bei ihrer Entstehung und halten schwache Referenzen. Die UI bewahrt den angebotenen Intent bis zur Ausführung; ein inzwischen geänderter Quellenzustand darf die beabsichtigte Untersuchung nicht still in Erzernte umdeuten.
- Die bestehenden E-Prompts zeigen weiterhin eine Aktion. Mehrfachauswahl, verborgene Möglichkeiten, Interaktionsdauer/Abbruch/Commitment und konkurrierende Actors bleiben offen. Der Vertrag unterstützt mehrere Angebote, entscheidet aber keine neue Bedienung.
- 789/789 Checks und beide Release-Packs sind geprüft. Die eigene manuelle M05-Windows-Abnahme bleibt offen. Saveformat 3, Definitionen, Balance, RegionLifecycle und Combat bleiben unverändert.

M04-Auftrag und Umsetzung am 2026-09-20:

- Tim bestätigt M03 samt manuellem Windows-Spieltest und beauftragt ausschließlich Datenkonsistenz und Content-Validierung. Danach Stop mit Foundation Completion Report; M04 braucht eine eigene manuelle Abnahme.
- JSON bleibt maßgeblich; gemeinsame einmalige Validierung und rekursiv schreibgeschützte Definitionen statt mehrerer Parser/Caches. Release-Fehler stoppen vor Weltaufbau und Dateischreiben.
- Bestehende Zahlen bleiben unverändert. Tatsächlich redundante Start-/HUD-/Bonuswerte nutzen dieselbe Definition. Stabile Generator-/Save-IDs bleiben explizite Verträge, kein generischer Content-Editor wird behauptet.
- Saveformat 3 speichert weiterhin absolute Ressourcen. Die Serialisierungsgrenze wird von aktuellen Spielermaxima getrennt; alter Überschuss bleibt mit Hinweis erhalten und wird durch Regeneration/Boni/Rast weder vermindert noch vermehrt.
- Creative Bible bleibt das WARUM. Keine neue Gameplay-Mechanik, Balanceentscheidung, 3D-Abstraktion oder vorgezogene Weltsimulation. Empfehlungen im Abschlussbericht sind PROPOSAL.

M03-Auftrag und Umsetzung am 2026-09-16:

- Tim bestätigt M02 ausdrücklich durch einen manuellen Windows-Spieltest und beauftragt ausschließlich M03; danach Stop vor M04. Die neue M03-EXE braucht ihre eigene manuelle Abnahme.
- Lichterhain bleibt dauerhaft ein 2D-isometrisches RPG. Keine 3D-Abstraktionen oder Streaming-Vorbereitung im aktuellen Umfang.
- Ein sitzungsgebundener RegionLifecycle besitzt genau eine RegionInstance. Bestehende Generatoren, Ansichten, Actors, Kampf- und Story-Fachlogik bleiben erhalten. Die bisherigen game-Zugriffe auf Player/Terrain/Combat sind nur lesende Sichten auf die aktuelle Instanz.
- Jede Instanz erhält eine neue, nicht gespeicherte Generation. Sie gilt nur beim zugehörigen Lebenszyklus; alte Deferred-/Timer-/Signalaktionen müssen ihre Herkunft mitbringen. Load und neue Runs setzen den Zähler nicht zurück.
- Die bisherige verzögerte Hüterbelohnung wird nach einer schnellen Gruft–Wald–Gruft-Rückkehr verworfen. Der damalige Regionsname allein konnte alte und neue Gruft nicht unterscheiden; der Fehler ist auf M02 reproduziert.
- Reiseprüfungen, Ressourcenübernahme, Camp-Rückkehr und Baumwechsel gehören zum Lebenszyklus. game.gd behält explizite Speicherpunkte und UI/Audio-Anbindung. Eine fehlgeschlagene Reisespeicherung behält die sichtbare Fehlermeldung.

M02-Fortsetzung am 2026-09-16:

- Tim beauftragt nach dem M01-Ergebnis die nächste besprochene Iteration. M02 wird umgesetzt; die offene native Windows-/manuelle Abnahme von M01 wird dadurch nicht als bestanden gewertet.
- RunState koordiniert bestehende Fortschrittsaktionen und komplette Belohnungen; DungeonProgress, SourceQuest und RelicInventory behalten ihre lokalen Regeln. Das vorhandene Signal meldet bestätigte Zustände, es löst keine globalen Befehlsfolgen oder Schreibvorgänge aus.
- Die physische Aktion bleibt bei Szene/Kampf/Actor; der dauerhafte Zustand entscheidet über Wiederholung und Belohnung. Insbesondere ist eine inaktive Truhengrafik keine Berechtigung für einen bereits gespeicherten Fund.
- Schema 3, Migrationen, Balance, Generatoren und vorhandene Save-Checkpoints bleiben erhalten. M03 und M04 werden nicht vorgezogen.

Nachtrag 2026-09-16:

- Tim erklärt M00 für abgeschlossen und beauftragt nach Integration der Creative Design Bible die Fortsetzung mit M01. Der frühere M00-Stop ist damit aufgehoben; M02–M04 bleiben geplant.
- Die vollständige [Creative Design Bible v1.0](docs/CREATIVE_DESIGN_BIBLE_V1.md) ist die kreative Autorität. Technische Einschränkungen dürfen ihre zentrale Spielerfahrung nicht still verändern. Offene Details bleiben offen; neue Details benötigen als **PROPOSAL** Tims Bestätigung.
- M01 behält Schema 3 und die bestehenden Migrationen. Ein kleiner Dateiadapter erlaubt reproduzierbare Fehler; Bytevergleich, geprüfte Backup-Kopien und kontrollierte Fehlerausgänge sichern den vorhandenen Schreibablauf ab. Kein Save-Reset oder globaler Eventbus.
- Eine bereinigte Arbeitsumgebung enthielt den noch nicht hochgeladenen M01-Stand nicht mehr. Wiederaufnahme aus dem gesicherten M00-Commit, unveränderten Eingaben und dokumentierten Änderungen; erneut ausgeführte Prüfungen sind von den verlorenen früheren Rohlogs getrennt. Fertige Audit-/Designanalyse wird nicht neu begonnen.

Historischer Nachtrag 2026-09-15 (M00):

- Tim priorisiert eine kleine, erweiterbare Weltsimulation und robuste Kernsysteme. Die nächste Inhalts-/Bedieniteration wird durch die verbindliche Reihenfolge M00–M04 ersetzt; Stop nach M00.
- Der ursprüngliche lokale 0.4-Quellstand ist wieder zugänglich und wurde unverändert nach `TboneIsHome/Fantasy-RPG` übertragen. Der Referenzzweig `reference/v0.4-original` hält dieses Release fest. Ein Rückgriff auf 0.3 ist deshalb nicht erforderlich.
- JSON, bestehende Zustandsmodelle, Generatorversionen und funktionierende Mechaniken bleiben erhalten. Der mögliche Save-I/O-Fehlerpfad wird in M01 zuerst reproduziert; M00 behebt ihn nicht vorsorglich.
- Neue Baseline-Prüfungen erfolgen in einer getrennten Kopie mit eigenem Benutzerverzeichnis. Originale Reports, Exporte und Legacy-Fixtures werden vorher gesichert. Persönliche Windows-Spielstände wurden nicht bereitgestellt.
- Tims positiver Testbericht zur neuen Version ist aufgenommen. Er ersetzt keine protokollierte native Windows-Abnahme oder mehrstündige Stabilitätsprüfung.

## Noch nicht endgültig entschieden

Die ausdrücklichen offenen Designbereiche werden zentral in Abschnitt 21 der [Design-Bible](docs/CREATIVE_DESIGN_BIBLE_V1.md) gepflegt. Neue verbindliche Details werden erst nach Tims Bestätigung ergänzt. Der aktuelle Magier und die milde Rückkehr zum Lager sind Prototyp-Regeln; sie legen weder starre Klassen noch die endgültige Progression fest.
