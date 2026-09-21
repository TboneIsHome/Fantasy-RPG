# LICHTERHAIN

## M06 — Stats & Trefferauflösung
### Gameplay / Systems Design & Implementation Specification V1.1

**Status:** DESIGN APPROVED FOR IMPLEMENTATION  
**Rolle:** Gameplay Director / Systems Design  
**Zweck:** Kleine Gameplay-Foundation für grundlegende Combat-Stats und die Auflösung eines bereits festgestellten Kontakts  
**Technische Implementierung:** durch den Astra Master Chat  
**Engine:** Godot 4.5.1  
**Projekt:** dauerhaft 2D-isometrisch

---

# 0. IMPLEMENTATION DIRECTIVE FÜR ASTRA

Dieses Dokument ist die verbindliche Gameplay-/Systems-Design-Grundlage für **M06 — Stats & Trefferauflösung**.

M06 soll als **kleiner, gemeinsamer Resolution-Kern** implementiert werden. Das System darf nicht zu einem vollständigen Combat-, Waffen-, Magie-, Status- oder Equipment-System anwachsen.

Die wichtigste Verantwortungsgrenze lautet:

> **M06 beantwortet: „Was passiert, wenn ein gültiger Angriffskontakt bereits festgestellt und ein Verteidigungs-Outcome bestimmt wurde?“**
>
> **M07 wird später beantworten: „Wie entstehen Treffer, Block, Dodge, Parry und aktive Combat-Fenster?“**

Astra darf die technische Architektur frei innerhalb der bestehenden Foundation wählen, muss aber die folgenden Gameplay-Semantiken und Scope-Grenzen erhalten.

Keine neuen Autoloads, keine globale Eventbus-Architektur, keine universelle Condition-Engine, kein vollständiger Combat-Rewrite und keine vorgezogene Implementierung von M07–M10.

Neue technische Datenmodelle müssen sich in die bestehenden State-Owner-, Region-Lifecycle-, Content- und Save-Regeln der Foundation einfügen.

---

# 1. PURPOSE

M06 definiert die kleinste gemeinsame Grundlage dafür, wie Lichterhain einen **bereits bestätigten Angriffskontakt** spielerisch auflöst.

Das System soll insbesondere:

- Treffer von Schaden trennen,
- Damage und Impact unabhängig behandeln,
- spätere Block-/Parry-/Dodge-Systeme vorbereiten,
- unterschiedliche Waffen, Skills und Magie tragen,
- physische und magische/elementare Effekte erweiterbar machen,
- mit Spieler und NPCs gleichermaßen funktionieren,
- Spezialisierung unterstützen,
- keine unnötige Stat-Flut erzeugen.

Das Ziel ist keine möglichst realistische Schadenssimulation, sondern:

> **Der Spieler soll nachvollziehen können, dass ein Angriff getroffen hat, wie stark er wirkt und welche spielerisch relevante Wirkung daraus entsteht.**

---

# 2. VERANTWORTUNGSGRENZE: M06 VS. M07

Dies ist die wichtigste Schärfung gegenüber V1.0.

## M06 besitzt

- die grundlegenden Werte/semantischen Kanäle für Health, Protection, Resistance, Stability, Damage und Impact,
- die Berechnung von Effective Damage,
- die Berechnung von Effective Impact,
- die gemeinsame Auflösung eines bereits festgestellten Kontakt-/Defense-Resultats,
- einen eindeutigen Resolution Result.

## M07 besitzt später

- Angriffsbeginn und Angriffsausführung,
- Hitbox-/Trajektorien-/Kontaktfeststellung,
- Timing-Fenster,
- aktive Dodge-Fenster / I-Frames,
- Block-Fenster,
- Parry-Fenster,
- Counter Windows,
- Attack Phases,
- Combo-/Chaining-Regeln,
- aktive Combat-State-Logik.

**M06 darf nicht selbst ein zweites Hit-Detection- oder Timing-System werden.**

Wenn M06 einen Kontakt erhält, wird davon ausgegangen, dass die fachlich zuständige Combat-/Hit-Detection-Schicht bereits festgestellt hat, **dass ein gültiger Kontakt vorliegt** und welches Defense Outcome dafür gilt.

---

# 3. PLAYER EXPERIENCE

Der Spieler soll bei einem Angriff drei klar unterscheidbare Ebenen wahrnehmen:

### 3.1 Kontakt

**„Habe ich tatsächlich getroffen?“**

Ein sauber ausgeführter Angriff muss sich eindeutig von einem Verfehlen unterscheiden.

### 3.2 Wirkung

**„Wie viel hat der Treffer bewirkt?“**

Health-Schaden ist relevant, aber nicht die einzige Wirkung.

### 3.3 Impact

**„Was hat mein Angriff mit dem Ziel gemacht?“**

Zum Beispiel:

- zurückgedrängt,
- unterbrochen,
- ins Wanken gebracht,
- Position verändert,
- defensiv zurückgedrängt,
- später ggf. Statuswirkung ausgelöst.

Damit unterstützt M06 die Creative Game Design Bible:

> **Treffer sollen sich wie physischer und spielerischer Kontakt anfühlen und nicht wie reines Abziehen einer Lebensleiste.**

---

# 4. CORE MODEL

Der konzeptionelle Ablauf von M06 lautet:

**Attack Profile**  
↓  
**Confirmed Contact / Defense Outcome**  
↓  
**Damage Resolution + Impact Resolution**  
↓  
**Resolution Result**

Nicht jeder Angriff muss jeden Kanal verwenden.

Ein Treffer kann beispielsweise:

- hohen Damage + niedrigen Impact,
- niedrigen Damage + hohen Impact,
- hohen Damage + hohen Impact,
- keinen direkten Damage + einen Secondary Effect

erzeugen.

---

# 5. BEGRIFFE UND EXAKTE BEDEUTUNG

## 5.1 Health

**Health** ist die aktuell verbleibende Lebensfähigkeit eines Ziels.

Health ist ein Zustand des Ziels, nicht Teil der Angriffsstärke.

M06 berechnet den effektiven Schaden; das zuständige Vitals-/Actor-System wendet diesen Schaden auf Health an.

M06 übernimmt nicht Healing oder Regeneration.

---

## 5.2 Protection

**Protection** ist die allgemeine, nicht schadensartspezifische Mitigation eines direkten Schadens.

Protection ist **kein Level**, keine Trefferchance und kein zusätzlicher Schaden.

Hohe Protection reduziert eingehenden direkten Schaden mit **diminishing returns**. Sie darf normale Treffer nicht durch eine lineare Subtraktion sofort vollständig wertlos machen.

### Exakte Startbedeutung

- Protection ist ein nichtnegativer numerischer Mitigationswert.
- Sie wirkt als Multiplikator auf direkten Schaden.
- Sie steigt mit diminishing returns.
- Sie erreicht durch die Formel allein niemals exakt 0 % verbleibenden Schaden.
- Explizite Immunität/komplette Negation ist eine separate Sonderregel und nicht einfach „sehr hohe Protection“.

### Beispiel

Protection = 0 → 100 % des Schadens bleiben vor Resistance erhalten.

Protection = 100 → 50 % des Schadens bleiben vor Resistance erhalten.

Protection = 200 → 33,3 % des Schadens bleiben vor Resistance erhalten.

Die konkreten Content-Werte werden später balanciert; die mathematische Form bleibt in M06 verbindlich.

---

## 5.3 Resistance

**Resistance** ist ein schadensartspezifischer prozentualer Modifikator.

Protection beantwortet:

> „Wie viel direkten Schaden hält dieses Ziel allgemein aus?“

Resistance beantwortet:

> „Wie empfindlich ist dieses Ziel gegenüber genau dieser Schadensart?“

Resistance wird anhand des **Damage Type** bestimmt.

M06 benötigt dafür keinen vollständigen Elementar-/Magie-Katalog. Der Resolver muss lediglich eine schadensartspezifische Resistance auflösen können. Neue Schadensarten werden später in ihren jeweiligen Systemen definiert.

### Exakter Startbereich

- `0` = keine Modifikation
- positive Werte = Resistenz
- negative Werte = Verwundbarkeit
- **+90** = sehr starke, aber noch nicht vollständige Resistenz
- **+100** wird nicht als normale Resistance behandelt, sondern als explizite vollständige Immunität/Negation
- **-50** ist die stärkste normale Vulnerability des Foundation-Modells

Damit ist der normale Bereich:

**-50 % bis +90 %**

Eine spätere Spezialmechanik kann diesen Bereich ausdrücklich erweitern, gehört aber nicht zum M06-Kern.

---

## 5.4 Stability

**Stability** ist der Widerstand eines Ziels gegen **Impact-basierte Kampfreaktionen**.

Stability ist **kein zusätzlicher Health-Balken** und keine Trefferchance.

Sie bestimmt nicht selbst, ob ein Angriff trifft.

Sie reduziert lediglich, wie viel eines bestätigten Impact-Werts in das Ziel übertragen wird.

### Exakte Startbedeutung

- Stability ist ein nichtnegativer Mitigationswert für Impact.
- Sie verwendet dieselbe diminishing-return-Idee wie Protection.
- Hohe Stability bedeutet nicht „Immunität gegen Physik“, sondern geringere resultierende Combat-Reaktion.
- M06 berechnet den **Effective Impact**.
- M07 / Combat entscheidet später, wie dieser Effective Impact konkret in Stagger, Knockback, Interrupt oder andere Combat States übersetzt wird.

Damit bleibt Stability ein einzelner verständlicher Foundation-Begriff und wird nicht automatisch zu einer Sammlung aus Poise, Balance, Stagger Resistance, Knockback Resistance usw.

---

# 6. EXAKTE MINIMALE SCHADENSFORMEL

Die erste M06-Formel soll absichtlich klein, deterministisch und leicht testbar sein.

## 6.1 Protection Factor

```text
ProtectionFactor = 100 / (100 + max(0, Protection))
```

Beispiele:

```text
Protection 0   → 1.000 = 100 %
Protection 50  → 0.667 = 66,7 %
Protection 100 → 0.500 = 50 %
Protection 200 → 0.333 = 33,3 %
```

---

## 6.2 Resistance Factor

Resistance wird als Prozentwert interpretiert:

```text
ResistanceFactor = 1 - clamp(Resistance, -50, 90) / 100
```

Beispiele:

```text
Resistance  0  → 1.00 = 100 %
Resistance 25  → 0.75 = 75 %
Resistance 50  → 0.50 = 50 %
Resistance 90  → 0.10 = 10 %
Resistance -25 → 1.25 = 125 %
Resistance -50 → 1.50 = 150 %
```

`+100` wird außerhalb der normalen Formel als **vollständige Immunität/Negation** behandelt.

---

## 6.3 Defense Outcome Modifier

Das bestätigte Defense Outcome darf einen bereits feststehenden Kontakt zusätzlich modifizieren.

Konzeptionell:

```text
DamageScale
ImpactScale
```

Diese Werte sind Eigenschaften des **Defense Outcomes**, nicht neue globale Stats.

Beispiele:

- `Hit` → DamageScale 1.0, ImpactScale 1.0
- `Block` → reduzierte Scales, deren konkrete Werte später im Defense-/Combat-Design festgelegt werden
- `Parry` → normalerweise 0 Damage/0 Impact auf das verteidigte Ziel; die Gegenreaktion des Angreifers gehört in M07
- `Miss/Evade` → keine Damage-/Impact-Resolution

M06 definiert also die Berechnung, aber nicht das Timing, das den Defense Outcome erzeugt.

---

## 6.4 Effective Damage

Für einen bestätigten, nicht vollständig negierten Treffer:

```text
EffectiveDamage = round(
    RawDamage
    × DamageScale
    × ProtectionFactor
    × ResistanceFactor
)
```

### Mindestregel

Wenn:

- der Kontakt gültig ist,
- `RawDamage > 0`,
- keine vollständige Immunität/Negation vorliegt,
- und `DamageScale > 0`,

dann ist der finale Schaden **mindestens 1**.

Damit kann normale Protection einen Treffer stark abschwächen, aber nicht allein auf 0 reduzieren.

Explizite Immunitäten oder eine fachliche vollständige Negation dürfen weiterhin **0 Schaden** erzeugen.

### Wichtig

M06 führt **keine globale Levelskalierung** ein.

Es gibt keine allgemeine Regel nach dem Muster:

> „Höheres Level = automatisch proportional mehr Schaden.“

---

# 7. EXAKTE MINIMALE IMPACT-FORMEL

Impact wird separat von Damage behandelt.

## Stability Factor

```text
StabilityFactor = 100 / (100 + max(0, Stability))
```

## Effective Impact

```text
EffectiveImpact = round(
    RawImpact
    × ImpactScale
    × StabilityFactor
)
```

Es gibt für Impact **keine künstliche Mindestwirkung**.

Ein Ziel mit sehr hoher Stability darf einen kleinen Impact auf 0 abrunden.

Ein sehr hoher Raw Impact kann auch gegen hohe Stability noch eine relevante Wirkung erzeugen.

### M06 entscheidet nur

> **Wie viel Impact kommt aus diesem Treffer effektiv beim Ziel an?**

### M07 entscheidet später

> **Was bedeutet dieser Effective Impact im aktiven Combat?**

Beispielsweise:

- Hit Reaction
- Interrupt
- Stagger
- Knockback
- Position Shift
- stärkere Combat State Transition

Diese Reaktionen sind bewusst nicht Teil des M06-Resolvers.

---

# 8. DEFENSE OUTCOMES

M06 übernimmt ein bereits festgestelltes Defense Outcome.

## Miss / Evade

Der Angriff wirkt nicht wirksam auf das Ziel.

Keine normale Damage- oder Impact-Auflösung.

M06 entscheidet nicht selbst, ob eine Bewegung ein gültiger Dodge war.

---

## Parry

Ein aktiver, korrekt aufgelöster Parry verhindert die normale Wirkung des eingehenden Angriffs auf das verteidigte Ziel.

M06 kann dafür `DamageScale = 0` und `ImpactScale = 0` erhalten.

Die taktische Gegenwirkung auf den Angreifer gehört **nicht** in M06, sondern in M07.

---

## Block

Der Kontakt ist grundsätzlich vorhanden, aber die aktive Verteidigung reduziert seine Wirkung.

M06 kann hierfür reduzierte Damage-/Impact-Scales anwenden.

Die konkrete Blockstärke, Stamina-Kosten, Blockrichtung, Winkel und Timing gehören zu späterem Defense-/Combat-Design.

M06 schreibt dafür **keine festen Block-Prozentwerte** vor.

---

## Hit

Der Angriff wirkt vollständig nach dem normalen M06-Modell:

```text
Damage + Impact
```

---

# 9. ATTACK PROFILE

Ein offensiv auflösbarer Angriff benötigt konzeptionell mindestens:

| Feld | Bedeutung |
|---|---|
| Raw Damage | Ausgangsschaden vor Mitigation |
| Damage Type | Schlüssel für passende Resistance |
| Raw Impact | Ausgangs-Impact vor Stability |
| Secondary Effect Information | optionale Information über spätere Nebenwirkungen |

Weitere Angriffseigenschaften dürfen existieren, müssen aber für M06 nicht automatisch relevant werden.

### Beispiele

**Leichter Dolchhieb**
- geringer Raw Damage
- geringer Raw Impact
- schnelle Angriffszyklen gehören nicht in M06

**Kriegshammer**
- hoher Raw Damage
- hoher Raw Impact

**Frostangriff**
- Raw Damage
- Damage Type = Frost bzw. bestehender entsprechender Projektschlüssel
- Raw Impact optional
- Secondary Effect Information optional

**Illusionszauber**
- kann ohne direkten Damage existieren
- seine primäre Wirkung kann später über andere Effects erfolgen

M06 erfindet für solche Spezialfälle keine eigene Berechnungslogik.

---

# 10. SECONDARY EFFECTS

Status Effects bleiben außerhalb des M06-Kerns.

M06 darf konzeptionell übermitteln:

> „Dieser Angriff trägt Information über einen möglichen Secondary Effect.“

M06 entscheidet jedoch nicht selbst:

- wie lange Brennen dauert,
- wie Frost Bewegung verändert,
- wie Gift tickt,
- wie Immunitäten gegen einen Status funktionieren,
- wie Status-Stacks funktionieren.

Das übernimmt das spätere Status-/Effect-System.

Ein Secondary Effect ist daher **kein verstecktes zweites Damage-System innerhalb von M06**.

---

# 11. KEINE AUTOMATISCHE MULTI-HIT-WIEDERHOLUNG

Eine einzelne Attack Action besitzt konzeptionell eine eindeutige **Attack-/Hit-Instanz**.

Ein Ziel darf innerhalb derselben Instanz standardmäßig nur einmal erfolgreich betroffen werden.

Das verhindert:

> „Die Collision bleibt mehrere Frames auf dem Gegner und verursacht automatisch mehrere Treffer.“

Spätere Systeme dürfen ausdrücklich definieren:

- Multi-Hit-Angriffe,
- mehrere Trefferphasen,
- AoE-Ticks,
- Channeling,
- kontinuierliche Effekte.

Diese Mechaniken müssen aber explizit mehrere Hit-/Effect-Instanzen erzeugen.

---

# 12. SPIELER UND NPCs

Spieler und NPCs verwenden grundsätzlich dieselbe M06-Auflösungslogik.

Unterschiede entstehen über ihre Inputs/Profile:

- unterschiedliche Attack Profiles,
- unterschiedliche Protection-/Resistance-/Stability-Werte,
- unterschiedliche Defense States.

Ein NPC erhält keine völlig andere Trefferrechnung, nur weil es ein NPC ist.

Boss-Sonderregeln sind später als explizite Gameplay-Erweiterungen erlaubt, dürfen aber keinen zweiten parallelen Damage Resolver erzeugen.

---

# 13. INTERACTIONS MIT ANDEREN SYSTEMEN

## Weapons

Weapons liefern Attack Profiles.

M06 ist nicht das Weapon System.

Beispiele:

- Schwert → ausgewogene Damage/Impact-Verteilung
- Dolch → geringer Impact, schnelle Angriffe
- Hammer → hoher Impact
- Bogen → Distanz-/Positionierungsvorteile kommen aus Combat/Weapon-Design

---

## Magic

Magic verwendet denselben grundlegenden Resolution Path.

Ein Zauber kann:

- treffen,
- Schaden verursachen,
- Impact erzeugen,
- Secondary Effects tragen,
- durch Resistance beeinflusst werden.

Magie ist damit kein „Combat 2“-System.

---

## Defense

Defense liefert das Defense Outcome.

M06 verarbeitet dieses Outcome.

Timing, I-Frames, Blockfenster und Parryfenster gehören nicht in M06.

---

## Equipment

Equipment darf später gezielt Werte beeinflussen, beispielsweise:

- Protection
- Resistance
- Stability
- Ressourcen oder spezielle Combat-Eigenschaften

M06 verlangt keine Equipment-Implementierung.

Ausrüstung soll vorzugsweise wenige klare Werte verändern statt viele kleine Prozentwerte zu stapeln.

---

## Progression / Learning by Doing

M06 vergibt keine Skill-XP.

Eine erfolgreiche Auflösung soll aber genug Kontext besitzen, damit das spätere Progressionssystem erkennen kann, **welche Aktion tatsächlich ausgeführt wurde**.

Ein erfolgreicher Schwerttreffer darf später Sword-Skill-Fortschritt unterstützen.

Ein verfehlter Angriff soll nicht automatisch denselben Fortschritt liefern.

Die XP-Regel gehört in das Progressionssystem.

---

## Physics

M06 liefert **Effective Impact**.

Das Physics-/Movement-/Combat-System entscheidet später, wie dieser Wert kontrolliert dargestellt wird.

M06 darf nicht von einer vollständig freien Physiksimulation abhängig werden.

---

# 14. WORLD INTERACTION

Die Trefferstruktur soll spätere Interaktionen mit bestimmten beschädigbaren Weltobjekten ermöglichen, etwa:

- brennbare Objekte,
- zerbrechliche Barrieren,
- bewegliche Objekte.

Das ist **nicht Bestandteil von M06**.

M06 liefert nur einen wiederverwendbaren Resolver-Kontext.

---

# 15. PROGRESSION-PHILOSOPHIE

M06 besitzt keine eigene Level- oder Mastery-Progression.

Progression soll vor allem die **Qualität und Möglichkeiten der Inputs** verändern.

Beispiel:

Früher Schwertkämpfer:

> normaler Angriff + moderater Impact

Später spezialisierter Schwertkämpfer:

> bessere Techniken + neue Hit Behaviors + neue Kombinationen

Nicht als alleinige Designrichtung:

> „Sword Level 50 = 500 % mehr Schaden.“

Damit bleibt Lichterhain bei:

- Player Expression,
- Spezialisierung ohne Gefängnis,
- neuen Möglichkeiten statt bloßer Zahlensteigerung.

---

# 16. WAS NICHT IN M06 IMPLEMENTIERT WIRD

Folgende Systeme sind ausdrücklich **OUT OF SCOPE**:

- vollständiges Combat-System,
- Hitbox-/Trajektorien-/Collision-System,
- Attack Animations,
- Dodge Timing / I-Frames,
- Block Timing,
- Parry Timing,
- Counter Windows,
- Combo-System,
- Weapon System,
- neues Magic System,
- Status Effect System,
- Equipment System,
- Skill-XP-System,
- Healing/Regeneration-System,
- Critical Hit System,
- globales Level Scaling,
- Körperteil-/Verletzungssimulation,
- Welt-Event-System,
- große neue Enemy-AI.

M06 darf bestehende Systeme so anbinden, dass ihre aktuellen Schadenspfade den neuen Resolver verwenden, aber es darf keine unnötige Neuentwicklung angrenzender Systeme auslösen.

---

# 17. FAILURE MODES / DESIGN RISKS

## 17.1 Stat-Flut

Kein automatisches Einführen von:

- Strength,
- Dexterity,
- Crit Chance,
- Crit Resistance,
- Hit Chance,
- Armor Penetration,
- Block Rating,
- Parry Rating,
- Poise,
- Stagger Resistance,
- Element Penetration,
- usw.

Jeder zusätzliche Wert braucht später einen nachweisbaren Gameplay-Mehrwert.

---

## 17.2 Damage wird wieder zur einzigen Wahrheit

Wenn alle Builds nur über Effective Damage bewertet werden, verliert Impact seinen Sinn.

Damage und Impact müssen im Datenmodell und Ergebnis getrennt bleiben.

---

## 17.3 Schutzwerte machen kleine Angriffe komplett nutzlos

Die Protection-Formel verwendet deshalb diminishing returns und keine reine lineare Subtraktion.

Normale Resistance endet im Foundation-Modell bei +90 %; +100 % ist eine explizite Immunität.

---

## 17.4 Physik wird chaotisch

M06 produziert einen kontrollierten Effective-Impact-Wert.

Die konkrete physische Reaktion wird später von Combat/Physics begrenzt und interpretiert.

---

## 17.5 M06 wird zum globalen Combat-Manager

Der Resolver darf nicht zum Besitzer von:

- Animation,
- Input,
- AI,
- Status-Timing,
- Weltänderungen,
- Savegame,
- UI,
- Questlogik

werden.

M06 ist ein fachlich enger Resolver.

---

# 18. MINIMALE BEISPIELE

## Beispiel A — Schwert gegen ungepanzerten Gegner

Attack:

- Raw Damage = 30
- Raw Impact = 20
- DamageScale = 1
- ImpactScale = 1

Target:

- Protection = 0
- Resistance = 0
- Stability = 0

Result:

- Effective Damage = 30
- Effective Impact = 20

---

## Beispiel B — gleicher Angriff gegen Protection 100

ProtectionFactor = 0.5

Result:

- Effective Damage = 15
- Effective Impact bleibt unabhängig davon bei 20, wenn Stability = 0

Damit ist Protection **kein Impact-Widerstand**.

---

## Beispiel C — Feuer gegen stark feuerresistentes Ziel

Raw Damage = 40

Protection = 20

Resistance = +75

ProtectionFactor = 100 / 120 = 0.8333

ResistanceFactor = 0.25

Vor Rundung:

`40 × 1 × 0.8333 × 0.25 = 8.33`

Result:

**Effective Damage = 8**

---

## Beispiel D — verwundbares Ziel

Raw Damage = 40

Protection = 0

Resistance = -25

Result:

`40 × 1 × 1.0 × 1.25 = 50`

**Effective Damage = 50**

---

## Beispiel E — Hammer gegen sehr stabile Kreatur

Raw Impact = 80

Stability = 200

StabilityFactor = 0.3333

Result:

**Effective Impact ≈ 27**

Der Angriff erzeugt also weiterhin deutliche Wirkung, aber die Stabilität des Ziels reduziert sie.

---

# 19. TEST- UND ABNAHMEKRITERIEN FÜR ASTRA

M06 gilt erst als abgeschlossen, wenn mindestens folgende Punkte nachgewiesen sind:

### Functional

- [ ] gültiger Hit wird korrekt aufgelöst
- [ ] Miss/Evade erzeugt keine normale Damage Resolution
- [ ] Block kann den Kontakt erhalten, aber die Wirkung reduzieren
- [ ] Parry kann normale Wirkung negieren
- [ ] Damage und Impact werden getrennt berechnet
- [ ] Protection wirkt nach der definierten Formel
- [ ] Resistance wirkt nach der definierten Formel
- [ ] Stability wirkt nach der definierten Formel
- [ ] explizite Immunität kann 0 Damage erzeugen
- [ ] normale hohe Protection kann allein keinen normalen Treffer auf 0 setzen
- [ ] Vulnerability funktioniert im definierten Bereich

### Resolution

- [ ] Player und NPC verwenden denselben Resolver
- [ ] Damage Type bestimmt die verwendete Resistance
- [ ] Defense Outcome kann DamageScale / ImpactScale liefern
- [ ] M06 entscheidet nicht selbst über Timing, Hitbox, Dodge oder Parry Window
- [ ] ein Hit wird innerhalb einer Attack-/Hit-Instanz nicht versehentlich mehrfach angewendet

### Architecture

- [ ] kein globaler Eventbus
- [ ] keine neue globale Registry
- [ ] keine universelle Condition-Engine
- [ ] kein zweiter paralleler Damage Resolver
- [ ] klare State Ownership
- [ ] keine doppelte dauerhafte Gameplay-Wahrheit
- [ ] Save-Format bleibt kompatibel, sofern kein ausdrücklich genehmigter Bedarf für eine Migration entsteht
- [ ] bestehender Region-Lifecycle bleibt intakt

### Regression

- [ ] vollständige bisherige Regression bleibt grün
- [ ] aktuelle bestehende Schadenspfade funktionieren nach Migration weiterhin
- [ ] Exporte bestehen
- [ ] Windows-Testpaket besteht
- [ ] manueller Windows-Spieltest wird durch den User durchgeführt

---

# 20. BALANCE-GRENZEN

M06 definiert die Mathematik, **nicht** die vollständige Balance des RPGs.

Die folgenden Werte sind Foundation-Semantik:

- Protection: nichtnegativ, diminishing returns
- Resistance: normal -50 % bis +90 %
- +100 % Resistance = explizite Immunität
- Stability: nichtnegativ, diminishing returns
- Damage: gesundheitsrelevante Wirkung
- Impact: separate Combat-Wirkung

Nicht Bestandteil der M06-Balance:

- tatsächliche Endgame-Statwerte,
- Waffen-DPS-Balance,
- Bosswerte,
- konkrete Blockkosten,
- konkrete Parry-Fenster,
- Heilökonomie,
- Crit-System,
- Skill-/Talent-Skalierungen.

Diese Entscheidungen werden in den jeweiligen späteren Systemen getroffen.

---

# 21. FINAL M06 MENTAL MODEL

Die verbindliche Kurzform lautet:

> **Confirmed Contact + Defense Outcome**  
> **→ Damage Resolution**  
> **→ Effective Damage**  
> **+ Impact Resolution**  
> **→ Effective Impact**  
> **→ Secondary Effect Information**

Die wichtigsten Regeln:

> **Treffer sind nicht dasselbe wie Schaden.**

> **Schaden ist nicht dasselbe wie Impact.**

> **Protection reduziert direkten Schaden.**

> **Resistance modifiziert Schaden abhängig von Damage Type.**

> **Stability reduziert übertragenen Impact.**

> **M06 entscheidet nicht, ob ein Angriff optisch/physisch trifft; das gehört zu Combat/Hit Detection.**

> **M06 berechnet nicht, wie Block/Dodge/Parry zeitlich funktionieren; es verarbeitet das bereits bestimmte Defense Outcome.**

> **Keine globale Levelskalierung als Fundament.**

> **Keine Körperteilsimulation.**

> **Keine automatische Crit-Mechanik.**

> **Keine unnötige Stat-Flut.**

> **Player und NPCs teilen denselben Resolution-Kern.**

Damit ist M06 klein genug als Foundation, aber stabil genug, damit spätere Systeme auf demselben Fundament aufbauen können:

**Weapons → M08**  
**Magic → M09**  
**Status Effects → M10**  
**aktive Combat-/Defense-Auflösung → M07**

---

# 22. STOP-PUNKT

Nach Implementierung und Abschlussprüfung von M06:

1. Completion Report erstellen.
2. Automatisierte Regression und Exporte prüfen.
3. Windows-Spieltest durch den User durchführen.
4. Gemeinsame technische und Gameplay-Abnahme durchführen.
5. **STOP.**

M07 oder spätere Systeme werden erst nach separater Prüfung begonnen.
