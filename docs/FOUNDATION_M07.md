# M07 COMPLETION REPORT

**Abnahme-Nachtrag 2026-09-29:** Tim hat den manuellen M07-Windows-Spieltest ohne gefundene Fehler bestätigt. M07 ist abgeschlossen (MANUAL WINDOWS TESTED: PASSED, Nutzerangabe). Die folgenden ursprünglichen Prüfnachweise bleiben historisch unverändert.

**Lichterhain — Active Combat & Defense Foundation**
Stand: 28.09.2026 · Godot 4.5.1 · dauerhaft 2D-isometrisch
Grundlage: unveränderte [M07 V1.1](M07_ACTIVE_COMBAT_DEFENSE_V1_1.md), [Creative Bible](CREATIVE_DESIGN_BIBLE_V1.md), abgeschlossener M06-Stand `fa887982a023f4fcdb3d3ad933796c0d3ec54748`.

| Status | Ergebnis |
| --- | --- |
| IMPLEMENTED | Action Lifecycle, Kontaktvalidierung, Dodge/Block/Parry, explizite Hit-Phasen, kontrollierte Combat Reaction und bestehende Verbraucher |
| AUTOMATED TESTED | **1.070/1.070 Checks**, alle 25 Regressionstufen und sechs Release-Gates bestanden |
| MANUAL WINDOWS TESTED | **NOT TESTED für M07**; der vom Nutzer bestätigte M06-Test gilt für dessen vorherigen Build |
| Lieferung | Windows-Testpaket mit eigener Prüfliste; Quellstand, Dokumentation und Nachweise auf `foundation/m07-active-combat` |
| Nächster Schritt | Gemeinsame Reportprüfung und manueller M07-Windows-Test. **STOP vor M08.** |

## 1. Ausgangslage und Vorgehen

M06 besaß gemeinsame numerische Trefferauflösung, regionale HitInstance-Receipts und bestehende Actor-/Vitals-Besitzer. Die Kontakt- und Phasenprüfung lag verteilt bei Wolf, Projektil, Nova, Dornen und Hüter. M07 ergänzt diese Pfade um kleine gemeinsame lokale Verträge; es ersetzt weder die bestehende KI noch die Regionserzeugung.

Die ursprünglichen lokalen M07-Arbeiten wurden vor Abschluss durch automatische Workspace-Bereinigung entfernt. Der erneut erstellte Zwischenstand wurde anschließend auf GitHub gesichert und nach einer weiteren Bereinigung von dort wiederhergestellt. **Alle hier genannten Prüfungen wurden am 28.09. auf dem wiederhergestellten Stand erneut ausgeführt.** Frühere verlorene Testlogs/Exporte werden nicht als Nachweis verwendet. M06 und die Original-Fixtures blieben in Git erhalten.

Die Migration folgte den vorhandenen Abhängigkeiten: lokale Core-Verträge → Player/Enemy-Adapter → bestehende Attack-Verbraucher → reine und Szenentests → vollständige Regression → Release-Packs. Einige ältere Tests erzeugten künstlich nur einen KI-Mode ohne echte Attack Action; diese Setups starten jetzt die reguläre Action. Ihre bisherigen Assertions und erwarteten Gameplayzahlen bleiben erhalten.

## 2. Architektur und Zustandsbesitzer

- `ActionTimeline` modelliert Intent, Startup, Commit, Active, Recovery und Completed/Interrupted unabhängig von Animationen. Ein kostenloser Abbruch endet vor Commit; bestätigte Unterbrechungen sind ausdrücklich erlaubt.
- `AttackInstance` hält die Timeline, Herkunft, Generation, schwache Actor-/Payloadbezüge und M06-HitInstance je expliziter Phase. Der bestehende regionale `CombatSystem` erzeugt sie; es gibt keinen neuen globalen Besitzer.
- `ContactContext` erfasst Phase, schwaches Target und räumliche Daten. Aktuelle Entfernung, Richtung, Sicht, Actor-/Target-Lebensdauer und Region werden vor Kontakt geprüft.
- `CombatContact` liefert ein maßgebliches Outcome mit Ablehnungsgrund oder bestätigtem M06-Resultat. Kein Accuracy-Wurf, kein Defense Stacking.
- `ActiveDefense` und `CombatReaction` gehören dem jeweiligen Actor. Vitals bzw. Enemy behalten Health; MageAbilities behalten Ressourcen und Cooldowns. Movement setzt begrenzte Verschiebung um; vorhandene Präsentation zeigt Feedback.
- RunState, SourceQuest, DungeonProgress und RelicInventory behalten dauerhaften Fortschritt. RegionLifecycle bleibt der einzige Besitzer des Regionswechsels.

Der vollständige tatsächliche API-Vertrag und seine Grenzen stehen in [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md). Keine zusätzliche Architektur-Bibel, kein globaler Eventbus/Registry/Autoload und keine parallele Damage-/Impact-Rechnung.

## 3. M07 / M06-Grenze

M07 prüft Action-Fenster und Geometrie, dann Defense. **Miss/Evade übergibt im Live-Pfad keinen Kontakt an M06.** Für Hit/Block/Parry wird die bestehende Actor-Methode `receive_hit` aufgerufen. Die unveränderte HitInstance beansprucht das Ziel vor Signalen; der unveränderte HitResolver berechnet Damage und Effective Impact einschließlich Protection, Resistance und Stability.

M07 interpretiert anschließend den bereits geminderten Impact als Normal/Interrupt/Stagger. Stability wird nicht nochmals berechnet. Block übergibt ausschließlich vorhandene DefenseOutcome-Skalierungsfelder. Parry hat keine Crit-Formel und keinen automatischen Gegenangriff.

## 4. Reale Verbraucher und Bedienung

| Verbraucher | Migration |
| --- | --- |
| Player-Lichtfunke, Frostbonus, Widerhall | Caster-Action und ausdrücklich freigegebenes Projektil; einmalige bestätigte Haupt-/Kettenkontakte |
| Frostkreis | Eine Action, getrennte Zielvalidierung, unveränderte Verlangsamung/Heilung und einmalige Reliktrückgabe |
| Wolf | Bestehender Windup, festgelegte Lungenrichtung, Active-Kontakt, Ende der Bewegung bei Recovery |
| Irrlicht / Hüterfächer | Bestehender Release und eigene Payload-Lebensdauer; gleiche M06-Auflösung |
| Hüterschlag | Bestehende Flächengeometrie und ortsfester Actor; keine Boss-Neuentwicklung |
| Dornenfeld | Vorhandene Intervalle als ausdrücklich neue Hit-Phasen; keine Frame-Treffer durch Dauerüberlappung |

**F halten:** frontaler Block mit reduzierter Mobilität und verbleibender Wirkung. **Q:** kurze Parade mit exponierter Recovery. **Leertaste:** bestehender Dodge mit Bewegung, Kosten und kurzem Schutzfenster. Die bisherigen Angriffs-/Quest-/Reliktzahlen bleiben unverändert. Neue Defense-/Reaction-Werte sind geprüfte, vorläufige JSON-Definitionen gemäß M07 §28, keine endgültige Waffenbalance.

## 5. Lebensdauer und Persistenz

Eine freigegebene Payload darf ihren Caster innerhalb der aktiven Region überleben. Alte Payloads dürfen keine spätere Caster-Action unterbrechen. Ein Regionswechsel deaktiviert den vorhandenen Scope; erfasste Generation und schwache Referenzen verhindern weitere Kontakte, auch vor der verzögerten Freigabe des alten Baums. Reale Timer, alte Projektile, schneller Hin-/Rückwechsel und Load/Unload wurden geprüft.

Saveformat **3** und dessen Datenstruktur bleiben identisch. M07-Zustände, Defensefenster, Reaktionen und Receipts sind transient. Save während Action/Parry und anschließendes Laden wurden getestet; die Legacy-Fixtures 0.1/0.2/0.3/0.4 sowie bestehende Migrations-/Backup-/Fehlerfälle bleiben grün.

## 6. Konkrete Dateien

| Gruppe | Dateien |
| --- | --- |
| Neuer lokaler Core | `scripts/combat/action_timeline.gd`, `attack_instance.gd`, `contact_context.gd`, `combat_contact.gd`, `active_defense.gd`, `combat_reaction.gd`, `action_profiles.gd` und Godot-UIDs |
| Bestehende Verbraucher | `scripts/actors/player.gd`, `enemy.gd`, `source_guardian.gd`; `scripts/combat/combat_system.gd`, `projectile.gd`, `source_impact.gd`, `thorn_patch.gd` |
| Definitionen / Eingabe | `data/content.json`, `scripts/core/content_validator.gd`, `input_setup.gd` |
| Tests / Gates | Zwei `active_combat*_suite.gd`, angepasste Fixture-Setups in `test_suite.gd`, `hit_scene_suite.gd`, `data_consistency_suite.gd`; `content_startup_probe.gd`, `export_smoke.gd`; `tools/verify.py`, `verify_content_startup.py`, neuer reproduzierbarer `verify_exports.py` |
| Dokumentation | `TECHNICAL_DESIGN.md`, `TESTING.md`, `ROADMAP.md`, `README.md`, `TASKS.md`, `DECISIONS.md`, `CHANGELOG.md`, `AGENTS.md`, dieser Bericht, unveränderte Spezifikation und historische Statusnachträge |
| Nachweise | `qa/m07_results.json`, `qa/m07_reference_manifest.json`, `qa/m07_logs/` |

**Unverändert gegen M06 geprüft:** 25 geschützte Dateien einschließlich aller sieben M06-Vertrags-/Profilskripte, SaveSystem/SaveFileIO, RunState, RegionLifecycle/RegionInstance, game.gd, Export-/Projektkonfiguration und eingefrorener Fixtures. Quest-/Inventar-/Interaktionsbesitzer, Assets und Layout erhalten keine Änderungen. Alle **137** bisherigen Content-Blattwerte, darunter **106 Zahlen**, bleiben erhalten.

## 7. Tests und Exporte

| Nachweis | Ergebnis |
| --- | --- |
| M00–M06-Regression | Alle bisherigen **931** Checks bestanden |
| Neuer M07-Core | **65/65**: Zustände, deterministische Defense, M06-Impact, Guard, Fenster-/Contentfehler |
| Neue M07-Szenen | **67/67**: reale Eingabe/Actors, Kontakt, Phasen, AoE, Reentranz, Payload, Reaktion, Generation, Save/Load |
| Neuer M07-Fehlerstart | **7/7**; alle Startproben zusammen **40/40** |
| Gesamt | **1.070/1.070**, **25/25** Stufen; echter Linux-Schreibfehler zusätzlich bestanden |
| Release | **6/6** Stufen: Windows-/Linux-Export, beide Pack-Smokes, beide Fehlerstart-Gates |
| Windows-Paket | PE x86_64, ZIP-CRC und enthaltene EXE gegen geprüften Export per SHA256 kontrolliert |

Die Windows-Packprüfung läuft mit Godot unter Linux. Das ist **keine native Windows-Ausführung**. Rohprotokolle, ausführbare Reproduktionsbefehle und die vollständige manuelle Prüfliste stehen in [TESTING.md](../TESTING.md). Geprüfte Code-/Test-/Binärhashes: [Referenzmanifest](../qa/m07_reference_manifest.json).

## 8. Verbleibende Risiken und Grenzen

- **NOT TESTED:** manueller M07-Windows-Spieltest, visuelle Abnahme, neue Langzeit-/Performance-Messung, Controller, native Windows-Dateifehlerinjektion. Keine fremde Abnahme wird übernommen.
- Parrygefühl, Blockmobilität und neue Reaktionsschwellen benötigen menschliche Rückmeldung. Vorläufige Werte sind Content, keine zusätzliche Stat-Struktur.
- Die heutigen Angriffe haben überwiegend Impact unter Interrupt/Stagger. Stärkere Reaktionen sind an realen Actors automatisiert geprüft; M07 fügt keinen schweren Demo-Content nur für diesen Test hinzu.
- Keine Defense-Entscheidungs-KI für NPCs, komplexen Waffenformen, Combos, Status- oder Bossmechaniken. Dafür sind nur die notwendigen lokalen Anschlüsse vorhanden.
- Diagnose-/Legacy-Einstiege bleiben ausdrücklich neue Einzelkontakte/-Releases. Live-Angriffe dürfen sie nicht als zweite Ausführung benutzen. Kein Netzwerk-, Thread-, Anticheat- oder allgemeiner Signal-Rollback-Vertrag.
- Bisherige technische Schulden außerhalb dieses Milestones bleiben bestehen; insbesondere Session-/Präsentationsumfang und spätere Geometrie-/Animationserweiterungen. Kein vorgezogener Rewrite.

**STOP:** M07 ist automatisiert geprüft und als Windows-Testpaket bereit. Die menschliche Windows-Abnahme und gemeinsame Reportprüfung bleiben offen. M08 wurde nicht begonnen.
