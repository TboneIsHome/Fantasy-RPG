# LICHTERHAIN
# M08 — WEAPON FOUNDATION
## Gameplay / Systems Design Specification V1.0

**Status:** PROPOSAL  
**Owner:** Gameplay Director / Systems Design  
**Implementation:** Nicht Bestandteil dieses Dokuments  
**Dependencies:** M06 — Stats & Trefferauflösung; M07 — Active Combat & Defense Foundation  
**Test Surface:** Developer Combat Sandbox

---

# 0. Status- und Entscheidungslegende

**BINDING**  
Aus der Creative Game Design Bible oder bereits abgenommenen Foundations abgeleitet.

**PROPOSAL**  
Neue Gameplay-Definition, die noch Game-Director-Freigabe benötigt.

**OPEN QUESTION**  
Bewusste Detailentscheidung, die noch nicht festgelegt wird.

**OUT OF SCOPE**  
Wird in M08 ausdrücklich nicht definiert oder implementiert.

---

# 1. Purpose

M08 definiert die Gameplay-Basis dafür, dass Lichterhain eine **große Vielfalt unterschiedlicher Waffen** unterstützen kann, ohne für jede Waffe ein eigenes Kampfsystem zu benötigen.

Die Foundation soll ermöglichen, dass sich beispielsweise:

- Dolch
- Einhandschwert
- Zweihandschwert
- Streit-/Handaxt
- schwere Kriegsaxt
- Mace / Streitkolben
- Kriegshammer
- Speer
- Bogen
- Dual-Wield-Kombinationen

nicht nur durch Zahlen, sondern durch ihre **tatsächliche Kampfform** unterscheiden.

M08 soll daher vor allem definieren:

> **Wie kämpft sich diese Waffe?**

und nicht:

> **Wie hoch ist ihre DPS?**

Die langfristige Zielsetzung lautet:

> **Viele Waffen, wenige gemeinsame Combat-Regeln, starke qualitative Unterschiede.**

Dies entspricht der Creative-Bible-Forderung nach Player Expression, Spezialisierung ohne Klassen-Gefängnis, glaubwürdigem Impact und Systeminteraktion. 

---

# 2. Player Experience Goal

**BINDING + PROPOSAL**

Der Spieler soll beim Wechsel einer Waffe innerhalb weniger Kämpfe spüren:

> **„Ich spiele jetzt anders.“**

Der Spieler soll idealerweise Unterschiede wahrnehmen wie:

> „Mit dem Dolch muss ich viel näher ran und kleine Öffnungen ausnutzen.“

> „Mit dem Speer kontrolliere ich Abstand.“

> „Mit dem Kriegshammer muss ich meine Angriffe wirklich auswählen.“

> „Mit dem Zweihandschwert kontrolliere ich Raum.“

> „Mit zwei Waffen bekomme ich andere offensive Möglichkeiten, verliere dafür aber bestimmte defensive Vorteile.“

Die Waffe soll dadurch nicht nur ein Ausrüstungsgegenstand, sondern ein **Gameplay-Entscheidungswerkzeug** sein.

---

# 3. Combat Design Goals

## 3.1 Fast Response

**BINDING**

Eingaben sollen sich reaktiv anfühlen.

Waffen dürfen unterschiedliche Startup- und Recovery-Profile besitzen, aber keine Waffe soll sich grundsätzlich träge oder unkontrollierbar anfühlen.

---

## 3.2 Heavy Impact

**BINDING**

Treffer sollen Gewicht besitzen.

Dafür wird M06s **Impact** genutzt.

M08 definiert, welche Waffen typischerweise wie viel Impact erzeugen und in welcher Form dieser Impact eingesetzt wird.

M08 führt dafür **keinen zweiten Impact- oder Force-Stat** ein.

---

## 3.3 Believable Commitment

**BINDING + PROPOSAL**

Eine mächtige Aktion darf eine stärkere Verpflichtung des Spielers erzeugen.

Eine schwere Waffe darf deshalb langsamere oder riskantere Aktionen besitzen.

Das bedeutet:

> Stärke wird mit Entscheidungskosten bezahlt.

Nicht zwingend mit einem Ressourcensystem, sondern zunächst durch:

- Startup
- Reichweite
- Recovery
- Mobilität
- Fehlerrisiko
- Positionierung.

---

## 3.4 Weapon Identity Over Numbers

**BINDING**

Eine Waffenidentität darf nicht hauptsächlich aus:

> Damage + Attack Speed + Range

bestehen.

Diese Werte sind Teile des Profils, aber nicht dessen vollständige Bedeutung.

---

# 4. Weapon Foundation Philosophy

## 4.1 Eine Waffe ist ein Combat Profile

**PROPOSAL**

Jede Waffe bzw. Waffenfamilie besitzt ein konzeptionelles **Weapon Combat Profile**.

Dieses Profile beschreibt:

1. Welche Aktionen die Waffe besitzt.
2. Welche Räume diese Aktionen kontrollieren.
3. Wie schnell sie handelt.
4. Wie stark sie den Spieler bindet.
5. Wie mobil sie während und nach Angriffen bleibt.
6. Welche Kontaktgeometrie sie besitzt.
7. Welche Wirkung sie typischerweise erzielt.
8. Wie sie mit Block, Dodge und Parry interagiert.
9. Welche taktischen Entscheidungen sie bevorzugt.
10. Welche Schwächen sie bewusst besitzt.

Damit wird eine neue Waffe nicht zu einem neuen Combat-System.

---

# 5. Weapon Identity Model

**PROPOSAL**

Die Identität einer Waffe soll aus mehreren voneinander unterscheidbaren Dimensionen entstehen.

## 5.1 Reach

Wie viel Raum kann die Waffe effektiv bedrohen?

Nicht nur maximale Distanz, sondern auch:

- effektiver Nahbereich
- mittlerer Bereich
- Spitzen-/Endbereich
- seitliche Abdeckung
- Angriffswinkel.

---

## 5.2 Tempo

Wie schnell kommt eine Aktion von Intent zu Active Window und zurück in Recovery?

Wichtig:

**Tempo ≠ DPS.**

Eine schnelle Waffe kann beispielsweise geringeren Impact und geringere Reichweite besitzen.

---

## 5.3 Commitment

Wie stark bindet sich der Spieler an eine Aktion?

Commitment wird beeinflusst durch:

- Startup
- Beweglichkeit
- Interruptibility
- Recovery
- Angriffswinkel
- Position nach dem Angriff.

---

## 5.4 Mobility

Wie stark kann der Spieler während einer Aktion seine Position verändern?

Beispiele:

- frei beweglich
- eingeschränkt
- stark vorwärtsgerichtet
- kaum beweglich.

---

## 5.5 Contact Shape

**PROPOSAL**

Waffen sollen unterschiedliche **Kontaktgeometrien** besitzen können.

Beispiele:

- enger Stich
- kurzer Hieb
- weiter Bogen
- breiter Zweihandschlag
- lange lineare Reichweite
- Projektil.

Das gehört in M08, weil es einen unmittelbaren Unterschied in der Spielweise erzeugt.

Es ist keine technische Collision-Definition.

---

## 5.6 Impact Profile

Referenziert M06s Impact.

M08 bestimmt nur:

> Welche Angriffshandlungen dieser Waffe besitzen welchen qualitativen Impact-Charakter?

Kein neuer Force- oder Physics-Stat.

---

## 5.7 Defense Profile

**PROPOSAL**

Jede Waffenfamilie besitzt eine grobe defensive Ausprägung:

- stark block-kompatibel
- normal block-kompatibel
- eingeschränkt
- nicht als primäre Defense gedacht.

Analog kann die Waffe einen:

- normalen Parry-Charakter,
- spezialisierten Parry-Charakter,
- eingeschränkten Parry-Charakter

besitzen.

M07 bleibt Eigentümer der eigentlichen Defense-Regeln.

---

# 6. Core Weapon Behaviors

M08 braucht nur wenige universelle Kernverhalten.

## 6.1 Action Portfolio

Eine Waffe besitzt eine Auswahl konkreter Aktionen.

Beispielsweise:

- Primary Attack
- Heavy Attack
- Secondary Attack
- Optional Follow-up / Alternative Action
- Ranged Attack bei Distanzwaffen.

Nicht jede Waffe muss alle davon besitzen.

---

## 6.2 Action Profile

**PROPOSAL**

Jede konkrete Waffenaktion besitzt konzeptionell:

- Zweck
- Reichweitenprofil
- Startup
- Commit Point
- Active Window
- Recovery
- Bewegungsprofil
- Kontaktgeometrie
- Damage-/Impact-Profil
- Defense Interaction
- optionale Folgeaktion.

Damit bleibt M07 die gemeinsame Lifecycle-Grundlage.

---

# 7. Verhältnis M08 → M07 → M06

Dies ist ein zentraler Architekturpunkt.

## M08 entscheidet

> **Welche Combat-Form besitzt die Waffe?**

## M07 entscheidet

> **Wann kann diese Aktion tatsächlich Kontakt erzeugen?**

## M06 entscheidet

> **Was passiert nach dem bestätigten Kontakt?**

Beispiel:

**Kriegshammer**

M08:

> langsam, hohe Commitment, hoher Impact, große Wirkung.

M07:

> prüft Startup, Active Window, Position und Kontakt.

M06:

> löst Damage, Effective Impact und Result auf.

M07 verarbeitet danach die entstehende Combat Reaction.

Dadurch entsteht keine doppelte Schadens- oder Trefferlogik.

---

# 8. Offensive Actions

## 8.1 Primary Attack

Die wichtigste und am leichtesten lesbare Standardaktion.

Sie soll die Grundidentität der Waffe vermitteln.

Der Primary Attack muss deshalb nicht zwingend der stärkste Angriff sein.

---

## 8.2 Heavy Attack

**PROPOSAL**

Heavy Attacks sollen nicht zwingend jede Waffe brauchen.

Wenn vorhanden, sollen sie vor allem:

- höheres Commitment,
- andere Raumkontrolle,
- stärkeren Impact,
- besondere Zielkontrolle

ermöglichen.

Sie sollen nicht lediglich:

> „Primary Attack, aber 2× Damage“

sein.

---

## 8.3 Alternative Actions

Einige Waffen können eine zweite offensive Funktion besitzen.

Beispiele:

- Speerstoß vs. Sweep
- Schwert-Hieb vs. anderer Winkel
- Hammer-Schlag vs. langsamer Heavy
- Bogen: schneller Schuss vs. stärker gezogener Schuss.

Alternative Aktionen sollen unterschiedliche Entscheidungen erzeugen.

---

# 9. Angriffsgeometrie

**PROPOSAL**

Die Geometrie eines Angriffs ist ein wesentlicher Teil der Waffenidentität.

Dabei können folgende qualitative Formen verwendet werden:

### Narrow

Schmaler Kontaktbereich.

Vorteil:

> präzise.

Nachteil:

> leichter zu verfehlen.

---

### Wide

Breiter Kontaktbereich.

Vorteil:

> mehrere Gegner / Raumkontrolle.

Nachteil:

> häufig höheres Commitment.

---

### Forward

Starke Reichweite nach vorne.

Vorteil:

> Distanz kontrollieren.

Nachteil:

> schwächer bei seitlicher / sehr naher Position.

---

### Sweep

Breite seitliche Bewegung.

Vorteil:

> Gruppen / Raum.

Nachteil:

> Commitment und Recovery.

---

### Projectile

Der Kontakt entsteht räumlich getrennt vom Spieler.

Dies wird vom bestehenden M07-Projektilpfad unterstützt.

---

# 10. Defense Interaction

M08 verändert die M07-Defense nicht.

Es definiert lediglich die **waffenspezifische Ausprägung**.

---

## 10.1 Block

Waffen sollen sich darin unterscheiden dürfen, wie sinnvoll Block mit ihnen ist.

### Beispielhafte Rollen

**Einhandschwert**

> starke Allround-Defense.

**Zweihandschwert**

> gute Reichweite und Präsenz, aber höhere Bewegungs-/Commitment-Kosten.

**Dolch**

> eher mobil und reaktiv als blockorientiert.

**Speer**

> Distanz und Raumkontrolle wichtiger als passives Blocken.

**Bogen**

> Block ist nicht der primäre Verteidigungsstil.

**Dual Wield**

> Defense hängt stärker von Positionierung und aktiver Wahl ab.

---

## 10.2 Parry

**PROPOSAL**

Parry darf unterschiedliche Waffencharaktere besitzen.

Aber:

> Es gibt nicht für jede Waffe ein eigenes Parry-System.

M07 bleibt für:

- Parry Window
- Defense Outcome
- Counter Opportunity

zuständig.

M08 liefert lediglich die waffenspezifische Ausprägung.

Beispielsweise:

**Dolch**

> präzises, schnelles Parry-Profil.

**Einhandschwert**

> ausgewogenes Parry-Profil.

**Kriegshammer**

> stärker auf harte Gegenwirkung statt schnelle Wiederaufnahme ausgerichtet.

**Bogen**

> kein regulärer Parry-Schwerpunkt.

Diese Unterschiede müssen später durch tatsächliche Tests bestätigt werden.

---

# 11. Weapon Profiles

Die folgende Tabelle ist eine **Gameplay-Richtung**, keine finale Balance.

| Waffe | Reichweite | Tempo | Commitment | Mobility | Impact | Kernidentität |
|---|---|---|---|---|---|---|
| Dolch | sehr kurz | sehr hoch | niedrig | sehr hoch | niedrig | Öffnungen / Präzision |
| Einhandschwert | mittel | hoch | mittel | hoch | mittel | vielseitig |
| Zweihandschwert | lang | mittel | hoch | mittel | hoch | Raumkontrolle |
| Streitaxt | kurz–mittel | mittel | mittel | mittel | hoch | aggressiver Druck |
| Kriegsaxt | mittel–lang | niedrig–mittel | hoch | niedrig–mittel | sehr hoch | massive Raumkontrolle |
| Mace | mittel | mittel | mittel–hoch | mittel | hoch | robuste Nahkampfwucht |
| Kriegshammer | mittel | niedrig | sehr hoch | niedrig | sehr hoch | einzelne schwere Entscheidungen |
| Speer | sehr lang | mittel | mittel | mittel | mittel–hoch | Spacing |
| Bogen | sehr lang | situationsabhängig | situationsabhängig | situationsabhängig | variabel | Distanz / Positionierung |

**PROPOSAL:** Die Begriffe sind zunächst relationale Designwerte. Noch keine Zahlen.

---

# 12. Weapon-Specific Identity

# 12.1 Dolch

**Identity**

> **Nähe, Geschwindigkeit, Präzision und Reaktionsfähigkeit.**

## Stärken

- sehr schneller Angriff
- kurze Recovery
- hohe Mobilität
- kleine Öffnungen gut ausnutzbar
- schnelle Richtungsänderungen
- besonders gut für aggressive und präzise Spieler.

## Schwächen

- geringe Reichweite
- geringe Raumkontrolle
- geringer Impact
- Fehlpositionierung wird schnell bestraft.

## Attack Feel

Der Dolch soll nicht wie ein „schwaches Schwert“ wirken.

Er soll:

> **rein in eine Lücke → treffen → wieder heraus**

fördern.

## Defense

Dodge und Positionierung sind natürliche Stärken.

Parry kann stark sein, aber als präzise Technik.

Block ist nicht der bevorzugte Identitätskern.

## Gegnerreaktion

Ein Dolchkämpfer soll vom Gegner besonders durch:

- Abstand,
- Flächenangriffe,
- Gegenbewegung

unter Druck gesetzt werden.

---

# 12.2 Einhandschwert

**Identity**

> **Der flexible Allrounder.**

## Stärken

- gute Reichweite
- gutes Tempo
- gute Mobilität
- solide Defense
- solide Parry-Fähigkeit
- viele Situationen brauchbar.

## Schwächen

- keine extreme Spezialisierung
- in keinem einzelnen Bereich die stärkste Waffe.

## Player Type

Geeignet für:

> Anfänger, flexible Spieler, klassische Schwertkämpfer und Hybride.

Das Schwert ist kein „Default Best Weapon“.

Sein Wert ist seine Flexibilität.

---

# 12.3 Zweihandschwert

**Identity**

> **Raum kontrollieren.**

## Stärken

- hohe Reichweite
- große Angriffsbögen
- hoher Impact
- mehrere Gegner kontrollierbar
- starke Kontrolle mittlerer Distanz.

## Schwächen

- hoher Commitment
- größere Recovery
- schwierigere Nutzung in engen Räumen
- weniger flexible schnelle Reaktionen.

## Gameplay

Der Spieler soll Abstand und Winkel bewusst wählen.

Das Zweihandschwert belohnt:

> **Vorausschau statt hektisches Reagieren.**

---

# 12.4 Streitaxt / Einhand-Axt

**Identity**

> **Aggressiver, wuchtiger Einhandkampf.**

**PROPOSAL:** Für M08 wird „Streitaxt“ zunächst als primär einhändige Axtfamilie behandelt.

## Stärken

- höherer Impact als leichte Klingen
- gute Nahkampfwirkung
- starke einzelne Treffer
- offensive Präsenz.

## Schwächen

- weniger vielseitig als Schwert
- etwas höheres Commitment
- geringere defensive Flexibilität.

## Gameplay

Die Axt soll nicht einfach „Schwert mit mehr Damage“ sein.

Sie setzt stärker auf:

> **Druck + Wucht + gezielte Öffnungen.**

---

# 12.5 Kriegsaxt / schwere Zweihandaxt

**PROPOSAL**

Für eine klare Spielerlesbarkeit wird die **Kriegsaxt** vorläufig als schwere Zweihand-Axtfamilie geführt.

**OPEN QUESTION:** Diese Bezeichnung kann später geändert werden, falls die endgültige Waffentaxonomie mehrere historische Axttypen differenzierter abbilden soll.

## Identity

> **Massive offensive Raumkontrolle.**

## Stärken

- sehr hoher Impact
- breite Angriffsbögen
- große Raumkontrolle
- starke Wirkung gegen mehrere Ziele.

## Schwächen

- hohe Commitment
- langsame Recovery
- geringe Reaktionsfähigkeit
- Fehler sind teuer.

Sie soll sich aggressiver und flächiger anfühlen als der Kriegshammer.

---

# 12.6 Mace / Streitkolben

**Identity**

> **Robuste, kontrollierte Wucht.**

## Stärken

- hoher Impact
- gute Einzelzielkontrolle
- robuste Defense
- gut gegen Ziele, die schwere Treffer aushalten.

## Schwächen

- weniger Reichweite als große Zweihandwaffen
- langsamer als Schwert/Dolch
- geringere Mobilität.

Der Mace soll eine interessante Mitte darstellen:

> nicht so extrem wie Kriegshammer, nicht so flexibel wie Schwert.

---

# 12.7 Kriegshammer

**Identity**

> **Jeder Angriff ist eine Entscheidung.**

## Stärken

- sehr hoher Impact
- starke Einzelangriffe
- starke Stagger-/Interrupt-Chancen
- hohe Wirkung gegen stabile Ziele.

## Schwächen

- hoher Startup
- sehr hoher Commitment
- lange Recovery
- schlechte Fehlerverzeihung
- schlechte Reaktion auf schnelle Gegner.

## Combat Philosophy

Der Kriegshammer soll nicht einfach die höchste Schadenswaffe sein.

Seine Stärke ist:

> **Wenn ich die Situation richtig lese, kann ein einziger sauberer Angriff die gesamte Kampfsituation verändern.**

---

# 12.8 Speer

**Identity**

> **Distanz kontrollieren.**

Der Speer ist eine besonders wichtige Testwaffe, weil er demonstriert, dass Reichweite allein keine „größere Version des Schwerts“ erzeugt.

## Stärken

- sehr hohe Reichweite
- starke Vorwärtskontrolle
- gutes Spacing
- Gegner auf Distanz halten
- gute Kontrolle enger Angriffsachsen.

## Schwächen

- schlechter, wenn Gegner zu nahe kommt
- geringere Seitenabdeckung als breite Schläge
- kann in beengten Situationen Nachteile besitzen.

## Gameplay

Der Spieler soll mit dem Speer nicht hauptsächlich „mehr Damage von weiter weg“ bekommen.

Er spielt ein anderes Problem:

> **Wie halte ich den Gegner dort, wo meine Waffe optimal funktioniert?**

---

# 12.9 Bogen

**Identity**

> **Distanz + Vorbereitung + Positionierung.**

Der Bogen benötigt ein anderes Tempo-Modell als Nahkampfwaffen.

## Grundablauf

**Prepare / Draw → Aim → Release → Projectile Travel → Contact**

Die Kontaktauflösung folgt weiterhin M07/M06.

## Stärken

- extreme Reichweite
- hohe Positionierungsvorteile
- gute Vorbereitbarkeit
- Distanzkontrolle
- taktische Eröffnung aus sicherer Position.

## Schwächen

- stark von Position abhängig
- schlechter in unmittelbarer Nahdistanz
- Defense primär über Dodge und Positionierung
- Angriff benötigt Vorbereitung.

## Wichtiger Designpunkt

Der Bogen darf kein:

> „Melee weapon, nur mit sehr großer Range“

sein.

Er ist ein anderer Kampfstil.

---

# 13. Dual Wielding

Dual-Wielding wird von Anfang an berücksichtigt, ohne ein zweites vollständiges Combat-System aufzubauen.

## 13.1 Grundprinzip

**PROPOSAL**

Dual-Wielding ist zunächst eine **Waffenkonfiguration**, keine neue Waffengattung im technischen Sinn.

Zwei gültige Einhandwaffen werden kombiniert.

Jede Waffe behält ihr eigenes Combat Profile.

---

## 13.2 Hände bleiben eigenständig

Die Foundation muss konzeptionell unterscheiden können:

- Main-Hand Weapon
- Off-Hand Weapon.

Eine einzelne Aktion kann:

- nur Main Hand,
- nur Off Hand,
- beide Hände

verwenden.

Nicht jede Kombination darf automatisch beide Waffen gleichzeitig verwenden.

---

## 13.3 Standard-Dual-Wielding

**PROPOSAL**

Das grundlegende Dual-Wielding soll zunächst auf:

- Main-Hand-Angriff
- Off-Hand-Angriff
- optionalem Wechsel
- expliziten kombinierten Aktionen

beruhen.

Damit können wir Dual-Wielding bereits testen, ohne ein komplexes Combo-System zu bauen.

---

## 13.4 Keine automatische Doppel-Damage-Regel

Ein besonders wichtiger Grundsatz:

> **Zwei Waffen bedeuten nicht automatisch doppelten Output.**

Ein Angriff mit linker und rechter Waffe muss durch eine explizite Action definiert werden.

Dadurch bleiben:

- Timing
- Commitment
- Balance
- Defense

kontrollierbar.

---

# 14. Dual-Wield Weapon Combinations

## Schwert + Schwert

**Identity**

> Geschwindigkeit + kontinuierlicher Druck.

Stärken:

- hohe Angriffsdichte
- flexible Richtungswechsel
- gute offensive Verkettung.

Schwächen:

- weniger defensive Klarheit
- hoher Bedien-/Entscheidungsbedarf.

---

## Dolch + Dolch

**Identity**

> maximale Nähe und Präzision.

Stärken:

- extrem mobil
- sehr schnelle Aktionen
- starke Nutzung kleiner Öffnungen.

Schwächen:

- sehr geringe Reichweite
- geringe Raumkontrolle
- Fehler gegen schwere Waffen besonders gefährlich.

---

## Axt + Axt

**Identity**

> aggressiver, wuchtiger Dual-Wield-Stil.

Stärken:

- hoher offensiver Druck
- hoher kombinierter Impact.

Schwächen:

- hohe Commitment-Risiken
- weniger kontrollierbar als Schwert + Schwert.

---

## Schwert + Dolch

**Identity**

> Reichweite + schnelle Nahaktion.

Beispielsweise:

> Schwert hält mittlere Distanz, Dolch bestraft das Eindringen.

Dies ist ein besonders gutes Beispiel für Player Expression.

---

## Allgemeine Regel

Nicht jede Kombination muss gleich gut funktionieren.

Einige Kombinationen dürfen bewusst:

- stärker offensiv,
- sicherer defensiv,
- mobiler,
- spezialisierter

sein.

Aber keine Kombination soll ausschließlich durch höhere Zahlen besser sein.

---

# 15. Ranged Weapon Foundation

Bogen ist die erste Kern-Fernkampfwaffe.

M08 muss jedoch konzeptionell einen Unterschied zwischen:

> **Contact Delivery**

und

> **Projectile Delivery**

tragen können.

## Contact Delivery

Der Angriff wirkt unmittelbar innerhalb seines Active/Contact-Kontexts.

## Projectile Delivery

Der Angriff erzeugt einen räumlich getrennten Kontaktträger.

M07 besitzt bereits einen entsprechenden Projektilpfad; M08 definiert lediglich, dass der Bogen diesen verwendet. Die bestehende Sandbox sieht Projektile und AttackInstance-Verhalten ebenfalls ausdrücklich als Testfläche vor.

---

# 16. Impact / Reaction Interaction

M08 verwendet M06s Effective Impact.

Es definiert keine neue Reaktionsstatistik.

## Beispiel

### Dolch

niedriger Impact

→ eher minimale Hit Reaction.

### Schwert

mittlerer Impact

→ normale Hit Reaction.

### Kriegshammer

sehr hoher Impact

→ stärkere Reaktion / höhere Chance auf Unterbrechung abhängig von Stability.

M07 interpretiert anschließend:

> Effective Impact ↔ Stability.

Damit bleibt Stagger vollständig in der bestehenden Combat Foundation.

---

# 17. Controlled Physics

**BINDING**

M08 darf physische Eigenschaften unterstützen, aber keine Vollsimulation verlangen.

Eine Waffe darf dadurch beispielsweise:

- stärker zurückstoßen,
- Position verändern,
- einen Gegner aus einem Raum drängen,
- einen Angriff unterbrechen.

Aber:

> Das Combat-System soll weiterhin zuverlässig und vorhersehbar bleiben.

Das entspricht dem Blueprint: Gameplay-Systeme sollen semantische Ergebnisse liefern, während Weltreaktionen und Präsentation getrennt davon entscheiden, wie diese Ergebnisse weiterverarbeitet und dargestellt werden.

---

# 18. Environmental Interaction Hooks

## Was gehört in M08?

**PROPOSAL**

Nur die **semantische Anschlussfähigkeit**, nicht die Umweltreaktion selbst.

Eine Waffe darf konzeptionell später Informationen liefern wie:

> Physical Impact

> Delivery Mode

> optionaler Kontakt-/Angriffstyp.

M08 soll jedoch nicht wissen:

> „Tree = fällt bei diesem Angriff.“

oder:

> „Ice = zerstört sich bei 20 Damage.“

Das gehört in die spätere World-/Environment-Domain.

Der Future Systems Blueprint definiert genau diese Trennung: Combat erzeugt einen semantischen Effekt wie Impact; die World-Domain entscheidet anhand expliziter Fähigkeiten wie Breakable oder Pushable über die tatsächliche Reaktion.

---

## 18.1 Kein eigener Force-Wert

**PROPOSAL**

M08 führt **keinen separaten numerischen Force-Wert** ein.

Warum?

Weil M06 bereits Impact besitzt.

Ein zweiter Wert für praktisch dieselbe Bedeutung würde nur Redundanz schaffen.

Falls spätere Umweltinteraktionen eine zusätzliche Information benötigen, sollte erst dann ein eigener Contract vorgeschlagen werden.

---

# 19. Potential Future Physical Contact Tags

**OPEN QUESTION / PROPOSAL**

Langfristig könnten bestimmte Angriffe semantisch unterscheiden:

- Edge / Cutting
- Blunt
- Piercing
- Projectile.

Das könnte später bei:

- Umweltreaktionen,
- Rüstung,
- speziellen Gegnern,
- Status Effects

interessant werden.

**Empfehlung:**

Diese Tags werden **nicht automatisch als M08-Pflichtbestandteil festgeschrieben**.

Erst wenn mindestens ein späteres System tatsächlich davon profitiert, sollte die Foundation erweitert werden.

Das folgt direkt der Blueprint-Regel:

> keine vorzeitigen generischen Abstraktionen ohne konkreten Use Case.

---

# 20. Player Expression

M08 soll nicht primär Klassen definieren.

Stattdessen entstehen natürliche Combat Identities.

## Aggressive

Besonders unterstützt durch:

- Dolch
- Dual-Wield
- Axt.

## Defensive

Besonders unterstützt durch:

- Einhandschwert
- Mace
- Parry-orientierte Profile.

## Heavy

Besonders unterstützt durch:

- Kriegshammer
- Kriegsaxt
- Zweihandschwert.

## Mobility

Besonders unterstützt durch:

- Dolch
- Schwert
- Dual-Wield.

## Spacing

Besonders unterstützt durch:

- Speer
- Bogen
- Zweihandschwert.

## Precision

Besonders unterstützt durch:

- Dolch
- Speer
- Bogen
- Parry-orientierte Schwertspielweise.

Diese Archetypen sind keine Klassen.

Ein Spieler darf später zwischen ihnen wechseln und sie kombinieren.

---

# 21. Learning / Mastery Hooks

**BINDING**

M08 implementiert kein Mastery-System.

Es soll aber spätere Spezialisierung sinnvoll ermöglichen.

## Gute Mastery

Eine Meisterschaft könnte später:

- neue Angriffswinkel freischalten,
- neue Follow-ups ermöglichen,
- Recovery gezielt verbessern,
- neue Counter-Möglichkeiten schaffen,
- neue Raumkontrolle eröffnen,
- neue Synergien mit bestimmten Waffenprofilen erzeugen.

## Schlechte Mastery

Nicht:

> „Sword Mastery 50 = +30 % Damage“

als alleinige Bedeutung.

Eine höhere Meisterschaft darf Zahlenverbesserungen enthalten, aber ihr wichtigster Wert sollte möglichst in **neuen oder vertieften Möglichkeiten** liegen.

Das folgt der Creative Bible direkt:

> „Neue Fähigkeiten sollen neue Möglichkeiten eröffnen.“

---

# 22. M08 + Magic Compatibility

M08 darf M09 nicht vorwegnehmen.

Die Foundation muss aber folgende Kombinationen ermöglichen:

### Battlemage

Waffe + Zauber.

### Melee + Element

Physischer Angriff + späterer semantischer Elementeffekt.

### Bogen + Magic

Projektil als Träger späterer magischer Wirkung.

### Frost + Heavy

Hoher physischer Impact + späterer Frost-Effekt.

### Fire + Weapon

Nahkampf + späterer Feuer-/Heat-Effekt.

M08 muss dafür nur sicherstellen:

> Eine Weapon Action besitzt einen sauberen, erweitbaren Angriffskontext.

M09 entscheidet später, wie Magie diesen Kontext erweitert.

---

# 23. M08 + Status Effect Compatibility

M08 definiert keine Status Effects.

Es muss jedoch zulassen, dass ein Angriff später optionale sekundäre Effekte besitzt.

Beispiel:

> Weapon Attack → bestätigter Kontakt → M06 Result → später Status Application.

Das Weapon System besitzt nicht:

> „Burning Logic“

oder:

> „Freeze Logic“.

M10 bleibt hierfür zuständig.

---

# 24. M08 + Stealth Compatibility

Der Future Systems Blueprint erwartet später eine Kompatibilität zwischen Combat Contact / Attack Profiles und AI Perception, wobei Stealth nicht als universeller Damage Multiplier fest verdrahtet werden soll.

Deshalb:

**PROPOSAL**

M08 soll eine spätere Unterscheidung ermöglichen zwischen:

> sichtbarem Angriff  
> überraschendem Angriff  
> Angriff aus ungewöhnlicher Position.

Aber M08 besitzt kein Stealth-System.

Ein späteres Stealth-/AI-System entscheidet:

- ob der Angriff überraschend ist,
- wie NPCs ihn erkennen,
- welche taktische Situation daraus entsteht.

---

# 25. Combo Decision

Dies ist eine wichtige Scope-Entscheidung.

## Empfehlung

**Kein vollständiges Combo-System in M08.**

### Warum?

Ein großes Combo-System würde schnell:

- eigene Zustandslogik,
- eigene Balancingregeln,
- viele Spezialfälle,
- Animationsabhängigkeiten,
- Lernaufwand

erzeugen.

Das widerspricht:

> **Complexity only with value.**

---

## Was M08 stattdessen benötigt

M08 definiert ein **Action Portfolio**.

Aktionen können später grundsätzlich:

> aufeinander folgen

wenn M07 dies erlaubt.

Das reicht zunächst, um:

- schnell → stark,
- Primary → Alternative,
- Main Hand → Off Hand

zu modellieren.

Ein formales Combo-System mit:

- Combo Points,
- langen festen Sequenzen,
- Combo Meter,
- hunderten definierten Strings

ist **OUT OF SCOPE**.

---

# 26. Weapon Action Chaining

**PROPOSAL**

Für spätere Erweiterung reicht zunächst eine kleine Fähigkeit:

> Eine Action kann optional eine oder mehrere zulässige Folgeaktionen besitzen.

Beispiel:

> Sword Primary → Sword Follow-up

oder:

> Dual-Wield Main-Hand → Off-Hand.

Das ist noch kein vollständiges Combo-System.

Es beschreibt lediglich:

> Welche Aktionen können sinnvoll aufeinander folgen?

Diese Erweiterung sollte erst aus realen Waffenprofilen heraus entwickelt werden.

---

# 27. Weapon Defense Philosophy

Eine wichtige Entscheidung für M08:

> **Nicht jede Waffe soll überall gleich gut sein.**

Das wäre zwar einfacher zu balancieren, würde aber Waffenidentität zerstören.

Eine Waffe darf deshalb:

- sehr gute Offensive,
- mittelmäßige Defense

besitzen.

Eine andere:

- starke Defense,
- geringere Offensive.

Damit entstehen echte Entscheidungen.

Aber:

> Keine Standardwaffe soll sich grundsätzlich unspielbar anfühlen.

---

# 28. Weapon Categories

## Core Categories — BINDING / REQUIREMENT

### One-Handed Blade
- Dolch
- Einhandschwert

### Two-Handed Blade
- Zweihandschwert

### One-Handed Blunt
- Mace / Streitkolben

### Heavy Blunt
- Kriegshammer

### One-Handed Axe
- Streitaxt / Einhand-Axt

### Two-Handed Axe
- Kriegsaxt / schwere Axt

### Polearm
- Speer

### Ranged
- Bogen

### Dual-Wield
Konfiguration aus zwei kompatiblen Einhandwaffen.

---

# 29. Future Expansion Categories

**PROPOSAL**

Spätere sinnvolle Kandidaten:

- Kurzschwert
- Keule / Club
- Langwaffe / Stangenwaffe
- Hellebarde
- Armbrust
- Stab
- weitere kulturelle oder regionale Waffen.

Sie sind nicht Bestandteil von M08 V1.0.

Die Foundation sollte nur sicherstellen, dass ihre Ergänzung nicht ein neues Basissystem benötigt.

---

# 30. Data / Gameplay Contract

Das spätere technische Modell muss konzeptionell mindestens folgende Gameplay-Wahrheiten abbilden können.

## Weapon Identity

- Weapon Family
- Handedness
- Dual-Wield Compatibility
- Delivery Mode

## Weapon Profile

- Reach
- Tempo
- Commitment
- Mobility
- Impact Character
- Defense Profile

## Action Portfolio

Für jede Aktion:

- Action Purpose
- Startup
- Commit
- Active Window
- Recovery
- Reach
- Contact Shape
- Movement
- Damage / Impact Profile
- Defense Interaction
- optional Follow-up.

## Important Rule

Diese Informationen beschreiben **Gameplay-Wahrheiten**, keine technischen Implementierungsdetails.

Der Astra Master Chat entscheidet später:

- Datenstrukturen,
- Komponenten,
- Assets,
- Scripts,
- Resource-Systeme,
- Dateiorganisation.

Die Blueprint-Vorgabe „Data-driven content“ unterstützt genau diese Richtung: neue Waffen sollen ergänzt werden können, ohne Regeln über viele Stellen im Code zu verteilen.

---

# 31. Presentation Separation

M08 darf nicht von konkreten:

- Sprite-Frames,
- Animationen,
- VFX,
- Sounds

abhängig sein.

Die Gameplay-Wahrheit lautet:

> „Dieser Angriff befindet sich im Active Window.“

Nicht:

> „Frame 7 der Animation bedeutet Hit.“

Das folgt direkt aus dem bestehenden Presentation Contract des Blueprint: Gameplay Truth und semantisches Ergebnis müssen unabhängig von konkreten visuellen Assets bleiben.

---

# 32. Weapon Behavior vs. Presentation

Eine Waffe kann visuell sehr unterschiedlich präsentiert werden.

Ein und derselbe Gameplay-Begriff:

> Heavy Sword Attack

kann später durch unterschiedliche Animationen dargestellt werden.

M08 definiert:

> Reichweite, Timing, Commitment, Kontaktcharakter.

Art/Animation entscheidet:

> Wie sieht es aus?

---

# 33. Developer Sandbox Test Strategy

Die Developer Sandbox ist ausdrücklich als Labor für spätere Weapon Profiles vorgesehen. Die bestehende Sandbox-Spezifikation verlangt unter anderem echte Nutzung der M06/M07-Pfade, wiederholbare Szenarien, diagnostizierbare Action-/Contact-/Defense-/Reaction-Zustände und spätere Weapon-Profile ohne Sandbox-Sonderpfad.

M08 sollte die Sandbox deshalb nicht nur zum Anschauen, sondern zum **systematischen Vergleichen** verwenden.

---

# 34. Weapon Test Set

## Baseline Set

**A01** Dolch  
**A02** Einhandschwert  
**A03** Zweihandschwert  
**A04** Streitaxt  
**A05** Kriegsaxt  
**A06** Mace  
**A07** Kriegshammer  
**A08** Speer  
**A09** Bogen  
**A10** Dual-Wield Sword + Sword  
**A11** Dual-Wield Sword + Dagger  
**A12** Dual-Wield Axe + Axe

Die exakte Reihenfolge ist ein Testvorschlag.

---

# 35. Standard Comparison Tests

Jede Waffe sollte mindestens unter identischen Bedingungen getestet werden.

## Same Target

- gleicher Gegner
- gleiche Health
- gleiche Protection
- gleiche Stability.

## Same Position

- gleiche Startdistanz
- gleiche Ausrichtung
- gleiche Arena.

## Same Action Goal

Zum Beispiel:

> Einen einzelnen Gegner treffen.

Danach:

> Einen Gegner in Bewegung treffen.

Danach:

> Einen Angriff bestrafen.

Dadurch vergleichen wir echte Waffenidentität statt nur Werte.

---

# 36. Reach Tests

### R01

Ziel außerhalb der Reichweite.

### R02

Ziel am Rand der Reichweite.

### R03

Ziel im optimalen Bereich.

### R04

Ziel extrem nah.

### R05

Ziel bewegt sich rückwärts.

### R06

Ziel bewegt sich seitlich.

Ziel:

> Jede Waffe soll erkennbare Reichweitenstärken und -schwächen besitzen.

---

# 37. Commitment Tests

### C01

Aktion korrekt ausgeführt.

### C02

Aktion verfehlt.

### C03

Gegner greift während Recovery an.

### C04

Gegner greift während Startup an.

### C05

Angriff wird vor Commit unterbrochen.

### C06

Angriff wird nach Commit getroffen.

Ziel:

> Commitment soll bei schweren und schnellen Waffen unterschiedlich spürbar sein.

---

# 38. Defense Tests

## Block

Jede passende Waffe gegen:

- leichten Angriff
- mittleren Angriff
- schweren Angriff.

Beobachten:

- verbleibender Schaden
- Impact
- Mobilität
- Position
- Folgesituation.

M06 berechnet den Result; M07 stellt die Reaction dar.

---

## Parry

Jede geeignete Waffe gegen:

- zu frühen Parry
- korrektes Parry
- zu spätes Parry.

Ziel:

> Parry soll als Timing-Entscheidung funktionieren, nicht als versteckter Damage-Bonus.

---

## Dodge

- Vorwärts
- Seitwärts
- Rückwärts
- früh
- exakt
- spät.

Ziel:

> Waffe und Positionierung müssen miteinander funktionieren.

---

# 39. Reaction Tests

Für verschiedene Waffen sollen definierte Impact-Bereiche getestet werden:

### Light

Normale Reaktion.

### Medium

Interrupt / stärkere Reaktion.

### Heavy

Stagger.

Die konkrete Reaktionsschwelle bleibt M06/M07-Balancing vorbehalten.

---

# 40. Multi-Target Tests

Besonders wichtig für:

- Zweihandschwert
- Kriegsaxt
- Mace
- Speer
- Dual-Wield.

Testen:

- ein Ziel
- zwei Ziele
- mehrere Ziele
- unterschiedliche Winkel.

Ziel:

> Flächenwirkung darf Waffenidentität stärken, aber nicht automatisch „besser“ bedeuten.

---

# 41. Bow Tests

### B01

Schuss aus optimaler Distanz.

### B02

Schuss auf bewegliches Ziel.

### B03

Ziel kommt näher.

### B04

Spieler wird während Draw angegriffen.

### B05

Projectile misses.

### B06

Projectile hits after caster movement.

Die Sandbox besitzt bereits explizite Projectile- und AttackInstance-Testanforderungen; M08 soll diesen realen Pfad nutzen statt eine eigene Testlogik aufzubauen.

---

# 42. Dual-Wield Tests

### DW01

Sword + Sword

### DW02

Sword + Dagger

### DW03

Axe + Axe

### DW04

Main-Hand Attack

### DW05

Off-Hand Attack

### DW06

Alternating Actions

### DW07

Defense während Dual-Wield

### DW08

Kontaktduplikation verhindern

Ziel:

> Dual-Wielding erzeugt neue Optionen, nicht automatisch doppelte Stärke.

---

# 43. Weapon Balance Philosophy

**BINDING**

Finale Zahlen werden erst später festgelegt.

Zuerst müssen die **Relations** stimmen.

Eine gute Waffenbalance lautet nicht:

> Alle Waffen haben exakt dieselbe erwartete DPS.

Sie lautet:

> Jede Waffe besitzt erkennbare Stärken, erkennbare Schwächen und Situationen, in denen ihr Profil besonders wertvoll ist.

---

# 44. Weapon Power Budget

**PROPOSAL**

Beim Balancing sollte jede Waffe einen begrenzten „Power Budget“-Gedanken erhalten.

Wenn eine Waffe sehr stark ist bei:

- Reichweite
- Impact
- Raumkontrolle

muss sie dafür möglicherweise bezahlen mit:

- Tempo
- Recovery
- Mobilität
- Commitment.

Wenn eine Waffe sehr stark ist bei:

- Geschwindigkeit
- Mobilität
- Reaktion

sollte sie nicht gleichzeitig:

- höchste Reichweite,
- höchsten Impact,
- beste Defense

besitzen.

Das ist keine technische Formel.

Es ist eine Designregel.

---

# 45. Waffe darf in einer Nische hervorragend sein

Lichterhain braucht keine völlige Gleichmacherei.

Beispiel:

Der Kriegshammer darf gegen bestimmte robuste Gegner extrem gut wirken.

Der Dolch darf bei präzisem Ausnutzen kleiner Öffnungen hervorragend sein.

Der Speer darf in seinem optimalen Distanzbereich außergewöhnlich kontrollierend sein.

Der Bogen darf aus guter Position enorme taktische Vorteile geben.

Das ist nicht „unbalanced“, solange ihre Gegenbedingungen klar und spielerisch nachvollziehbar sind.

---

# 46. Fehlerverzeihung als Balance-Achse

**PROPOSAL**

Eine wichtige bisher unterschätzte Dimension ist:

> **Wie stark bestraft eine Waffe einen Fehler?**

### Dolch

Fehler = meist schlechte Position, aber schnelle Korrektur.

### Schwert

Fehler = moderates Risiko.

### Zweihandschwert

Fehler = deutlicher Recovery-Nachteil.

### Kriegshammer

Fehler = potenziell sehr gefährlich.

Damit entsteht ein natürlicher Unterschied in der Lernkurve.

---

# 47. Skill Ceiling

**PROPOSAL**

Waffen dürfen unterschiedliche Skill Ceilings besitzen.

### Niedrige Einstiegshürde / hohe Tiefe

Einhandschwert.

### Hohe Präzision

Dolch.

### Hohe Entscheidungsqualität

Kriegshammer.

### Hohe Raumkompetenz

Speer / Zweihandschwert.

### Hohe Situationskompetenz

Bogen.

Das ist wertvoll für unterschiedliche Spieler, ohne Klassen festzuschreiben.

---

# 48. Learning Curve

M08 sollte zwischen:

> leicht zu benutzen

und

> leicht zu meistern

unterscheiden.

Ein Spieler kann mit jeder Basiswaffe funktionsfähig sein.

Aber manche Waffen sollten deutlich mehr Tiefe besitzen.

Das entspricht:

> **Alles lernen können ≠ alles meistern können.**

---

# 49. M08 + Equipment

**OUT OF SCOPE**

M08 definiert nicht:

- Rüstung
- Waffenqualität
- Verzauberungen
- Haltbarkeit
- Loot.

Es muss aber mit späteren Equipment-Systemen kompatibel bleiben.

Ein späteres Item kann das bestehende Weapon Profile verändern oder erweitern.

---

# 50. M08 + Loot

**OUT OF SCOPE**

Loot-System entscheidet später:

> Woher bekomme ich die Waffe?

M08 entscheidet:

> Wie spielt sich die Waffe?

Diese Trennung ermöglicht regionale Waffenidentitäten wie:

- elfische Schwerter,
- zwergische Hämmer,
- antike Reliktwaffen.

Die Combat-Logik bleibt dennoch dieselbe.

---

# 51. M08 + Magic

**OUT OF SCOPE**

Keine Zauberschulen.

Keine Mana-Regeln.

Keine Zauberbäume.

Keine endgültigen Elementregeln.

Aber:

> Weapon Actions müssen als gültige Träger späterer magischer Modifikatoren funktionieren können.

---

# 52. M08 + Status Effects

**OUT OF SCOPE**

Keine Burning-/Frozen-/Poison-Logik.

Aber:

> Weapon Actions dürfen später semantisch zusätzliche Effekte tragen.

---

# 53. M08 + Environment

**OUT OF SCOPE**

Keine Baumfäll-, Feuer-, Frost- oder Destruktionssimulation.

Aber:

> Impact und andere semantische Ergebnisse müssen später von einer World-Domain konsumiert werden können.

Der Blueprint sieht dafür explizit die Trennung vor: Gameplay erzeugt den semantischen Effekt, eine spätere World-Domain entscheidet über Burnable, Breakable, Pushable usw.

---

# 54. M08 + Presentation

**OUT OF SCOPE**

Keine finale Animation.

Keine finale VFX.

Keine Audio-Definition.

M08 muss jedoch diese spätere Präsentation nicht blockieren.

---

# 55. Cross-System Dependencies

## Required

### M06

- Damage
- Impact
- Defense Result.

### M07

- Action Lifecycle
- Contact
- Defense
- Attack Instance
- Reaction.

### Developer Sandbox

- Vergleich
- Diagnose
- Wiederholung.

Die bestehende Sandbox ist ausdrücklich so angelegt, dass spätere Weapon Profiles ohne Sandbox-Sonderpfade integrierbar und vergleichbar sein sollen.

---

## Future

### M09

Magic.

### M10

Status Effects.

### Living World

AI / perception / world reactions.

### RPG Systems

Skills, Mastery, Equipment, Loot.

### Dynamic World

Environmental reactions / persistence.

Diese zukünftige Erweiterung entspricht der etablierten Roadmap-Reihenfolge des Compatibility Blueprint.

---

# 56. Compatibility Review — Future Systems Blueprint

## Clear State Ownership

**COMPATIBLE**

M08 sollte keine konkurrierende Wahrheit zu M06/M07 besitzen.

Weapon besitzt die Waffendefinition.

M07 besitzt Combat Lifecycle.

M06 besitzt Hit Resolution.

---

## No Global Event Bus Dependency

**COMPATIBLE**

M08 benötigt keine globale Kommunikationsarchitektur.

---

## Semantic Gameplay Results

**COMPATIBLE**

Waffen liefern semantische Eigenschaften und verwenden M06/M07.

---

## Data-Driven Content

**STRONGLY COMPATIBLE**

M08 sollte möglichst neue Waffenprofile hinzufügen können, ohne Core-Combat-Code zu verändern.

---

## Presentation Separation

**COMPATIBLE**

Weapon Gameplay darf nicht von konkreten visuellen Assets abhängen.

---

## Bounded Simulation

**COMPATIBLE**

Keine Waffensimulation auf Realweltphysik-Ebene.

---

## Backward-Compatible Evolution

**COMPATIBLE**

Neue Weapon Actions können später als Erweiterung des bestehenden Profils hinzukommen.

Alle diese Punkte entsprechen den zentralen Foundation Guardrails des Blueprint.

---

# 57. Architektur-Risiken aus Gameplay-Sicht

## Risiko 1 — Zu viele Parameter

Wenn jede Waffe 40–60 konfigurierbare Werte erhält, wird das System schwer verständlich.

**Empfehlung:**

Zunächst nur Werte aufnehmen, die tatsächlich einen spielbaren Unterschied erzeugen.

---

## Risiko 2 — Jeder Angriff wird einzigartig

Wenn jede Waffe eigene Regeln benötigt:

> Weapon Foundation verliert ihren Wert.

**Empfehlung:**

Profile zuerst, Sondermechaniken nur bei nachgewiesenem Mehrwert.

---

## Risiko 3 — Alle Waffen werden gleich

Wenn nur:

> Range / Damage / Speed

unterscheidet, verlieren Waffen ihre Identität.

**Gegenmaßnahme:**

Contact Shape, Commitment, Mobility, Recovery und Raumkontrolle als echte Designachsen.

---

## Risiko 4 — Dual-Wielding wird zu komplex

Wenn jede Kombination individuelle Regeln benötigt:

> 20 Waffen = möglicherweise hunderte Kombinationen.

**Empfehlung:**

Zwei Waffen werden zunächst über ihre vorhandenen Profile kombiniert; nur ausgewählte Paaraktionen werden explizit definiert.

---

## Risiko 5 — Heavy = immer besser

Wenn schwere Waffen einfach mehr Werte besitzen, entsteht eine dominante Meta.

**Gegenmaßnahme:**

Commitment und Fehlerkosten müssen echte Gegenwerte darstellen.

---

## Risiko 6 — Range schlägt alles

Ein Speer oder Bogen könnte leicht alle Nahkampfwaffen dominieren.

**Gegenmaßnahme:**

Optimal Range ≠ maximale Stärke in jeder Distanz.

Jede Reichweitenwaffe braucht echte Schwächezonen.

---

## Risiko 7 — Combo Creep

Kleine Follow-ups könnten unbemerkt zu einem vollständigen Combo-System wachsen.

**Gegenmaßnahme:**

Combo-System als separaten Scope behandeln.

---

# 58. Open Design Questions

## OQ01 — Exakte Waffen-Taxonomie

Sind:

> Streitaxt

und

> Kriegsaxt

wirklich zwei notwendige Gameplay-Familien?

**PROPOSAL:** Ja, wenn ihre Kampfform tatsächlich unterschiedlich genug ist.

---

## OQ02 — Heavy Weapon Commitment

Wie stark sollen Kriegshammer und schwere Axt Recovery/Commitment besitzen?

Noch keine Zahlenentscheidung.

---

## OQ03 — Block-Profil pro Waffe

Wie stark soll ein Zweihandschwert beispielsweise gegenüber einem Einhandschwert beim Block differenziert werden?

Diese Frage soll erst anhand Sandbox-Tests beantwortet werden.

---

## OQ04 — Parry-Profile

Brauchen wir tatsächlich unterschiedliche Parry-Charaktere pro Waffenfamilie?

**Empfehlung:** Ja, aber nur wenige Kategorien.

---

## OQ05 — Spear Close Range

Soll ein Speer bei extremer Nähe bewusst deutlich schwächer werden?

**Empfehlung:** Ja, sofern sich dadurch echtes Spacing-Gameplay ergibt.

---

## OQ06 — Bow Defense

Soll Bogen im normalen Zustand überhaupt blocken können?

**Empfehlung:** Primäre Defense über Positionierung und Dodge; Block nicht als gleichwertiger Standardstil.

---

## OQ07 — Contact Tags

Brauchen wir Edge / Blunt / Piercing bereits in M08?

**Empfehlung:** Noch nicht als Pflicht. Nur hinzufügen, wenn ein echter späterer Use Case dies verlangt.

---

## OQ08 — Stamina

Wie stark sollen schwere Waffen indirekt über Stamina beeinflusst werden?

Die grundlegende Stamina-Domain ist nicht M08-spezifisch.

---

## OQ09 — Weapon Switching

Wie schnell der Spieler Waffen wechseln kann und welche Commitment-Regeln dabei gelten, gehört in eine spätere Equipment-/Combat-Interaktion.

**OUT OF SCOPE für M08 V1.0.**

---

# 59. M08 Scope

## IN SCOPE

- Weapon Foundation Philosophy
- Weapon Categories
- Weapon Identity Model
- Weapon Combat Profiles
- Action Portfolio
- Action Profiles
- Reach
- Tempo
- Commitment
- Mobility
- Contact Shape
- Impact Profile
- Weapon Defense Profile
- Core Weapon Identities
- Dolch
- Einhandschwert
- Zweihandschwert
- Streitaxt / Einhand-Axt
- Kriegsaxt / schwere Zweihand-Axt
- Mace
- Kriegshammer
- Speer
- Bogen
- Dual-Wield Foundation
- Basic Dual-Wield Combinations
- Ranged Delivery Model
- Future compatibility hooks
- Sandbox test strategy
- qualitative balance philosophy.

---

# 60. M08 Non-Scope

## OUT OF SCOPE

- Magic Foundation
- Status Effects
- Skill Trees
- Mastery implementation
- Equipment System
- Loot System
- Crafting
- Enchanting
- Crit System
- full Combo System
- Boss mechanics
- final enemy AI
- environmental simulation
- final physics simulation
- final animations
- final VFX
- final audio
- final numerical weapon balancing
- final stamina economy.

---

# 61. Acceptance Criteria

M08 Gameplay Design ist erst dann als abgeschlossen anzusehen, wenn:

### AC01 — Clear Identity

Jede Kernwaffe besitzt eine verständliche qualitative Identität.

---

### AC02 — Distinct Playstyles

Die Kernwaffen unterscheiden sich nicht nur über Damage / Range / Speed.

---

### AC03 — M06 Boundary

Keine neue Damage-/Impact-Rechnung wird in M08 definiert.

---

### AC04 — M07 Boundary

M08 ersetzt weder Contact Validation noch Action Lifecycle noch Defense Logic.

---

### AC05 — Weapon Profiles

Neue Waffen können konzeptionell als Profile beschrieben werden, ohne ein neues Basissystem zu benötigen.

---

### AC06 — Heavy vs. Light

Leichte und schwere Waffen besitzen tatsächlich unterschiedliche:

- Entscheidungsrhythmen,
- Commitment,
- Mobilität,
- Fehlerkosten.

---

### AC07 — Defense

Block, Dodge und Parry unterscheiden sich waffenspezifisch, ohne jeweils ein neues Defensesystem zu erzeugen.

---

### AC08 — Dual Wield

Zwei kompatible Einhandwaffen können gemeinsam verwendet werden, ohne automatische Doppel-Damage-Logik.

---

### AC09 — Ranged

Bogen verwendet denselben übergeordneten Combat-/Contact-Pfad, obwohl der Kontakt über Projektilzustellung erfolgt.

---

### AC10 — Impact

Waffen unterscheiden sich qualitativ in ihrer Impact-Rolle, ohne eine neue Parallelstatistik einzuführen.

---

### AC11 — Player Expression

Mindestens folgende Spielweisen werden unterstützt:

- Aggressive
- Defensive
- Heavy
- Mobility
- Spacing
- Precision
- Dual-Wield.

---

### AC12 — Progression Compatibility

Spätere Mastery kann qualitative neue Möglichkeiten erzeugen, ohne M08 neu zu bauen.

---

### AC13 — Magic Compatibility

M09 kann später Weapon Actions erweitern, ohne ein zweites Combat-System zu benötigen.

---

### AC14 — Status Compatibility

M10 kann spätere Effekte an Weapon Contacts anschließen.

---

### AC15 — Environment Compatibility

Spätere World-Reaction-Systeme können semantische Waffen-/Impact-Ergebnisse konsumieren, ohne dass M08 die Welt simuliert.

---

### AC16 — Presentation Independence

Weapon Gameplay bleibt unabhängig von konkreten Animationen und Assets.

---

### AC17 — Sandbox Compatibility

Jede Kernwaffe kann in der Developer Sandbox vergleichbar getestet werden.

---

### AC18 — No Premature Abstraction

Es wurden keine generischen Systeme ergänzt, nur weil sie irgendwann theoretisch nützlich sein könnten.

Das entspricht ausdrücklich dem Compatibility Blueprint.

---

# 62. Recommended M08 Development Sequence

Für die spätere gemeinsame Ausarbeitung und danach technische Übergabe empfehle ich diese Reihenfolge:

## Phase 1 — Foundation Lock

Weapon Identity Model endgültig prüfen.

---

## Phase 2 — Archetype Profiles

Zuerst nur:

- Dolch
- Einhandschwert
- Kriegshammer
- Speer
- Bogen.

Diese fünf repräsentieren fünf sehr unterschiedliche Combat-Probleme.

---

## Phase 3 — Heavy / Dual Expansion

Danach:

- Zweihandschwert
- Axt
- Kriegsaxt
- Mace
- Dual-Wield.

---

## Phase 4 — Action Portfolio

Für jede Waffenfamilie:

- Primary
- Heavy
- Alternative
- mögliche Follow-up-Richtung.

---

## Phase 5 — Sandbox Comparison

Alle Profile in standardisierten Szenarien vergleichen.

---

## Phase 6 — Identity Audit

Für jede Waffe die Frage:

> **Würde ein Spieler nach fünf Minuten erkennen, dass er eine andere Waffe verwendet?**

---

## Phase 7 — Balance Pass

Erst nach bestätigter Identität:

- Damage
- Tempo
- Commitment
- Recovery
- Impact
- Reichweite.

---

# 63. Final Gameplay Director Recommendation

**PROPOSAL**

Die M08 Foundation sollte letztlich auf **sechs Hauptideen** reduziert bleiben:

> **Range**

> **Tempo**

> **Commitment**

> **Mobility**

> **Contact Shape**

> **Impact Profile**

Dazu kommen:

> **Action Portfolio**

und

> **Defense Profile**

Das genügt bereits, um sehr unterschiedliche Waffen zu erzeugen.

Wir brauchen zunächst **keine**:

- Force-Stat
- Poise-Stat
- Accuracy-Stat
- Crit-Stat
- Combo-Meter
- Weapon-Simulation
- Spezialphysik pro Waffe
- eigene Hit-Resolver pro Waffe.

---

# 64. M08 Core Mantras

> **Eine Waffe ist eine Spielweise, nicht nur eine Zahl.**

> **Reichweite ist Raum, nicht nur Meter.**

> **Tempo ist nicht DPS.**

> **Commitment ist eine Gameplay-Ressource.**

> **Impact ist Wirkung, nicht nur Schaden.**

> **Schwere Waffen sollen mächtig sein, weil sie gute Entscheidungen belohnen — nicht weil sie überall die höchsten Werte besitzen.**

> **Leichte Waffen sollen stark sein, weil sie Präzision, Mobilität und Timing belohnen.**

> **Dual-Wielding bedeutet neue Entscheidungen, nicht automatisch doppelten Schaden.**

> **Fernkampf ist ein eigener Spielstil, nicht Nahkampf mit mehr Reichweite.**

> **Neue Waffen benötigen möglichst neue Profile, nicht neue Combat-Systeme.**

> **Neue Komplexität muss sich durch neue Entscheidungen rechtfertigen.**

---

# 65. M08 Final Design Principle

**BINDING + PROPOSAL**

Die wichtigste Frage bei der Entwicklung jeder zukünftigen Waffe lautet:

> **„Welche Art zu kämpfen bringt diese Waffe in die Welt?“**

Nicht:

> „Welche Werte geben wir ihr?“

Ein Dolch soll den Spieler zu Nähe und Präzision bringen.

Ein Schwert zu Flexibilität.

Ein Zweihandschwert zu Raumkontrolle.

Ein Kriegshammer zu Commitment und Timing.

Ein Speer zu Spacing.

Ein Bogen zu Distanz und Positionierung.

Dual-Wielding zu hoher offensiver Ausdrucksfähigkeit auf Kosten anderer Optionen.

Damit erfüllt M08 seine eigentliche Aufgabe:

> **Nicht möglichst viele Waffen zu erzeugen, sondern möglichst viele glaubwürdige Arten, Lichterhains Kampfprobleme zu lösen.**

Das entspricht der übergeordneten Spielerfantasie der Creative Bible: Der Charakter soll nicht bloß bessere Zahlen besitzen, sondern seine persönliche Geschichte und Spielweise durch Entscheidungen, Spezialisierung und emergente Systeminteraktionen ausdrücken.