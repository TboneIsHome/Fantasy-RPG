# Änderungen

## Gameplay Foundation M07 — 2026-09-28

- Gemeinsamer lokaler Action-/Kontaktvertrag für sämtliche vorhandenen Angriffspfade; M06-Rechnung unverändert. Explizite Hit-Phasen, regionale Generation und schwache Actor-/Payloadbezüge.
- F: aktiver Block, Q: Parade; vorhandener Dodge angebunden. Deterministische Outcomes, kontrollierte Reaktion und Schutz gegen verlängerte Stagger-Ketten. Keine neue Defense-KI oder Waffen-/Magiesysteme.
- 1.070/1.070 Checks, 25 Regressionstufen und sechs Release-Gates bestanden. Alte Saves, geschützte Verträge und ursprüngliche Gameplaywerte erhalten.
- Lokale Arbeitsstände wurden automatisch bereinigt; aus dem GitHub-Zwischenstand wiederhergestellt und am 28.09. vollständig neu geprüft. Nur die neuen Protokolle gelten als Abschlussnachweis.
- [M07 Completion Report](docs/FOUNDATION_M07.md), Windows-Testpaket und Prüfliste. Manueller M07-Windows-Test offen; Stop vor M08. M06-Windows-Test wurde zuvor vom Nutzer bestätigt.

## Gameplay Foundation M06 — 2026-09-21

- Genehmigte Stats-/Trefferauflösungs-Spezifikation V1.1 umgesetzt: gemeinsame reine Rechnung mit getrennter Damage-/Impact-Wirkung, Protection, Resistance, Stability und bereits vorgegebenem DefenseOutcome.
- Player und Gegner verwenden denselben Resolver. Einmalige regionale HitInstance verhindert doppelte Kontaktlieferung, auch aus reentranten Signalen oder alten Regionen. Bestehende wiederholte Dornenpulse bleiben explizite neue Treffer.
- Lichtfunke, Frostkreis, Widerhall, Wolfslunge, Gegner-/Hütergeschosse, Quellenschlag und Dornen migriert. Vorhandene Treffererkennung, Timing, Health-Besitzer, Rückstoß-/Slow-/Bonusregeln bleiben bei ihren bisherigen Systemen.
- Neutrale Defense-Felder und Schadensartenschlüssel in JSON ergänzt und beim Start geprüft. Alle vorher vorhandenen Inhaltswerte, Saveformat 3, Referenzspielstände und RegionLifecycle bleiben erhalten.
- 931/931 Checks, davon 142 neue; beide Release-Exporte/Packs und Fehlerstart-Proben bestanden. [M06 Completion Report](docs/FOUNDATION_M06.md) und Windows-Testpaket erstellt. Manueller M06-Windows-Spieltest offen: **PARTIALLY TESTED**. Stop vor M07.

## Gameplay Foundation M05 — 2026-09-21

- Von Tim abgenommene Foundation M00–M04 als Basis erhalten; genehmigten Interaction-Vertrag umgesetzt.
- Discovery, erfassten Intent, frische Ausführungsprüfung und bestätigte Folgen getrennt. Generation/Lifecycle-ID und schwache Referenzen verwerfen alte Requests; verschachtelte Auflösungen werden abgewiesen.
- Sternenkarte/Bernsteinsamen, Sickerquelle, geheimer Steindurchgang und Quellenfassung/Garten/Erzader verwenden den Vertrag. Bestehende Zustandsbesitzer, Rückmeldungen und Save-Checkpoints bleiben erhalten.
- 789/789 Checks, davon 82 neue; beide Release-Exporte und Pack-Prüfungen bestanden. Definitionen, Balance, Saveformat 3, eingefrorene Saves, Regions- und Kampfsystem unverändert.
- [M05 Completion Report](docs/FOUNDATION_M05.md), Windows-Testpaket und Prüfliste erstellt. Manueller M05-Windows-Test offen: **PARTIALLY TESTED**. Stop vor M06.

## Foundation M04 — 2026-09-20

- Bestehende Spieler-, Zauber-, Talent-, Gegner- und Belohnungswerte mit Gameplay/HUD/Journal zusammengeführt; keine Balanceänderung.
- Einmalige gemeinsame Validierung der drei JSON-Dateien, schreibgeschützter Cache, Schema-/Referenz-/Geometriefehler mit Dateipfad und sichtbarem Startabbruch.
- Speicherformat 3 erhalten; gespeicherte Ressourcen bleiben auch über geänderten Maximalwerten exakt erhalten, inklusive Hinweis und sicherer Backup-Wiederherstellung.
- 707/707 Checks; beide Release-Packs geprüft. Manuelle M04-Windows-Abnahme offen. M03 laut Tim erfolgreich unter Windows getestet.
- Foundation Completion Report erstellt; Stop vor einer weiteren Entwicklungsphase.


## Foundation M03 — 2026-09-16

- M02 durch Tims manuellen Windows-Spieltest ausdrücklich abgenommen; ausschließlich M03 begonnen.
- Aktive 2D-Region in sitzungsgebundenen RegionLifecycle und RegionInstance abgegrenzt; bestehende Generatoren, Player-Neuaufbau und Combat-Mechanik erhalten.
- Monotone, nicht gespeicherte Generation verwirft alte Deferred-/Timer-/Signalaktionen; Gruft–Wald–Gruft-Hüterfehler vor dem Fix reproduziert.
- Alte Region vor Neubau deaktiviert und getrennt; HUD, SourceStory, Interaktionen und Session-Signale kontrolliert gelöst/neu verbunden. Keine doppelten Players oder Gegner im geprüften Umfang.
- Savefehler beim Reisen bleibt sichtbar; unverändertes Schema 3 und originale Referenzspielstände.
- 504/504 Checks plus echter OS-Schreibfehler, Vergleichsmessung und beide Release-Packs bestanden. M03-Windows-Spieltest offen: **PARTIALLY TESTED**. Keine neuen Grafikaufnahmen wegen nicht startendem lokalem X11-Server.
- [M03 Completion Report](docs/FOUNDATION_M03.md); Stop vor M04.

## Foundation M02 auf 0.4.0 — 2026-09-16

- Fortschrittsaktionen bei RunState und den vorhandenen Zustandsmodellen gebündelt: Aufträge, Lichter, Gegnerbelohnungen, Räume, Erinnerungen/Funde, Tore, Berichte, Quellenabschluss, Erz, Lichtstaub und Reliktwechsel.
- Reproduzierten Doppelaufruf über eine zweite Truhenansicht abgesichert; gespeicherter Besitz verhindert doppelte Funde/XP und einen dadurch ungültigen Save.
- Benachrichtigung erst nach vollständiger Zustandsänderung und Belohnung; unbekannte IDs, fehlende Voraussetzungen und Wiederholungen gezielt geprüft.
- Erfolgreicher Zustand im Arbeitsspeicher und erfolgreiche Speicherung getrennt behandelt; Speicherfehler bei betroffenen Weltmeldungen nicht mehr durch einen Erfolgstext ersetzt.
- 290 bestehende und 115 neue Checks bestanden, dazu echter OS-Schreibfehler und beide Release-Packs. Acht Spielansichten gerendert, drei tatsächlich visuell kontrolliert. Native Windows-/manuelle Abnahme offen: **PARTIALLY TESTED**.
- Keine neuen Gameplay-Systeme, kein Saveformatwechsel. M03/M04 bleiben geplant.

## Foundation M01 auf 0.4.0 — 2026-09-16

- Creative Design Bible v1.0 vollständig aus Tims unverändertem Dokument übernommen; kreative Autorität, Konfliktregeln und offene Details dokumentiert.
- Nach realer Fehlerreproduktion den bestehenden Save-Schreibablauf gezielt abgesichert: vollständiger Bytevergleich, geprüfte temporäre Backup-Kopien, Schutz gültiger Sicherungen nach Recovery und sichere Fehlerrückgaben bei fehlgeschlagenem Rename.
- Vorversionssicherungen geprüft erstellen; vorhandene Originale unverändert lassen. Kein Schema-, Balance- oder Generatorwechsel.
- Speicherfehler und erfolgreicher Wiederholungsversuch auch im Pausefenster lesbar anzeigen.
- 197 bestehende und 93 neue automatisierte Checks bestanden; zusätzlicher echter OS-Schreibfehler geprüft. Linux-Export nativ und Windows-Spielpaket unter Linux geprüft. Native Windows-/manuelle Abnahme offen: insgesamt **PARTIALLY TESTED**.
- Quellstand nach Bereinigung der Arbeitsumgebung wiederhergestellt und erneut verifiziert. M00-Nachweise und eingefrorene Altstände bleiben erhalten; M02–M04 nicht begonnen.

## 0.4.0 — 2026-09-13 · Das Gedächtnis der Quelle

- Gebundener Quellenhüter mit angekündigtem Quellenschlag, fünfteiligen Projektilfächern, Rückzug und eigenen Pixelgrafiken.
- Vollständiger Untersuchungsweg mit drei Zeichen und gespeicherten Zwischenschritten; vollständiger Kampfweg bis zu Eddas Reaktion.
- Dauerhafte unterschiedliche Folgen: geschützter Quellengarten mit kostenloser Rast oder einmalig nutzbare Erzader.
- Quellenherz als an-/ablegbares Relikt: sechs Mana für einen Frostkreis mit Treffer, einmal pro Zauber. Beide Wege geben dieselbe Hauptbelohnung.
- Eigene Quest-/Reliktmodule, Bossanzeige, Ausrüstungsreiter und drei weitere Journaltexte.
- Format 3 mit expliziter Migration von 0.1–0.3 und unveränderter Vorversions-Sicherung, auch bei Backup-Wiederherstellung.
- Fehlenden automatischen Speicheraufruf beim ersten Lesen einer Dungeon-Erinnerung behoben.
- 197 automatisierte Prüfungen, echter 0.3-Altstand, gerenderte Spielansichten und ein 60-Sekunden-Kampf mit aktivem Hüter.

Der erste vollständige Abschnitt ist inhaltlich implementiert. Menschliche Abnahme, mehrstündige Inhalte und allgemeine Welt-/NPC-Simulation bleiben offen.

## 0.3.0 — 2026-09-10 · Unter den Wurzeln

Erster Dungeon als nächster Schritt zum vollständigen Vertical Slice.

- Quellengruft mit sechs Haupträumen, optionaler Nische, Schleife, Abkürzung und sieben Begegnungen; Zugang nach Eddas Auftrag.
- Datenbasierte Raumdefinitionen, begrenzte Seed-Variation, neue originale Pixelobjekte, Wasserbecken, Archiv- und Gartenmotive.
- Dornkobold mit angekündigter fester Dornenfläche, Verlangsamung und klarer Erholung; Raster-Wegfindung aller Dungeon-Gegner.
- Entdeckungsjournal mit neun individuellen Texten, zwei Erinnerungen und zwei dauerhaften Funden; Edda reagiert auf die Sternenkarte.
- Lichtstaub bezahlt Erholung an der Sickerquelle. Entdeckte Dungeonräume werden auf der Karte ergänzt.
- Gemeinsame Weltzeit über Gebietswechsel hinweg; Rückkehr zum Waldlager bei Dungeon-Tod.
- Speicherformat 2 mit validiertem Dungeonzustand, expliziter Migration von 0.1/0.2 und einmaliger unveränderter `.pre-v03`-Sicherung.
- 132 automatisierte Prüfungen, darunter 100 Dungeon-Seeds und echte Altstände; gerenderter 60-Sekunden-Kampf mit wiederholtem Regionsabbau.
- Lokaler Prüfaufruf erkennt Scriptfehler auch dann, wenn Godot mit Exitcode 0 beendet wird.

Waldgeneratorversion 1 bleibt unverändert. Quellenhüter, verzweigte Questlösungen, Ausrüstung und mehrstündige Weltinhalte folgen später.

## 0.2.0 — 2026-09-10 · Der Wald erwacht

Grafikiteration nach Tims positivem ersten Spieltest und seinem Wunsch nach einer deutlich schöneren Welt.

- 32 Baumvarianten mit kantigen Blattgruppen, Tannen, Birken, kleinen Bäumen und Baumstümpfen.
- Kontinuierliche Moosfarben statt sichtbarer Tile-Farbflächen; unregelmäßige Pfadränder und feine Vegetation.
- Lagerdetails: zwei unterschiedliche Zelte, Teppiche, Vorräte und drei Laternen.
- Neue Pixeldefinitionen für Magier, Edda, Dämmerwolf, Irrlicht, Steine, Feuer und Waldlichter.
- Vier Gehphasen für Magier/Wolf, Magier-Rückenansicht, flackerndes Feuer und dezente Magierkontur.
- Örtliche Lichtquellen, bewegte Wasserreflexe, Lichtstrahlen, Partikel und herabfallende Blätter.
- Frostkreis mit zwei Ringen und Kristallspitzen; Lichtgeschosse mit Schweif, Funken und hellem Kern.
- Oberfläche mit Porträt, eigenen Zauberzeichen, Abklinganzeige und neuem Hauptmenü; DejaVu-Überschriften mit Lizenz.
- Zusätzliche Abend- und Flussaufnahmen sowie acht Prüfungen gegen einen originalen 0.1-Spielstand.
- Vollständiger Quellcode nach ausdrücklicher Zustimmung in TboneIsHome/Fantasy-RPG gesichert.

Generatorversion 1, Speicherformat 1 und Spielbalance bleiben erhalten. Dies ist weiterhin der Grundprototyp mit zwei Gegnertypen und der ersten Erkundungsrunde.

## 0.1.0 — 2026-09-08

Erster ausführbarer Magier-Prototyp mit einer kleinen, abgeschlossenen Erkundungsrunde.

- Seed-basierter Wald, Flussübergänge, Lager und drei Waldlichter.
- Bewegung, Mausziel, Lichtfunke, Frostkreis, Splittersynergie und Ausweichschritt.
- Dämmerwolf mit angekündigtem Sprung; Irrlicht mit Fernprojektil.
- Eigenständige prozedural gezeichnete Pixeltexturen, Verdeckungsreduktion bei Baumkronen, Partikel und Tageslichtfarbe.
- Edda, kurze Dialoge, Erkundungsauftrag und Quellenfokus als Belohnung.
- Erfahrung, drei freischaltbare Talente, Beutel und Übersichtskarte.
- Hauptmenü, Pause, Lautstärke, optionale Erschütterung und Vollbild.
- Gespeicherter Welt-/Spielerfortschritt mit Datentyp-, ID- und Versionsprüfung sowie Sicherung.
- Eigenständige Windows-/Linux-Exportkonfigurationen und Godot-Tests.

Dieser Stand ist die Grundlage des größeren Vertical Slice. Ein Dungeon, ein Elitegegner, eine dritte Gegnerrolle und zwei ausgearbeitete Questlösungen fehlen noch.
