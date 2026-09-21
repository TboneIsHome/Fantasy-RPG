# LICHTERHAIN — M03 COMPLETION REPORT

Stand: 16.09.2026 · Basis: M02 `da04ab81cdb5fc4ea1b17254aeccd96a8742bbd9` · Godot 4.5.1.stable.official.f62fdbde1.

**IMPLEMENTED / PARTIALLY TESTED.** Implementierung, automatische Regression, Vergleichsmessung und Exportprüfungen sind abgeschlossen. Für die vollständige M03-Abnahme fehlt der manuelle Windows-Spieltest des neuen Pakets. **Stop: M04 ist nicht begonnen.**

**Nachtrag 20.09.2026 — TESTED laut Nutzerbericht:** Tim bestätigt im M04-Auftrag ausdrücklich, dass M03 abgeschlossen und manuell unter Windows bestätigt ist. Die damalige Abnahmelücke ist damit geschlossen; Windows-Unterversion, einzelne Prüfschritte und Buildhash wurden nicht separat genannt. Der nachfolgende Bericht und seine QA-Dateien bleiben historische Nachweise vom 16.09.2026. M04 ist durch den neuen Auftrag autorisiert.

## 1. Ausgangslage

Der lokale saubere M02-Stand entsprach GitHub `main`. Tim hat M02 ausdrücklich durch einen zusätzlichen erfolgreichen manuellen Windows-Spieltest bestätigt. Der vollständige Ausgangsstand bleibt über den Commit und ein vor Änderungen erzeugtes Referenzarchiv erhalten; originale Releases, eingefrorene Savegames und bisherige QA-Nachweise wurden nicht überschrieben.

M02 hatte genau einen aktiven Weltbaum, Wald/Gruft, RunState und einen neu erzeugten Player bei jedem Wechsel. `game.gd` vermischte dessen Aufbau, Reiseprüfung, Referenzanbindung und UI/Speicherpunkte. SourceStory lebte außerhalb dieses Baums. Sein verzögerter Hüterabschluss verglich RunState und `region == "vault"`, konnte aber zwei nacheinander geladene Gruftinstanzen nicht unterscheiden.

**Tatsächlich reproduziert:** Ein echter Hütertod stellt seinen Deferred-Abschluss in die Warteschlange; unmittelbar danach reist derselbe Run Gruft → Wald → Gruft. Auf M02 löst der alte Abschluss die neue Gruft, vergibt das Relikt/XP und entfernt deren neuen Hüter. Der identische Test bestand vorher **1/4**, nach dem Fix **4/4**. [Vorher](../qa/m03_logs/region_replay_reproduction_baseline.txt) · [Nachher](../qa/m03_logs/region_replay_reproduction.txt). Dies ist eine gezielt hergestellte Reihenfolge, kein behaupteter Bericht über einen im normalen Windows-Spiel beobachteten Fehler.

## 2. Architekturänderung

Ein normaler, sitzungsgebundener **RegionLifecycle** besitzt genau eine **RegionInstance** als 2D-Baum. Er koordiniert Build, Aktivierung, Deaktivierung, Unload, Travel und die aktuelle Identität. RegionInstance enthält den bisherigen Zusammenbau. Generatoren, Views, Actors, Vitals, Navigation, Kampfmechaniken und Story-Regeln bleiben bei ihren vorhandenen Besitzern.

`game.gd` behält Sitzung/RunState, UI/Audio, Interaktionen und explizite Save-Checkpoints. Seine bisherigen Zugriffe auf Welt/Player/Terrain/Combat sind lesende Sichten auf die aktuelle Instanz. SourceStory bleibt außerhalb des Regionsbaums; seine regionalen Referenzen werden ausdrücklich gelöst und neu verbunden. Ein Player wird weiterhin bei jedem Neuaufbau ersetzt.

Die bindende Richtung ist dauerhaft **2D-isometrisch**. M03 enthält keine 3D-Vorbereitung, kein Streaming, keine Autoloads und keinen globalen Eventbus. Die tatsächliche Verantwortung und Ablaufreihenfolge stehen zentral in [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md#regionslebenszyklus--m03).

## 3. Konkrete Dateien

| Datei | Änderung |
| --- | --- |
| `scripts/world/region_lifecycle.gd` | Neuer kleiner Besitzer: eine aktive Instanz, Generation, geordneter Austausch, Reiseprüfung/Vitals, Camp-Rückkehr, Reentranzschutz |
| `scripts/world/region_instance.gd` | Aus game.gd verlagerter 2D-Aufbau und Abschalten des regionalen Players/Combat; vorhandene Generatoren und Daten erhalten |
| `scripts/game.gd` | Delegiert Wechsel/Neuaufbau; löst und verbindet Session-Referenzen; gespeicherte Meldungen bleiben bei Reisesavefehlern sichtbar |
| `scripts/progression/source_story.gd` | Expliziter Referenzabbau und Herkunftsprüfung für Hütertod/-rückzug und Deferred-Abschluss |
| `scripts/combat/combat_system.gd` | Kleine Deaktivierungsgrenze: alte Treffer-/Belohnungs-/Effektaufrufe ablehnen und Run/Player-Referenzen lösen; keine Mechanikumschreibung |
| `scripts/ui/game_ui.gd` | Bereits entfernte Dialog-/Titelbuttons senden keine verspäteten Requests mehr; kein neues UI/Layout |
| `tests/region_replay_reproduction.gd`, `tests/region_lifecycle_suite.gd` | Reproduktion und neue Lebenszyklus-/Szenenprüfungen |
| `tests/measure_region_lifecycle.gd` | Identische begrenzte Messung für M02 und M03 |
| `tests/export_smoke.gd`, `tests/capture_source.gd`, `tools/verify.py` | Release-Prüfung erweitert, bestehender Capture-Aufruf an erforderliche Herkunft angepasst, zwei Tests ins Gate aufgenommen |
| Projektdokumente und `qa/m03_*` | Aktuelle Architektur/Abnahme, dieser historische Änderungsbericht und überprüfbare Logs/Hashes |

**Unverändert:** RunState-Fachaktionen, SaveSystem/SaveFileIO, Schema 3, Generatoren/Versionen, JSON-Inhalte, Assets, Projektszene, Exportkonfiguration und sechs eingefrorene Save-Fixtures. Der M02-Bericht erhielt lediglich einen klar getrennten Nachtrag zu Tims späterer manueller Abnahme.

## 4. Region-Generation-Konzept

`RunState.region` bleibt die dauerhafte Identität (`forest`/`vault`). Jeder neue Baum erhält zusätzlich eine fortlaufende `generation`. Diese wird weder gespeichert noch bei Load oder neuem Run innerhalb derselben Sitzung zurückgesetzt. Sie gilt nur zusammen mit ihrem sitzungsgebundenen RegionLifecycle, nicht weltweit zwischen Spielprozessen.

Beim Deaktivieren wird die alte Instanz sofort ungültig. Nach Unload gibt es keine gültige aktuelle Generation. Die nächste Instanz erhält eine andere Zahl, selbst wenn sie wieder dieselbe Gruft darstellt. Verschachtelte Reise-/Sitzungsaufbauten während des Wechsels werden abgewiesen. Es gibt keinen zweiten Besitzer dauerhaften Fortschritts.

## 5. Umgang mit verzögerten Aktionen

- Hütersignale binden ursprünglichen RunState und Generation schon bei ihrer Verbindung. Der Deferred-Abschluss prüft beides erneut bei Ausführung. Er wird auch nach einer schnellen Rückkehr in dieselbe Region verworfen.
- SourceStory-, HUD-, Interaktions- und Player-/Audio-Verbindungen werden vor Entfernung gelöst. Bereits erfasste Player-Tod-/Audio-/Hüterrückzug-Callbacks prüfen dennoch ihre Herkunft.
- Alte Combat-Systeme nehmen keine weiteren Kampfaktionen an. Projektile, Dornen und Einschläge bleiben ihre Kinder und verlassen mit ihnen den Baum; ihre Mechaniken bleiben unverändert.
- Alte Weltobjekte können keine Interaktion in der neuen Region auslösen. Entfernte Dialogpanels können keine Buttonrequests mehr senden.
- Ein SceneTreeTimer außerhalb der Region wird nicht automatisch durch `queue_free()` beendet. Der neue Test bindet ausdrücklich die alte Generation und bestätigt deren Verwerfung. Künftige solche Aktionen müssen dieselbe Herkunftsregel einhalten.

Die alte Region wird vor Neubau aus Szenenbaum, Gruppen und Physikwelt entfernt. Die eigentliche Speicherfreigabe erfolgt wie bisher am Frame-Ende. Bei vielen Wechseln ohne Zwischenframe können mehrere bereits abgetrennte, inaktive Bäume auf Freigabe warten; es existiert trotzdem höchstens eine aktive Region.

## 6. Tests

| Anforderung | Nachweis / Status |
| --- | --- |
| A/B: Wald → Gruft und zurück | **TESTED**; Identität, Vitals, Ankunftsschutz, Wald-Rückkehrpunkt, Kamera/Referenzen |
| C: Schneller Hin-/Rückwechsel | **TESTED**; zwölf unmittelbare Wechsel, exakt zwölf Player-/View-/Combat-Aufbauten, gültige Gruppen/IDs |
| D: Alte verzögerte Aktion | **TESTED**; reproduzierter Hüter-Deferred-Fehler, Timer, bereits erfasste Signal-/UI-Callbacks, auch nach Load/neuem Run |
| E: Gegnerprojektile beim Wechsel | **TESTED**; echte Projektil-/Impact-/Dornenobjekte beim Wechsel, direkte späte Trefferlieferung an neuen Player abgewehrt, alte Objekte freigegeben |
| F/G: Ein Player, keine doppelten Gegner | **TESTED**; Gruppen, erwartete Enemy-IDs, Zielreferenzen und Abstammung im aktuellen Baum |
| H: SourceStory-Referenzen | **TESTED**; Guardian/Site/Grove/HUD und Raumgrenzen im Wald geleert, in Gruft neu verbunden, alte Instanzen freigegeben |
| I: Save/Load nach Wechsel | **TESTED**; Region/Fortschritt/Relikt/Gegnerzustand, unverändertes Format, Fehlerpfad und F5-Retry; keine gespeicherte Generation |
| Zusätzliche Lebenszyklusgrenzen | **TESTED**; gesperrtes/ungültiges Ziel, toter Player, gleicher Ort ohne Neubau, Reentranz, Dungeon-Tod/Camp, wiederholtes Unload |
| Aktuelle gültige Aktionen | **TESTED**; echter Hütertod in der aktuellen Generation vergibt weiterhin seine eine Belohnung |

Neue Prüfungen: **99/99** (Reproduktion 4, Szenensuite 95). Die 95 enthalten wiederholte Invarianten über mehrere Wechsel, keine 95 unterschiedlichen Features. Ausführung und manuelle Prüfliste: [TESTING.md](../TESTING.md).

## 7. Regression und begrenzte Performance-Messung

Die vollständige Regression besteht mit **504/504 Checks**: alle bisherigen **405/405** plus **99/99** neue. Zusätzlich bestanden: echter Linux-Schreibfehler mit Dateigrößenlimit; bestehende Migrationen mit originalen Fixtures; beide Questwege und echter Hüterkampf mit normalen Zaubern. Keine bestehenden Assertions entfernt. [Ergebnisse](../qa/m03_results.json) · [Logs](../qa/m03_logs/) · [Prüfsummen](../qa/m03_reference_manifest.json).

Identischer Headless-Messlauf auf M02/M03: 14 Wechsel einschließlich Save-Checkpoint; zwei Aufwärmwechsel, danach sechs Rundreisen. Jeweils **14 Player, 14 Views und 14 CombatSysteme**. Immer ein aktiver Player; nach Frame-Abbau konstante Objektzahlen je Region.

| Messgröße | M02 | M03 |
| --- | --- | --- |
| Wald: Nodes | 4.555 | 4.556 |
| Gruft: Nodes | 364 | 365 |
| Wald: Godot-Objekte | 8.765 | 8.768 |
| Gruft: Godot-Objekte | 2.286 | 2.289 |
| Waldreise: Median / Bereich | 770,2 ms / 722,2–806,9 ms | 770,5 ms / 730,2–830,0 ms |
| Gruftreise: Median / Bereich | 68,0 ms / 64,6–80,8 ms | 74,5 ms / 70,9–77,8 ms |

Der zusätzliche Node ist der sitzungsgebundene Besitzer; keine unnötigen Doppelaufbauten oder anwachsenden Objektzahlen im Messumfang. Die sechs Timing-Stichproben pro Richtung zeigen keine allgemeine Performance-Garantie; insbesondere liegt der gemessene Gruftmedian etwas höher. Es wurden weder Zielgeräte-FPS noch stundenlange Stabilität oder Streaming gemessen. [Vollständige Rohmessungen](../qa/m03_region_measurements.json).

## 8. Exportstatus

**TESTED:** Windows-x86_64- und Linux-x86_64-Release mit offiziellen Godot-4.5.1-Vorlagen. Linux-Export nativ gestartet; eingebettetes Windows-Pack mit der Linux-Engine geprüft. Beide melden erfolgreich: Region Lifecycle, State Replay, Save Recovery, Save Error und vollständiger Export Smoke. Der Inhalt des Windows-Archivs entspricht der geprüften EXE; ZIP-CRC, PE-Architektur und SHA-256 sind dokumentiert.

Der erste Exportversuch hatte im neuen Testprofil keinen Vorlagenpfad. Nach Verknüpfung der bereits vorhandenen identischen Vorlagen bestanden die Exporte, ohne Runtime-Änderung. Neue grafische Spielaufnahmen sind **NOT TESTED**: Der lokale X11-Server konnte keine Sockets öffnen. Alte M02-Aufnahmen werden nicht als M03-Nachweis ausgegeben.

Testpaket: **Lichterhain_0.4_M03_Windows.zip**, mit `START_HIER.txt`, EXE und bestehenden Lizenzen. Vor Verwendung den vorhandenen Windows-Spielstandordner separat sichern. **Native Windows-Ausführung und manueller M03-Spieltest: NOT TESTED.** Tims erfolgreiche M02-Abnahme bleibt eine eigene Referenz.

## 9. Verbleibende Risiken und Stop

- Manuelle M03-Windows-Abnahme steht aus; bis dahin **PARTIALLY TESTED**, kein vollständig abgenommener Meilenstein.
- Die begrenzte automatische Messung ersetzt keine lange Spielrunde, Zielgeräte-Leistungsmessung oder native Windows-Dateifehlerprüfung.
- Künftige Timer/Callbacks außerhalb eines Regionsbaums müssen die Herkunftsprüfung ausdrücklich verwenden. Es gibt keine globale automatische Absicherung beliebigen zukünftigen Codes.
- Aufbau bleibt synchron und kann die bisherigen Ladepausen verursachen. Kein Streaming, Hintergrundaufbau, Region-Cache oder dauerhafter Player wird behauptet.
- Ein fehlgeschlagener Reisesave lässt die neue Region im Arbeitsspeicher aktiv und schützt den vorigen Datenträgerstand. Die sichtbare Meldung und erneutes Speichern sind geprüft; das ist kein Zurückrollen der Reise.
- Öffentliche GDScript-Zustände bleiben wie bisher technisch beschreibbar. Die vorhandenen Laufzeitaufrufer halten die dokumentierten Besitzer ein; keine vollständige Objektimmutabilität.

**M04 bleibt PLANNED. Keine weiteren Gameplay-Systeme oder Inhalte begonnen.**
