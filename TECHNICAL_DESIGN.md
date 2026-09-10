# Technische Architektur

## Laufzeit

Godot **4.5.1 Standard**, GDScript, Compatibility-Renderer, 60 Physikschritte/Sekunde. Keine Add-ons, externen Bibliotheken, Online-Abfragen oder Laufzeit-KI. Der Editor ist nur zur Weiterentwicklung nötig; Exporte laufen eigenständig.

## Verantwortlichkeiten

| Bereich | Dateien / Zuständigkeit |
|---|---|
| Zusammenbau | `scripts/game.gd`: baut eine Sitzung, verdrahtet Signale, verarbeitet Interaktionen und Menüzustände |
| Zustandsdaten | `core/run_state.gd`: Seed, Fortschritt, IDs veränderter Weltobjekte; `core/content.gd`: Definitionen aus JSON |
| Eingabe / Figur | `actors/player.gd`, `core/input_setup.gd`: Bewegung, Kamera, Zielrichtung, Eingaben |
| Attribute | `actors/vitals.gd`: Leben, Mana, Ausdauer, Regeneration und Schadensschutz |
| Fähigkeiten | `actors/mage_abilities.gd`: Ressourcen und Abklingzeiten; `combat/combat_system.gd`: Effekte und Kombinationen |
| Kampf | `combat/projectile.gd`, `combat/feedback.gd`: kontinuierliche Kollisionsbewegung, Partikel und Trefferzahlen |
| Gegner | `actors/enemy.gd`: explizite Zustandsmaschine mit Ankündigung und Erholung; Werte aus JSON |
| Welt | `world/world_generator.gd`: reine seed-basierte Erzeugung; `world/world_view.gd`: Darstellung und Kollisionskörper |
| Dungeon | `dungeon/dungeon_generator.gd`: Raumgraph und Raster; `dungeon/dungeon_view.gd`: Darstellung, Kollisionen und AStarGrid2D; `dungeon/dungeon_object.gd`: Interaktionsobjekte |
| Ortsgedächtnis | `dungeon/dungeon_progress.gd`: dauerhafte Raum-, Fund- und Torzustände; `core/discovery_book.gd`: sichtbare Einträge aus `data/discoveries.json` |
| Orte / Atmosphäre | `world/landmark.gd`, `world/atmosphere.gd`: Interaktionsobjekte, Tagesfarbe und Lichtpartikel |
| Grafik | `art/pixel_art.gd`: aus Pixelprimitiven aufgebaute, zwischengespeicherte Sprite-Texturen |
| Dungeon-Grafik | `art/dungeon_art.gd`: eigene Wurzeln, Säulen, Tore, Quellen, Funde und Dornkobold |
| UI | `ui/game_ui.gd`: Menüs und Steuerelemente; `ui/hud_canvas.gd`: HUD und Karte |
| Persistenz | `persistence/save_system.gd`: Schema, Validierung, temporäre Datei und Sicherung |
| Audio | `audio/audio_controller.gd`: lokal synthetisierte Klänge, Stimmenpool, Lautstärke |

Es gibt keine Autoload-Singletons für Spielzustände. Definitionen und unveränderliche Texturen werden statisch gecacht. Eine Sitzung besitzt ihre Welt, Figur, Kampfobjekte und ihren Zustand. Ein neues Spiel ersetzt nur diese Sitzung. Die UI bleibt beim Pausieren bedienbar, die Welt pausiert.

`game.gd` ersetzt bei Gebietswechseln nur den aktiven Weltbaum; der RunState mit beiden Regionen bleibt bestehen. Leben, Mana und Ausdauer werden übernommen. Der alte Baum wird vor dem Aufbau aus dem Szenenbaum entfernt, damit alte Gegner-/Interaktionsgruppen sofort verschwinden. Weltzeit gehört zum RunState und tickt nur im laufenden Spiel, unabhängig von Wald oder Gruft. `combat/thorn_patch.gd` begrenzt die Lebensdauer, prüft Sichtkontakt und nutzt dieselbe Schadensannahme wie andere Angriffe.

## Ordner und kommende Module

`scenes/` Einstiegsszene; `scripts/actors`, `art`, `audio`, `combat`, `core`, `dungeon`, `persistence`, `ui`, `world`; `data/` Werte und Ortsdefinitionen; `tests/` ausführbare Prüfungen; `tools/verify.py` lokaler Prüfablauf.

Mit dem vollständigen Slice werden Inventar/Ausrüstung, Questgraph und NPC-Erinnerungen eigene Module. Fraktionen und abstrakte Regionsereignisse kommen danach. Dafür werden aktuell keine leeren Scheinmodule angelegt.

## Generierung

1. Expliziter begrenzter Seed-Hash; separate Zufallsströme für Gelände und Darstellung.
2. Gröberes Rauschfeld verteilt Waldgruppen. Regelbasierter Fluss und Teich bilden Orientierung.
3. Strukturierte Landmarken erhalten begrenzte Positionsvariation.
4. Pfade werden anschließend freigeräumt; Wasserquerungen werden Brücken.
5. Sichere Lichtungen und Gegnergebiete erhalten garantierte Anschlüsse.
6. Persistente IDs entfernen besiegte Gegner und aktivieren zuvor geweckte Lichter.

Alle Schleifen sind begrenzt. Ein Breitensuchtest prüft Erreichbarkeit auf dem begehbaren Raster. Das Rendering nutzt eine gebackene Bodentextur; Sprite-Texturen sind gecacht. Genau eine Region ist aktiv: Wald mit 112 × 88 oder Gruft mit 96 × 64 Tiles. Chunk-Streaming und langfristige Weltsimulation sind nicht implementiert.

Dungeonversion 1 verwendet einen festen, in `data/vault.json` definierten Raumgraphen und begrenzte Seed-Variation der Raumgrößen und Gegnerpositionen. Drei Tiles breite Gänge, zwei solide Wasserbecken und veränderbare Torsperren bilden das Raster. Geöffnete Tore aktualisieren Physikkörper und AStarGrid2D gemeinsam. Die Navigation nutzt vier Nachbarn ohne diagonales Schneiden von Ecken. Separate Breitensuchen prüfen geschlossene und geöffnete Geheimwege für 100 Seeds. Der Waldeingang wird auf der bestehenden freien Lichtung ergänzt, ohne Terrainversion 1 oder dessen Zufallsstrom zu ändern.

## Speicherung und Kompatibilität

Format 2, Waldgeneratorversion 1 und Dungeonversion 1. JSON speichert Seed, Figur, Fortschritt, Talente, Licht- und Gegner-IDs, entdeckte Orte, Tageszeit und Einstellungen. Neu sind die aktive Region und ein eigener Dungeonzustand für besuchte Räume, Erinnerungen, Funde, offene Tore und Eddas Kartenreaktion. IDs, Datentypen, Wertebereiche und Zustandsabhängigkeiten werden geprüft. Eine gespeicherte Dungeonposition muss auf einem tatsächlich zugänglichen Bodentile liegen. Schreiben erfolgt über eine temporäre Datei und den vorherigen Stand als `.bak`.

Gültiges Format 1 wird beim Lesen explizit im Speicher auf Format 2 erweitert: aktive Region Wald, leerer Dungeonzustand, erhaltene Originalwerte. Die Quelldatei bleibt beim Laden unverändert. Vor dem ersten Überschreiben eines gültigen Altstands wird eine bytegenaue `.pre-v03`-Kopie angelegt; spätere Speicherungen verändern sie nicht. Der bekannte Dateiname `lichtpfad_v1.json` bleibt erhalten. Godots JSON-Zahlen können als Float ankommen, deshalb vergleichen Versionsprüfungen numerisch und verwenden keine typstrenge Array-Mitgliedschaft.

Beschädigte Hauptdateien können auf die gültige Sicherung zurückfallen. Unbekannte Format-/Generator-/Dungeonversionen werden mit einer Meldung abgelehnt; hier erfolgt kein stiller Rückfall auf eine ältere Sicherung. Ältere Builds können Format 2 nicht lesen. Weitere Schemaänderungen brauchen erneut eine explizite Migration oder parallele Generatorversion.

Lebende Gegner starten beim Laden und erneutem Betreten einer Region wieder gesund an ihren Ausgangsorten; laufende Projektile und kurze Effekte werden nicht gespeichert. Abklingzeiten werden zurückgesetzt. Dauerhafte Verluste/Entdeckungen bleiben erhalten. Ein Gebietswechsel gibt kurz 0,8 Sekunden Ankunftsschutz. Tod in der Gruft führt zum Waldlager. Dies sind die dokumentierten Grenzen des Prototyps.

## Pixelregeln

- Interne Auflösung 640 × 360, 16 × 16 Pixel große Bodentiles.
- Figur ungefähr 28 × 42 Pixel inklusive Hut und Stab; Fußpunkt als Sortieranker.
- Ganzzahlige Viewport-Skalierung und Nearest-Filter. Positionen werden im Rendering auf Pixel eingerastet.
- Smaragd, Türkis und gedämpftes Gold für Natur; Elfenbein für Hinweise und Runen; dunkles Blaugrau für Gefahr.
- Oben links hellere Kanten, farbige Konturen, kurze transparente Bodenschatten; keine schwarzen Vollumrisse überall.
- Boden → nach Fußpunkt sortierte Objekte/Figuren → Kampfpartikel → atmosphärische Ebene → unabhängige UI.
- Vier Gehphasen für Magier und Wolf, Magier-Rückenansicht, schwebende Irrlichter, Feuerphasen, Dash-Spur und Trefferblitz. Vollständige Animationsatlanten für alle Richtungen folgen später.
- Baumtexturen: 96 × 112 Pixel, Fußanker (48, 105); andere Sprites: 64 × 72 Pixel, Fußanker (32, 65).
- Bodenfarbe und Vegetation werden einmalig in eine RGBA-Textur gebacken. Wasserreflexe werden nur im sichtbaren Kameraausschnitt gezeichnet.
- Kleine additive PointLight2D-Quellen nutzen eine gecachte Falloff-Textur. Kein dynamisches Schattennetz und kein notwendiger Forward+-Renderer.
- Generator 1 und dessen Zufallsstrom sind unverändert. Der separate Darstellungsstrom `/art/v2` beeinflusst keine Kollisionen oder IDs.
- `tests/fixtures/v01_save.json` und der vollständige Terrain-Hash stammen vom unveränderten 0.1-Code. Der Kompatibilitätstest lädt diese Dateien tatsächlich in die Szene.
- `tests/fixtures/v02_completed_save.json` stammt vom unveränderten 0.2-Code und enthält den abgeschlossenen ersten Auftrag; der Migrationstest prüft damit den sofortigen Dungeonzugang.

## Technische Referenzen

- [Godot 4.5.1, offizielles Archiv](https://godotengine.org/download/archive/4.5.1-stable/)
- [Godot: Pixelauflösungen und ganzzahlige Skalierung](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
- [Godot: Kommandozeile und Exporte](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
