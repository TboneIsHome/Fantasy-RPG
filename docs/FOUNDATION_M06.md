# LICHTERHAIN — M06 COMPLETION REPORT

Stand: 21.09.2026 · Quellstand 0.4.0 / Stats & Trefferauflösung M06 · Godot 4.5.1 · dauerhaft 2D-isometrisch.

**IMPLEMENTED**, automatisiert **TESTED**, insgesamt **PARTIALLY TESTED** bis zum eigenen manuellen Windows-Spieltest. **931/931 Checks**, beide Release-Exporte und ihre Pack-Prüfungen bestanden. Windows-Testpaket bereit. **STOP nach M06**; M07 ist nicht begonnen.

## 1. Auftrag, Ausgangslage und Abhängigkeiten

Verbindlich ist Tims [genehmigte Spezifikation V1.1](M06_STATS_HIT_RESOLUTION_V1_1.md), unverändert mit SHA-256 `bfb5d74b10fbe1bd87a2ee6bef942beceb557910c136db1498caad387a0e7dfb` übernommen. Die [Creative Bible](CREATIVE_DESIGN_BIBLE_V1.md) bleibt unverändert. Der neue Kern trennt wahrnehmbaren Kontakt, Health-Schaden und Impact, ohne neue Waffen, aktive Verteidigung oder Statusmechanik einzuführen.

Ausgangspunkt ist M05-Commit `3f3a2317dc056525d8d050f2632ceea4d727e767`. Vollständiger Git-Referenzstand, Exportkonfiguration und verfügbare Save-Fixtures wurden gesichert; die unveränderte Basis bestand vor Änderungen erneut **789/789** Checks. Persönliche Windows-Spielstände liegen nicht vor. Tims ausdrückliche M06-Freigabe erlaubt diese Iteration, behauptet aber keine zuvor nicht gemeldete manuelle M05-Abnahme.

Vorher übernahmen Player/Vitals und WildEnemy HP-Schaden/Rückstoß getrennt. CombatSystem koordinierte Bolt, Nova, Echo und Gegnerangriffe; Frostbonus lag an der Gegnerannahme. Kontaktidentität beruhte auf den jeweiligen Einzelabläufen (`struck`, `attack_connected`, Projektilfreigabe). M06 benötigt genau diese bestehenden Pfade, den geprüften Content und die M03-Regionidentität. RunState, SaveSystem, M05-Interaktionen und Questregeln brauchen keinen Umbau.

## 2. Architekturänderung und Zustandsbesitzer

Ein gemeinsamer reiner `HitResolver` berechnet Effective Damage und Effective Impact aus AttackProfile, CombatStats und einem bereits bestimmten DefenseOutcome. Player und NPC verwenden dieselbe Rechnung. Health gehört weiterhin Vitals bzw. dem Gegner; Hit-Detection, Eingaben, Schutzzeiten, Angriffsphasen und Effekte bleiben bei ihren bestehenden Systemen.

Eine kleine `HitInstance` ergänzt Herkunft und einmalige Lieferung je Ziel. Ihr Besitzer ist das bereits vorhandene regionale CombatSystem. Es gibt keinen neuen Node-Prozess, Manager, Autoload, Eventbus oder globalen Trefferkatalog. M06 liest keine Quest-/Savezustände und vergibt keine neuen Progressionspunkte.

Der tatsächliche API-Vertrag, Formeln, JSON-Regeln und Kompatibilitätsgrenzen haben einen eindeutigen Besitzer: [TECHNICAL_DESIGN.md, M06](../TECHNICAL_DESIGN.md#stats-und-trefferauflösung--m06). Dieser Bericht dokumentiert Umsetzung und Abnahme, keine zweite Architekturvorgabe.

## 3. Konkrete Dateien und migrierte Angriffe

| Dateien unter `scripts/`, sofern nicht anders angegeben | Änderung |
| --- | --- |
| `combat/attack_profile.gd`, `combat_stats.gd`, `defense_outcome.gd`, `hit_resolver.gd`, `hit_resolution.gd` | Kleine Daten-/Ergebnistypen und reine gemeinsame Rechnung |
| `combat/hit_instance.gd`, `combat_profiles.gd` | Regionale Kontaktquittierung und Adapter zu den vorhandenen Definitionen |
| `actors/player.gd`, `vitals.gd`, `enemy.gd`, `source_guardian.gd` | Gemeinsame Annahme, bestehende Health-Besitzer und kontrollierte Reaktionen; ortsfester Hüter bleibt erhalten |
| `combat/combat_system.gd`, `projectile.gd`, `source_impact.gd`, `thorn_patch.gd` | Bestehende Angriffe erfassen/liefern ihre HitInstance; jeweilige Fachfolgen bleiben beim Verbraucher |
| `data/content.json`, `core/content_validator.gd` | Neutrale Defense-Felder und offene Schadensartenschlüssel samt einmaliger Startvalidierung |
| `tests/hit_resolution_suite.gd`, `hit_scene_suite.gd` | Rechenkern, Content und reale Szenen-/Lebensdauerintegration |
| `tests/content_startup_probe.gd`, `export_smoke.gd`, `tools/verify.py`, `verify_content_startup.py` | Neue Fehlerstart-/Release-Prüfungen in bestehende Gates integriert |

Migriert sind **Lichtfunke, Frostkreis, Widerhall, Wolfslunge, Irrlicht-/Hütergeschosse, Quellenschlag und Dornenpulse**. Bolt addiert den bestehenden Frostbonus einmal vor der gemeinsamen Mitigation. Widerhall ist eine eigene Folgeinstanz; Nova darf mehrere Ziele jeweils einmal treffen. Jeder bisherige Dornenpuls ist ausdrücklich eine neue Instanz. Slow, Talentheilung, Mana-/Reliktrückgabe und VFX bleiben außerhalb des Resolvers.

Alle **96 vorher vorhandenen numerischen Inhaltswerte** sowie alle anderen bisherigen Blattwerte bleiben unverändert. Neue Protection/Stability sind 0, Resistance-Maps leer. So liefern die bestehenden Angriffe weiterhin ihre bisherigen Damage-/Impact-Werte. Kein neues Balancing oder endgültiger Elementarkatalog wurde beschlossen.

## 4. Region, Wiederholung und Persistenz

Die Instanz erfasst bei ihrer Entstehung Generation, Aktions-ID und Urheber-ID. Ihr Combat-Besitzer ist schwach referenziert; Zielquittungen enthalten nur numerische Instanz-IDs. Alte/entfernte/queued/freigegebene oder regionsfremde Ziele werden abgewiesen, auch nach Rückkehr zur gleichen dauerhaften Regions-ID. Bereits abgefeuerte Geschosse dürfen nach dem Tod ihres Urhebers innerhalb der aktuellen Region fertig fliegen.

Ein bestätigter Kontakt wird vor HP-Änderung und Signalcallbacks quittiert. Derselbe Treffer kann nicht über Wiederholung, Reentranz, später abgelaufenen Schadensschutz oder geänderte Defense erneut wirken. Auch Parry und Immunität quittieren den Kontakt. Miss/Evade erzeugen keine normale Wirkung und keine Quittung; bestehende Angriffe behalten zusätzlich ihre bisherige Verbrauchslogik.

RegionLifecycle/RegionInstance, RunState, SourceQuest, DungeonProgress, RelicInventory und SaveSystem bleiben unverändert. Saveformat **3** und absolute gespeicherte Ressourcen bleiben erhalten. Defense-Definitionen und transiente Treffer werden nicht gespeichert. Gefrorene Fixtures wurden weder neu erzeugt noch verändert.

## 5. Tests, Regression und Export

| Prüfung | Ergebnis / Status |
| --- | --- |
| Pristiner M05-Stand; danach Actor-/Vitals-Migration | Jeweils **789/789**, **TESTED** |
| Rechenkern und Content | **77/77**, **TESTED**; verbindliche Beispiele, getrennte Kanäle, Grenzen, Fehler und sekundäre Information |
| M06-Szenenintegration | **58/58**, **TESTED**; tatsächliche Angriffe/Boni, Player/NPC, Reentranz, Wiederholung, Defenses, alte Kontakte, Regionswechsel und Save/Load |
| Zusätzlicher Content-Fehlerstart | **7/7** neu, insgesamt 33/33 Startchecks; **TESTED** vor Weltaufbau/Dateischreiben |
| Abschließende vollständige Regression | **931/931**, 789 bisherige + 142 neue, **TESTED**; 23 serielle Runner-Stufen inklusive Import und zusätzlichem echtem Linux-Schreibfehler |
| Release-Exporte | Windows x86_64 und Linux x86_64, **TESTED** |
| Release-Laufzeit / Fehlerstart | Linux nativ und Windows-Pack unter Linux, je Smoke samt `EXPORT HIT RESOLUTION PASS` und fünf Startproben, **TESTED** |
| Windows-ZIP | PE-Architektur, ZIP-CRC, identische geprüfte EXE, **TESTED** |
| Native Windows-Ausführung / menschliche M06-Spielrunde | **NOT TESTED**; Paket und konkrete Prüfliste bereit |
| Neue Grafik-/Langzeit-/Performance-Abnahme | **NOT TESTED**; keine neuen Layouts/Assets oder Benchmarkbehauptung |

Die Zahlen zählen Assertions, keine Features oder Spielstunden. Nach der finalen Regression und den Exporten wurden nur Dokumentation/Nachweise ergänzt. Frühere Parse-/Testdiagnosen und der unterbrochene Zwischengang werden nicht als bestandene Gates ausgegeben. Details, Reproduktion und manuelle Prüfliste: [TESTING.md](../TESTING.md). Maschinenlesbare Nachweise: [Ergebnisse](../qa/m06_results.json), [Logs](../qa/m06_logs/), [Prüfsummen](../qa/m06_reference_manifest.json).

## 6. Verbleibende Risiken und bewusste Grenzen

- Native Windows-Dateioperationen, persönliche Spielstände und menschliches Kampfgefühl wurden hier nicht geprüft. Die manuelle Abnahme früherer Builds ersetzt diese M06-Runde nicht.
- `take_damage()` und isoliertes `Vitals.damage()` bleiben kompatible Diagnose-/Legacy-Einstiege: jeder Aufruf ist ein neuer Kontakt. Neue Live-Angriffe müssen ihre HitInstance wiederverwenden, um Doppellieferung zu verhindern.
- Öffentliche GDScript-Objekte sind keine manipulationssichere Transaktion. `HitResolution` ist ein Ergebnis, kein beliebig wiederholbarer HP-Befehl; keine allgemeine Nebenläufigkeits-/Rollback-/Netzwerksicherung.
- Impact wird aktuell in die vorhandenen Rückstoß-/Hitstop-Reaktionen übersetzt. Neue Stagger-/Poise-Regeln, aktive Block-/Parry-Fenster, Skill-XP, Equipment und Statussysteme sind nicht implementiert. Schadensimmunität entscheidet nicht über eine zukünftige Statusimmunität.
- Schadensartenschlüssel sind erweiterbar, endgültige Elementar-/Lorezuordnung und spätere Balance bleiben offen. Keine neue Stat-Flut oder globale Levelskalierung.
- Mehrstündige Belastbarkeit ist nicht aus der automatisierten Suite ableitbar. Der neue Kern fügt keine Frameprozesse oder globale Suche hinzu; eine neue Leistungsmessung liegt nicht vor.

## 7. Lieferung und Stop

Quellstand: `foundation/m06-stats-hit-resolution` in `TboneIsHome/Fantasy-RPG`; keine automatische Umstellung des Hauptbranches. Windows-Testpaket: **Lichterhain_0.4_M06_Windows.zip**. `START_HIER.txt` enthält Sicherungshinweise für den bisherigen Saveordner, Buildhash und M06-Prüfschritte. Die definitive Paket-/EXE-Prüfsumme steht im Referenzmanifest.

**Nächster Schritt:** Tim spielt dieses Paket unter Windows und wir prüfen die Ergebnisse samt diesem Bericht gemeinsam. M06 bleibt bis dahin **PARTIALLY TESTED**. **M07 wird erst nach einem eigenen genehmigten Design und einer neuen Freigabe begonnen.**
