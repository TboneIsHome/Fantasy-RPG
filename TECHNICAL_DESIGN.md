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
| Orte / Atmosphäre | `world/landmark.gd`, `world/atmosphere.gd`: Interaktionsobjekte, Tagesfarbe und Lichtpartikel |
| Grafik | `art/pixel_art.gd`: aus Pixelprimitiven aufgebaute, zwischengespeicherte Sprite-Texturen |
| UI | `ui/game_ui.gd`: Menüs und Steuerelemente; `ui/hud_canvas.gd`: HUD und Karte |
| Persistenz | `persistence/save_system.gd`: Schema, Validierung, temporäre Datei und Sicherung |
| Audio | `audio/audio_controller.gd`: lokal synthetisierte Klänge, Stimmenpool, Lautstärke |

Es gibt keine Autoload-Singletons für Spielzustände. Definitionen und unveränderliche Texturen werden statisch gecacht. Eine Sitzung besitzt ihre Welt, Figur, Kampfobjekte und ihren Zustand. Ein neues Spiel ersetzt nur diese Sitzung. Die UI bleibt beim Pausieren bedienbar, die Welt pausiert.

## Ordner und kommende Module

`scenes/` Einstiegsszene; `scripts/actors`, `art`, `audio`, `combat`, `core`, `persistence`, `ui`, `world`; `data/` Werte; `tests/` ausführbare Prüfungen. Die neun Projekt-Dokumente liegen im Wurzelordner.

Mit dem Slice werden Inventar/Ausrüstung, Questgraph, NPC-Erinnerungen, Loot und Dungeongenerierung eigene Module. Fraktionen und abstrakte Regionsereignisse kommen danach. Dafür werden aktuell keine leeren Scheinmodule angelegt.

## Generierung

1. Expliziter begrenzter Seed-Hash; separate Zufallsströme für Gelände und Darstellung.
2. Gröberes Rauschfeld verteilt Waldgruppen. Regelbasierter Fluss und Teich bilden Orientierung.
3. Strukturierte Landmarken erhalten begrenzte Positionsvariation.
4. Pfade werden anschließend freigeräumt; Wasserquerungen werden Brücken.
5. Sichere Lichtungen und Gegnergebiete erhalten garantierte Anschlüsse.
6. Persistente IDs entfernen besiegte Gegner und aktivieren zuvor geweckte Lichter.

Alle Schleifen sind begrenzt. Ein Breitensuchtest prüft Erreichbarkeit auf dem begehbaren Raster. Das Rendering nutzt eine gebackene Bodentextur; Sprite-Texturen sind gecacht. Die Karte bleibt in 0.1 vollständig geladen (112 × 88 Tiles). Chunk-Streaming und langfristige Weltsimulation sind nicht implementiert.

## Speicherung und Kompatibilität

Format 1 und Generatorversion 1. JSON speichert Seed, Figur, Fortschritt, Talente, Licht- und Gegner-IDs, entdeckte Orte, Tageszeit und Einstellungen. Dateigröße, Datentypen, Wertebereiche und IDs werden geprüft. Schreiben erfolgt über eine temporäre Datei und den vorherigen Stand als `.bak`.

Beschädigte Hauptdateien können auf die gültige Sicherung zurückfallen. Unbekannte Format-/Generatorversionen werden mit einer Meldung abgelehnt und nicht automatisch überschrieben. Vor der nächsten Schemaänderung muss eine explizite Migration oder eine parallele Generatorversion eingeführt werden.

Lebende Gegner starten beim Laden wieder gesund an ihren Ausgangsorten; laufende Projektile und kurze Effekte werden nicht gespeichert. Abklingzeiten werden zurückgesetzt. Dauerhafte Verluste/Entdeckungen bleiben erhalten. Das ist die dokumentierte Speichergrenze des ersten Prototyps.

## Pixelregeln

- Interne Auflösung 640 × 360, 16 × 16 Pixel große Bodentiles.
- Figur ungefähr 28 × 42 Pixel inklusive Hut und Stab; Fußpunkt als Sortieranker.
- Ganzzahlige Viewport-Skalierung und Nearest-Filter. Positionen werden im Rendering auf Pixel eingerastet.
- Smaragd, Türkis und gedämpftes Gold für Natur; Elfenbein für Hinweise und Runen; dunkles Blaugrau für Gefahr.
- Oben links hellere Kanten, farbige Konturen, kurze transparente Bodenschatten; keine schwarzen Vollumrisse überall.
- Boden → nach Fußpunkt sortierte Objekte/Figuren → Kampfpartikel → atmosphärische Ebene → unabhängige UI.
- Erste Animationen: Schrittversatz, schwebende Irrlichter, Dash-Spur, Trefferblitz. Umfangreiche richtungsabhängige Animationsatlanten folgen später.

## Technische Referenzen

- [Godot 4.5.1, offizielles Archiv](https://godotengine.org/download/archive/4.5.1-stable/)
- [Godot: Pixelauflösungen und ganzzahlige Skalierung](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
- [Godot: Kommandozeile und Exporte](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
