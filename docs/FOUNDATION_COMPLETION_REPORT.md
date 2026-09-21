# LICHTERHAIN — FOUNDATION COMPLETION REPORT

**Nachtrag vom 21.09.2026:** Tim hat vor M05 die Prüfung dieses Berichts, Foundation M00–M04, 707/707 Checks und die manuelle Windows-Abnahme ausdrücklich bestätigt. Foundation v1.0 ist damit **COMPLETE**. Anschließend wurde ausschließlich das genehmigte Interaction Design für M05 freigegeben. Der aktuelle Folgebericht ist [FOUNDATION_M05.md](FOUNDATION_M05.md). Die folgenden Aussagen bleiben als historischer Stand zum damaligen Abschluss erhalten; der Nutzerbericht ersetzt keine einzeln protokollierte native Windows-Dateifehlerinjektion.

---

Stand: 21.09.2026 · Quellstand 0.4.0 / Foundation M04 · Godot 4.5.1.

**M04: IMPLEMENTED / PARTIALLY TESTED.** Die technische Umsetzung, automatisierte Regression und Release-Prüfung sind abgeschlossen. Die eigene manuelle Windows-Abnahme des neuen Pakets steht aus. **Stop nach M04.** Keine anschließende Entwicklungsphase wurde begonnen.

M04 basiert auf dem gesicherten M03-Commit `788d8ed090eef34ac11046db4f58d3487a0f911a`. Vor Änderungen bestand dieser erneut 504/504 Checks. Ein vollständiges Git-Referenzarchiv, die bisherigen QA-Nachweise und die unveränderten Save-Fixtures sichern den Vergleich. Persönliche Windows-Spielstände wurden nicht bereitgestellt und daher auch nicht bearbeitet.

## 1. M00–M04-Status

| Milestone | Ergebnis | Status / Abnahmegrenze |
| --- | --- | --- |
| M00 — Audit/Referenz | Tatsächliches 0.4 gegen Audit 0.3 abgeglichen; Originalstand und sechs Save-Fixtures gesichert | **COMPLETE** laut Tim. Historischer [M00-Bericht](FOUNDATION_M00.md) |
| M01 — Save-System | Tatsächliche Schreibfehler erkannt, Original-/Backup-Kopien geprüft, beschädigte Hauptdatei überschreibt keine gültige Sicherung | **IMPLEMENTED / automatisiert TESTED**. Historisch 290 Checks plus echter Linux-Dateifehler. Native Windows-Dateifehlerinjektion weiterhin **NOT TESTED**; spätere positive Spieltests werden nicht zu solchen Tests umgedeutet |
| M02 — Zustandsbesitzer | Dauerhafte Aktionen und komplette, einmalige Belohnungen bei RunState/Teilmodellen | **COMPLETE / TESTED** laut Tim einschließlich manuellem Windows-Spieltest; historisch 405 Checks |
| M03 — Region Lifecycle | Genau eine sitzungsgebundene 2D-Region, Generationen, Referenzabbau, Ablehnung alter Aktionen | **COMPLETE / TESTED** laut Tim einschließlich Windows-Abnahme im M04-Auftrag; historisch 504 Checks |
| M04 — Datenkonsistenz | Gemeinsame Definitionen, belastbare einmalige JSON-Prüfung, verständlicher Startabbruch, Maximalwert-kompatible Saves | **IMPLEMENTED / PARTIALLY TESTED**. 707/707 Checks und beide Release-Packs geprüft; eigener manueller Windows-Spieltest **NOT TESTED** |

Die Foundation ist kein fertiges RPG-Framework und noch keine dynamische Open World. Sie ist ein abgesicherter, weiterhin spielbarer 2D-Prototyp mit klareren Erweiterungsgrenzen.

## 2. Aktuelle Architekturübersicht

`game.gd` besitzt die Sitzung, RunState, UI/Audio, SourceStory und einen normalen RegionLifecycle-Kindknoten. RegionLifecycle besitzt genau eine RegionInstance. Darin leben Terrain/Navigation, der jeweils neu erzeugte Player, Gegner, Interaktionsobjekte und Combat. Generatoren und Darstellung behalten ihre Fachaufgaben. SourceStory lebt außerhalb des austauschbaren Baums und wird bei jedem Wechsel neu angebunden.

Dauerhafte Requests werden beim fachlichen Zustandsbesitzer geprüft. Erst der vollständige bestätigte Zustand erzeugt seine benannten Meldungen und die passenden UI-/Audio-/VFX-Reaktionen. Die Sitzung schreibt explizite Save-Checkpoints. Inhaltsdefinitionen sind ein eigener, unveränderlicher Datenbestand.

**Erhalten:** dauerhaft 2D-isometrisch, Godot/GDScript, Wald und Gruft, beide Questwege, Kampf/Telegraphing, Talente/Journal/Karte/Relikt, bestehende Inhalte und Balance. **Nicht eingeführt:** Autoload-Manager, globaler Eventbus, 3D-Abstraktion, Streaming oder neue Gameplay-Systeme. Die laufend gültigen Details haben einen Besitzer: [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md).

## 3. Wichtige Zustandsbesitzer

| Besitzer | Zustand und klare Grenze |
| --- | --- |
| RunState | Dauerhafter Fortschritt, Seed, Region, Tagesphase, XP/Talente, Lichter/Entdeckungen, besiegte IDs; koordiniert einmalige Belohnungen |
| DungeonProgress | Besuchte Räume, Erinnerungen/Funde, Tore und Bericht |
| SourceQuest | Untersuchung, Zeichenfolge, verbindlicher Ausgang, Hütersieg/Bericht/Erzflag |
| RelicInventory | Besitz und Ausrüstung des vorhandenen Relikts |
| Player/Vitals/MageAbilities | Laufende Position, Ressourcen, Schutzzeiten und Cooldowns; Position/Ressourcen fließen in den Save-Snapshot |
| RegionLifecycle / RegionInstance | Aktueller Baum, aktive Referenzen und transiente Generation; keine zweite Fortschrittswahrheit |
| Content | Gemeinsam geprüfte, rekursiv schreibgeschützte Definitionen; kein veränderlicher Weltzustand |
| SaveSystem / SaveFileIO | Schema, Validierung, Migration, verifizierte Dateioperationen; keine Quest- oder Kampfentscheidung |

## 4. Regionsarchitektur

M03 bleibt erhalten: deaktivieren und Generation ungültig machen, externe Referenzen lösen, alten Baum entfernen, einmal neu aufbauen, aktivieren und neu verbinden. Der Player wird weiterhin pro Region neu erzeugt. Persistente Regions-ID und transiente Generation sind getrennt; Load/neuer Run setzen den sitzungsgebundenen Zähler nicht zurück.

Alte Projektile/Effekte verlassen mit Combat die Region. Externe Deferred-/Timer-/Signalaktionen müssen ihre Herkunft mitführen und bei Lieferung prüfen. Die M03-Prüfungen für schnelle Rundreisen, genau einen Player, keine doppelten Gegner, SourceStory, Save/Load und alte Hüteraktionen bleiben vollständig im M04-Gate. Der neue Content-Guard kann ungültige Daten schon vor einem Aufbau abweisen. Es gibt weiterhin nur synchronen Aufbau, keinen Region-Cache und kein Streaming.

## 5. Datenarchitektur und konkrete M04-Änderungen

Die drei JSON-Dateien werden gemeinsam eingelesen und geprüft. Nur ein vollständig gültiges Bundle wird veröffentlicht; verschachtelte Arrays/Dictionarys sind anschließend schreibgeschützt. Syntax-/Schema-/Referenz-/Geometriefehler nennen Datei und Feld bzw. Parserzeile. Das Spiel zeigt einen eigenen Fehlerbildschirm und erzeugt keine Teilwelt. Auch Release-Builds sind ohne Assertions abgesichert.

Start-/Maximalwerte, Regeneration/Rast, Zauberkosten/Cooldowns, Talentboni, Frostsynergie, relevante Gegnerwerte, XP/Lichtstaub und zugehörige UI-Texte verwenden ihre maßgeblichen Definitionen. Beschreibungstokens erhalten Zahlen aus genau dieser Definition; ganzzahlige JSON-Zahlen erscheinen weiterhin als „6 Mana“, nicht „6.0 Mana“. Tatsächlich unbenutzte Kopien von Rastermetadaten und Questzielanzahl wurden entfernt. Stabile Generator-/Save-Verträge bleiben ausdrücklich in ihren bisherigen Besitzern.

**Keine Balanceänderung:** Alle zuvor vorhandenen numerischen JSON-Regeln bleiben gleich. Die nach JSON verlagerten Zahlen wurden mit ihren bisherigen Codewerten abgeglichen. `vault.json`, `discoveries.json`, Assets, Projektszene, Projekt-/Exportkonfiguration und eingefrorene Save-Fixtures sind unverändert. Neue Definitionen ersetzen bestehende Literale; sie führen keine neue Mechanik ein.

| Dateigruppe | Konkrete Änderung |
| --- | --- |
| `core/content.gd`, neu `core/content_validator.gd`, neu `dungeon/vault_content_validator.gd` | Einmaliges Bundle, schreibgeschützter Cache, reine Prüfung und Zahlenformatierung |
| `data/content.json` | Bestehende Zahlen zentralisiert, Texttokens; ungenutzte Duplikate entfernt |
| `actors/vitals.gd`, `player.gd`, `mage_abilities.gd`, `enemy.gd`, `source_guardian.gd` | Definitionen für Ressourcen, Fähigkeiten und bestehende Angriffe/Reaktionen |
| `combat/combat_system.gd`, `projectile.gd`, `thorn_patch.gd`, `source_impact.gd` | Gemeinsame Bonus-/Schadens-/Effektparameter; keine Neuschreibung des Kampfsystems |
| `core/run_state.gd`, `progression/source_quest.gd`, `source_story.gd` | Definitionen für Belohnungen/XP und zugehörige Texte; unveränderte Wiederholungssperren |
| `ui/hud_canvas.gd`, `game_ui.gd`, `game.gd` | Einheitliche Anzeigen, voller Ressourcenstand, Fehleransicht vor Spielstart |
| `core/discovery_book.gd`, `dungeon/dungeon_generator.gd`, `world/world_generator.gd`, `region_instance.gd`, `region_lifecycle.gd` | Gemeinsamer Datenzugriff/Guard, bestehende Geometriekonstanten, Startressourcen ohne zweite Zahl |
| `persistence/save_system.gd` | Ressourcenprüfung unabhängig von aktuellen Maxima, expliziter Übernahmehinweis; Dateitransaktion unverändert |
| Drei neue Testskripte, Startup-Runner, `tools/verify.py`, bestehende State-/Export-Tests | Fehlerfälle, geänderte Definitionen, echte Szenen und Release-Startschutz; alle alten Assertions erhalten |

Die vollständige Quellenmatrix und tatsächlich implementierten Validierungsregeln stehen ausschließlich ausführlich im [technischen Design](../TECHNICAL_DESIGN.md#inhaltsdaten-und-konsistenz--m04).

## 6. Save-Architektur

**Format 3 bleibt erhalten.** Generatorversionen, Feldstruktur und Migrationen 1→2→3 ändern sich nicht. Byteprüfung temporärer Dateien, gültige `.bak` und permanente `.pre-v03`/`.pre-v04` bleiben Bestandteil des bestehenden Schreibablaufs. Kein Save-Reset und keine still verworfenen Legacy-Daten.

Ein Save speichert absolute Ressourcen ohne damalige Maxima. Deshalb ist seine numerische Schutzgrenze nun eine stabile Serialisierungsgrenze, kein zweiter Balancewert. Ein älterer Stand oberhalb aktueller Maxima wird exakt übernommen und angezeigt. Regeneration/Boni/Rast erhalten diesen Überschuss; sie vergrößern ihn nicht. Verbrauch/Schaden kann ihn abbauen. Die sechs originalen Fixtures sind auch bei testweise reduzierten Maxima lesbar und bytegleich geblieben. Mehrfaches Save/Load und Recovery erhalten die Werte und den Hinweis.

Die aktuelle Auslieferung behält LP/MP/AU jeweils bei 100. Die neue Regel ist eine Kompatibilitätsabsicherung. Eine spätere XP-Kurven- oder ID-Änderung braucht weiterhin eine eigene Migrationsentscheidung. Alte Programme müssen neu erlaubte Ressourcenwerte nicht lesen können.

## 7. Verbleibende technische Schulden

- `game.gd` verbindet weiterhin konkrete Interaktionsarten, UI/Audio und Checkpoints. Die Verantwortung ist kleiner, aber noch keine allgemeine Interaktionsarchitektur.
- Gegner-, Raum-, Quellen- und Encounter-IDs sowie einzelne Koordinaten gehören zum festen Generator-1-Inhalt. Validierung macht diese Kopplung sichtbar; sie verwandelt sie nicht in einen universellen Editor.
- Saveprüfung kennt konkrete Fortschrittsmodelle und generiert bei Dungeonpositionen Gelände. Speicherung bleibt synchron, mit Grenzen für Datenmenge/Fortschritt und ohne Mehrprozess-Locking oder garantierte Stromausfall-Dauerhaftigkeit.
- RunState/Teilmodelle sind weiterhin öffentliche GDScript-Objekte. Laufzeitaufrufer halten die fachlichen Zuständigkeiten ein; nur Content ist technisch rekursiv schreibgeschützt.
- Combat und AI sind für die vorhandenen Rollen ausgelegt; noch kein allgemeines Stats-/Damage-/Status-Effect-Modell. Lebende Gegner und transiente Effekte werden bei Regionsaufbau zurückgesetzt.
- Native Windows-Dateifehlerfälle und der neue manuelle M04-Spieltest bleiben offen. Neue M04-Bildschirmaufnahmen waren wegen der nicht verfügbaren X11-Verbindung nicht möglich; alte Bilder werden nicht als M04-Nachweis ausgegeben.

## 8. Offene Architektur- und Designfragen

**PLANNED, keine Vorentscheidung:** stabile IDs für wesentlich mehr Inhalte und prozedurale Orte; Migrationen bei geänderten Generatoren/XP-Kurven; Grenzen zwischen Actor-Stats und Ausrüstung; kleine gemeinsame Treffer-/Interaktionsverträge; später abstrakte Simulation in inaktiven Regionen und eine dauerhafte Weltzeit. Ein Nachfolge-Milestone muss daraus genau einen prüfbaren Zusammenhang auswählen.

Die Creative Bible bleibt unverändert maßgeblich: Neugier/Freiheit, glaubwürdige Konsequenzen, optionale Tiefe, kombinierbare Systeme und prozedurale Variation, die Geschichten trägt. Konkrete Biome/Fraktionen, Magieschulen, Progressionskurven, Wirtschaft, Reise-/Quest-UI, Umweltinteraktionen und Endgame-Balance bleiben offen. Technische Grenzen dürfen diese Erfahrung nicht still abschwächen. Kein 3D- oder Streamingkonzept wird daraus vorgezogen.

## 9. Test- und Exportstatus

**TESTED: 707/707 Checks** — 504 bisherige plus 203 neue. Die Zahl zählt einzelne Assertions einschließlich parametrisierter Fälle, keine 707 Features.

| Nachweis | Ergebnis |
| --- | --- |
| Bestehende vollständige Regression | 504/504, mit allen originalen Save-Fixtures, beiden Quellenwegen, Kampf und M01–M03-Fehler-/Lebenszyklusfällen |
| Content-Negativtests | 88/88: Pflichtfelder, Typen, Zahlen/NaN/Infinity, Enums/IDs/Referenzen, Räume/Verbindungen/Spawns, Belohnungen, Discovery- und Texttokens |
| Datenkonsistenz/Szenen/Maximalwerte | 89/89: Definitionen gezielt geändert, tatsächliche Gameplay-/HUD-/Journal-/Dialogverbraucher geprüft, keine doppelten Boni/Belohnungen; Altstände und Überschuss-Recovery |
| Tatsächlicher Start mit Datenfehlern/Cache | 26/26 in vier getrennten Prozessen; sichtbare Diagnose, kein Run/Player/Teilbundle, vorhandene Savebytes erhalten, keine erneute Prüfung pro Frame |
| Zusätzlicher echter OS-Schreibfehler | Linux-Dateigrößenlimit erkannt; kein Ersatz für native Windows-Fehlerinjektion |
| Release-Exporte | Windows x86_64 und Linux x86_64 mit Godot 4.5.1; bisheriger Export-Smoke plus Datenprüfung bestanden |
| Release-Fehlerstarts | Dieselben 26 Startprüfungen zusätzlich gegen jedes kompilierte Pack; nicht nochmals zur 707-Summe addiert |
| Manuelle M04-Windows-Abnahme / neue Grafikaufnahme | **NOT TESTED** / grafische Testumgebung blockiert |

Die einmalige Bundle-Prüfung benötigt im protokollierten Headless-Lauf nur wenige Millisekunden. Das ist eine einzelne lokale Messung, keine Zielgeräte- oder Langzeitgarantie. Es gibt keine neue permanente Prüfung oder parallelen Regionsaufbau.

Im ersten Gesamtlauf erforderte ein bestehender Fehlertest eine isolierte Kopie des nun schreibgeschützten Content-Bundles; seine 100 Assertions bleiben erhalten. Der erste zusätzliche Release-Datentest fand den Text „6.0 Mana“. Nach dem kleinen Formatter-Fix prüfen vier neue Fälle Ganzzahl-/Bruchzahltexte; finaler Gesamtlauf und Exporte wurden erneut ausgeführt. Keine fehlgeschlagene Prüfung wird als bestanden gezählt.

Ein zwischenzeitlicher paralleler Gesamt-/Exportlauf meldete drei Fehler der Regionssuite. Die gezielten isolierten Nachläufe bestanden; die Ursache wurde nicht eindeutig reproduziert. Die Suite protokolliert nun Save-/Load-Fehler genauer. Der abschließende Gesamtlauf erfolgt seriell mit einem frischen Profil; die frühere fehlgeschlagene Ausgabe bleibt als Diagnosebeleg erhalten. Dies ist keine behauptete Behebung eines Spielfehlers.

Ausführung, Windows-Prüfliste und Nachweise: [TESTING.md](../TESTING.md), [Ergebnisse](../qa/m04_results.json), [Logs](../qa/m04_logs/), [Prüfsummen/Referenz](../qa/m04_reference_manifest.json).

## 10. Empfehlungen für die nächste Phase — PROPOSAL

1. Zuerst das M04-Paket unter Windows spielen und diesen Bericht gemeinsam prüfen. Erst dann den nächsten Milestone festlegen.
2. **PROPOSAL:** Eine kleine Interaktionsschnittstelle aus den vorhandenen Türen/Funden/Quellen ableiten: zuständiges System prüft den Request, bestätigt das Ergebnis, danach Darstellung und Speicherung. Keine neuen Inhalte dafür nötig.
3. **PROPOSAL:** Danach ein begrenztes Stats-/Treffer-Datenmodell an den bestehenden zwei Zaubern und Gegnern prüfen. Ausrüstung, Waffen und Statuswirkungen erst erweitern, wenn diese Schnittstellen belastbar sind.
4. **PROPOSAL:** Eine ausdrückliche Weltzeit-Verantwortung wäre anschließend ein kleiner Einstieg in Simulation; Wetter, NPC-Routinen und größere prozedurale Welt erst nach ihren eigenen Voraussetzungen und Abnahmen.

Diese Vorschläge sind keine bestätigten Designentscheidungen und kein Implementierungsauftrag. **Nach M04 wird gewartet.**
