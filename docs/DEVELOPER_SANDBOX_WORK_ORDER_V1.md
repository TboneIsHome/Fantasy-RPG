# Lichterhain Developer Sandbox Foundation Work Order V1.0

Textauszug des unveränderten DOCX (Absätze und Tabellenzellen in Lesereihenfolge).
Original SHA-256: `39993246bb712cfe188d294660a981df46d84bccc3b0f6e0ab5925e798c5739d`.

LICHTERHAIN
Developer Sandbox Foundation
Concrete Work Order V1.0
Status: PROPOSAL / implementation-ready after reviewOwner: Astra Master Chat / Technical DirectorScope: developer-only testing infrastructure, primarily for Combat FoundationPrerequisite: M07 completed and accepted; Future Systems & Foundation Compatibility Blueprint V1.0 supplied to Astra
“Die Sandbox ist ein Labor, nicht die eigentliche Spielwelt.”
Lichterhain – Foundation → Sandbox → M08 → M09 → M10

1. Zweck und strategische Rolle
Die Developer Sandbox Foundation soll eine kontrollierte, reproduzierbare und erweiterbare Testumgebung schaffen, in der die bestehenden echten Gameplay-Pfade von Lichterhain gezielt untersucht, getestet und später getunt werden können. Sie ist Entwicklungs- und QA-Infrastruktur, kein neues Spielerfeature und keine zweite Spielwelt.
Der Schwerpunkt liegt zunächst auf dem Active Combat & Defense Foundation aus M07. Die Sandbox muss insbesondere Angriffslifecycle, Kontakt, Dodge, Block, Parry, Impact, Reaktionen, Projektile und unterschiedliche Actor-/Build-Konstellationen kontrolliert sichtbar und wiederholbar machen. Sie soll gleichzeitig so gebaut sein, dass M08 Weapons, M09 Magic und M10 Status Effects später ohne Sandbox-Neubau darin getestet werden können.
2. Verbindliche Ausgangslage
Bereich
Verbindlicher Stand
Foundation
M00–M06 abgeschlossen; M06 liefert gemeinsame Hit Resolution; Saveformat 3 unverändert.
M07
ActionTimeline, AttackInstance, ContactContext, CombatContact, ActiveDefense und CombatReaction; keine Accuracy-RNG; M06/M07-Grenze bleibt bestehen.
Architektur
RegionLifecycle besitzt den Regionenwechsel; CombatSystem bleibt regionaler Besitzer der AttackInstances; kein globaler Eventbus/Registry/Autoload.
Vision
Combat soll reaktiv, dynamisch, glaubwürdig und physisch nachvollziehbar sein; Physik nur mit spielerischem Mehrwert.
Zukunft
Blueprint V1.0 definiert Kompatibilitätsleitplanken für Umweltreaktionen, Weltzustand, Persistenz und Presentation Decoupling.
3. Harte Architekturregeln
Die Sandbox darf keinen eigenen Combat-Kern parallel zum echten Spielpfad erzeugen. Tests müssen nach Möglichkeit den tatsächlich verwendeten M07/M06-Pfad ausführen.
Keine globale Sandbox-Autoload, kein globaler Eventbus und kein globaler Test-Manager.
Sandbox-Logik bleibt lokal zur Sandbox-Szene bzw. zu klar zugeordneten Test-Fixtures.
Keine zweite Damage-/Impact-Rechnung, keine zweite Hit-Resolution und keine Sandbox-only Defense-Logik, die vom echten System abweicht.
Developer-Steuerung darf vorhandene Zustände gezielt setzen, muss dies aber explizit und diagnostizierbar tun.
Production Savegames dürfen durch Sandbox-Nutzung nicht verändert oder mit Sandbox-Zuständen vermischt werden.
Keine vorgezogene Environment-Reaction-, NPC-, World-Simulation-, Status- oder Weapon-Komplexität nur damit die Sandbox “vollständig” wirkt.
Keine Änderungen an M07-Verträgen ohne separaten Review. Sandbox-Bedarf allein ist kein Grund, M07 zurückzubauen.
4. Zielbild der Sandbox
Die erste Version soll als kleine, technische Testarena aufgebaut sein. Das Zielbild ist bewusst modular:
Combat Sandbox: zentrale Arena für Player, Dummies und kontrollierbare Gegner.
Encounter Control: definierte Gegner-Presets, Spawn, Reset und wiederholbare Waves.
Actor / Build Control: Auswahl bzw. Konfiguration von Player- und Enemy-Testprofilen.
Attack / Defense Control: Auswahl vorhandener Aktionen und kontrollierte Testbedingungen.
Diagnostics: sichtbare Phasen, Kontaktresultat, DefenseResult, Effective Damage/Impact, Reaction und relevante IDs.
Scenario Runner: feste Testszenarien, die reproduzierbar wiederholt werden können.
Future Hooks: vorbereitete Anschlusspunkte für Weapons, Magic und Status Effects, ohne diese Systeme vorwegzunehmen.
5. Funktionaler Mindestumfang V1.0
5.1 Arena und Reset
Eine klar abgegrenzte Entwickler-Arena ohne Abhängigkeit von der normalen Questwelt.
Schneller vollständiger Reset: Actors, HP, Ressourcen, Cooldowns, Positionen, laufende Payloads und Wave-Zustand werden auf den gewählten Startzustand zurückgesetzt.
Reset darf keine persistenten Save-Daten verändern.
Deterministischer Ausgangszustand pro Szenario.
5.2 Actor Presets
Mindestens Player-Testprofile für Nahkampf, Fernkampf und Magie-orientierten Aufbau, soweit die bestehenden Systeme dies bereits unterstützen.
Mehrere Enemy-Presets mit definierbaren Health-/Combat-Werten und klar erkennbaren Defense-/Reaction-Eigenschaften.
Presets sind Testdaten, keine endgültige Balance und keine neuen Live-Spielklassen.
5.3 Attack Control
Auswahl vorhandener live angebundener Angriffe/Abilities, soweit sie den M07-Pfad verwenden.
Kontrollierbare Distanz, Richtung/Facing und Position.
Möglichkeit, einzelne Attacken wiederholt gegen dasselbe Ziel zu testen.
Möglichkeit, bestimmte Angriffsarten in kontrollierten Waves zu kombinieren, ohne dafür neue Combat-Regeln einzubauen.
5.4 Defense Control
Gezieltes Testen von Dodge, Block und Parry gegen unterstützte Angriffstypen.
Insbesondere Timing-Tests für Parry: zu früh, korrekt, zu spät.
Block-Tests mit reduzierter Mobilität und verbleibender Wirkung sichtbar machen.
Dodge-Tests mit Richtungswahl und Schutzfenster.
Mage-orientierte Defense-Szenarien ausdrücklich vorsehen, damit das von Hand noch nicht ausreichend geprüfte Verhalten kontrolliert untersucht werden kann.
5.5 Waves / Encounter Control
Manueller Spawn einzelner Gegner.
Definierte Wave-Folgen mit steigender Stärke.
Start / Stop / Reset.
Optionaler Pausenmodus bzw. kontrollierbares Tempo für Diagnosezwecke.
Keine “Endlos-Simulation” als Selbstzweck; Testreproduzierbarkeit ist wichtiger als maximale Menge.
5.6 Diagnostics
Aktuelle Action Phase (Intent/Startup/Commit/Active/Recovery/Completed/Interrupted).
Kontakt: bestätigt oder abgelehnt, inklusive relevantem Ablehnungsgrund.
Defense: None / Dodge / Block / Parry sowie Ergebnis.
M06 Resultat: Effective Damage und Effective Impact, soweit bereits vorhanden.
Reaction: Normal / Interrupt / Stagger bzw. der tatsächlich vom System verwendete Zustand.
AttackInstance-/Generation-/Target-Bezug für reproduzierbare Fehleranalyse.
Keine Debuganzeige, die das eigentliche Spieler-UI verändert oder Production Content voraussetzt.
6. Test-Szenarien, die V1.0 ausdrücklich ermöglichen muss
ID
Szenario
Erwartbares Testziel
Primärer Prüfbereich
A01
Basic Contact
Angriff startet, aktive Phase wird erreicht, Kontakt trifft korrekt oder wird korrekt abgelehnt.
Timeline + Contact
A02
Range / Facing
Gleicher Angriff bei gültiger/ungültiger Distanz und Ausrichtung.
Geometry
A03
Dodge Timing
Dodge vor, während und nach Active Window; Richtungsänderung prüfen.
Defense + Position
A04
Block
Front block vs. Angriff; Mobilität, Schaden und Impact prüfen.
DefenseOutcome + Reaction
A05
Parry Timing
Parry zu früh / korrekt / zu spät.
Defense timing
A06
Mage Defense
Magie-orientierter Player gegen Nah- und unterstützte Distanzangriffe.
Player expression
A07
Projectile
Payload überlebt Caster, trifft korrekt, erzeugt keinen Doppelkontakt.
AttackInstance + payload
A08
AoE / Multi-target
Ein Angriff trifft mehrere zulässige Ziele, jedes Ziel nur nach definiertem Verhalten.
AttackInstance
A09
Reaction
Unterschiedliche Effective Impact-Werte erzeugen die vorgesehenen Reaktionen.
M06 → M07
A10
Interruption
Unterbrechung vor/nach Commit verhält sich entsprechend dem Vertrag.
Timeline
A11
Generation / Reset
Alte Payload/Action kann nach Reset/Scopewechsel keinen unzulässigen Kontakt erzeugen.
Lifecycle safety
A12
Wave Stress
Mehrere Gegner/Waves ohne Kontaktduplikation oder Zustandsfehler.
Integration
7. Reproduzierbarkeit und Diagnose
Jedes Szenario muss mit einem klaren Startzustand definiert sein.
Wo Zufall relevant ist, muss ein reproduzierbarer Seed bzw. deterministischer Modus vorhanden sein, sofern dies ohne unnötige globale Infrastruktur möglich ist.
Ein Fehlerbericht aus der Sandbox soll mindestens Szenario, Actor-Preset, Angriff, Defense-Aktion, Position/Distanz, Zeit-/Phase-Kontext und relevante Generation/Instance IDs benennen können.
Die Sandbox soll das Erkennen von Timing-Problemen erleichtern; sie soll nicht versuchen, aus einem schlechten Gefühl automatisch Balancewerte abzuleiten.
Debug-Informationen sollen aus den tatsächlichen Systemzuständen lesen. Keine parallele “Erklärungslogik”, die möglicherweise von der echten Berechnung abweicht.
8. Vorbereitung auf M08 Weapons
M08 soll nach erfolgreicher Sandbox-Abnahme direkt in derselben Umgebung testbar werden. Deshalb:
Weapon-Definitionen müssen später in die bestehende Attack-/Action-Pipeline einsteckbar sein, ohne Sandbox-spezifische Sonderpfade.
Die Sandbox soll unterschiedliche Weapon Profiles/Loadouts auswählen können, sobald M08 diese bereitstellt.
Schwer/leicht, Nah-/Distanz und unterschiedliche Reichweiten/Commitment-Profile sollen als Datenunterschiede testbar sein, nicht als hartcodierte Sandbox-Regeln.
Dual-Wielding und weitere Waffenarten werden erst mit M08 definiert. Die Sandbox darf hierfür keine vorgezogene eigene Kombinationslogik bauen.
9. Vorbereitung auf M09 Magic
Die Sandbox muss später Magic-Abilities als echte Verbraucher der Combat-Pipeline aufnehmen können.
M09-Zauber sollen gegen dieselben Actor-/Defense-/Reaction-Pfade testbar sein, soweit das jeweilige Design dies vorsieht.
Die Sandbox darf nicht schon jetzt ein eigenes Magic-System nachbauen.
Spätere Environmental-Reaction-Tests (Fire/Frost/etc.) sollen als separate zukünftige Szenarien ergänzt werden können; V1.0 implementiert die Weltreaktion selbst nicht.
10. Vorbereitung auf M10 Status Effects
Status Effects sollen später als zusätzliche, echte Gameplay-Zustände im selben Testlauf sichtbar und reproduzierbar werden.
Die Sandbox soll Platz für “Attack + Status + Defense + Reaction”-Szenarien haben, ohne jetzt bereits den Status-Contract zu definieren.
Keine vorgezogene globale Status-Registry nur für Sandbox-Zwecke.
11. Zukunftskompatibilität: Blueprint-Anbindung
Die Sandbox muss die im Future Systems & Foundation Compatibility Blueprint V1.0 vorgesehenen Grenzen respektieren. Insbesondere gilt:
Gameplay Truth bleibt von Presentation getrennt. Die Sandbox darf Diagnose anzeigen, aber Gameplay darf nicht an Debug-Visuals gekoppelt werden.
Persistent World Deltas werden nicht in der Combat Sandbox simuliert. Spätere World-Interaction-Sandboxes können darauf aufbauen.
Umweltreaktionen bleiben ein zukünftiger separater Domain-Vertrag: Combat/Magic erzeugt einen semantischen Effekt; eine spätere World-Reaction-Schicht entscheidet über Burnable/Freezeable/Breakable/Pushable usw.
Stable IDs und Generation Guards werden respektiert. Die Sandbox darf diese Mechanismen nicht umgehen.
Keine Sandbox-Architektur soll eine spätere große prozedurale Welt oder World Simulation voraussetzen.
12. Was ausdrücklich NICHT Teil von V1.0 ist
keine finale Combat-Balance
keine finalen Weapon Values oder Combo-Systeme
keine M09-Magieimplementierung
keine Status-Effect-Systemimplementierung
keine Environment-Reaction-Systemimplementierung
keine NPC-Defense-KI
kein Boss-System
kein Production Save/Progression Hook für die Sandbox
keine vollständige Editor-/Toolchain-Plattform
kein globales Debug-/Telemetry-Framework
keine visuelle Produktionsüberarbeitung des eigentlichen Spiels.
13. Technische Implementierungsstruktur (Vorschlag)
Astra soll vor Implementierung prüfen, welche bestehenden lokalen Verträge direkt wiederverwendet werden können. Die folgende Struktur ist Zielbild, kein Zwang zu bestimmten Dateinamen:
Eine lokale Sandbox-Hauptszene mit klarer Orchestrierung.
Ein lokaler Encounter-/Scenario-Controller, der nur Sandbox-Zustand besitzt.
Test-Presets als immutable bzw. klar definierte Datenquellen.
Ein lokales Diagnostics-Modul/Panel, das aus echten Combat-Zuständen liest.
Ein Reset-/Fixture-Pfad, der Actors und laufende Transienten auf einen bekannten Zustand bringt.
Wiederverwendung vorhandener Player-, Enemy-, CombatSystem-, Attack-, Defense- und M06-Modelle statt Duplikation.
Keine zusätzliche globale Abhängigkeit für das Laden der normalen Spielsession.
14. Implementierungsreihenfolge
Phase
Arbeitspaket
Phase 0 — Review
Blueprint + Work Order mit dem tatsächlichen M07-Stand abgleichen; Widersprüche vor Implementierung melden.
Phase 1 — Sandbox Shell
Lokale Szene, Arena, Spawn/Reset, Isolation.
Phase 2 — Actors & Presets
Player-/Enemy-Fixtures, Loadouts und definierte Startzustände.
Phase 3 — Combat Controls
Angriffe, Position, Defense, Waves und Wiederholung.
Phase 4 — Diagnostics
Timeline, Contact, Defense, M06 Result, Reaction, IDs.
Phase 5 — Scenario Suite
A01–A12 oder gleichwertige reproduzierbare Szenarien.
Phase 6 — QA / Packaging
Automatisierte Tests, Export-/Pack-Smokes, Developer-Testpaket.
Phase 7 — STOP / Handover
Completion Report; danach manueller Windows-Test durch den Nutzer; Stop vor M08.
15. Akzeptanzkriterien
ID
Bereich
Akzeptanz
A1
Isolation
Sandbox-Verwendung verändert keine Production Save-Daten und keine normale Spielfortschrittslogik.
A2
Real Path
Combat-Tests verwenden die echten M06/M07-Pfade; keine parallele Testberechnung.
A3
Reset
Ein Szenario lässt sich vollständig und reproduzierbar zurücksetzen.
A4
Defense
Dodge, Block und Parry sind getrennt testbar; Parry-Timing ist gezielt untersuchbar.
A5
Mage testing
Magie-orientierte Spielerprofile können die vorhandenen unterstützten Defense-/Attack-Pfade gezielt testen.
A6
Waves
Gegner-Waves funktionieren reproduzierbar, ohne Hit-Spam-/Duplicate-Contact-Fehler.
A7
Diagnostics
Relevante M07/M06-Zustände sind für Debugging sichtbar, ohne Gameplay-Code an UI zu koppeln.
A8
Future compatibility
M08/M09/M10 können später ergänzt werden, ohne die Sandbox-Grundarchitektur neu zu erfinden.
A9
Architecture compliance
Kein globaler Eventbus/Autoload/Registry und keine doppelte Combat-Wahrheit.
A10
Regression
Gesamtregression der bestehenden Foundation bleibt grün.
A11
Packaging
Windows-Developer-Testpaket ist reproduzierbar erstellt und geprüft.
A12
Documentation
Completion Report dokumentiert Scope, Tests, bekannte Grenzen und manuellen Teststatus.
16. QA-Fokus
Functional: alle Sandbox-Steuerelemente und Testabläufe funktionieren.
Regression: bestehende Foundation-Tests bleiben unverändert grün.
Integration: echte Player/Enemy/Combat/Payload-Pfade funktionieren gemeinsam.
Persistence: Sandbox darf keine normalen Savezustände verändern.
Performance: keine dauerhafte Debuglast außerhalb der Sandbox; Waves bleiben kontrolliert.
UX (Developer): schnelle Reset-/Retry-Schleife, klare Diagnose, keine unnötige Bedienkomplexität.
Gameplay: Sandbox macht echte Combat-Probleme sichtbar, statt sie durch Sonderlogik zu verstecken.
Cross-System: insbesondere Action → Contact → Defense → M06 Result → Reaction → Payload/Generation.
Design Compliance: Combat bleibt reaktiv, nachvollziehbar, physisch sinnvoll und ohne unnötige Simulation.
17. Completion Report muss enthalten
Geänderte und neu erstellte Dateien.
Welche bestehenden Contracts wiederverwendet wurden.
Automatisierte Testanzahl und Regressionsergebnis.
Liste der implementierten Sandbox-Szenarien bzw. Szenario-Suite.
Windows-Export-/Pack-Nachweis.
Offene Risiken und bewusst nicht implementierte Funktionen.
Expliziter manueller Windows-Teststatus: NOT TESTED / PASSED / FAILED — nicht implizit.
STOP vor M08.
18. Entscheidungs- und Änderungsregeln
Dieser Work Order autorisiert nicht automatisch Änderungen an M07-Core-Verträgen.
Wenn Astra feststellt, dass eine Anforderung nur durch Architekturänderung erfüllbar ist, muss dies vor der Änderung als Konflikt/Proposal beschrieben werden.
Neue Features außerhalb dieses Scopes werden nicht “vorsorglich” eingebaut.
Die Sandbox soll möglichst klein bleiben, aber jede enthaltene Funktion muss einen konkreten Testmehrwert haben.
Bei Konflikten gilt die Creative Bible und der Future Systems & Foundation Compatibility Blueprint als übergeordnete Design-/Architekturleitplanke.
19. Übergabe an Astra Master Chat
Empfohlene Reihenfolge: zuerst Future Systems & Foundation Compatibility Blueprint V1.0 senden, danach diesen Work Order V1.0 als konkreten Implementierungsauftrag. Astra soll vor Beginn die vorhandene M07-Architektur gegen beide Dokumente prüfen und nur bei Widerspruch nachfragen bzw. einen Change Proposal vorlegen.
STOP-Klausel: Die Sandbox Foundation wird als eigener, abgeschlossener Arbeitsschritt behandelt. Erst nach QA und dem manuellen Windows-Test beginnt M08.
