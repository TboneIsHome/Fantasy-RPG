# Technische Architektur

Diese Beschreibung gehört zum tatsächlichen 0.4-Code mit Foundation M03. Der [M00-Abgleich](docs/FOUNDATION_M00.md) bleibt die historische Architekturaufnahme; [M01](docs/FOUNDATION_M01.md) dokumentiert die Save-Absicherung, [M02](docs/FOUNDATION_M02.md) die kontrollierten Fortschrittsaktionen und [M03](docs/FOUNDATION_M03.md) den abgegrenzten Regionslebenszyklus. Kreative Ziele gehören in die [Design-Bible](docs/CREATIVE_DESIGN_BIBLE_V1.md). Erweiterungen sind nur dort implementiert, wo dies ausdrücklich beschrieben ist.

## Laufzeit

Godot **4.5.1 Standard**, GDScript, Compatibility-Renderer, 60 Physikschritte/Sekunde. Keine Add-ons, externen Bibliotheken, Online-Abfragen oder Laufzeit-KI. Der Editor ist nur zur Weiterentwicklung nötig; Exporte laufen eigenständig.

## Verantwortlichkeiten

| Bereich | Dateien / Zuständigkeit |
|---|---|
| Sitzung | `scripts/game.gd`: RunState, UI/Audio, Interaktionen und explizite Speicherpunkte; verdrahtet regionale Referenzen |
| Regionslebenszyklus | `world/region_lifecycle.gd`: genau eine aktive Region, Wechsel, Invalidierung, Generationskennung, Ressourcenübernahme und Camp-Rückkehr |
| Regionsinstanz | `world/region_instance.gd`: bestehender 2D-Aufbau von Terrain, Player, Gegnern, Landmarken, Combat und Atmosphäre |
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
| Quellenquest / Ausrüstung | `progression/source_quest.gd`: dauerhafte Entscheidung und Zeichenfolge; `progression/source_story.gd`: Szenen-/Dialogablauf; `progression/relic_inventory.gd`: Besitz und Reliktplatz |
| Quellenhüter / Folgen | `actors/source_guardian.gd`, `combat/source_impact.gd`, `dungeon/source_site.gd`, `dungeon/source_grove.gd`, `art/source_art.gd` |
| Persistenz | `persistence/save_system.gd`: Schema, Validierung und Schreibtransaktion; `persistence/save_file_io.gd`: kleine, pro Schreibaufruf ersetzbare Dateischnittstelle für überprüfbare Fehlerpfade |
| Audio | `audio/audio_controller.gd`: lokal synthetisierte Klänge, Stimmenpool, Lautstärke |

Es gibt keine Autoload-Singletons für Spielzustände. Definitionen und unveränderliche Texturen werden statisch gecacht. Eine Sitzung besitzt ihre Welt, Figur, Kampfobjekte und ihren Zustand. Ein neues Spiel ersetzt nur diese Sitzung. Die UI bleibt beim Pausieren bedienbar, die Welt pausiert.

`RegionLifecycle` ersetzt bei Gebietswechseln den aktiven 2D-Regionsbaum; der RunState mit beiden Regionen bleibt bestehen. Leben, Mana und Ausdauer werden übernommen. Der alte Baum wird vor dem Aufbau aus dem Szenenbaum entfernt, damit alte Gegner-/Interaktionsgruppen sofort verschwinden. Lichterhain bleibt dauerhaft 2D-isometrisch; M03 verändert weder Darstellung noch Projektion und enthält keine 3D-Vorbereitung. Weltzeit gehört zum RunState und tickt nur im laufenden Spiel, unabhängig von Wald oder Gruft. `combat/thorn_patch.gd` begrenzt die Lebensdauer, prüft Sichtkontakt und nutzt dieselbe Schadensannahme wie andere Angriffe.

## Ordner und kommende Module

`scenes/` Einstiegsszene; `scripts/actors`, `art`, `audio`, `combat`, `core`, `dungeon`, `persistence`, `progression`, `ui`, `world`; `data/` Werte und Ortsdefinitionen; `tests/` ausführbare Prüfungen; `tools/verify.py` lokaler Prüfablauf.

SourceQuest und RelicInventory sind eigene Module. Ein allgemeiner Questgraph, weitere Ausrüstungsarten und allgemeine NPC-Erinnerungen folgen später. Fraktionen und abstrakte Regionsereignisse kommen danach. Dafür werden aktuell keine leeren Scheinmodule angelegt.

## Fortschrittsaktionen und Zustandsbesitzer — M02

**IMPLEMENTED.** Szenen, UI und Kampf fordern dauerhafte Fortschrittsänderungen bei `RunState` an. Die lokalen Modelle bleiben erhalten; RunState koordiniert Änderungen, die zugleich einen Fund/Questzustand und XP, Lichtstaub oder Ausrüstung betreffen. Es gibt keinen neuen Manager oder globalen Eventbus.

| Besitzer | Fachaktionen / Verantwortung |
| --- | --- |
| RunState | Auftrag annehmen/abschließen, Lichter, Entdeckungen, Talentlernen, Gegner-ID mit XP/Lichtstaub, geprüfte Lichtstaubausgabe; koordiniert die folgenden Teilmodelle samt Belohnungen |
| DungeonProgress | Raum-ID prüfen/besuchen, Erinnerung freischalten, Fund beanspruchen, Tore öffnen, Sternenkarte berichten; wiederholte und unzulässige Requests ablehnen |
| SourceQuest | Quelle untersuchen, Zeichenfolge, Reset vor Herausforderung, einmaliger Ausgang, Bericht und Erzflag |
| RelicInventory | Bekanntes Relikt einmalig vergeben, Besitz vor Ausrüstung prüfen, leeren Platz erlauben; bestehende Frost-Manarückgabe |
| `game.gd`, SourceStory, CombatSystem | Physische Voraussetzungen, Szenenreaktion, Actor-Ressourcen, Dialoge/Audio/VFX und explizite Save-Checkpoints nach bestätigter Aktion |

`RunState.changed` meldet einmal den **vollständigen** dauerhaften Fortschrittszustand. Bei Questabschluss stehen Flag, XP/Stufe/Talentpunkte und gegebenenfalls Relikt/Equipment vor der Meldung fest. Auch der dritte richtige Quellenzeichenschritt löst die Quest samt Belohnung vor der Meldung auf: Kein Beobachter erhält `alignment=3` oder einen Ausgang ohne sein Relikt. Wiederholte Belohnungsrequests ändern nichts und melden nichts. Das ermöglicht einen unmittelbaren gültigen Snapshot aus dem Signalhandler; das Signal schreibt selbst keine Datei.

Rückgabewerte sind fachlich: Die meisten Methoden geben an, ob sie den Zustand geändert haben. `align_source()` bestätigt mit `true` ein richtiges Zeichen; ein falsches bekanntes Zeichen kann mit `false` einen **gemeldeten Reset** bewirken. Unbekannte Zeichen verändern nichts. `prepare_source_challenge()` bestätigt die zulässige Herausforderung auch ohne vorherige Zeichenfolge; nur ein tatsächlicher Reset emittiert `changed`. Diese Sonderfälle werden explizit getestet; es gibt keinen generischen Dispatcher, der alle Bool-Ergebnisse als dasselbe behandelt.

Persistenz bleibt getrennt: Erfolg einer Fortschrittsaktion bedeutet eine bestätigte Änderung im Arbeitsspeicher. Scheitert anschließend der Save-Checkpoint, bleibt diese Änderung bestehen, der letzte gute Datenträgerstand bleibt geschützt, und ein erneuter Save schreibt denselben Zustand. Wiederholte Quest-/Fundrequests sind kein erneuter Belohnungsweg. Szenenmeldungen bei Erz, Toröffnung, Quellengarten und Herausforderung überschreiben eine fehlgeschlagene Speicherung nicht mit einem Erfolgstext.

Die bestehenden Speicherzeitpunkte bleiben erhalten: Erinnerungen/Funde, geöffnete Tore, Questabschluss, Zeichenfortschritt, Herausforderung, Erz, Berichte und Reliktwechsel werden an ihren bisherigen Aufrufstellen gesichert. Gegnerbelohnungen, Entdeckungen, Räume, Waldlicht-Aktivierung, Annahme und Talentlernen gehen wie bisher in den nächsten Checkpoint ein; `changed` erzeugt kein Autosave pro Treffer oder Scan. F5, Rast, Reise und reguläres Schließen bleiben Checkpoints. Wiederholte bereits bestätigte Aktionen benötigen keinen neuen Schreibvorgang. Eine fehlschlagende Speicherung kann ausdrücklich mit F5 wiederholt werden.

Ausnahmen von dieser Fortschrittsoberfläche sind bewusst erhalten: `restore()` und Testaufbau konstruieren geprüfte Zustände direkt; `game.gd` setzt den Seed beim Sitzungsstart; `RegionLifecycle` setzt `RunState.region` beim bestätigten Reise-/Campablauf (M03). Zeit bleibt bei `advance_time()` ohne Änderungsmeldung pro Frame; Position und Vitals bleiben Actor-Zustand, Einstellungen gehören zur Sitzung. Öffentliche GDScript-Felder sind keine technisch erzwungene Unveränderlichkeit; Laufzeitaufrufer halten die Zuständigkeiten ein.

`RunState.LIGHT_IDS` besitzt die bekannten Licht-IDs; `SaveSystem.LIGHTS` bleibt als kompatibler Alias erhalten. Die normale Gegnerannahme prüft die bestehenden Generator-1-IDs/Kinds und verwendet XP aus der vorhandenen JSON-Definition. Die noch feste Identitätskonvention von Generator und Saveprüfung sowie übrige doppelte Inhaltswerte gehören weiterhin zu M04; kein neues Datenformat oder Schema wurde eingeführt.

## Regionslebenszyklus — M03

**IMPLEMENTED.** `game.gd` besitzt einen RegionLifecycle als normalen Kind-Node, ohne `_process()`, Autoload oder Eventbus. Dieser besitzt genau eine RegionInstance (`Node2D`). `game.world`, `terrain`, `player` und `combat` sind lesende Zugriffssichten auf diese Instanz, keine separat gepflegten Referenzen. Generatoren und Views erzeugen weiterhin Terrain/Navigation/Grafik; RegionInstance übernimmt nur den aus game.gd herausgelösten Zusammenbau. SourceStory bleibt ein eigener Sitzungs-Node und besitzt weiter den Quest-/Dialogablauf.

`build()` erzeugt eine Region aus einem gegebenen RunState und Player-Snapshot. `travel()` prüft Ziel, Questzugang und lebenden Player, übernimmt dessen Vitals und setzt `run.region`. `return_to_camp()` behält den bisherigen Tod-in-der-Gruft-Ablauf. Pro erfolgreichem Neuaufbau entstehen ein Terrain, ein neuer Player und ein CombatSystem; bestehende Generatoren werden nicht doppelt aufgerufen, nur um den Wald-Rückkehrpunkt zu ermitteln. Ein erneuter Aufruf für dasselbe Reiseziel baut nichts auf.

Ein Wechsel läuft synchron ab:

1. Aktuelle Instanz ungültig setzen; Verarbeitung und Player-Eingabe deaktivieren, Combat gegen weitere Signal-/Trefferaktionen sperren.
2. Über das benannte lokale Signal `deactivating` UI-, SourceStory-, Interaktions- und Audio-/Player-Verbindungen lösen. Auch bereits erfasste Callbacks müssen ihre Herkunft noch prüfen.
3. Aktuelle Besitzerreferenz leeren, alten Baum sofort aus dem Szenenbaum entfernen, danach `queue_free()`. Alte Actors verschwinden sofort aus Gruppen und Physikwelt; Speicherfreigabe erfolgt am Frame-Ende.
4. Generation erhöhen, genau eine neue 2D-Instanz aufbauen und aktivieren.
5. Über `activated` SourceStory, HUD, Audio und Player-Tod neu anbinden. Erst nach dem synchronen Wechsel schreibt game.gd seinen bisherigen Save-Checkpoint.

`_transitioning` weist verschachtelte Wechsel zurück. Auch `build_run()` darf während eines Lebenszyklus-Callbacks keinen anderen RunState einsetzen. `unload()` ist wiederholt sicher. Die alten Bäume können bis zum Frame-Ende noch zur Freigabe vorgemerkt sein; sie sind bereits getrennt und inaktiv, also keine zweite aktive Region.

**Identitäten:** `RunState.region` (`forest`/`vault`) bleibt gespeichert. Die RegionInstance trägt nur die Identität ihres Aufbaus und eine transiente fortlaufende `generation`. `is_current(origin_generation)` ist während Abbau oder nach Unload falsch; Reise, Load und neuer Run erzeugen stets eine andere Generation. Die Zahl wird nicht gespeichert und gilt im Kontext ihres RegionLifecycle, nicht als global eindeutige ID zwischen Spielprozessen.

**Verzögerte Aktionen:** SourceStory bindet RunState und Generation schon beim Verbinden der Hütersignale und reicht sie an `finish_broken()` weiter. Die Prüfung erfolgt erneut bei der verzögerten Ausführung. Somit reicht auch eine Rückkehr in dieselbe Gruft nicht aus, um eine alte Aktion gültig zu machen. Rückzugsaktionen sowie Player-Tod/Audio besitzen dieselbe Herkunftsprüfung. Neue regionsübergreifend wartende Timer/Callbacks müssen dieses Muster verwenden; es gibt keinen universellen Dispatcher.

Projektile, Einschläge und Dornen bleiben Kinder des regionsgebundenen CombatSystem. Sie werden gemeinsam deaktiviert, entfernt und freigegeben; ihre Mechanik bleibt unverändert. Alte Combat-Callbacks lehnen nach Deaktivierung weitere Treffer, Belohnungen oder Effekte ab. Interaktionen verlangen ein Objekt aus dem aktuellen Baum. Dialogbuttons aus einem bereits entfernten UI-Panel senden keine Requests mehr.

RunState, Generator-/Saveversionen, JSON-Inhalte und Belohnungsregeln bleiben erhalten. Der Player lebt weiterhin nur bis zum nächsten Neuaufbau. Kein Streaming, Region-Cache, Hintergrundsimulation oder persistenter regionsübergreifender Actor. Savefehler ändern die erfolgreich betretene Region im Arbeitsspeicher nicht zurück; die Meldung bleibt sichtbar und F5 kann erneut speichern.

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

M01-Schreibablauf (**IMPLEMENTED**, automatisiert **TESTED**):

1. Snapshot validieren und serialisierte UTF-8-Größe gegen `MAX_BYTES` prüfen.
2. `.tmp` schreiben, Flush-/Schreibfehler auswerten, anschließend wieder öffnen und alle Bytes vergleichen. Die Datei muss zusätzlich die bestehende Save-Validierung bestehen. Godot 4.5.1 meldet nicht jeden Betriebssystemfehler über `get_error()`; der Bytevergleich ist deshalb erforderlich.
3. Benötigte permanente `.pre-v03`-/`.pre-v04`-Originale über eine eigene temporäre Kopie erstellen und bytegenau prüfen. Vorhandene Originale nie überschreiben; eine ungültige vorhandene Vorversionssicherung blockiert die Migration mit einer Fehlermeldung.
4. Nur eine **gültige Hauptdatei** über `.bak.tmp` geprüft nach `.bak` kopieren. Eine beschädigte Hauptdatei darf eine gültige Sicherung nicht ersetzen. Die Hauptdatei bleibt bis zur letzten Umbenennung erhalten.
5. Erst danach `.tmp` auf den Hauptpfad umbenennen. Bei einem Fehler bleibt die gültige Sicherung für `read()` verfügbar; keine ungeprüfte Rückbenennung verbraucht sie. Die Fehlermeldung verspricht nur dann eine Sicherung, wenn sie tatsächlich lesbar ist.

`SaveFileIO` ist keine globale Schnittstelle und kein neuer Manager. Nur Tests übergeben gezielt fehlschlagende Dateioperationen. Normales Gameplay verwendet echte Dateizugriffe. `game.gd` behandelt fehlgeschlagenes Speichern bereits korrekt; M01 zeigt dessen Meldung zusätzlich im Pausefenster, damit sie dort lesbar bleibt. Speichern-und-Titel sowie Fensterschließen lassen bei einem Speicherfehler die Sitzung für einen erneuten Versuch offen.

Grenzen: synchroner einzelner Schreiber; keine zugesicherte Stromausfall-/Hardware-Dauerhaftigkeit und kein Mehrprozess-Locking. Eine fehlgeschlagene Ersetzung kann unter Windows das Ziel bereits entfernt haben: Beim Backup-Schritt bleibt dann die Hauptdatei, beim abschließenden Hauptdatei-Schritt die zuvor geprüfte Sicherung. Dieses Verhalten ist durch Fehlerinjektion abgedeckt; native Windows-Dateioperationen sind noch **NOT TESTED**. Zusätzliche `.tmp`-Dateien sind Arbeitsdateien und keine Ladequelle. Schema und Migration selbst bleiben unverändert.

Format 3, Waldgeneratorversion 1 und Dungeonversion 1. JSON speichert Seed, Figur, Fortschritt, Talente, Licht- und Gegner-IDs, entdeckte Orte, Tageszeit und Einstellungen. Zur aktiven Region und dem Dungeonzustand kommen `source` (gesehen, Zeichenfortschritt, Ausgang, Hütersieg, Eddas Reaktion, Erzernte) sowie `inventory` (besessene Relikte, angelegtes Relikt). IDs, Datentypen, Wertebereiche und Zustandsabhängigkeiten werden geprüft. Eine gespeicherte Dungeonposition muss auf einem tatsächlich zugänglichen Bodentile liegen. Schreiben erfolgt über eine temporäre Datei und den vorherigen Stand als `.bak`.

Gültiges Format 1 wird zunächst auf Format 2 erweitert: aktive Region Wald und leerer Dungeonzustand. Format 2 wird dann explizit auf Format 3 migriert: unentschiedene Quellenquest und leeres Reliktinventar. Vorhandene Hinweise aus 0.3 zählen bereits für die neue Untersuchung. Die Quelldatei bleibt beim Laden unverändert. Vor dem ersten Überschreiben eines gültigen Altstands wird eine bytegenaue `.pre-v04`-Kopie angelegt; eine bestehende `.pre-v03`-Kopie wird nie überschrieben. Bei direktem Umstieg aus 0.1/0.2 bleibt auch die bisherige `.pre-v03`-Regel erhalten. Das gilt ebenso bei Wiederherstellung aus einer gültigen alten `.bak`-Datei.

Der bekannte Dateiname `lichtpfad_v1.json` bleibt erhalten. Godots JSON-Zahlen können als Float ankommen, deshalb vergleichen Versionsprüfungen numerisch. Quellenzustände werden auch gegeneinander validiert: Reparatur benötigt die Hinweise, ein Sieg passt nur zur gebrochenen Bindung, Erzernte nur zur Erzader, ein angelegtes Relikt muss besessen sein und Belohnung/Ausgang müssen zusammenpassen. Die Zeichenfolge darf in einem Speicherpunkt nur 0–2 betragen; das dritte Zeichen schließt die Quest vor dem Schreiben ab.

Beschädigte Hauptdateien können auf eine gültige Sicherung zurückfallen. Unbekannte Format-/Generator-/Dungeonversionen werden abgelehnt; hier erfolgt kein stiller Rückfall auf einen älteren Stand. Ältere Builds können Format 3 nicht lesen. Weitere Schemaänderungen brauchen erneut eine explizite Migration oder parallele Generatorversion.

Lebende Gegner starten beim Laden und erneutem Betreten einer Region wieder gesund an ihren Ausgangsorten; laufende Projektile und kurze Effekte werden nicht gespeichert. Abklingzeiten werden zurückgesetzt. Dauerhafte Verluste/Entdeckungen bleiben erhalten. Ein Gebietswechsel gibt kurz 0,8 Sekunden Ankunftsschutz. Tod in der Gruft führt zum Waldlager. Der Hüter ist nach dem Laden zunächst inaktiv und gesund. Seine abgeschlossenen Ergebnisse und das Relikt bleiben erhalten. Dies sind die dokumentierten Grenzen des Prototyps.

## Quellenkampf und Folgen

SourceGuardian erweitert die bestehende WildEnemy-Schnittstelle für Treffer, Frostsynergie und Projektile. Nur ein ausdrücklich erweckter Hüter gehört zur Gegnergruppe. Seine zwei Angriffe sind eine feste Markierung mit einmaligem SourceImpact sowie ein angekündigter Projektilfächer. Projektil-Urheber werden mit stabilen IDs markiert, damit Rückzug nur die Hütereffekte aufräumt. Der Sieg wird nach dem laufenden Kampfschritt abgeschlossen; ein mitgeführter RunState-Bezug verhindert die Übertragung eines verspäteten Siegcallbacks auf einen neu geladenen Lauf.

SourceStory baut pro aktiver Gruft genau einen Quellenort und gegebenenfalls einen Hüter auf. Das Gelände und seine Generatorversion werden nicht verändert. Der Garten ist ein explizites Schutzrechteck für Gegner, Geschosse und Dornen; zwei Wächter werden ohne zusätzliche Erfahrung beruhigt. SourceGrove zeichnet den dauerhaften Ausgang, SourceSite bietet Rast oder einmalige Erzernte. Lebensdauer und Gebietsabbau bleiben an den Szenenbaum gebunden.

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

- `tests/fixtures/v03_completed_save.json` stammt vom unveränderten 0.3-Code; Quellenquest, Ausrüstung, Hinweisfortschritt und beide Lösungen werden in `tests/source_suite.gd` geprüft.

## Technische Referenzen

- [Godot 4.5.1, offizielles Archiv](https://godotengine.org/download/archive/4.5.1-stable/)
- [Godot: Pixelauflösungen und ganzzahlige Skalierung](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
- [Godot: Kommandozeile und Exporte](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
