# LICHTERHAIN — FOUNDATION M00

Stand: 2026-09-15. Audit-Abgleich des unveränderten Releases **0.4.0** mit Foundation Audit V1 auf **0.3**. Umfang: tatsächlicher Quellstand, Abhängigkeiten, Referenzsicherung und bestehende Prüfungen. **M01–M04 bleiben PLANNED.**

## 1. Nachweisbare Ausgangsbasis

| Referenz | Identität |
| --- | --- |
| Audit V1 / GitHub 0.3 | `24b66a914827f11bb7da39c245e9da3a19d14731` |
| Entsprechender lokaler 0.3-Commit | `fdfac23e1c3287690aea73c08dfbb29598d0f0d9` |
| Gemeinsamer 0.3-Dateibaum | `1bcbb634c9f68086cb615a2b4a0b2aab55fea35d` |
| Ursprünglicher lokaler 0.4-Commit | `dcf9a2a79111b2249f7ea5e28f1088f4dfc28a1f` |
| Am 15.09. nach GitHub übertragener 0.4-Commit | `766f16e681fb715f6c56638ab38077ec3fca7c66` |
| Gemeinsamer 0.4-Dateibaum | `f3d164d24ca71a4f2f71883d1d93689516e9c2a7` |
| Engine | `4.5.1.stable.official.f62fdbde1`, Linux x86_64 |

Die lokalen und entfernten Commit-IDs unterscheiden sich wegen ihrer unterschiedlichen Git-Historie. Der identische Git-Dateibaum belegt identische Projektdateien. Der Upload umfasste die bereits vorbereiteten 64 Dateiänderungen; es wurde kein 0.4-Ersatz aus 0.3 rekonstruiert. GitHub meldet das von Tim ausgewählte Repository als öffentlich. `main` wurde ohne erzwungenes Überschreiben auf das unveränderte Release weitergeführt und zurückgelesen.

Verglichen wurden Laufzeitcode, Szene, Shader, JSON-Dateien, Projekt-/Exportkonfiguration, Tests, Fixtures, dokumentierte Prüfberichte und Projektanweisungen. Der Abgleich verwendet den vollständigen lokalen Stand und dessen tatsächlichen Diff zu 0.3. Die 0.4-Erweiterung umfasst 1.375 eingefügte und 145 entfernte Zeilen; das sind keine 1.375 neuen Architekturbausteine.

## 2. Reale Architektur in 0.4

Eine Einstiegsszene `scenes/game.tscn` erzeugt den übrigen Szenenbaum im Code. Es gibt **keine Autoloads** und keinen globalen Eventbus. Die Zustandsklassen sind `RefCounted`; Welt, Darsteller und laufende Effekte sind Nodes. JSON bleibt die vorhandene Inhaltsquelle. Die nachfolgend beschriebenen Module sind **IMPLEMENTED**; der jeweilige Prüfungsumfang steht in Abschnitt 7.

| Besitzer / Bereich | Tatsächliche Verantwortung und Abhängigkeiten |
| --- | --- |
| `scripts/game.gd` — 415 Zeilen, zuvor 391 | Sitzungsaufbau, vollständiger Regionswechsel, Spieler/Gegner/Objekte, Menüaktionen, Interaktion, erster Auftrag, Entdeckungen, Speichern und UI-Verdrahtung. Hält `RunState`, `WorldView`/`DungeonView`, `MagePlayer`, `CombatSystem`, `GameUI`, `AudioController`, `SourceStory`. |
| `core/run_state.gd` — 81 Zeilen | Seed, Region, normierte Tageszeit, XP/Stufe/Talente, Lichtstaub, Welt-IDs, erster Auftrag; besitzt `DungeonProgress`, neu `SourceQuest` und `RelicInventory`. Fachmethoden existieren teilweise, öffentliche Felder bleiben direkt veränderbar. |
| `progression/source_quest.gd` — 56 Zeilen, neu | Hinweise prüfen, Zeichenfolge, endgültige Lösung, Hütersieg, Bericht und Erzflag. `align()`/`resolve()` enthalten Regeln; mehrere Flags werden weiterhin von außen gesetzt. |
| `progression/relic_inventory.gd` — 31 Zeilen, neu | Besitz, einmaliges Gewähren, ein Reliktplatz, An-/Ablegen und Frost-Manaeffekt. Kein allgemeines Inventar- oder Equipmentframework. |
| `progression/source_story.gd` — 169 Zeilen, neu | Quellenort/Hüter aufbauen, Dialoge, Interaktionsprüfung, Questabschluss, Belohnung, Garten/Erz und Edda. Bleibt über `game` eng mit Szene, Zustand, Audio, Kampf und Speicherung verbunden. |
| Regionsbaum | Genau eine aktive Region. `game._build_region()` entfernt den alten Baum sofort aus dem Szenenbaum und gibt ihn verzögert frei; danach entstehen Gelände, ein neuer Spieler, Kampfobjekte und Gegner. `SourceStory` bleibt außerhalb dieses Baums bestehen und bindet seine Referenzen neu. |
| Player / Combat | `Vitals` und `MageAbilities` trennen Ressourcen bzw. Kosten/Cooldowns; `CombatSystem` erzeugt Treffer/Effekte und vergibt normale Gegnerbelohnungen. Konkrete `MagePlayer`-/`WildEnemy`-Typen und globale Szenengruppen bleiben zentrale Kopplungen. |
| Quellenhüter — 98 Zeilen, neu | Erweitert `WildEnemy`; ausdrücklich erwecken, feste Angriffsankündigung, Einschlag und Projektilfächer, Rückzug. `SourceImpact` verursacht höchstens einen Einschlag. Urheber-IDs ermöglichen selektives Aufräumen der Hütergeschosse. |
| Welt / Rendering | Unveränderte Generatorversionen 1; Wald 112×88, Gruft 96×64 Tiles. Seed-Wald und fest vorgegebener Dungeon-Raumgraph mit begrenzter Variation. Gebackener Boden, gecachte eigene Pixeltexturen, Compatibility-Renderer. Neue `SourceArt`, `SourceSite`, `SourceGrove` visualisieren Quellenzustände. |
| UI / Audio | `GameUI` sendet benannte Anfragen; `HudCanvas` liest Spielzustand und jetzt den Hüter. Journal hat einen Reliktreiter. Audio bleibt ein kleiner wiederverwendbarer Stimmenpool. Keine Online-Abhängigkeit. |
| SaveSystem — 190 Zeilen, zuvor 157 | Schema 3, Validierung, explizite Migration 1→2→3, temporäre Datei, rotierende `.bak`, permanente `.pre-v03`/`.pre-v04`. Hängt für ID-/Positionsprüfung von Content, Generatoren und Zustandsmodellen ab. |

Ein Gebietswechsel erhält `RunState` und die aktuellen LP/MP/AU. Lebende Gegner, laufende Angriffe und Cooldowns werden neu aufgebaut. Dauerhafte Ergebnisse bleiben im Zustand; eine fortlaufende Simulation entladener Regionen existiert noch nicht. Die Tageszeit tickt in `game._process()` nur bei leerer UI-Seite. Jahreszeiten, Wetterzustand und NPC-Routinen sind nicht implementiert.

## 3. Audit-Befunde gegen 0.4

| Audit-Befund / neuer Bereich | Zustand in 0.4 | Konkrete Aktion |
| --- | --- | --- |
| Vollständiger 0.4-Quellstand fehlte beim Audit | **Behoben:** Original wieder erreichbar und mit identischem Dateibaum nach GitHub übertragen | Referenz festhalten; kein Rückbau auf 0.3 nötig |
| Dungeon-Erinnerung wurde nach dem Lesen nicht sofort gespeichert | **Behoben:** `interact_dungeon()` ruft nach neuem Fund `save_game()` auf; `source_suite.gd` prüft unmittelbare Speicherung der Hinweise | Erhalten; keinen zweiten Fix einbauen |
| Vorhandene Altstände müssen erhalten bleiben | **Erweitert:** Format 3, Herkunftsfixture aus echtem 0.3, explizite Migration und permanente `.pre-v04`, auch bei Wiederherstellung einer alten `.bak` | Bestehende Migrationen unverändert als Regression übernehmen |
| Möglicher Verlust des letzten gültigen Save-Recovery-Kandidaten bei I/O-Fehlern | **Weiterhin vorhanden:** Schreib-/Flushfehler werden nicht ausgewertet; vorhandene `.bak` wird vor `main→bak` entfernt; bei defekter Hauptdatei kann diese die gültige `.bak` ersetzen; Ergebnis der Rückbenennung wird ignoriert | **M01:** Fehler deterministisch reproduzieren, dann kleinsten Fix; aktuell kein reproduzierter Datenverlust |
| Zu viele Aufgaben in `game.gd` | **Verändert, nicht gelöst:** Quellenablauf ausgelagert, aber Datei auf 415 Zeilen gewachsen; Regions- und ältere Questlogik bleiben dort | **M02/M03:** Zustandsaktionen und Regionslebenszyklus getrennt migrieren |
| Dauerhafter Weltzustand über Szenen verstreut | **Teilweise bereits gut:** RunState und Unterzustände speichern Daten unabhängig von Nodes | Besitzer behalten; Schreibzugriffe kontrollieren statt neuen WorldManager daneben setzen |
| Direkte Array-/Flag-/Währungsänderungen | **Weiterhin vorhanden:** `game.gd`, `CombatSystem._defeated()`, `SourceStory` verändern dauerhafte Felder direkt | **M02:** fachliche, idempotente Methoden bei den Zustandsbesitzern |
| Doppelte Belohnungen / wiederholte Aktionen | **Neue Schutzmaßnahmen vorhanden:** `resolve()`, `grant()`, Quest-/Erz-/Gegnerprüfungen verhindern untersuchte Wiederholungen | Schutz behalten; Zustandsänderung plus komplette Belohnung beim selben Besitzer bündeln; keine beobachtete Doppelbelohnung behaupten |
| SourceQuest / RelicInventory | **Neu und sinnvoll abgegrenzt:** persistente Teilmodelle mit kleinen APIs | Erhalten und schrittweise vervollständigen; keine generischen Questgraphen oder 10 Equipmentplätze vorziehen |
| SourceStory | **Neu:** trennt Quellenablauf vom Hauptscript, koppelt aber sieben Aufgabenbereiche über `game` | Szenenreaktionen dort lassen; Belohnungs-/Fortschrittsentscheidungen nach M02 verlagern |
| Alte Referenzen bei Szenenwechseln | **Teilweise abgesichert:** alter Baum wird abgehängt, Quellenreferenzen/HUD werden neu gesetzt; verzögerter Hütersieg prüft ursprünglichen RunState und Region | **M03:** zusätzlich Herkunft einer konkreten Regionsinstanz prüfen; gleicher RunState bei schneller Hin-/Rückreise ist nicht durch eine Instanzkennung abgesichert |
| Doppelte Gameplay-Werte | **Weiterhin vorhanden, teilweise erweitert:** HUD-Kosten/Cooldowns, Start-/Maximalwerte 100, Heilung/Manarückgabe, Quest-XP; neuer Abschlussdialog enthält zusätzlich feste 90 XP / 6 MP | **M04:** Datenquelle mit tatsächlichen Gameplay-/UI-/Save-Verbrauchern verbinden |
| Inhaltsvalidierung | **Weiterhin unzureichend:** `Content.all()` prüft nur per `assert` den obersten Typ; DiscoveryBook und Dungeon-JSON haben keine vollständige Schema-/Referenzprüfung | **M04:** explizite Startvalidierung mit Dateipfad, Feldpfad und verständlicher Release-Fehlermeldung |
| Allgemeine Combat-/Actor-Foundation | **Nicht vorgezogen:** bestehender Gegner wird wiederverwendet, Hüter/Slam ergänzen das jetzige System | Schnittstellen später aus realen Nutzern ableiten; keine M00-Kampfneuentwicklung |
| Regions- und Content-Skalierung | **Weiterhin begrenzt:** feste Regionsnamen, Objekt-IDs, Hüterkoordinaten, Globalgruppen, DungeonView erbt WorldView | M03 grenzt Lebensdauer ab; M04 prüft Referenzen; Streaming bleibt später |
| Performance / Leaks | **Kein neuer Leistungsfehler reproduziert.** Historische 0.4-Soakwerte sind vorhanden; fortlaufende Gegner-/UI-/Wasserschleifen und neue SourceGrove-Zeichenarbeit bleiben Profiling-Kandidaten | Aktuelle kleine Welt messen; keinen großen Scheduler ohne Bedarf bauen |
| Roadmap / menschlicher Teststatus | **Veraltet:** lokale Dokumente erwarteten Inhalts-/Bedieniteration und meldeten noch fehlendes Nutzerfeedback | M00 aktualisiert Priorität auf Foundation und hält Tims positiven Test als Nutzerbericht fest, ohne eine dokumentierte Windows-Abnahme zu erfinden |

Die Save-Sicherungen vor Migration verbessern die Aufbewahrung **alter** Formate. Sie ersetzen keine sichere Transaktion für bereits bestehende Format-3-Spielstände. Die bisherigen Recovery-Tests decken beschädigte Hauptdateien mit gültigen Altstand-Sicherungen ab, injizieren aber keine Schreib-/Renamefehler.

## 4. Zustandsverantwortung: konkrete Schreibstellen

| Dauerhafter Zustand | Heutige Schreibstelle | Empfohlener Besitzer in M02 |
| --- | --- | --- |
| Erster Auftrag / 45 XP | `game.handle_action("accept"/"reward")` | RunState-Fachaktionen für Annahme und einmaligen Abschluss |
| Gegner-ID / Lichtstaub / XP | `CombatSystem._defeated()` | Eine RunState-Aktion für bestätigte Niederlage und Belohnung |
| Besuchte Räume | `game._scan_landmarks()` | `DungeonProgress` mit Prüfung von ID und Wiederholung |
| Erinnerungen / Funde / XP | `game.interact_dungeon()` | DungeonProgress-Operation plus koordinierter RunState-Fortschritt; Objektaktivierung erst nach bestätigtem Ergebnis |
| Quelle bezahlen | `game.interact_dungeon("font")` | Geprüfte RunState-Ausgabe; Vitals-Erholung bleibt beim Actor |
| Tore / Gruftbericht | `game.interact_dungeon()` / `game.interact()` | DungeonProgress-Fachmethoden |
| Quellenhinweis / Zeichenreset / Hütersieg / Bericht / Erz | `SourceStory`, teils `SourceQuest.align()`/`resolve()` | SourceQuest-Methoden und koordinierende RunState-Transaktion für Relikt/XP/Lichtstaub |
| Reliktplatz | `RelicInventory.equip()`, ausgelöst aus `game.handle_action()` | Bestehenden Besitzer erhalten; bestätigte Änderung einheitlich melden/speichern |
| Weltzeit / aktive Region | `RunState.advance_time()` / `game.travel_to()` und Respawn | Zeit weiterhin RunState; Regionswechsel nur über den künftigen Lebenszyklus |

`RunState.changed` ist bereits ein benanntes Signal, aber kein vollständiges Änderungsprotokoll. Einige Aktionen emittieren über `add_xp()`, andere gar nicht. M02 braucht zuerst klare Bestätigung und genau einmalige Zustandsänderung; eine universelle globale Nachrichtenvermittlung ist nicht erforderlich. Wiederholbar gewollte Rast und einmalige Erzernte müssen unterschiedliche Regeln behalten.

## 5. Erste Änderungen mit dem größten Nutzen

| Reihenfolge / Priorität | Geplante Dateien und kleinster Schritt | Risiko / erforderlicher Nachweis |
| --- | --- | --- |
| 1 · **KRITISCH — M00** | Originalrelease, Tests, Save-Fixtures, Reports und Exporte eindeutig sichern; neue Prüfungen getrennt ausführen | Ein rekonstruierter oder überschrieben gemessener Stand wäre keine verlässliche Referenz |
| 2 · **HOCH — M01** | `persistence/save_system.gd`: `write()`, ggf. kleine injizierbare Dateioperationen; gezielte neue Save-Fehlertests | Zuerst Schreib-/Flush-, Haupt→Backup-, Temp→Haupt- und Wiederherstellungsfehler reproduzieren. Bei jeder fehlgeschlagenen Speicherung mindestens einen gültigen letzten Stand erhalten. Alle Legacy-Fixtures, beschädigte Daten und gültige Format-3-Backups mitprüfen. Kein Formatwechsel für reinen I/O-Fix |
| 3 · **HOCH — M02** | `run_state.gd`, `dungeon_progress.gd`, `source_quest.gd`, `relic_inventory.gd`; anschließend nur betroffene Aufrufe in `game.gd`, `source_story.gd`, `combat_system.gd` | ID-/Voraussetzungsprüfung vor Mutation, einmalige Belohnung als Einheit, Meldung erst danach. Doppelte Requests, fehlende Hinweise, bereits erhaltene Funde, Wiederladen und Savefehler an den Übergängen prüfen |
| 4 · **HOCH — M03** | `_build_region()`/`travel_to()` aus `game.gd` in einen kleinen, sitzungsgebundenen Regionsbesitzer überführen; `SourceStory.build_region()`/`finish_broken()` einbinden | Altes Gebiet deaktivieren/abkoppeln, Referenzen lösen, neu aufbauen, aktivieren. Genau ein Spieler; keine doppelten Gegner. Späte Aktionen mit Regionsgeneration verwerfen. Aktuelle `game.player`/`terrain`/`combat`-Zugriffe zunächst kompatibel halten |
| 5 · **MITTEL — M04** | `content.gd`, `discovery_book.gd`, `dungeon_generator.gd` und eng betroffene Verbraucher in Vitals, Abilities, Combat, HUD, SourceStory und SaveSystem | JSON behalten. Fehlende IDs/Felder, Typen, endliche Zahlen, Bereiche, Enums und Querverweise prüfen. Zuerst vorhandene Werte zentralisieren, ohne Balance zu ändern. Spätere Maximalwertänderungen dürfen alte Savewerte nicht stillschweigend ungültig machen |

M01-Fehlerreproduktion ist **PLANNED / NOT TESTED**. Aus statischen Risiken wird erst nach einem deterministisch fehlschlagenden Test ein bestätigter Fehlerfall. Ein Prozessabbruch oder Stromausfall ist außerdem ein anderer Fall als ein zurückgemeldeter Dateisystemfehler; ein erfolgreicher Rename-Test beweist keine vollständige Stromausfallsicherheit.

M03 erhält den heutigen Neuaufbau eines Spielers pro Region. Ein über alle Regionen langlebiger Player wäre eine zusätzliche Verhaltensänderung und ist für die erste Abgrenzung nicht notwendig. Auch die Regeln für lebende Gegner und zurückgesetzte Cooldowns bleiben erhalten.

M04 muss zum Beispiel `guardian.fan_count >= 2` absichern, da die Fächerberechnung durch `fan_count - 1` teilt. Positive Kosten, sinnvolle Cooldowns, gültige Gegnerarten, Raum-/Verbindungs-IDs, Belohnungsrelikte und Discovery-Einträge gehören zur Inhaltsprüfung. Unbekannte zukünftige Saveversionen bleiben ausdrücklich abgelehnt.

## 6. Was erhalten bleibt und was später kommt

**Erhalten:** Godot 4.5.1, JSON, Generatorversionen/Seeds/stabile IDs, eigener Pixelstil und Asset-Caches, funktionierende Bewegung und Telegraphing, Vitals/MageAbilities, beide Questlösungen, sämtliche Legacy-Fixtures, SourceQuest/RelicInventory, ein aktiver Regionsbaum, vorhandene benannte Signale.

**NIEDRIG:** Aufteilen kohärenter Grafikdateien nur wegen Zeilenanzahl, kosmetische Umbenennungen, allgemeine Hilfsabstraktionen ohne zweiten Verbraucher.

**SPÄTER / PLANNED:** umfassende Zeit-/Wetterwelt, universelles Inventar/Equipment, Waffen-, Status- und Questframeworks, komplexe Wahrnehmung/NPC-Routinen, Streaming, Fraktionen, Wirtschaft und Crafting. Weder neue Kartenmasse noch neue Story sind Abnahmekriterien von M00–M04.

Die langfristige prozedurale Welt braucht nachvollziehbare Zustandsbesitzer, stabile Identitäten und getrennte Simulation/Darstellung. Diese Richtung lässt sich auf **0.3 oder 0.4** aufbauen. Da der vollständige 0.4-Stand wieder verfügbar ist und zusätzliche Zustandsmodelle samt Tests enthält, gibt es hier keinen technischen Grund für einen Rückschritt. 0.3 bleibt ein archivierter Vergleichsstand. Ein 0.4-Spielstand im Format 3 lässt sich nicht einfach mit dem alten 0.3-Build laden; ein alternativer Entwicklungszweig müsste getrennte Savepfade benutzen.

## 7. Referenzsicherung und aktueller Prüfstatus

**Referenzsicherung — IMPLEMENTED / TESTED:** Der GitHub-Zweig [`reference/v0.4-original`](https://github.com/TboneIsHome/Fantasy-RPG/tree/reference/v0.4-original) hält den ursprünglichen 0.4-Commit fest. Zusätzlich wurden ein Quellarchiv und ein geprüftes vollständiges lokales Git-Bundle angelegt. Der Git-Stand enthält Projektdateien, Assets, Tests, die drei bisherigen Save-Fixtures, freigegebene QA-Berichte und beide Exportkonfigurationen. Alle 128 bereits vorhandenen Dateien außerhalb der Markdown-Dokumentation wurden bytegenau gegen das Original geprüft und sind unverändert.

Die vorhandenen Windows-/Linux-Exporte und 79 bisherige lokale Prüfartefakte wurden **vor** neuen Testläufen in `Lichterhain_0.4_Referenzartefakte_M00.zip` gesichert und dauerhaft bereitgestellt. Das Archiv enthält 83 Einträge, ist 62.971.157 Byte groß und besteht ZIP-CRC sowie SHA-256-Prüfung jedes Mitglieds. Archiv-SHA-256: `0a8519c96f3024e8833526445bc6855a8ac461f134afbe196dd6362ef16dfb66`. Diese historischen Berichte umfassen auch vorherige Iterationen; ihre Dateinamen bleiben erhalten.

Das ursprüngliche Windows-Spielpaket ist bytegleich zur damaligen Auslieferung: SHA-256 `c00c4e4a618e3908c6701bb0957580ee8392624a2edd52a7bd2b61a84bc2025b`. Seine eingebettete EXE stimmt mit dem ursprünglichen lokalen Windows-Export überein. Das Paket und frühere Berichte wurden nicht durch die neue Messung ersetzt.

| Gegenstand | Ergebnis am 15.09.2026 / Status |
| --- | --- |
| Vollständige bestehende Regression | **TESTED: 197/197**, alle sechs Gruppen und der vorgeschaltete Import erfolgreich, keine erfassten Scriptfehler |
| Legacy-Saves 0.1 / 0.2 / 0.3 | **TESTED** in den bestehenden Kompatibilitäts-/Migrations-/Quellenprüfungen; Originaldateien unverändert |
| Drei neue eingefrorene 0.4-Referenzen | **IMPLEMENTED / TESTED:** begonnene Zeichenfolge, reparierte Quelle mit angelegtem Relikt, gebrochene Quelle mit geerntetem Erz und abgelegtem Relikt; mit unverändertem 0.4-Code erzeugt, geschrieben und validiert zurückgelesen |
| Export erstellen | **TESTED:** Windows-x86_64- und Linux-x86_64-Release neu aus der isolierten Originalkopie mit Godot 4.5.1 exportiert |
| Export-Laufzeit | **TESTED:** Linux nativ und Windows-Ressourcenpaket unter Linux; bestehender Export-Smoke prüft Version, Gruft/Hüter, echten Untersuchungsabschluss, Relikt und Format 3 |
| Sichtprüfung | **PARTIALLY TESTED:** 16 aktuelle Godot-Ansichten gerendert; Titel, Lager, Quellenwahl, Hüter und Reliktansicht tatsächlich auf Layout/Lesbarkeit/Inhalt angesehen. Keine Änderung an Spielgrafik oder UI |
| Native Windows-Smoke-Runde | **NOT TESTED:** kein Windows-Laufzeitsystem in dieser Prüfung |
| Persönliche 0.4-Spielstände von Tim | **NOT TESTED:** nicht bereitgestellt; am aktuellen Linux-Standardpfad ist kein normaler Spielstand vorhanden. Die generierten Referenzen werden nicht als persönliche Originale ausgegeben |
| Neuer mehrstündiger / Performance-Soak | **NOT TESTED:** vorhandene historische 60-Sekunden-Messung gesichert; kein neuer Leistungstest und keine Aussage über eine große Welt |
| M01-I/O-Fehlerreproduktion und Fix | **PLANNED / NOT TESTED:** bewusst noch nicht begonnen |

Die ursprünglichen 132 Checks aus 0.3 plus 65 Quellenchecks ergeben die jetzt erneut ausgeführten **197**. Aufteilung: 50 Basis-, 14 UI-, 8 Original-0.1-, 48 Dungeon-, 12 Migrations- und 65 Quellenprüfungen. Details und tatsächliche Logs: [`qa/m00_results.json`](../qa/m00_results.json), [`qa/m00_reference_manifest.json`](../qa/m00_reference_manifest.json), [`qa/m00_logs/`](../qa/m00_logs/). Herkunft und feste Prüfsummen der sechs Save-Fixtures: [`tests/fixtures/README.md`](../tests/fixtures/README.md).

Alle aktuellen Engine-Läufe arbeiteten in einer aus dem Originalcommit extrahierten Kopie mit eigenem XDG-Daten-/Konfigurationsverzeichnis. Die erste Grafikumgebung scheiterte an nicht verfügbaren lokalen Sockets und einer fehlenden Tastatur-Hilfsdatei. Nach begrenzter Umgebungseinrichtung gelangen die Aufnahmen; die temporäre Verknüpfung wurde entfernt. Dafür wurde kein Spielcode geändert.

Tims Aussage, die neue Version getestet zu haben und keine Funktionsprobleme gesehen zu haben, ist als positiver Nutzerbericht aufgenommen. Die neue automatische Prüfung und die Bildkontrolle ersetzen keine strukturierte manuelle Windows-Abnahme. M00-Audit und Sicherung der verfügbaren Referenzen sind abgeschlossen; die Plattform-/Nutzersave-Abdeckung bleibt **PARTIALLY TESTED**.

## 8. Dokumentationsverantwortung und Stop-Punkt

| Dokument | Eindeutiger Zweck |
| --- | --- |
| `TECHNICAL_DESIGN.md` | Tatsächliche Laufzeitarchitektur, Generierung, Kampf und Saveformat; bleibt vorerst zentraler Besitzer dieser Beschreibung |
| `docs/FOUNDATION_M00.md` | Dieser Audit-Abgleich, Befundmatrix, konkrete M01–M04-Migrationsrisiken und Grenzen |
| `ROADMAP.md` | Verbindliche Meilensteinreihenfolge und Abnahme |
| `TESTING.md` | Wiederholbare Testbefehle, geprüfter Umfang, aktuelle Grenzen; historische Ergebnisse bleiben datiert |
| `tests/fixtures/README.md` | Herkunft unveränderlicher Save-Fixtures |
| `qa/` | Maschinenlesbare freigegebene Ergebnisse; historische Dateien nicht als neue Messung ausgeben |

`ARCHITECTURE.md`, `SYSTEMS.md`, `SAVE_FORMAT.md`, `WORLD_STATE.md` und `COMBAT_ARCHITECTURE.md` werden nicht als redundante Wunscharchitektur angelegt. Wenn ein späterer Milestone einen Bereich sinnvoll aus `TECHNICAL_DESIGN.md` herauslöst, wird dessen Beschreibung dorthin verschoben und verlinkt.

**STOP nach M00.** M01 beginnt erst nach Präsentation dieses tatsächlichen Zustands. Kein Save-Fix, Zustandsumbau, Regionsmanager oder Inhaltsformatwechsel ist Bestandteil dieses Berichts.

Technische Grundlagen: Godot dokumentiert, dass [`assert()` nur in Debug-Builds ausgeführt wird](https://docs.godotengine.org/en/4.5/classes/class_@gdscript.html#class-gdscript-method-assert). Für die spätere I/O-Absicherung sind die tatsächlichen Fehlerrückmeldungen von [`FileAccess`](https://docs.godotengine.org/en/4.5/classes/class_fileaccess.html) auszuwerten; Assertions allein sind keine Release-Fehlerbehandlung.
