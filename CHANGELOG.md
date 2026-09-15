# Änderungen

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
