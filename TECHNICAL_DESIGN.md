# Technische Architektur

Diese Beschreibung gehört zum tatsächlichen 0.4-Code mit Foundation v1.0, Interaction Foundation M05 sowie Stats/Trefferauflösung M06 und Active Combat/Defense M07. Der [M00-Abgleich](docs/FOUNDATION_M00.md) bleibt die historische Architekturaufnahme; [M01](docs/FOUNDATION_M01.md) dokumentiert die Save-Absicherung, [M02](docs/FOUNDATION_M02.md) die kontrollierten Fortschrittsaktionen und [M03](docs/FOUNDATION_M03.md) den abgegrenzten Regionslebenszyklus. Der [Foundation Completion Report](docs/FOUNDATION_COMPLETION_REPORT.md) enthält den M00–M04-Abschluss und Tims anschließende Windows-Abnahme. [M05](docs/FOUNDATION_M05.md) und [M06](docs/FOUNDATION_M06.md) dokumentieren die folgenden Iterationen. Kreative Ziele gehören in die [Design-Bible](docs/CREATIVE_DESIGN_BIBLE_V1.md), das genehmigte M06-Gameplay in die [unveränderte Spezifikation V1.1](docs/M06_STATS_HIT_RESOLUTION_V1_1.md). Erweiterungen sind nur dort implementiert, wo dies ausdrücklich beschrieben ist.

## Developer Sandbox Foundation

Die getrennte Szene `developer/sandbox.tscn` ergänzt die Questwelt als Labor. Sie startet weder `game.gd` noch SaveSystem. Produktionscode, Daten, Assets, Saveformat 3 und die M05/M06/M07-Verträge bleiben unverändert. Im Editor Szene mit F6 starten; im Developer-Export direkt die eigene EXE.

| Lokaler Besitzer | Implementierte Zuständigkeit |
| --- | --- |
| `developer/session.gd` | Startprofile, Reset, Pause, monotone Generation, explizite Entwickleranfragen |
| `developer/fixture.gd` | Spezialisierte RegionInstance mit Arena, transientem RunState und echten MagePlayer/WildEnemy/CombatSystem-Instanzen; vorhandene activate/deactivate-/Scope-Grenzen |
| `catalog.gd` + `presets.json` | Einmal beim Start validierte, danach rekursiv schreibgeschützte Testdaten: drei Player- und sechs Enemy-Presets, Bolt/Nova, A01–A12, drei Wellen |
| `waves.gd` | Endliche Wave-Folge, Wartezeit und Abschlusszahl; schwacher Session-Bezug plus erfasste Generation |
| `observed_player.gd`, `observed_enemy.gd` | Unveränderte Weitergabe an super; kopieren echte Defense-/M06-Ergebnisse. Passiver Dummy bzw. einzelner Angriff sind lokale KI-Teststeuerung |
| `telemetry.gd` | Maximal 96 Live-Ereignisse ohne Actor-Referenzen; Preset, Zeit, Generation, Target/Attack/Hit-ID, Phase, Outcome, Damage/Impact und Reaction |
| `scenarios.gd` | Reproduzierbare Fixtures A01–A12, die vorhandene Contact-/M06-/Actor-Pfade ausführen; Unterfälle behalten ihre Diagnose im Szenarioergebnis |
| `sandbox.gd` | Labor-Controls und Anzeige zehnmal/Sekunde; Gameplay hängt nicht von der Anzeige ab |

**Reset:** Wellen stoppen → alte Fixture deaktivieren (Combat-Scope sofort ungültig) → Baum entfernen/freigeben → Generation erhöhen → frische Fixture, Wellen und Telemetrie → Presets → aktivieren. Alte Actions/Callbacks scheitern an den unveränderten regionalen Guards. Der normale RegionLifecycle wird nicht ersetzt. Es entsteht genau ein neuer Player.

**Pause und Zeit:** Nur die Fixture-Verarbeitung wird angehalten. CollisionObjects bleiben für kontrollierte Physikproben aktiv (`DISABLE_MODE_KEEP_ACTIVE`). `advance_probe()` bewegt ausgewählte Probe-/Defense-/Reaction-/Vitals-Uhren, keine Körper und keine vollständige Welt. Freies Spielen nutzt normale Physik; die Sandbox ist keine allgemeine Einzelschritt-Engine. Eingaben gelten in der Arena; das Verlassen eines Zahlenfeldes per Arena-Klick löst keinen Zauber aus.

**Daten:** Nahdistanz bedeutet vor M08 den vorhandenen Magier mit aktiver Abwehr, keine neue Spielerwaffe. Fern-/Magieprofile verwenden vorhandene Fähigkeiten/Talente. Enemy-Testwerte ändern ausschließlich private Definitionskopien. Keine Mutation des globalen Content-Caches, keine freien globalen Player-Stats. Maximal acht lebende Gegner; drei endliche Wellen. Testwerte sind keine Produktionsbalance.

**Diagnose:** Freie Kämpfe protokollieren echte Defense und Actor-/M06-Auflösung. Vollständige Ablehnungsgründe stehen in der ausdrücklich bezeichneten Kontaktprobe und den Szenarien zur Verfügung. Die bestehenden Live-Adapter melden nicht jeden Miss; die Sandbox erfindet keine Ereignisse und ergänzt keinen Core-Eventbus.

**Save-/Export-Isolation:** Der optionale Buttonbericht schreibt nur `user://developer_sandbox/last_report.json`. Keine SaveSystem-Aufrufe. `tools/export_sandbox.py` erstellt eine Staging-Kopie mit eigener Startszene, 1280×720-UI und Benutzerordner `Lichterhain_DeveloperSandbox`. Das originale `project.godot` bleibt bytegleich. Produktions-Presets schließen `developer/*` aus. Paket-Smokes verwenden ein leeres Ressourcenverzeichnis, damit lose Quelldateien keine fehlenden Pack-Inhalte verdecken.

**Erweiterung:** Künftige genehmigte Weapon-/Magic-/Status-Verbraucher können über Presets, Controls und zusätzliche Szenarien eingebunden werden. Ihre Contracts werden jetzt nicht definiert. Blueprint-Welt-Deltas, Umweltreaktionen und Simulation bleiben zukünftige Leitplanken. Kein globaler Manager, keine Registry, keine zweite Formel.

## Laufzeit

Godot **4.5.1 Standard**, GDScript, Compatibility-Renderer, 60 Physikschritte/Sekunde. Keine Add-ons, externen Bibliotheken, Online-Abfragen oder Laufzeit-KI. Der Editor ist nur zur Weiterentwicklung nötig; Exporte laufen eigenständig.

## Verantwortlichkeiten

| Bereich | Dateien / Zuständigkeit |
|---|---|
| Sitzung | `scripts/game.gd`: RunState, UI/Audio, Interaktionen und explizite Speicherpunkte; verdrahtet regionale Referenzen |
| Interaktionsvertrag | `interaction/interaction_core.gd`, `interaction_target.gd`, `interaction_request.gd`, `interaction_context.gd`, `interaction_result.gd`: sitzungsgebundene Anfrage, aktuelle Angebote/Validierung, bestätigtes Ergebnis; kein Besitzer von Gameplayregeln |
| Interaktionsverbraucher | `dungeon/dungeon_interaction.gd`, `source_interaction.gd`: vorhandene Truhen, Sickerquelle, Steindurchgang und Quellenfassung; fragen RunState/Vitals an und präsentieren das bestätigte Ergebnis |
| Regionslebenszyklus | `world/region_lifecycle.gd`: genau eine aktive Region, Wechsel, Invalidierung, Generationskennung, Ressourcenübernahme und Camp-Rückkehr |
| Regionsinstanz | `world/region_instance.gd`: bestehender 2D-Aufbau von Terrain, Player, Gegnern, Landmarken, Combat und Atmosphäre |
| Zustandsdaten | `core/run_state.gd`: Seed, Fortschritt, IDs veränderter Weltobjekte |
| Inhaltsdaten | `core/content.gd`: einmalig geprüftes, schreibgeschütztes JSON-Bundle; `core/content_validator.gd`: Schema/Querverweise; `dungeon/vault_content_validator.gd`: Generator-1-Geometrie |
| Eingabe / Figur | `actors/player.gd`, `core/input_setup.gd`: Bewegung, Kamera, Zielrichtung, Eingaben |
| Attribute | `actors/vitals.gd`: Leben, Mana, Ausdauer, Regeneration und Schadensschutz |
| Fähigkeiten | `actors/mage_abilities.gd`: Ressourcen und Abklingzeiten; `combat/combat_system.gd`: Effekte und Kombinationen |
| Trefferrechnung | `combat/attack_profile.gd`, `combat_stats.gd`, `defense_outcome.gd`, `hit_resolver.gd`, `hit_resolution.gd`: reiner gemeinsamer Damage-/Impact-Vertrag; keine HP-Änderung, Treffererkennung oder aktive Verteidigung |
| Trefferlieferung | `combat/hit_instance.gd`: transiente Identität und einmaliger Kontakt je Ziel; vorhandenes CombatSystem prüft Region/Herkunft. `combat_profiles.gd` verbindet vorhandene Definitionen, Actor/Vitals übernehmen das Ergebnis |
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

`scenes/` Einstiegsszene; `scripts/actors`, `art`, `audio`, `combat`, `core`, `dungeon`, `interaction`, `persistence`, `progression`, `ui`, `world`; `data/` Werte und Ortsdefinitionen; `tests/` ausführbare Prüfungen; `tools/verify.py` lokaler Prüfablauf.

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

`RunState.LIGHT_IDS` besitzt die bekannten Licht-IDs; `SaveSystem.LIGHTS` bleibt als kompatibler Alias erhalten. Die normale Gegnerannahme prüft die bestehenden Generator-1-IDs/Kinds und verwendet XP aus der vorhandenen JSON-Definition. M04 bindet die numerischen Belohnungen an JSON. Die feste Identitätskonvention bleibt ein explizit validierter Generator-/Save-Vertrag; eine beliebige Erweiterung der IDs ist noch kein unterstützter Authoring-Workflow.

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

## Interaktionsvertrag — M05

**IMPLEMENTED.** Die Sitzung besitzt einen `InteractionCore` als `RefCounted`, ohne eigenen Prozess, Autoload oder Signale. Ein vorhandenes DungeonObject kann einen `InteractionTarget`-Adapter besitzen. Die Sitzung verdrahtet die derzeit ausgewählten Verbraucher einmal nach Regionsaktivierung. Das Objekt hält seinen Adapter; Adapter und Request halten die Weltobjekte nur über schwache Referenzen. Es entsteht kein zusätzlicher Interaktions-Node pro Objekt und keine globale Target-Registrierung.

Der Kern kennt keine Truhen, Questbedingungen, Kosten, Beute oder VFX. Er prüft Herkunft/Lebensdauer, lässt den Verbraucher sein aktuelles Angebot und seine Bedingungen prüfen und gibt dessen Ergebnis zurück. `RunState`, DungeonProgress, SourceQuest und Vitals behalten ihre vorhandenen Fachregeln. Der Adapter schreibt keine zweite persistente Zustandskopie.

### Tatsächliche Schnittstellen

| Schnittstelle | Vertrag |
| --- | --- |
| `core.discover(actor, target, state)` | Liefert `{"offers": [...], "notice": "..."}` vom Target. Jedes Angebot besitzt einen eindeutigen lokalen `intent` und `prompt`. Ein Target darf mehrere Angebote liefern; es gibt kein globales Verb-Enum. Discovery ist ohne Zustandsänderung, Dateizugriff oder aufwendige Bedingungsprüfung. |
| `core.request(actor, target, intent)` | Erzeugt eine Anfrage mit gewähltem Intent, schwachen Actor-/Adapterreferenzen, Herkunftsgeneration und Lebenszyklus-ID. Diese Herkunft wird beim Erstellen erfasst, niemals bei späterer Lieferung neu zugewiesen. |
| `InteractionContext` | Für den synchronen Aufruf frisch aufgebaut: Actor, tatsächlicher Target-Node, Intent, opaque `world_state`-Referenz und Generation. `distance()` verwendet aktuelle Weltpositionen. Actor-Ressourcen werden am tatsächlichen Actor gelesen; der Weltzustand wird weder kopiert noch gespeichert. |
| `target.validate(context)` | Leerer `StringName` erlaubt die Auflösung; ein lokaler Grundcode weist sie ab. Der Kern enthält keine Condition-Engine. Validation verändert keinen Zustand und wartet nicht. |
| `target.resolve(context)` | Fragt die zuständigen Fachsysteme an und liefert erst nach deren synchronem Ergebnis einen `InteractionResult`. Keine Coroutines oder wartenden Animationen innerhalb der Auflösung. |
| `InteractionResult` | `resolved` unterscheidet Ablehnung vor/bei der Auflösung von einem bestätigten Ausgang. `code` ist ein lokaler Grund/Ausgang. `consequences` enthält eine kopierte, außen schreibgeschützte Dictionary mit bereits angewandten Folgen; aktuelle Verbraucher nutzen nur einfache Werte. Keine weiter auszuführenden Befehle oder Node-Referenzen. |
| `game.execute_interaction(request)` | Ruft den Kern mit dem aktuellen RunState auf. Erst danach ruft die Sitzung `target.present(result)` auf, sofern Herkunft, Actor und Ziel weiterhin aktuell sind. Darstellung und bestehende Save-Checkpoints gehören diesem Verbraucher, nicht dem Core. |

Ausführung: Herkunft und lebende Baumreferenzen prüfen → frischen Kontext bilden → angebotenen Intent erneut abgleichen → konkrete Bedingungen erneut prüfen → Lebensdauer nochmals prüfen → fachlich auflösen → Ergebnis zurückgeben → bei weiterhin aktueller Region präsentieren. Die erneute Discovery wählt **keinen anderen Intent**: Eine frühere Untersuchung darf nach einem Quellenabschluss nicht automatisch Erz ernten.

Das Ergebnis darf ohne Weltänderung bestätigt sein. Der geschlossene Steindurchgang lässt sich untersuchen, obwohl der Wasserhinweis noch fehlt; der bisherige Hinweistext ist ein gültiger Ausgang `unreadable`. Eine volle oder unbezahlbare Sickerquelle wird dagegen vor dem Abbuchen abgelehnt. Ein bereits eingesammelter Fund bietet keine weitere Öffnung an. Zustand und Wiederholbarkeit werden beim zuständigen Besitzer geprüft, nicht durch einen generischen Einmal- oder Cooldownmechanismus.

### Migrierte Verbraucher und Grenzen

| Vorhandenes Ziel | Lokaler Intent | Zuständigkeit / bestätigte Folgen |
| --- | --- | --- |
| Sternenkarte, Bernsteinsamen | `open` | RunState/DungeonProgress vergeben den vorhandenen Fund und seine bestehenden XP genau einmal; danach Grafik, Klang, Save und Discovery-Dialog. |
| Sickerquelle | `rest` | Aktueller Actor, Reichweite/Sicht, vorhandene Kosten und Ressourcenstand prüfen; RunState bezahlt, Vitals füllt auf, danach Ring und Save. |
| Stein mit Wasserspuren | `inspect` | RunState entscheidet mit dem bestehenden Wasserhinweis über Öffnung; bestätigte Öffnung aktualisiert die bestehende Barriere/Navigation und speichert. Ohne Hinweis bleibt der alte Reaktionstext erhalten. |
| Quellenfassung / Garten / Erzader | `inspect`, `rest` oder `gather`, je nach Zustand | SourceInteraction fragt RunState/Vitals an. SourceStory behält Wahl-/Zeichendialoge, Herausforderung, Hüterabschluss und Weltreaktion; bestehende Questregeln und einmalige Erzbelohnung bleiben erhalten. |

Die gemeinsame Nahprüfung der **Verbraucher** verwendet den tatsächlichen lebenden Magier, dessen RunState, Entfernung und einen aktuellen Sichtstrahl. Die vorhandene Auswahlgrenze bleibt 36 Pixel (`DungeonInteraction.REACH`); die bisherige Quellen-Ausführungsgrenze bleibt 42 Pixel (`SourceStory.REACH`, auch für bestehende Dialogbedingungen). Das Target-eigene Torhindernis ist kein fremdes Sichthindernis. Ein fremdes Hindernis oder eine zwischenzeitliche Bewegung wird bei der Ausführung erkannt. Künftige Actors dürfen den generischen Vertrag verwenden, benötigen aber ihren eigenen Verbraucher; diese Adapter sind ausdrücklich für den vorhandenen Player ausgelegt.

Die bestehende Suche innerhalb der einzigen aktiven Region bleibt bei 0,12 Sekunden. Nur das nächste relevante Target wird nach seinen Angeboten gefragt. Die UI zeigt wie bisher die erste vorhandene Aktion oder einen Informationstext. Sie leitet die Aktion bei migrierten Zielen nicht aus dem Objekttyp ab; `E` verwendet die erfasste Anfrage. Keine neue Mehrfachauswahl-UI, globale Weltsuche oder per-Frame-Condition-Auswertung.

NPC/Edda, Lager/Waldlichter, Erinnerungen, Wurzelwinde, Hauptgitter und Regionsübergänge bleiben bei ihren bestehenden Pfaden. `game.interact()`/`interact_dungeon()` leiten die migrierten Ziele in den Vertrag. Bestehende M02/M04-Tests positionieren den Player nun tatsächlich neben ihrem Testobjekt; ihre bisherigen Assertions bleiben erhalten.

### Lebensdauer, Reentranz und Persistenz

M03 bleibt unverändert. Die Sitzung löscht ihre nächste Anfrage bei Deaktivierung; extern aufgehobene Requests scheitern trotzdem an Lifecycle-ID/Generation und schwachen Referenzen. Ein gleicher stabiler Objektname in einer neu aufgebauten Gruft macht einen alten Request nicht gültig. Entfernte, zur Freigabe vorgemerkte und freigegebene Targets werden abgewiesen. Kein alter Ergebnisdialog wird in der neuen Region angezeigt.

Während einer synchronen Ausführung weist der Core verschachtelte Ausführungen mit `busy` zurück, auch aus vorhandenen RunState-Signalhandlern. Danach entscheidet wieder der fachliche Zustand über eine neue Anfrage. Dies ist keine Reservierung für mehrere NPCs, kein Thread-/Mehrspieler-Locking, keine lang dauernde Aktion und keine allgemeine Rollback-Transaktion. Consumer-Callbacks müssen synchron bleiben; reaktive Regionswechsel innerhalb einer noch laufenden fachlichen Mutation sind kein unterstützter Ablauf.

Bestätigung bedeutet eine abgeschlossene Änderung im Arbeitsspeicher. Ein anschließend fehlgeschlagener Save macht die Aktion nicht ungeschehen und berechtigt nicht zur erneuten Belohnung. Der bestehende Fehler bleibt sichtbar, der letzte gültige Datenträgerstand bleibt erhalten, und F5 kann denselben Zustand erneut speichern. Schema 3, Generatoren, JSON-Balance, eingefrorene Spielstände und die Save-Implementierung sind unverändert. Der Core speichert weder Requests noch Context/Result.

Bewusst offen bleiben die im genehmigten Proposal genannten UX-Auswahlregeln, verborgene Interaktionsmöglichkeiten, Dauer/Abbruch/Commitment und konkurrierende Actors. M05 entscheidet diese Bereiche nicht vor. Aktuelle Tests und Abnahme: [TESTING.md](TESTING.md); Ergebnis und Risiken: [M05 Completion Report](docs/FOUNDATION_M05.md).

## Stats und Trefferauflösung — M06

**IMPLEMENTED / automatisiert TESTED.** Grundlage ist die genehmigte [Spezifikation V1.1](docs/M06_STATS_HIT_RESOLUTION_V1_1.md). Der reine Resolver beantwortet ausschließlich die Wirkung eines bereits bestimmten Kontakts/Defense-Outcomes. M07 prüft heute die von den bestehenden Geometrie-Adaptern gelieferten Kontakte und entscheidet die aktive Defense. Der M06-Vertrag und seine Formeln bleiben unverändert.

### Daten und Schnittstellen

| Baustein | Tatsächlicher Vertrag |
| --- | --- |
| `AttackProfile` | `damage`, `damage_type`, `impact`, optionale `secondary`-Information; keine Actor-, Health-, Timing- oder Flugbahnlogik |
| `CombatStats` | Snapshot aus `protection`, schadensartspezifischen `resistances` und `stability`; Health bleibt beim Actor/Vitals |
| `DefenseOutcome` | Vorgegebenes `hit`, `block`, `parry`, `miss` oder `evade`, getrennte `damage_scale`/`impact_scale`. `block()` verlangt beide Werte vom Aufrufer; keine festgelegte Blockbalance |
| `HitResolver.resolve(attack, stats, defense)` | Reine synchrone Rechnung ohne Nodes, Content-Zugriff, Lebensuhr, HP-Änderung, Signale oder Effekte |
| `HitResolution` | `resolved`, `contact`, Ablehnungsgrund, Outcome, effektiver Damage/Impact, Damage-Type, Immunität und sekundäre Information. Liefert ein Ergebnis, keinen später erneut auszuführenden Schadensbefehl |
| `HitInstance.resolve(target, ...)` | Ergänzt transiente Treffer-ID, Aktions-ID, stabile Urheber-ID, Ziel-Instanz-ID und Regiongeneration; prüft den vorhandenen Combat-Besitzer und quittiert je Ziel höchstens einen bestätigten Kontakt |
| `Player.receive_hit()` / `WildEnemy.receive_hit()` | Prüfen den Actor, liefern dessen aktuellen Defense-Snapshot, verwenden denselben Resolver und übernehmen das bestätigte Ergebnis. Player-HP gehört weiterhin `Vitals.apply_hit()`, Gegner-HP weiterhin dem Gegner |

`resistances` und `secondary` werden kopiert und außen schreibgeschützt; aktuelle sekundäre Nutzdaten sind einfache Werte (`shatter`, `slow_seconds`). Öffentliche GDScript-Felder bilden einen internen Vertrag, keine manipulationssichere API. Verbraucher dürfen Profile/Ergebnisse nicht nachträglich verändern oder ein Ergebnis mehrfach an `Vitals.apply_hit()` liefern. Die abgesicherte Laufzeitoberfläche für Angriffe ist `receive_hit()` mit derselben HitInstance.

### Rechnung und Fehlerausgänge

Mit `P = protection`, `R = passende resistance` und `S = stability` gilt:

```text
EffectiveDamage = round(rawDamage × damageScale × 100/(100+max(0,P)) × (1-clamp(R,-50,90)/100))
EffectiveImpact = round(rawImpact × impactScale × 100/(100+max(0,S)))
```

Genau `R = 100` ist explizite Damage-Immunität und ergibt 0 Damage, unabhängig vom Impact. Sonst bleibt ein positiver Raw Damage bei positivem Scale mindestens 1. Impact hat kein Minimum. `miss`/`evade` bestätigen ein Ergebnis ohne Kontakt, Damage, Impact oder sekundäre Lieferung. `parry` ist ein negierter Kontakt mit beiden Scales 0; widersprüchliche Parry-Scales werden abgewiesen. Eine Gegenreaktion am Angreifer ist nicht implementiert.

Der reine Aufruf weist fehlende Eingaben, leere Schadensart, negative/nicht-endliche Angriffswerte oder Scales, nicht-endliche Defense-Werte, nichtnumerische Resistance, unbekanntes Outcome und nicht-endliche Ergebnisse mit einem Grundcode zurück. Negative Protection/Stability werden in der Rechnung gemäß Spezifikation auf 0 begrenzt; normale Resistance wird auf −50…90 begrenzt, genau 100 separat behandelt. Die Inhaltsvalidierung ist bewusst strenger als diese mathematische Normalisierung.

In `data/content.json` sind `player.defense` und `enemies.*.defense` Pflichtfelder: endliche Protection/Stability im bestehenden technischen Zahlenbereich 0…10.000, Resistance-Dictionary mit endlichen Werten −50…90 oder genau 100. Bool, Zahlstring, NaN/Infinity, 91…99 und ungültige Schlüssel werden abgelehnt. `damage_type` bei Bolt, Nova, Echo und den vier Gegnerdefinitionen sowie `combat.default_damage_type` verwenden `[a-z][a-z0-9_]*`, 1–64 Zeichen. Neue gültige Schlüssel brauchen keinen Eintrag in einem globalen Elementkatalog; eine nicht vorhandene Resistance bedeutet 0. Die Diagnose nennt Datei, Feld und Problem. Fehler stoppen weiterhin einmalig beim Laden vor Weltaufbau/Save-Schreiben.

Ausgeliefert bleiben sämtliche bisherigen Zahlen unverändert. Neue Defense-Werte sind neutral (0/leer/0). `light` für Lichtfunke/Widerhall, `frost` für Frostkreis und `untyped` für bisher untypisierte Angriffe sind technische Schlüssel, keine endgültige Elementar-/Lore-Taxonomie. `CombatProfiles` liest Raw Impact aus den bereits vorhandenen Rückstoßquellen `combat.enemy_knockback` bzw. `player.knockback`; keine neuen unabhängigen Zahlenkopien.

### Reale Verbraucher und einmalige Kontakte

Bolt besitzt eine bei Erzeugung erfasste HitInstance. Der bestehende Frostbonus wird einmal vor Mitigation addiert; Widerhall erzeugt eine eigene benannte Instanz. Nova verwendet eine Instanz für alle getroffenen Ziele. Gegnergeschosse einschließlich Hüterfächer, Wolfslunge und Quellenschlag besitzen jeweils ihre Instanz; jede bereits vorhandene Dornenperiode erzeugt ausdrücklich einen neuen `thorn_pulse`. M07 koordiniert diese Instanzen je expliziter Active-Phase; die bestehenden Intervalle, Reichweiten und Schadenswerte bleiben erhalten.

Die Instanz speichert nur eine schwache Referenz auf ihr vorhandenes regionales CombatSystem und numerische Ziel-IDs. Sie besitzt keine globale Registry und hält weder Gegner noch alte Regionen am Leben. `CombatSystem.accepts_hit()` prüft Aktivität, Baumzugehörigkeit, Freigabezustand, Besitzeridentität und die beim Erzeugen erfasste Generation. Getrennte, alte, freigegebene und regionsfremde Ziele werden abgewiesen, auch nach Gruft–Wald–Gruft oder Load. Ein bereits abgefeuertes Geschoss darf nach dem Tod seines Urhebers innerhalb derselben aktiven Region fertig fliegen; seine Herkunft bleibt als String erhalten.

Ein bestätigter Kontakt wird **vor** HP-Änderungen und Signalcallbacks quittiert. Wiederholte oder reentrante Lieferung derselben Instanz wirkt nicht erneut, auch nach Ablauf der Player-Unverwundbarkeit oder Änderung einer Defense. Das gilt ebenfalls für Parry und Immunität. Miss/Evade beanspruchen das Ziel nicht; die bisherigen Projektile/Lungen behalten trotzdem ihre eigene Kontakt-/Verbrauchslogik. Mehrere Ziele sind erlaubt, weitere echte Treffer benötigen eine ausdrücklich neue Instanz.

### Zustandsbesitzer und Grenzen

Vitals/Gegner ändern Health. Die M07-Actor-Adapter interpretieren Effective Impact mit CombatReaction; der Quellenhüter bleibt ortsfest. Vorhandener Dash-/Schadensschutz und die aktive Defense werden vor Live-Treffern geprüft. Reiner Impact erzeugt keinen erfundenen HP-Schaden oder neuen Schadensschutz. M07 fügt keine zweite Stability-/Poise-Statistik hinzu.

CombatSystem/ThornPatch behalten Frostverlangsamung, Widerhall, Mana-/Heilboni und Feedback. Der Resolver interpretiert sekundäre Information nicht. Damage-Immunität bedeutet weder Status-Immunität noch Verfehlen: Ein bestätigter Frostkontakt kann weiterhin die vorhandene Verlangsamung und einmalige Reliktrückgabe auslösen. Trefferzahlen verwenden den effektiven Damage. Dauerhafte Gegnerbelohnungen bleiben RunState-Aktionen und werden nicht vom Resolver vergeben.

`take_damage()` und isoliertes `Vitals.damage()` bleiben als Kompatibilitätseinstiege erhalten; sie verwenden dieselbe Rechnung, interpretieren aber **jeden Aufruf als neuen Kontakt**. Sie eignen sich nicht zur wiederholten Lieferung einer bereits erfassten Attack Action. Aktuelle Live-Angriffe verwenden die explizite Instanz. Es gibt keinen allgemeinen Signal-Rollback, Thread-/Netzwerkvertrag oder manipulationssicheren Result-Container.

Saveformat 3, RunState und RegionLifecycle bleiben unverändert. Defense-Werte kommen aus Content; Trefferinstanzen, Receipts, CombatStats und Ergebnisse werden nicht gespeichert. Absolute gespeicherte LP/MP/AU bleiben erhalten. Kein zusätzlicher Node-/Frameprozess und keine Prüfung des Content-Bundles pro Treffer; pro Kontakt entstehen nur die benötigten kleinen Eingabe-/Ergebnisobjekte. Ein neuer Performance-Benchmark wird nicht behauptet. Abnahme und Grenzen: [TESTING.md](TESTING.md), [M06 Completion Report](docs/FOUNDATION_M06.md).

## Active Combat und Defense — M07

**IMPLEMENTED / AUTOMATED TESTED.** Grundlage: [M07 V1.1](docs/M07_ACTIVE_COMBAT_DEFENSE_V1_1.md). M07 bestimmt gültigen Kontakt und genau ein Defense Outcome; M06 bestimmt dessen numerische Wirkung. Miss/Evade führen im Live-M07-Pfad nicht zu einem Resolver-Aufruf. Es gibt keine Accuracy-Würfe, Registry, Autoloads oder Eventbusse.

### Vertrag und lokale Besitzer

| Vertrag | Zuständigkeit |
| --- | --- |
| `ActionTimeline(preparation, commitment, phases, after)` | Reine lokale Zeit: Intent, Startup, Commit, Active, Recovery, Completed/Interrupted. Halb offene Phasen mit `start` und `duration`; kein Animationszustand bestimmt den Kontakt. `start`, `tick`, `cancel` vor Commit, `interrupt`, `finish_active`, `phase_index`, `remaining`. Ungültige/überlappende/nicht-endliche Fenster werden abgewiesen. |
| `CombatSystem.new_action(actor, id, clock, rules, source_id)` | Lokale Factory im bereits vorhandenen regionalen CombatSystem; startet eine gültige Timeline. Kein zusätzlicher Manager. |
| `AttackInstance` | Schwacher Actor-/Scope-/Payloadbezug und erfasste Generation; hält Timeline, Herkunft, Block-/Parry-Eignung und höchstens eine aktuelle `HitInstance` je expliziter Phase. `is_current()` prüft die Lebensdauer, getrennt von der Timeline-Phase. |
| `ContactContext(action, target, center, radius, heading, facing_dot)` | Erfasst Hit-Phase und schwaches Ziel. `follow(node)` bindet den Ursprung an eine lebende Instanz; alternativ fester Einschlag-/Flächenpunkt. Aktuelle Position, Reichweite, Richtung, endliche Geometrie und optionale reine `visibility`-Abfrage werden unmittelbar vor Lieferung geprüft. |
| `CombatContact.resolve(action, context, profile)` | Einziger Live-Übergang: Lebensdauer → Phase → Geometrie → Actor-Defense → bestehendes `receive_hit`/M06 → bestätigtes Ergebnis. Ergebnis: `outcome`, Ablehnungs-`reason`, optionales M06-`resolution`; `confirmed()` bedeutet aufgelöster Kontakt. |
| Actor-Schnittstelle | `combat_alive`, `combat_defense`, `receive_hit`, `confirm_parry`, `parried_action`, `defense_feedback`. Player/Vitals und WildEnemy bleiben Health-Owner. Die bestehenden Actor-Adapter verarbeiten das M06-Ergebnis vor eigenen Signalen. |
| `ActiveDefense` | Ein lokaler Zustand: Normal, Dodge, Block, Parry oder Recovery. Bestehender Schadensschutz/Dodge → Evade; sonst geeigneter frontaler Parry, geeigneter frontaler Block, sonst Hit. Keine additive Schutzmischung. |
| `CombatReaction` | Interpretiert bereits durch M06/Stability geminderten Impact: Normal, Interrupt, Stagger; begrenzte Verschiebung. Keine zweite Mitigation. Timer und anschließender Guard verhindern erneute/verlängerte Kontrollsperren; Health-Schaden bleibt möglich. |
| `ActionProfiles` | Kleine Adapter für die heutigen Definitionen; spätere Waffen/Abilities liefern eigene Timeline, Kontaktgeometrie und M06-Profile. Keine Waffen-/Magie-Foundation in M07. |

Player tickt seine aktiven Actions, Defense und Reaction in seinem bestehenden Physics-Prozess. Gegner tickt seine Action am vorhandenen KI-Ablauf; die alten Mode-/Timer-Felder stellen diese Zustände für Telegraphing dar. Projektile und explizite Pulse besitzen nach Freigabe ihre eigene lokale Action. Kein zusätzlicher Prozess-Node und kein globales Durchsuchen aller Actors pro Frame.

### Tatsächlich migrierte Angriffe

Lichtfunke einschließlich einmaligem Frostbonus und separat bestätigtem Widerhall, Frostkreis mit mehreren Zielen und einmaliger Reliktrückgabe, Wolfslunge, Irrlicht-/Hüterprojektile, Hüterschlag und Dornenpulse verwenden `CombatContact`. Normale Instant-Zauber behalten ihren sofortigen Release; ihre vorhandenen Cooldowns liefern Recovery, MageAbilities behält Ressourcen und Wiederbenutzung. Gegner verwenden bestehende Windup-/Lunge-/Recovery-Werte. Beim Active-Ende endet auch die Lungenbewegung.

Geometrie bleibt beim Verbraucher: bestehende Strahlen/Kreise, eingefrorene Lungenrichtung, aktuelle Target-Position. Der Projektiladapter verwendet tatsächlichen Projektil-/Zielradius plus Godot-`safe_margin`; nur die normale numerische Approximation gleicht Rundungsfehler aus. Keine unsichtbare Accuracy-Korrektur. Neue Geometrieformen brauchen später eigene kleine Adapter.

`HitInstance` quittiert weiterhin vor HP-Mutation/Signalen. Mehrere Ziele pro Phase sind erlaubt, Wiederholung desselben Ziels nicht. Weitere Treffer brauchen ausdrücklich neue Phasen; die vorhandenen Dornenintervalle definieren diese. Große Simulationsschritte holen ausgelassene Pulse nicht als Schadenssalve nach.

### Aktive Defense und Reaktion

**F halten** blockt zur Maus-Ausrichtung, reduziert Bewegung und verhindert gleichzeitiges Zaubern. **Q** startet eine kurze Parade; ein früher/ungeeigneter Versuch bietet keinen Ersatzblock. Erfolg verbraucht das Fenster, geht in Recovery und kann die noch zugehörige Angreifer-Action unterbrechen. Kein automatischer Gegenangriff und keine Parry-Schadensformel. **Leertaste** behält Bewegung, Kosten und vorhandene Dauer des Ausweichens. Während seiner Wiederbenutzungs-Recovery gibt es keinen weiteren Dodge-Schutz. Gleichzeitig gedrückte Requests werden deterministisch behandelt (Dodge vor Parry; gehaltenes Block darf diese nicht überschreiben).

M06 erhält ausschließlich `DefenseOutcome` mit den bestehenden Block-Skalierungsfeldern. Actor/Movement setzt Reaction-Zustand und begrenzten Rückstoß um; VFX, Zahlen, „Block“/„Parade“, Sound und Camera bleiben bestehende Präsentation. Der Stagger-Guard verhindert auch, dass wiederholter Gegner-Hitstop das zugesagte Kontrollfenster verdeckt. Der ortsfeste Hüter erhält weiter keine Ortsverschiebung.

### Lebensdauer, Daten und Grenzen

Release bindet eine Payload ausdrücklich an ihre Instanz. Sie kann den Tod ihres Casters innerhalb derselben Region überleben. Ein Parry darf nur die zugehörige, noch aktuelle Angreifer-Action beeinflussen; ein altes Geschoss unterbricht keinen späteren Angriff. Deactivate/Travel/Load/Unload invalidieren den Scope sofort; Generation und schwache Referenzen verhindern Kontakte in neue/alte entfernte Regionen. Keine M07-Daten werden gespeichert, keine Schemaänderung.

Die neue geprüfte JSON-Sektion `active_combat` besitzt Commitment-Anteil, Instant-Fenster, Defense-, Reaction- und Contact-Regeln. Neue Tuningwerte sind vorläufige Foundation-Werte gemäß Spezifikation §28, keine endgültige Waffenbalance. Alle bisherigen 137 Content-Blattwerte (davon 106 Zahlen) bleiben identisch. Validierung beim Laden: Pflichtfelder, echte Bool-Eignung, endliche Zahlen; Skalierungen/Commit-Anteil 0…1, Facing −1…1, positive Dauern/Schwellen/Maximalverschiebung im bestehenden Bereich; Stagger-Schwelle ≥ Interrupt-Schwelle. Dornen sind auf höchstens 512 explizite Phasen begrenzt. Fehler melden Datei/Feld/Problem und stoppen vor Weltaufbau/Save-Schreiben.

`take_damage`, `Vitals.damage`, `_bolt_hit` sowie direkte `_enemy_bolt`/`_source_slam`/`_thorns`-Aufrufe ohne Parent bleiben klar begrenzte Diagnose-/Kompatibilitätseinstiege. Sie bedeuten einen **neuen** Kontakt bzw. eine neue Freigabe und dürfen keine erfasste Live-Action umgehen. Live-KI-Signale liefern ihre bestehende Parent-Action; Live-Projektile behalten ihre Action. Keine Netzwerk-/Thread-/Anticheat-Garantie, allgemeine Condition-Engine, Defense-KI oder Animationstechnologie. Testumfang und Windows-Abnahme: [TESTING.md](TESTING.md).

## Inhaltsdaten und Konsistenz — M04

**IMPLEMENTED / automatisiert TESTED.** JSON bleibt die Inhaltsquelle. `Content.ensure_loaded()` liest beim ersten Zugriff `data/content.json`, `data/vault.json` und `data/discoveries.json`, prüft das gesamte Bundle und veröffentlicht es erst nach erfolgreicher Prüfung. Dictionarys und Arrays sind rekursiv schreibgeschützt. `DiscoveryBook.entries()` und `DungeonGenerator.content()` sind lesende Zugriffe auf denselben Cache; ihre früheren unabhängigen Parser/Caches entfallen. Fehler werden ebenfalls zwischengespeichert. Es gibt kein Hot Reload und keine Prüfung pro Frame. Ein Neustart lädt geänderte Dateien neu.

`ContentValidator` prüft die konkreten derzeit unterstützten Definitionen, `VaultContentValidator` den Raum-/Verbindungsvertrag. Die reinen Prüfmethoden ändern keine Eingabedaten. Das Laufzeit-Bundle ist unveränderlich; neue Tests setzen ausdrücklich eine private Testkopie ein, um geänderte Definitionen und den bestehenden Fehlerfall einer nicht verfügbaren Belohnung zu prüfen. Dies ist keine öffentliche Laufzeit-Schreibschnittstelle.

### Maßgebliche Regelquellen

Alle bisherigen Balancezahlen bleiben erhalten. Die Zahlen in dieser Tabelle beschreiben den M04-Stand; gepflegt werden sie ausschließlich in den genannten Definitionen.

| Regel | Maßgebliche Quelle | Verbraucher |
| --- | --- | --- |
| LP/MP/AU-Maximum, jeweils 100 | `content.player.hp/mana/stamina` | Vitals-Start, Regeneration, Rast, Heilung/Refund-Caps, Regionsaufbau, HUD; Save übernimmt absolute Ressourcen |
| Bewegung, Dash 28 AU / 0,62 s / 0,16 s | `content.player` | Player, MageAbilities, HUD über `MageAbilities.definition()` |
| Mana/AU-Regeneration 8/30, Regenerationspause und Schadensschutz je 0,65 s | `content.player` | Vitals; gleiche Zahlen bedeuten hier zwei getrennte Regeln |
| Lichtfunke 8 MP / 0,32 s / 19 Schaden; Frostbonus 10 | `content.spells.bolt` | MageAbilities, Projectile/Combat, Enemy, HUD |
| Frostkreis 28 MP / 4,5 s / 16 Schaden, Reichweite/Radius/Verlangsamung | `content.spells.nova` | MageAbilities, Combat, Enemy, HUD |
| Fließender Schritt 12 MP; Quellenkreis 12 LP | `content.skills.flow.mana_refund`, `bloom.healing` | Player/Combat/Vitals, Journaltexte mit geprüften Zahlentokens |
| Widerhall 12 Schaden / 65 Reichweite | `content.skills.echo` | Bestehender Combat-Ketteneffekt |
| Quellenherz 6 MP pro getroffener Nova | `content.relics.source_heart.frost_refund` | RelicInventory, Combat, Journal und Abschlussdialog; keine zweite Anwendung pro Ziel |
| Level-Schwelle `Stufe × 60`, normaler Gegner 1 Lichtstaub | `content.progression` | RunState; `xp_required()` auch für HUD, Journal und Saveprüfung |
| Waldlicht 20 XP; erster Auftrag 45 XP | `content.quest.light_xp/reward_xp` | RunState, Lichtmeldung; Questzielanzahl kommt aus `RunState.LIGHT_IDS` |
| Quelle 90 XP / Quellenherz; Erz 4 Lichtstaub | `content.source_quest` | RunState, SourceStory-Dialog/Meldung, Save-Referenzprüfung |
| Erinnerung 10, Karte 40, Samen 25 XP; Quelle kostet 2 Lichtstaub | `vault.json` bestehende Felder | RunState, Interaktion und Kostenhinweis |
| Gegnerspezifische HP/XP/Schaden/Reichweiten/Angriffszeiten | `content.enemies` | WildEnemy, SourceGuardian, Dornen/Einschlag, gegnerische HP-Balken |
| Gemeinsame Gegnergeschosse 115 Tempo / 210 Reichweite, Trefferreaktion/Campradius | `content.combat` | CombatSystem und WildEnemy |
| Tagesdauer 240 s | `content.world.day_seconds` | RunState-Zeitfortschritt |

Unbenutzte JSON-Kopien von Wald-Breite/Höhe/Tilegröße/Generatorversion und Questzielanzahl wurden entfernt. Die Generator-1-Konstanten und stabilen Licht-IDs besitzen diese Verträge bereits. Karte/Save greifen darauf zurück. Gruft-Spawn, Geheimweganschluss und Becken sind vorhandene Generatorregeln, die Erzeugung und Geometrieprüfung gemeinsam verwenden. Hüter-/Fassungspunkte gehören zu SourceStory. Layout-, Grafik-, Kollisions- und Scanparameter werden dadurch nicht zu frei veränderbaren Inhaltsdefinitionen erklärt.

### Tatsächliche Validierungsregeln

- Jede Datei muss ein JSON-Objekt sein. Pflichtfelder, Objekt-/Array-/Texttypen und unbekannte Felder werden geprüft; stille Fallback-Definitionen gibt es nicht.
- IDs verwenden `[a-z][a-z0-9_]*`, maximal 64 Zeichen. Bestehende Zauber-/Talent-/Gegner-/Relikt-, Raum-, Fund- und Encounter-IDs sind Pflichtverträge. Nicht unterstützte IDs/Modi, doppelte IDs und fehlende Verweise werden abgewiesen. Ein gültiger Name allein erzeugt keine neue Mechanik.
- Zahlen müssen endlich sein; boolesche Werte und Zahlstrings sind keine Zahlen. Allgemeine positive Zahlen liegen zwischen 0,000001 und 10.000, nichtnegative zwischen 0 und 10.000. XP/Lichtstaub sind ganze, nichtnegative Zahlen, XP-Multiplikator und Brunnenkosten ganze Zahlen ab 1. Kosten und Schaden dürfen 0 sein; Cooldowns, Reichweiten und wiederholte Angriffsintervalle müssen positiv sein. Multiplikatoren liegen in `[0,1]`, Hüterfächeranzahl ganzzahlig in `[2,64]`, Fächerwinkel in `[0,π]`, Leash mindestens so groß wie Aggro. Diese Authoring-Grenzen sind Schutzgrenzen, keine Balancingziele.
- Talent-/Relikttexte prüfen Klammern, bekannte numerische Platzhalter und die Pflicht-Tokens `{mana_refund}`, `{healing}` bzw. `{frost_refund}`. `Content.description()` formatiert die Definition; UI pflegt keine eigene Zahl.
- Räume haben ganzzahlige Koordinaten-/Größenpaare. Auch die größte ±2-Variation muss innerhalb des Rasterrands liegen. Verbindungen benötigen zwei bekannte, verschiedene Raum-IDs; ungerichtete Doppelverbindungen sind ungültig. Der bestehende Geheimzweig bleibt `cistern → secret`.
- Auf dem Boden der kleinsten möglichen Räume werden die echten Gang-/Beckenregeln verwendet. Spawn, Raumzentren, Interaktionspunkte und alle ±1-Encounter-Verschiebungen müssen mit offenen Toren erreichbar sein; Torpunkte müssen zu ihren Kollisionszellen passen. Fassung und Hüter müssen im erreichbaren Sanctum liegen. Dies ergänzt die bisherigen 100-Seed-Tests für geschlossene/offene Wege; es behauptet keine beliebige neue Topologie oder dreidimensionale Raumprüfung.
- Discovery-Einträge brauchen nichtleere Titel/Texte und unterstützte IDs. Erinnerungen/Funde müssen einen Journaleintrag besitzen; Quellenbelohnungen eine vorhandene Reliktdefinition.

Fehler nennen Datei, Feldpfad, erwartete Bedingung und erhaltenen Wert. Syntaxfehler nennen Datei und Parserzeile. Der Einstieg zeigt eine unabhängige Fehleransicht, erzeugt keine Sitzung/Region und schreibt keinen Save. Region-Build und Saveprüfung lehnen ungültigen Content ebenfalls ausdrücklich ab. Dies funktioniert in Release-Builds ohne Assertions. Beispiel:

```text
data/content.json
enemies.guardian.fan_count
Expected integer in [2, 64], finite
Received: 1
```

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

### Ressourcenkompatibilität — M04

Format **3** und die gespeicherten Felder bleiben unverändert. Formate 1–3 enthalten absolute LP/MP/AU, aber keinen damaligen Maximalwert. Die frühere feste Save-Obergrenze 100 wird deshalb durch eine stabile Serialisierungsgrenze von 1.000.000 ersetzt (`MAX_STORED_RESOURCE`), unabhängig von aktueller Balance. LP müssen endlich und strikt positiv, MP/AU endlich und nichtnegativ sein. Tote Charaktere bleiben nicht speicherbar. Diese Grenze erlaubt keine Regeneration bis eine Million; dafür gilt ausschließlich die Spielerdefinition.

Ein älterer Stand oberhalb aktueller Maxima wird exakt geladen und mit einem ausdrücklichen Hinweis versehen, auch nach Backup-Recovery. Regeneration, Talent-/Reliktboni und Rast reduzieren vorhandenen Überschuss nicht und vermehren ihn nicht. Ausgaben/Schaden können ihn verbrauchen; unterhalb der neuen Maxima füllen die normalen Regeln wieder auf. Wiederholtes Speichern/Laden erhält diese absoluten Werte. Aktuell sind weiterhin alle drei Maxima 100, daher verändert diese Kompatibilitätsregel keine reguläre Balance des ausgelieferten Prototyps.

Die bestehenden Fortschrittsgrenzen (ganze Werte bis 10.000) und Zustandsabhängigkeiten bleiben erhalten. Eine spätere Änderung der XP-Kurve oder persistenter IDs braucht eine eigene Kompatibilitäts-/Migrationsentscheidung: M04 löst ausdrücklich die Maximalwertkopplung, nicht jede denkbare zukünftige Inhaltsmigration. Frühere ausführbare Builds können höhere Ressourcenwerte weiterhin ablehnen; das ist keine zugesicherte Rückwärtskompatibilität neuer Daten mit alten Programmen.

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
