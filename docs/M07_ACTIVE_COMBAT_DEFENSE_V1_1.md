# LICHTERHAIN

## M07 — Active Combat & Defense Foundation
### Gameplay / Systems Design Proposal V1.1

**Status:** BINDING PROPOSAL  
**Rolle:** Gameplay Director / Systems Design  
**Abhängigkeit:** M06 — Stats & Trefferauflösung  
**Zweck:** Definition der aktiven Action-Combat- und Defensive-Grundlage  
**Technische Implementierung:** Nicht Bestandteil dieses Dokuments

---

# 0. Binding Design Decision

M07 und M06 besitzen strikt getrennte Verantwortlichkeiten.

> **M07 bestimmt, ob und unter welchen Bedingungen ein gültiger Kontakt entsteht und welches Defense Outcome daraus folgt.**

> **M06 bestimmt, was dieser bestätigte Kontakt numerisch bewirkt.**

M07 darf die Schadensformel von M06 nicht duplizieren, keine eigene parallele Trefferauflösung besitzen und keine zweite Schadenslogik erzeugen.

Der verbindliche Ablauf lautet:

**Action → Lifecycle → Active Window → Contact Validation → Defense Outcome → M06 Resolution → Combat Reaction → Recovery / Next Decision**

Damit bleibt der Combat-Kern klein, verständlich und erweiterbar.

---

# 1. Purpose

M07 definiert die Gameplay-Regeln dafür, wie eine offensive oder defensive Action zeitlich, räumlich und taktisch mit einem Ziel interagiert.

M07 schafft die gemeinsame Foundation für:

- schnelle Reaktion,
- klare Angriffsfenster,
- glaubwürdigen Kontakt,
- Gewicht und Commitment,
- Dodge,
- Block,
- Parry,
- Positionierung,
- Timing,
- kontrollierten Impact,
- Player Expression.

M07 ist **kein vollständiges Weapon-, Magic-, Combo- oder Status-System**.

Es ist die gemeinsame Combat-Schicht, auf der spätere Systeme ihre konkreten Attack Profiles und Defense-Varianten aufbauen.

Zentrale Designprinzipien:

> **Weight over spectacle**

> **Player Expression**

> **Options over obligation**

> **Purposeful Physics**

> **Complexity only with value**

---

# 2. Player Experience

Der Spieler soll das Gefühl haben:

> **„Meine Aktion war erfolgreich, weil ich sie räumlich, zeitlich und taktisch richtig ausgeführt habe.“**

Combat soll deshalb nicht primär wie ein statistischer Würfel funktionieren.

Ein Gegner außerhalb der realen Reichweite wird nicht getroffen.

Ein Gegner, der den Angriff rechtzeitig verlässt, kann ihm ausweichen.

Ein Spieler, der einen Angriff falsch einschätzt, kann dafür einen echten Nachteil erleiden.

Ein gut getimter Parry erzeugt einen deutlich anderen Vorteil als dauerhaftes Blocken.

Gleichzeitig soll Combat zugänglich bleiben.

Der Spieler muss nicht zahlreiche versteckte Werte oder physikalische Variablen verstehen. Für die eigentliche Entscheidung genügen grundsätzlich:

**Wo bin ich?**  
**Wo ist der Gegner?**  
**Was tut der Gegner?**  
**Was tue ich?**  
**Wann öffnet sich mein Fenster?**

Das System darf tief sein, ohne kompliziert wirken zu müssen.

---

# 3. Core Combat Model

## 3.1 Offensive Action

Eine offensive Action besitzt konzeptionell:

**Intent → Startup → Commit → Active → Recovery → Completed / Interrupted**

Nicht jede konkrete Action muss in allen Phasen dieselbe Länge oder Bedeutung besitzen, aber jede reguläre Action muss einen nachvollziehbaren zeitlichen Lebenszyklus besitzen.

### Intent

Der Spieler oder NPC entscheidet sich für eine offensive Action.

Noch kein Kontakt.

### Startup

Die Action wird vorbereitet.

Sie ist noch nicht kontaktfähig.

Startup erzeugt Lesbarkeit und gibt dem Gegenüber grundsätzlich die Möglichkeit zu reagieren.

### Commit

Ab einem definierten Punkt kann die Action nicht mehr beliebig durch normale Eingabe abgebrochen werden.

Commit ist ein Gameplay-Prinzip und darf nicht ausschließlich von Animationen abhängen.

### Active

Die Action ist kontaktfähig.

Nur während des gültigen Active Windows kann die Action einen normalen offensiven Kontakt erzeugen.

### Recovery

Die Action hat ihre primäre Wirkung beendet, aber der Angreifer befindet sich noch in einem kontrollierten Nachlauf.

Recovery erzeugt Commitment und Risiko.

### Completed / Interrupted

Die Action endet regulär oder wird durch einen gültigen Combat-Einfluss unterbrochen.

---

# 4. Defense Model

Defensive Actions laufen unabhängig von offensiven Actions.

Grundsätzlich stehen zur Verfügung:

- Normal
- Dodge Active
- Block Active
- Parry Window

Eine konkrete Defense Action kann je nach Situation durch einen gültigen Combat-Zustand ersetzt oder beendet werden.

## 4.1 Kein Defense Stacking

Für einen einzelnen Kontakt gilt:

> **Es gibt genau einen maßgeblichen aktiven Defense State.**

Defense States werden nicht als Wahrscheinlichkeiten oder additive Schutzwerte kombiniert.

Nicht:

- 50 % Dodge
- plus 30 % Block
- plus 20 % Parry

Sondern:

> **Der für den Kontakt gültige Defense State bestimmt den Defense Outcome.**

Dadurch bleibt Combat vorhersehbar und lesbar.

---

# 5. Contact Validation

M07 besitzt die Gameplay-Regeln dafür, wann ein Kontakt gültig ist.

M07 besitzt jedoch **nicht** die konkrete geometrische Definition jeder einzelnen Waffe, Ability oder Attacke.

Spätere Attack-/Weapon-/Ability-Systeme liefern dafür den relevanten Attack Context.

Beispielsweise kann dieser konzeptionell enthalten:

- Reichweite,
- räumliche Wirkungszone,
- Richtung / Facing,
- relevante Angriffsausdehnung,
- Zeitpunkt / Phase,
- Zieltyp,
- Sonderregeln der jeweiligen Action.

M07 bewertet diese Informationen anhand seiner allgemeinen Combat-Regeln.

## 5.1 Grundregeln

Ein normaler offensiver Kontakt ist nur möglich, wenn:

1. die Action sich in ihrem gültigen Active Window befindet,
2. das Ziel gültig und erreichbar ist,
3. die räumliche Beziehung zur Attack Action stimmt,
4. die Angriffsrichtung bzw. Wirkungszone stimmt,
5. das Timing stimmt,
6. kein relevanter Defense State den Kontakt verhindert oder verändert,
7. die Action nicht durch einen ungültigen Zustand bereits beendet wurde.

M07 bestimmt damit die **Gameplay-Wahrheit des Kontakts**.

Die konkrete Collision-Technologie, Shape-Implementierung oder Physikmethode ist keine Designvorgabe dieses Dokuments.

---

# 6. No Hidden Accuracy

Der normale Action Combat verwendet **keine klassische zufällige Hit Chance** als Fundament.

Nicht:

> „92 % Chance zu treffen.“

Sondern:

> **Der Angriff befindet sich korrekt in seinem gültigen zeitlichen und räumlichen Kontaktbereich.**

Ein sichtbarer Fehlschlag bleibt ein Fehlschlag.

Spätere Spezialfähigkeiten dürfen bewusst automatische oder halbautomatische Zielmechaniken besitzen, wenn sie einen nachweisbaren Gameplay-Mehrwert liefern.

Sie dürfen jedoch nicht heimlich zu einem allgemeinen Accuracy-System werden.

---

# 7. Defense Outcome

Nach der Kontaktprüfung erhält der Angriff genau ein maßgebliches Defense Outcome.

Grundlegende Outcomes:

### Miss / Evade

Es kommt zu keinem gültigen normalen Kontakt.

M06 wird für die normale Schadensauflösung nicht aufgerufen.

### Parry

Der Angriff wird durch eine aktive und korrekt getimte Parry-Action beantwortet.

Der Treffer erhält das Parry-Outcome und wird anschließend entsprechend der M06-/Combat-Regeln weiterverarbeitet.

### Block

Der Angriff trifft auf einen aktiven Block.

Der Treffer erhält das Block-Outcome und wird anschließend durch M06 unter Berücksichtigung dieses Outcomes aufgelöst.

### Hit

Es liegt kein ausweichender, blockender oder parierender Defense Outcome vor.

Der Treffer wird regulär an M06 übergeben.

Die zentrale Regel lautet:

> **Ein Kontakt erhält genau ein maßgebliches Defense Outcome.**

---

# 8. Dodge

Dodge ist eine aktive Positions- und Timing-Entscheidung.

Es ist keine passive Miss Chance.

## 8.1 Dodge Composition

Ein Dodge besteht konzeptionell aus:

- Bewegung,
- kurzem Schutzfenster,
- anschließender Positionierung.

## 8.2 Dodge Protection Window

Während eines gültigen Dodge Protection Windows kann ein relevanter Angriff keinen normalen Kontakt erzeugen.

Das Schutzfenster soll:

- kurz,
- verständlich,
- zuverlässig,
- bewusst nutzbar

sein.

Es ist kein permanenter Schutzstatus.

## 8.3 Dodge Direction

Die Richtung des Dodges ist spielerisch relevant.

Beispiele:

- rückwärts → Distanz,
- seitlich → Angriffslinie verlassen,
- vorwärts → Angriff überqueren / Position verändern.

Der Dodge verändert damit nicht nur Schaden, sondern die folgende Spielsituation.

## 8.4 Poor Dodge

Ein schlecht getimter Dodge kann:

- zu früh erfolgen,
- zu spät erfolgen,
- weiterhin in der Angriffslinie bleiben,
- den Spieler in eine schlechtere Position bringen.

## 8.5 Dodge Resources

Eine Ressource wie Stamina **darf** später als Balanceinstrument verwendet werden.

Sie ist kein zwingender Bestandteil der M07 Foundation, solange sie keinen nachweisbaren Entscheidungswert gegenüber unnötiger Einschränkung erzeugt.

---

# 9. Block

Block ist eine aktive defensive Haltung.

## 9.1 Grundprinzip

Block verändert den Defense Outcome eines eingehenden Angriffs von einem normalen Hit zu einem Block, sofern der Angriff grundsätzlich blockbar ist.

Die numerische Wirkung des Blocks wird anschließend durch M06 auf Basis des Defense Outcomes verarbeitet.

M07 besitzt **keine zweite Block-Schadensformel**.

## 9.2 Was Block leisten soll

Block soll insbesondere:

- direkten Schaden reduzieren,
- gefährliche Angriffe kontrollierbarer machen,
- defensive Stabilität ermöglichen.

## 9.3 Was Block nicht garantieren soll

Block muss nicht sämtliche Konsequenzen neutralisieren.

Ein ausreichend starker Angriff kann weiterhin:

- reduzierten Schaden verursachen,
- relevanten Impact übertragen,
- Position beeinflussen,
- den Verteidiger zurückdrängen,
- Ressourcen belasten,
- später definierte Reaktionen verursachen.

## 9.4 Block ist kein zweiter Health-Balken

> **Block ist keine zusätzliche Lebensleiste.**

Es ist eine taktische Entscheidung, keine zweite Form von HP.

## 9.5 Bewegung während Block

Block darf Mobilität reduzieren.

Die Bewegungseinschränkung soll aber nicht automatisch zu vollständigem Stillstand führen.

Die konkrete Ausprägung gehört in spätere Defense-/Balance-Arbeit.

---

# 10. Parry

Parry ist die präziseste aktive Defensive.

## 10.1 Grundprinzip

Parry besitzt ein engeres Timing-Fenster als Block.

Der Spieler muss den Angriff bewusst lesen und im richtigen Moment reagieren.

## 10.2 Erfolgreicher Parry

Ein erfolgreicher Parry soll:

- den normalen Angriffsvorteil des Angreifers aufheben,
- dessen laufende Action destabilisieren oder unterbrechen können,
- einen klaren taktischen Vorteil erzeugen,
- eine Counter Opportunity eröffnen können.

Ein Parry besitzt **keinen verpflichtenden automatischen Gegenangriff**.

Der Spieler erhält eine Chance und muss selbst entscheiden, wie er diese nutzt.

## 10.3 Fehlversuch

Ein fehlgeschlagener Parry besitzt echtes Risiko.

Je nach Timing kann der Spieler:

- den Angriff normal abbekommen,
- seine defensive Chance verlieren,
- in einer ungünstigen Recovery landen.

## 10.4 Parry vs. Block

Das verbindliche Designprinzip lautet:

> **Block = sicherer, verzeihender, weniger stark.**

> **Parry = präziser, riskanter, potenziell stärker.**

Parry darf kein Pflichtwerkzeug werden.

---

# 11. Attack vs. Defense Relationship

M07 soll kein starres Stein-Schere-Papier-System werden.

Stattdessen besitzen Actions erkennbare Wechselwirkungen.

| Situation | Mögliche Antworten |
|---|---|
| normaler Nahkampfangriff | Block, Dodge, Parry, Positionierung |
| schwerer langsamer Angriff | Distanz, Dodge, Parry, Bestrafung der Recovery |
| schneller Angriff | frühe Defense, Positionierung |
| hoher Impact | nicht blind blocken |
| Flächenangriff | Positionierung, passende Defense |
| Spezialangriff | abhängig von der tatsächlichen Fähigkeit |

Grundsatz:

> **Keine Situation soll ohne guten Grund nur eine einzige „richtige“ Antwort besitzen.**

Die Foundation soll unterschiedliche defensive Identitäten ermöglichen.

---

# 12. Combat Reactions

M07 berechnet **nicht** erneut Damage.

M06 liefert unter anderem:

- Effective Damage,
- Effective Impact,
- Resolution Result.

M07 interpretiert den erhaltenen Effective Impact in Bezug auf die Combat-Situation und erzeugt daraus einen kontrollierten Combat Reaction State.

Mögliche Grundreaktionen:

- Normal Reaction,
- Interrupt,
- Stagger,
- Knockback / Positionsverschiebung.

## 12.1 Hit Reaction

Ein normaler Treffer soll eine kontrollierte Reaktion auslösen, die den Kontakt glaubwürdig vermittelt, ohne jeden Treffer zum vollständigen Stopp des Kampfflusses zu machen.

## 12.2 Interrupt

Ein ausreichend relevanter Kontakt kann eine laufende Action abbrechen.

Nicht jeder Treffer muss automatisch interrupten.

## 12.3 Stagger

Ein Stagger bedeutet:

> **Das Ziel erhält aufgrund einer ausreichenden Impact-Wirkung eine deutliche temporäre Kampfreaktion.**

Es ist kein simuliertes Verletzungssystem.

## 12.4 Stability

M06 liefert Effective Impact und das Ziel besitzt Stability.

M07 verwendet diese vorhandene Beziehung.

M07 führt **keinen zusätzlichen Poise-, Stagger-Armor- oder Super-Armor-Stat** ein.

Die Foundation arbeitet zunächst bewusst mit wenigen Reaktionsstufen.

Empfohlene Basis:

**Normal Reaction → Interrupt → Stagger**

Weitere Reaktionsstufen dürfen erst eingeführt werden, wenn konkrete Gameplay-Situationen einen nachweisbaren Mehrwert zeigen.

Die exakten Balance-Schwellen zwischen diesen Stufen sind **Content-/Combat-Balance**, keine neue Statistik und kein Grund für eine parallele Stagger-Engine.

## 12.5 Stagger Lock Prevention

Ein einzelner Gegner darf nicht allein durch die Existenz des Impact-Systems unbegrenzt in einer nicht-interaktiven Stagger-Kette gehalten werden.

Spätere Balance- und Action-Profile müssen kontrollierte Recovery-, Immunitäts- oder Unterbrechungsgrenzen verwenden, falls dafür Gameplay-Bedarf besteht.

Diese Mechanismen dürfen nicht als neuer universeller Stat-Baukasten entstehen.

---

# 13. Combat Reaction ≠ Physics Simulation

M07 erzeugt einen **kontrollierten Gameplay-Zustand**.

Das Physics-/Movement-/Presentation-System entscheidet anschließend, wie dieser Zustand sichtbar und beweglich umgesetzt wird.

Nicht:

> „M07 wirft den Character mit einem beliebigen physikalischen Impuls in die Welt.“

Sondern:

> **„M07 bestimmt die beabsichtigte Combat-Reaktion; die technische Umsetzung stellt sie kontrolliert dar.“**

Damit bleibt Combat:

- reproduzierbar,
- lesbar,
- balancierbar,
- stabil.

Physik unterstützt das Gefühl, ersetzt aber nicht die Combat-Wahrheit.

---

# 14. Hit Stop and Presentation

Hit Stop kann das Gewicht eines Kontakts deutlich verbessern.

Es gehört jedoch nicht zur eigentlichen Schadens- oder Kontaktberechnung.

M07 darf die **Bedeutung eines Kontakts** liefern.

Die Presentation-Schicht entscheidet daraus über:

- Hit Stop,
- Animation,
- VFX,
- Sound,
- Camera Feedback.

Damit wird M07 nicht zu einem Presentation-System.

Hit Stop soll:

- kurz,
- gezielt,
- proportional zur Bedeutung des Kontakts

sein.

---

# 15. Attack Instances

M06 besitzt bereits `HitInstance`.

M07 bestimmt, wann die dafür relevante offensive Attack Instance entsteht.

## 15.1 Definition

Eine Attack Instance ist:

> **eine zusammenhängende offensive Aktion mit eigenem Start, Active Window, Ende und Recovery.**

## 15.2 Standardregel

Ein Ziel darf innerhalb einer einzelnen Hit-Phase höchstens einmal regulär getroffen werden.

Dasselbe räumlich aktive Angriffselement darf nicht allein wegen seiner Dauer automatisch wiederholt Schaden liefern.

## 15.3 Multi-Hit

Eine spätere Attacke darf ausdrücklich mehrere Hit-Phasen besitzen:

**Active Phase 1 → Hit → neue Phase → Active Phase 2 → weiterer Hit**

Das muss bewusst definiert werden.

Multi-Hit ist keine automatische Eigenschaft aller Angriffe.

## 15.4 AoE

Eine Attack Instance darf mehrere Ziele treffen.

Jedes Ziel wird dabei separat validiert und besitzt seine eigene Kontakt-/Hit-Behandlung.

---

# 16. Recovery and Commitment

Recovery erzeugt echte Konsequenzen für Entscheidungen.

Ein starker Angriff darf bei einem Fehlschlag eine Gelegenheit für den Gegner erzeugen.

Dadurch entsteht:

> **Entscheidung → Risiko → Konsequenz**

Recovery darf nicht pauschal den Spieler bewegungsunfähig machen.

Sie muss aber genügend Commitment besitzen, damit das Kampfsystem nicht in:

> Angriff → sofort abbrechen → Angriff

zerfällt.

Konkrete Recovery-Dauer und Abbruchmöglichkeiten gehören in das jeweilige Attack-/Weapon-/Skill-Design.

---

# 17. Player Expression

M07 muss mindestens diese grundlegenden Spielweisen ermöglichen:

## Aggressiver Nahkampf

- Chancen schnell nutzen,
- Druck aufbauen,
- Recovery-Risiken akzeptieren.

## Defensive Parry-Spielweise

- Gegner lesen,
- Timing beherrschen,
- aus Parrys eigene Chancen erzeugen.

## Dodge-orientiertes Spiel

- Mobilität,
- Angriffslinien verlassen,
- Positionierung als Ressource nutzen.

## Block-orientiertes Spiel

- sicheren Raum schaffen,
- Druck kontrollieren,
- passende Gegenangriffe wählen.

## Schwere Angriffe

- höheres Commitment,
- größere Wirkung,
- stärkerer Positionierungsdruck.

## Schnelle präzise Angriffe

- geringeres Commitment,
- geringere Einzelwirkung,
- stärkere Abhängigkeit von Timing und Positionierung.

M07 balanciert diese Rollen noch nicht vollständig.

Es muss nur sicherstellen, dass sie aus derselben Foundation entstehen können.

---

# 18. Interaction with M06

Die Grenze ist verbindlich.

## M07 entscheidet

- wann eine Action aktiv ist,
- ob ein Kontakt überhaupt möglich ist,
- ob die räumlichen Bedingungen stimmen,
- welcher Defense State maßgeblich ist,
- ob der Kontakt zu Miss/Evade, Block, Parry oder Hit führt,
- wann eine Attack Instance Kontakte erzeugen darf,
- welche Combat Reaction nach M06 interpretiert wird.

## M06 entscheidet

- Damage,
- Effective Damage,
- Impact,
- Effective Impact,
- Damage Type,
- Protection,
- Resistance,
- sonstige numerische Hit Resolution,
- Secondary-Effect-Information.

M07 darf keine parallele Damage Resolution hinzufügen.

---

# 19. Example — Normal Sword Attack

## M07

Spieler startet Angriff.

↓

Startup.

↓

Commit.

↓

Active Window.

↓

Ziel befindet sich innerhalb der gültigen räumlichen Bedingungen.

↓

Ziel dodged nicht.

↓

Kein Block.

↓

Kein Parry.

↓

**Defense Outcome = Hit.**

---

## M06

M06 erhält den bestätigten Kontakt und löst:

**Damage + Impact + Result**

auf.

---

## M07

M07 verarbeitet den Effective Impact für:

- Hit Reaction,
- möglichen Interrupt,
- möglichen Stagger,
- mögliche Positionsreaktion.

Danach:

**Recovery.**

---

# 20. Future Weapon Compatibility

M07 enthält keine konkrete Waffenlogik.

Eine spätere Weapon Foundation muss aber unterschiedliche Waffen über dieselbe Combat-Grundlage ausdrücken können.

Beispielsweise:

### Dolch

- kurzer Startup,
- kleine Reichweite,
- kurze Recovery,
- geringe Einzelwirkung.

### Kriegshammer

- längerer Startup,
- größerer Commitment-Bereich,
- starke Wirkung,
- längere Recovery.

### Speer

- große Reichweite,
- andere räumliche Kontaktanforderungen,
- andere Positionierungsdynamik.

M07 stellt das Format bereit.

Weapon Design definiert die Anwendung.

---

# 21. Future Magic Compatibility

Magie verwendet grundsätzlich denselben Combat-Ansatz.

Ein Zauber kann später:

- einen direkten Active Window besitzen,
- als Projektil auftreten,
- zeitverzögert aktiv werden,
- einen Bereich kontrollieren,
- mehrere explizite Hit-Phasen besitzen.

M07 muss dafür nicht zu einem zweiten Magiesystem werden.

Das Fundament bleibt:

> **Magie ist kein zweites Kampfsystem.**

Die konkrete Zauberlogik gehört später in Magic-/Ability-Design.

---

# 22. Progression Considerations

Progression soll M07 erweitern, nicht ersetzen.

Spätere Skills können beispielsweise:

- neue Attack Patterns,
- alternative Commitments,
- besondere defensive Aktionen,
- neue Counter-Möglichkeiten,
- veränderte Action Windows,
- spezielle Reaktionen

ermöglichen.

Der bevorzugte Fortschritt lautet:

> **Neue Möglichkeiten statt ausschließlich größere Zahlen.**

Beispiel:

Früher Kämpfer:

> Angriff → Recovery.

Fortgeschrittener Kämpfer:

> bestimmter Angriff → besondere Folgemöglichkeit unter definierten Bedingungen.

M07 besitzt selbst keine Skill-XP- oder Mastery-Logik.

---

# 23. Potential Problems and Guardrails

## 23.1 Animation ersetzt Gameplay-Regeln

Animation darf die Gameplay-Wahrheit darstellen, aber nicht heimlich ersetzen.

## 23.2 Combat Spam

Zu kurze Startup-/Recovery-Phasen führen zu Spam.

## 23.3 Combat Slowness

Zu lange Recovery oder übermäßige Hit Reactions bremsen den Flow.

## 23.4 Dodge Spam

Dodge darf nicht permanent sicher und kostenlos sein.

## 23.5 Block Spam

Block darf nicht jede Konsequenz neutralisieren.

## 23.6 Parry Obligation

Parry darf keine Pflichtspielweise werden.

## 23.7 Stagger Lock

Impact darf keine endlose Stagger-Kette erzeugen.

## 23.8 Physics Instability

Freie Physik darf nicht zu unvorhersehbaren Combat-Ergebnissen führen.

## 23.9 Hit Stop Overuse

Hit Stop darf nicht den eigentlichen Spielfluss zerstören.

## 23.10 Giant Combat System

M07 darf nicht schrittweise zu einem Container für:

- Waffen,
- Magie,
- Status,
- Equipment,
- Progression,
- Animation,
- VFX,
- AI

werden.

Neue Verantwortung muss weiterhin beim zuständigen System liegen.

---

# 24. Technical Requirements — Concept Level

Noch keine konkrete technische Implementierung.

Die spätere Architektur muss konzeptionell folgende Informationen sauber transportieren können.

## 24.1 Attack State

Mindestens:

- Intent,
- Startup,
- Commit,
- Active,
- Recovery,
- Completed / Interrupted.

## 24.2 Defense State

Mindestens:

- Normal,
- Dodge Active,
- Block Active,
- Parry Window.

## 24.3 Attack Context

Konzeptionell erforderlich:

- Angreifer,
- Ziel,
- Attack Instance,
- zeitliche Phase,
- räumliche Attack-Daten,
- relevanter Defense-Kontext,
- Region-/Lebensdauer-Kontext, soweit erforderlich.

## 24.4 Contact Result

M07 muss eindeutig unterscheiden können zwischen:

- kein Kontakt / Evade,
- Parry,
- Block,
- Hit.

## 24.5 Handoff to M06

Bei einem bestätigten Kontakt übergibt M07 genau den dafür notwendigen Kontext an M06.

M06 löst den Kontakt auf.

M07 erhält anschließend das Ergebnis zurück und erzeugt daraus den nächsten Combat-State.

## 24.6 No Global Combat Bus

M07 benötigt keinen globalen Event-Bus, keine universelle Combat-Registry und keinen globalen Trefferkatalog.

Verantwortlichkeiten bleiben lokal und explizit.

---

# 25. Scope

## Bestandteil von M07

- Action Lifecycle,
- Startup,
- Commit,
- Active Window,
- Recovery,
- Contact Validation,
- räumliche und zeitliche Kontaktregeln,
- Dodge-Grundprinzip,
- Block-Grundprinzip,
- Parry-Grundprinzip,
- Defense Outcomes,
- Attack Instances,
- grundlegende Multi-Hit-Unterstützung,
- Impact → Combat Reaction,
- Stability-Interpretation,
- grundlegende Player-Expression-Basis.

---

# 26. Non-Scope

Nicht Bestandteil von M07:

- Weapon Foundation,
- Weapon Balancing,
- vollständiges Combo-System,
- Magic Foundation,
- Status Effects,
- Equipment,
- Skill-/Mastery-System,
- Crit-System,
- Boss-Sondermechaniken,
- vollständige Physics-Simulation,
- Animationstechnologie,
- konkrete Collision-Implementierung,
- Skill-XP,
- globale Levelskalierung,
- allgemeine AI-Entscheidungslogik.

Diese Systeme dürfen M07 später verwenden oder erweitern, gehören aber nicht in die Foundation.

---

# 27. M07 vs. Later Systems

| Thema | M07 | Späteres System |
|---|:---:|---|
| Action Lifecycle | ✓ | |
| Startup / Commit / Active / Recovery | ✓ | |
| allgemeine Kontaktregeln | ✓ | |
| Attack-spezifische Geometrie | | Weapons / Abilities / Technical Layer |
| Dodge-Grundprinzip | ✓ | |
| Block-Grundprinzip | ✓ | |
| Parry-Grundprinzip | ✓ | |
| Defense Outcome | ✓ | |
| Damage-Berechnung | | M06 |
| Protection / Resistance | | M06 |
| Effective Impact Berechnung | | M06 |
| Impact → Combat Reaction | ✓ | |
| konkrete Waffenwerte | | Weapons |
| konkrete Angriffstechniken | | Weapons / Skills |
| Zaubereffekte | | Magic |
| Burning / Freeze / Poison | | Status Effects |
| Skill-XP | | Progression |
| Crits | | späteres Feature |
| Boss-Sonderregeln | | Boss / Encounter |
| Animationen | | Presentation |
| VFX / Sound / Camera | | Presentation |
| konkrete Collision-Technik | | Technical Architecture |

---

# 28. Open / Deferred Tuning

Die Foundation ist verbindlich, konkrete Zahlen dürfen später getestet und ausbalanciert werden.

Bewusst noch nicht festgezurrt sind:

1. exakte Startup-/Active-/Recovery-Dauern,
2. genaue Dodge-Protection-Dauer,
3. konkrete Dodge-Ressourcen,
4. genaue Block-Ressourcen,
5. genaue Block-Wirkung,
6. exakte Parry-Fenster,
7. konkrete Stagger-Schwellen,
8. spezifische Weapon Profiles,
9. spezifische Boss-Regeln.

Diese Punkte sind **Tuning- oder spätere Content-Fragen**, keine offenen Architekturentscheidungen.

M07 darf wegen dieser offenen Zahlen trotzdem implementiert werden.

---

# 29. Acceptance Criteria

M07 ist als Gameplay Foundation akzeptierbar, wenn:

### A1 — Contact Separation

Eindeutig dokumentiert ist:

> **M07 bestimmt, ob Kontakt entsteht.**

> **M06 bestimmt, was der Kontakt bewirkt.**

### A2 — No Hidden Accuracy

Ein sichtbarer Fehlschlag kann nicht durch einen generischen Accuracy-Wert automatisch zum Treffer werden.

### A3 — Clear Lifecycle

Jede reguläre Attack Action besitzt nachvollziehbar:

> Startup → Commit → Active → Recovery.

### A4 — Active Defense

Dodge, Block und Parry sind echte aktive Entscheidungen.

### A5 — One Defense Outcome

Ein Kontakt besitzt genau einen maßgeblichen Defense Outcome.

### A6 — No Defense Stacking

Dodge, Block und Parry werden nicht als additive Wahrscheinlichkeiten oder Schutzwerte kombiniert.

### A7 — Impact Integration

M07 verwendet M06 Effective Impact und Stability und führt keine parallele Poise-/Stagger-Stat ein.

### A8 — Controlled Reactions

Hit Reaction, Interrupt und Stagger sind kontrollierte Gameplay-Reaktionen und keine freie Physiksimulation.

### A9 — No Unintended Multi-Hit

Eine einzelne Hit-Phase darf ein Ziel nicht versehentlich mehrfach treffen.

### A10 — Player Expression

Die Foundation unterstützt mindestens:

- aggressives Spiel,
- Block-orientiertes Spiel,
- Parry-orientiertes Spiel,
- Dodge-/Positionsspiel,
- schwere Angriffe,
- schnelle präzise Angriffe.

### A11 — Future Compatibility

Spätere Waffen und Magie können eigene Attack Profiles verwenden, ohne M07 für jeden neuen Angriffstyp neu zu bauen.

### A12 — No Scope Creep

M07 führt keine zusätzlichen parallelen Systeme für:

- Accuracy,
- Hit Chance,
- Poise,
- Stagger Armor,
- Crits,
- Limb Damage

ein, solange kein konkreter späterer Gameplay-Mehrwert dies rechtfertigt.

### A13 — Presentation Separation

Hit Stop, Animation, VFX, Sound und Camera Feedback bleiben Präsentationsverantwortung und werden nicht zum Kern von M07.

### A14 — Architecture Discipline

Kein globaler Event-Bus, keine globale Combat-Registry und keine zweite zentrale Schadensberechnung.

---

# 30. Final Design Summary

Die verbindliche M07-Grundlage lautet:

> **Actions create windows.**

> **Position and timing determine contact.**

> **Active defense changes the contact outcome.**

> **M06 resolves the confirmed contact.**

> **Combat interprets the resulting impact and creates the next opportunity.**

Der Gameplay-Loop lautet:

**Entscheidung → Action → Startup / Commitment → Active Window → Kontakt oder Fehlschlag → Defense Outcome → M06 Resolution → Combat Reaction → Recovery → neue Entscheidung**

Die wichtigste Grenze bleibt:

> **M07 definiert, wann und unter welchen Bedingungen ein Angriff mit der Welt in Kontakt kommt.**

> **M06 definiert, welche numerische Wirkung dieser bestätigte Kontakt besitzt.**

> **Weapons, Magic, Skills und Status Effects definieren später die konkreten Inhalte, die auf diesen Foundation-Regeln aufbauen.**

Damit bleibt M07 klein genug, um stabil zu bleiben, und tief genug, um Lichterhains gewünschtes gewichtetes Action-Combat zu tragen.

**Dieses Dokument ist die verbindliche Gameplay-/Systems-Design-Grundlage für die technische M07-Implementierung.**
