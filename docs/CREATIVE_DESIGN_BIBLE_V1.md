# RPG CREATIVE & GAME DESIGN BIBLE v1.0 — FOUNDATION

**Maßgebliche kreative Referenz für Lichterhain.** Vollständige Text-/Tabellenübertragung der von Tim bereitgestellten DOCX. Das Original bleibt unverändert; nur die Darstellung wurde nach Markdown übertragen.

Quelle: `RPG_Creative_Game_Design_Bible_v1.0.docx` · SHA-256: `17f96df834dc9e5fd353bb965c48a0867056bef361e5f2fe56accfe0e7899263`.

## Verbindliche Integrationsregeln

- Diese Referenz beschreibt das gewünschte Spielerlebnis. [TECHNICAL_DESIGN.md](../TECHNICAL_DESIGN.md) beschreibt die tatsächlich implementierte Technik; [ROADMAP.md](../ROADMAP.md) besitzt Reihenfolge und Abnahme der Foundation-Milestones.
- Technische Einschränkungen dürfen die zentrale Spielerfahrung nicht still verändern. Verhindern sie diese, muss das als Design-/Architekturproblem sichtbar werden.
- Offene Details bleiben offen. Neue Ergänzungen sind bis zur Bestätigung durch Tim **PROPOSAL**, auch wenn sie zur Vision passen.
- Konflikte werden mit vorgeschlagener Änderung, unterstützten und verletzten Designregeln sowie Empfehlung benannt; neue Ideen haben keinen automatischen Vorrang.
- Vor einer späteren Feature-Implementierung: Priorität, vorhandene Abhängigkeiten, Foundation-Reife, erforderliche Architekturänderungen und Tests prüfen. Diese Referenz zieht keine Gameplay-Systeme vor M01–M04 vor.

---

RPG CREATIVE &GAME DESIGN BIBLE

Version 1.0 - Foundation

Open-World Fantasy RPG

> Dokumentstatus. Dies ist die erste vollständige Design-Bible auf Grundlage der bisher gemeinsam herausgearbeiteten Spielerfahrung. Sie definiert die kreativen Leitplanken und Systemphilosophie. Konkrete Zahlen, Inhalte und technische Implementierungsdetails dürfen später präzisiert werden, solange sie die hier festgelegten Prinzipien nicht verletzen.

Primärer Zweck: gemeinsame Referenz für Game Director, Design und Astra-Implementierung

## Inhalt

1. Projektidentität und zentrale Spielerfantasie

2. Übergreifende Designprinzipien

3. Welt, Atmosphäre und Exploration

4. Prozedurale Welt und Weltlogik

5. Gefahr, Schwierigkeit und Konsequenzen

6. Traversierung, Reisen und Weltzugang

7. Combat Philosophy und Physik

8. Charakterentwicklung, Klassen und Spezialisierung

9. Magie

10. Loot, Items und Progression

11. Economy

12. Crafting und Verzauberung

13. Quests, Environmental Storytelling und Zeit

14. NPCs, Beziehungen und lebendige Städte

15. Ruhe, Nebenaktivitäten und optionale Tiefe

16. Emergent Gameplay und Player Expression

17. Meta-Systeme, UI und Spielerkomfort

18. Endgame-Philosophie

19. Astra Design Rules

20. Konfliktregeln für zukünftige Entscheidungen

21. Noch offene Detailentscheidungen

22. Design-Mantras

## 1. Projektidentität und zentrale Spielerfantasie

Das Spiel ist ein großes Open-World-Fantasy-RPG mit einer Skyrim-artigen Grundfantasie, aber stärkerer Atmosphäre, glaubwürdigerer Physik, höherer visueller Qualität, größerer und detaillierterer Welt sowie stärkerem Fokus auf emergente und persönliche Spielerlebnisse.

Die Karte soll sehr groß und prozedural generiert sein und aus unterschiedlichen Regionen/Biomen bestehen. Der Spieler soll nicht nur Inhalte konsumieren, sondern eine Welt erleben, in der Neugier, Beobachtung, Entscheidungen, Spezialisierung und zufällige Situationen zu seiner eigenen Geschichte führen.

> Zentrale Spielerfantasie. „Ich habe nicht nur ein Spiel gespielt. Ich habe in dieser Welt gelebt und meine eigene Geschichte darin erlebt.“

Der Spieler soll nach vielen Stunden nicht hauptsächlich an erledigte Questmarker denken, sondern an eigene Geschichten: eine gefährliche Reise, eine unerwartete Entdeckung, einen NPC, den er gerettet oder verloren hat, ein Gebiet, das er zu früh betreten hat, einen außergewöhnlichen Gegenstand, einen improvisierten Kampf oder eine Situation, die nur durch das Zusammenspiel der Systeme entstanden ist.

| Dimension | Zielerlebnis | Zu vermeiden |
| --- | --- | --- |
| Welt | groß, geheimnisvoll, schön, gefährlich und unabhängig vom Spieler | Level statt Ort; leere Flächen ohne Grund zur Neugier |
| Exploration | Curiosity over Instruction | Questmarker als Standardantwort auf alles |
| Progression | neue Möglichkeiten und individuelle Spezialisierung | nur größere Zahlen |
| Combat | schnell in der Reaktion, schwer im Impact | stumpfes DPS-Spamming oder chaotische Physiksimulation |
| Simulation | Immersion und neue Möglichkeiten | Micromanagement ohne Mehrwert |
| Story | Spieler entdeckt und interpretiert | alles wird erklärt und abgeschlossen |
| Tiefe | optional und unter der Oberfläche | Systeme werden zu Pflichten |

## 2. Übergreifende Designprinzipien

| Prinzip | Bedeutung |
| --- | --- |
| Komplexität nur mit Mehrwert | Ein System verdient seine Komplexität nur dann, wenn sie Immersion, Ausdruck, Entscheidungstiefe oder neue spielerische Möglichkeiten erzeugt. |
| Optionen vor Zwang | Vertiefungssysteme sollen Vorteile bieten, aber Spieler nicht ständig mit Pflichten, Checks und Mikromanagement beschäftigen. |
| Curiosity over Instruction | Die Welt soll den Spieler neugierig machen. Das Spiel zeigt Möglichkeiten; es muss nicht ständig Lösungen vorgeben. |
| Die Welt existiert auch ohne den Spieler | NPCs, Orte, Konflikte und wirtschaftliche Abläufe dürfen sich unabhängig weiterentwickeln. |
| Die Welt vergisst nichts, aber sie bleibt nicht stehen | Konsequenzen sollen spürbar sein, gleichzeitig soll die Welt weiterleben und Ersatzstrukturen bilden. |
| Realismus mit Zweck | Realismus ist kein Selbstzweck. Er ist dann wertvoll, wenn er Immersion oder Gameplay verbessert. |
| Tiefe unter der Oberfläche | Fortgeschrittene Systeme dürfen reichhaltig sein, ohne jeden Spieler zu zwingen, sie vollständig zu verstehen. |
| Freiheit ohne Handlungsleere | Der Spieler bekommt echte Möglichkeiten, aber die Welt muss auf diese Möglichkeiten reagieren. |
| Player Expression | Probleme sollen nach Möglichkeit auf mehrere Weisen lösbar sein; Systeme sollen unerwartete Lösungen zulassen. |
| Spezialisierung ohne Gefängnis | Grundsätzlich kann vieles erlernt werden, aber langfristige Schwerpunktsetzung bestimmt, worin ein Charakter Meister werden kann. |
| Konsequenzen ohne unnötige Frustration | Scheitern darf Geschichten verändern, soll aber nicht nur bestrafen oder den Spielspaß zerstören. |
| Die Welt soll Geschichten erzeugen | Prozedurale Systeme sollen glaubwürdige Anlässe für persönliche Geschichten erzeugen, nicht bloß Zufallskombinationen. |

## 3. Welt, Atmosphäre und Exploration

Die emotionale Grundspannung der Welt entsteht aus der Kombination von Vertrautheit, unbekanntem Raum, Schönheit, Gefahr und Entdeckung. Der Spieler soll regelmäßig das Gefühl haben: Hinter dem Bekannten liegt etwas Größeres, das ich noch nicht kenne.

Gefahr soll Neugier verstärken, nicht jede Bewegung verhindern. Der Spieler soll eine leichte Unsicherheit spüren: „Bin ich hier noch sicher?“ Diese Unsicherheit ist besonders wertvoll, wenn sie in echte Entdeckung münden kann.

### 3.1 Discovery Curve

Die Welt soll Kontraste verwenden. Nicht alles darf spektakulär sein, sonst verliert das Außergewöhnliche seine Bedeutung.

| Stufe | Charakter |
| --- | --- |
| Normal | gewöhnliche Natur, Wege, Dörfer, Alltag |
| Interessant | ungewöhnlicher Ort, auffälliges Objekt, Spuren, kleine Entdeckung |
| Mysteriös | Hinweise auf eine Geschichte, deren Bedeutung unklar ist |
| Außergewöhnlich | bemerkenswerter Ort, seltenes Ereignis, besondere Belohnung |
| Sehr selten magisch | Momente, die der Spieler als echten „Wow“-Fund erinnert |

### 3.2 Environmental Storytelling

- Umgebung soll Geschichten erzählen, ohne sie vollständig zu erklären.

- Der Spieler darf eigene Theorien bilden; diese müssen nicht immer bestätigt oder widerlegt werden.

- Zwei Spieler dürfen denselben Ort unterschiedlich interpretieren.

- Orte dürfen sich über Zeit verändern.

- Eine spätere Rückkehr soll neue Informationen oder Situationen ermöglichen.

- Beobachtung ist oft wertvoller als Exposition.

> Leitsatz. „Die Welt soll dem Spieler Dinge geben, über die er nachdenken kann, nicht alles, was er verstehen muss.“

## 4. Prozedurale Welt und Weltlogik

Die Welt soll sehr groß und prozedural generiert sein, ähnlich der Grundidee einer Minecraft-Welt: viele Regionen, Biome und unterschiedliche geographische Situationen. Die prozedurale Generierung soll jedoch nicht aus beliebigen Zufallskombinationen bestehen.

### 4.1 Curated Procedural Generation

Die bevorzugte Architektur ist eine Mischung aus handgearbeiteten Archetypen/Regeln und prozeduraler Variation. Entwickler definieren glaubwürdige Muster; das System wählt konkrete Orte, Personen, Details und Ausprägungen.

| Handgearbeitet / kontrolliert | Prozedural variabel |
| --- | --- |
| Story-Archetypen | genauer Fundort |
| Logik und Voraussetzungen | konkrete NPCs |
| Erzählregeln | Namen und Details |
| Item-Verteilungsregeln | Gelände und Position |
| Regionsidentität | Ausprägung der Ereignisse |
| mögliche Reaktionen | Zeitpunkt und konkrete Kombinationen |

> Prinzip. „Prozedurale Systeme sollen Geschichten variieren, nicht Geschichten ersetzen.“

### 4.2 Loot- und Weltlogik als Teil der Generierung

Zufall ist erwünscht, aber nur innerhalb glaubwürdiger Pools und regionaler Logik. Ein besonderes Item darf variabel platziert sein, muss aber in einen Kontext gehören, in dem sein Auftreten plausibel ist.

- Elfenregionen: elfische Materialien, Glaswaffen, besondere elfische Magie.

- Zwergenregionen: zwergische Waffen, Rüstungen und Schmiedekunst.

- Ruinen und verlorene Städte: antike Waffen und Relikte.

- Bestimmte Kreaturen: passende Materialien und Beute.

- Regionen sollen unterschiedliche Identitäten und Beuteprofile besitzen.

## 5. Gefahr, Schwierigkeit und Konsequenzen

Die Welt besitzt eine klare Gefahrenhierarchie. Nicht jede Region soll gefährlich sein, aber der Spieler soll regelmäßig erkennen können, dass es Orte gibt, an denen er noch nicht bereit ist.

| Gefahrenstufe | Funktion |
| --- | --- |
| Sicher / Einsteiger | Dörfer, Hauptwege, frühe Regionen, Grundlagen lernen und leveln |
| Herausfordernd | stärkere Wildnis, mittlere Gegner, gute Vorbereitung hilfreich |
| Gefährlich | fortgeschrittene Regionen, starke Gegner, hohe Belohnungen |
| Extrem | Gebiete/Bosse, die selbst starke Spieler ernst nehmen müssen |
| Ausnahmsweise tödlich | Bereiche, die den Spieler klar warnen, dass er an seine Grenzen stößt |

### 5.1 Zugänglichkeit der Regionen

Starke Regionen sollen nicht grundsätzlich durch unsichtbare Levelschranken blockiert werden. Ein mutiger Spieler darf sehr früh dorthin reisen und versuchen, dort zu überleben. Er wird aber wahrscheinlich schnell an seine Grenzen stoßen und später zurückkehren müssen.

> Ziel. „Du kannst dorthin gehen. Aber die Welt darf dir glaubwürdig zeigen, dass du vielleicht noch nicht bereit bist.“

### 5.2 Zeitliche Konsequenzen

Bestimmte Situationen besitzen echte Zeitfenster. Beispiel: Ein entführter Händler kann innerhalb von 1–2 Ingame-Wochen gerettet werden. Wird er nicht rechtzeitig gerettet, stirbt er. Die Stadt bleibt funktionsfähig und erhält einen neuen Händler, aber die zuvor aufgebaute Beziehung und Vorteile mit dem alten Händler sind verloren.

Damit entsteht eine Konsequenz, die real ist, ohne den gesamten Spielstand zu zerstören. Save/Load bleibt eine mögliche Spielerentscheidung, mit der eine unerwünschte Entwicklung rückgängig gemacht werden kann.

> Leitsatz. „Die Welt vergisst nichts, aber sie bleibt nicht stehen.“

### 5.3 Schwierigkeitsgrade

Die Spieler entscheiden selbst, wie anspruchsvoll sie spielen möchten. Vorgesehene Ausgangsprofile: Anfänger, Normal, Pro, Hardcore und Permadeath. Zusätzlich sollen relevante Einstellungen individuell angepasst werden können.

## 6. Traversierung, Reisen und Weltzugang

Reisen ist Teil des Erlebnisses, darf aber mit der Zeit nicht zur Pflicht werden. Die Welt soll zu Fuß erlebbar sein und gleichzeitig effiziente Reiseoptionen anbieten.

| System | Richtung |
| --- | --- |
| Zu Fuß | zentrale Form der Erkundung |
| Boote | Wasser als echte Traversierungsoption |
| Schwimmen | freie Wasserbewegung, dort wo sinnvoll |
| Klettern | zusätzliche vertikale Freiheit und alternative Wege |
| Mounts | zum Projektstart bewusst nicht priorisiert |
| Schnellreise | nur zwischen besonderen, bereits erkundeten Punkten |
| Reiseereignisse | können Entdeckung, Gefahr und kleine Geschichten erzeugen |

Schnellreise dient als Komfortventil. Sie darf die Welt nicht ersetzen, sondern soll verhindern, dass das wiederholte Durchqueren bereits bekannter Gebiete ermüdend wird.

## 7. Combat Philosophy und Physik

Kampf soll schnell reagieren, aber schwer und glaubwürdig wirken. Ein Treffer muss sich anfühlen, als hätte er tatsächlich Kontakt hergestellt.

- Hit-Feedback, Animation, Knockback und Impact sind wichtiger als reine Schadenszahlen.

- Blocken, Ausweichen und Parieren sollen flüssig miteinander verbunden sein.

- Ein sauber getimter Parry soll ein starkes „Ich habe das perfekt erwischt“-Gefühl erzeugen.

- Wie der Spieler angreift soll eine Rolle spielen; blindes Hineinstürmen soll nicht immer die beste Lösung sein.

- Physik ist Gameplay: Stöße, Gewicht, Umgebung, Abgründe und Elementeffekte können taktische Möglichkeiten erzeugen.

- Körperteilverletzungen und andere komplizierte Simulationen werden nicht verfolgt, wenn sie den Spielfluss nicht sinnvoll verbessern.

> Prinzip. „Physik soll Kämpfe glaubwürdiger, dynamischer und spielerisch interessanter machen - nicht unnötig komplex.“

## 8. Charakterentwicklung, Klassen und Spezialisierung

Der Spieler wählt nicht dauerhaft ein enges Klassen-Gefängnis. Grundsätzlich soll ein Charakter jederzeit neue Fähigkeiten und Richtungen erlernen können. Der langfristige Spielverlauf erzeugt jedoch natürliche Spezialisierung.

### 8.1 Learning by Doing

Was der Spieler häufig tut, soll einen großen Anteil daran haben, worin sein Charakter gut wird. Bogenschießen, Schwertkampf, Magie oder andere Tätigkeiten werden durch tatsächliche Nutzung weiterentwickelt.

### 8.2 Spezialisierung mit Opportunitätskosten

Ein Spieler kann seine Richtung wechseln, aber nicht beliebig schnell sämtliche Meisterschaften gleichzeitig erreichen. Ein Charakter mit 50 Stunden Kriegerfokus kann später Magie lernen, wird im Endgame aber nicht genauso tiefe Magiemeisterschaft erreichen wie ein Spieler, der nahezu den gesamten Weg auf Magie spezialisiert hat.

| Archetyp | typische Stärke | typischer Preis |
| --- | --- | --- |
| Krieger | Waffen, Nahkampf, Widerstand, physische Techniken | weniger Tiefe in Magie und anderen Spezialisierungen |
| Magier | tiefe Magiesysteme, starke Zaubersynergien, hohe Effizienz | körperlich fragiler, weniger Nahkampfspezialisierung |
| Battlemage | Kombination aus Nahkampf und Magie, robust, vielseitig | weniger extreme Tiefe in beiden Einzelbereichen |
| Bogenschütze / Ranger | Distanz, Positionierung, Gelände und Tarnung | weniger Schwerpunkt auf schwerem Nahkampf |
| Hybride Builds | freie Kombination der vorhandenen Systeme | breitere, aber weniger extreme Meisterschaft |

> Prinzip. „Alles lernen können ≠ alles maximieren können.“

## 9. Magie

Magie soll etwas Besonderes bleiben. Grundlegende Zauber können relativ zugänglich sein, während mächtige Magie eine Kombination aus passenden Skills, Mana, Spezialisierung und langfristigem Investment verlangt.

### 9.1 Magie als langfristige Spezialisierung

- Jeder Charakter darf grundsätzlich Magie lernen.

- Mächtige Endgame-Zauber können theoretisch von jedem erlernt werden, sofern der Charakter die Voraussetzungen erfüllt.

- Ein Spieler, der sich früh und dauerhaft auf Magie spezialisiert, soll dieselben Endgame-Zauber stärker, effizienter und mit besseren Synergien einsetzen können.

- Magie soll nicht nur über größere Schadenszahlen skalieren; neue Zauberstufen sollen qualitativ neue Möglichkeiten eröffnen.

### 9.2 Mana

Mana ist eine zentrale Ressource für starke Magie. Es kann unter anderem durch Charakterentwicklung, Ausrüstung, Verzauberungen und besondere Umgebungen beeinflusst werden.

### 9.3 Magieschulen

Eine Struktur ähnlich Skyrim mit unterschiedlichen Magieschulen ist als Ausgangspunkt geeignet. Denkbare Schulen sind beispielsweise Zerstörung, Wiederherstellung, Illusion, Veränderung und Beschwörung. Die endgültige Einteilung und genaue Mechanik bleibt eine spätere Designentscheidung.

## 10. Loot, Items und Progression

Loot ist teilweise zufällig, aber niemals völlig kontextlos. Die Welt soll logisch verteilen, welche Itemtypen wo vorkommen. Besondere Gegenstände müssen gefunden oder verdient werden und ihre Bedeutung visuell vermitteln.

### 10.1 Drei Ebenen von Ausrüstung

| Ebene | Rolle |
| --- | --- |
| Allgemeines Equipment | häufiger Loot, regelmäßige Verbesserungen, funktionale Grundausstattung |
| Hochwertige / spezialisierte Items | seltenere Gegenstände mit starken Build-Eigenschaften, potenziell lange relevant |
| Einzigartige / legendäre Items | starke Identität, besondere Mechanik, visuell imposant, nicht nur höherer Zahlenwert |

### 10.2 Endgame-Balance

Generisches Level-scaling soll besondere Gegenstände nicht automatisch entwerten. Ein legendäres Item soll wegen seiner einzigartigen Mechanik oder Synergie wertvoll bleiben können. Stärke entsteht aus dem Zusammenspiel von Item, Build und Spielweise.

> Ziel. Der Spieler soll nicht nach 200 Stunden das Gefühl haben, dass ein liebloses Standarditem besser ist als sein legendärer persönlicher Fund, nur weil dessen Zahlen größer sind.

## 11. Economy

Die Economy soll langfristig interessant bleiben, ohne zum Wirtschaftssimulator zu werden. Geld ist eine echte Ressource und soll auch im Endgame einen Zweck behalten.

- Geld darf in hochwertigen Ausrüstungs-, Dienstleistungs- und Spezialangeboten relevant bleiben.

- Handel soll nachvollziehbar und interessant sein, ohne permanentes Preis-Micromanagement zu erfordern.

- Lokale Unterschiede in Angebot, Nachfrage und Verfügbarkeit sind wünschenswert.

- Wirtschaftliche Veränderungen dürfen aus Ereignissen der Welt entstehen, sollten aber nicht zu ständiger Verwaltungspflicht werden.

- Künstliche Goldsenken ohne spielerischen Mehrwert sind zu vermeiden.

## 12. Crafting und Verzauberung

Crafting und Verzauberung sind optionale Vertiefungssysteme. Wer sie nutzt, kann seine Ausrüstung stark optimieren; wer sie ignoriert, soll trotzdem einen starken und funktionierenden Charakter spielen können.

> Prinzip. „Mehr Tiefe für diejenigen, die sie wollen - keine Pflicht für alle.“

## 13. Quests, Environmental Storytelling und Zeit

Quests sollen Orientierung geben, ohne den Spieler wie an einer Schiene zu führen. Der Spieler erhält genug Informationen, um eine Richtung zu erkennen, aber Raum für eigene Ermittlungen.

### 13.1 Quest Loop

NPC / Ausgangsinformation -> Hypothese -> eigene Untersuchung -> neue Hinweise -> neue Hypothese -> Entdeckung. Nicht jede Nebenquest muss vollständig und eindeutig aufgelöst werden.

### 13.2 Unterschiedliche Konsequenzarten

| Typ | Beispiel |
| --- | --- |
| Permanentes Ereignis | NPC stirbt und wird ersetzt |
| Veränderbares Ereignis | Situation verändert sich abhängig von Spieleraktion |
| Zeitabhängiges Ereignis | Quest verschwindet oder entwickelt sich anders, wenn zu viel Zeit vergeht |
| Persistentes Geheimnis | Spieler erhält Hinweise, aber nie eine eindeutige Auflösung |

### 13.3 Main Quest vs. Side Quest

Hauptquests dürfen stärker geführt und narrativ stabil sein. Nebenquests dürfen stärker auf Zeit, Zufall, Konsequenzen und offene Enden reagieren.

## 14. NPCs, Beziehungen und lebendige Städte

NPCs sollen durch Routinen und Erinnerungen glaubwürdig wirken. Sie arbeiten, essen, schlafen, interagieren und reagieren auf relevante Ereignisse. Das System muss nicht jede Kleinigkeit simulieren, wenn sie keine Bedeutung für das Spiel hat.

### 14.1 NPC-Beziehungen

- Persönlichkeit ist wichtiger als reine Questfunktion.

- NPCs sollen sich an relevante Handlungen des Spielers erinnern.

- Verlust eines NPCs darf emotionales Gewicht haben.

- Verlust soll nicht automatisch den gesamten Spielspaß ruinieren.

- Beziehungen sollen keine Tamagotchi-Pflichten erzeugen.

> Prinzip. „Emotionale Konsequenzen ohne emotionale Zwangsarbeit.“

### 14.2 Städte

Städte sollen lebendige, sichere und angenehmere Ruhepole sein. Sie dürfen sich ohne den Spieler verändern, sollen ihn aber nicht zum dauerhaften Stadtverwalter machen.

## 15. Ruhe, Nebenaktivitäten und optionale Tiefe

Spieler sollen bewusst die Atmosphäre genießen können, ohne das Gefühl zu haben, Zeit ineffizient zu verschwenden. Sitzen am Feuer, Beobachten von Tieren, Kochen, Angeln, Schlafen oder Naturbeobachtung dürfen existieren, ohne dass alles davon verpflichtend ist.

- Ein Spieler darf einfach die Welt genießen.

- Wer mehr Systeme möchte, kann sie aktiv nutzen.

- Kochen kann z. B. Vorteile geben, muss aber nicht zwingend betrieben werden.

- Survival-Mechaniken wie ständiges Verletzungsmanagement, Feuerholz sammeln oder häufige Haltbarkeitskontrolle gehören nicht in den Kernmodus.

- Ein möglicher späterer Survival-Modus könnte strengere Systeme separat anbieten.

### 15.1 Reisevorbereitung

Für besonders schwierige Reisen darf Vorbereitung bedeutend sein. Beispiele: Essen mit guten Effekten, erneuerte Ausrüstung, Tränke oder spezielle Buffs. Diese Maßnahmen sollen einen Vorteil geben, aber idealerweise keine Checkliste darstellen, die bei jeder Reise abgearbeitet werden muss.

## 16. Emergent Gameplay und Player Expression

Das RPG soll Situationen nicht nur über vorgeplante Lösungen definieren. Systeme müssen miteinander interagieren, sodass Spieler mit eigenen Ideen überraschen können.

### 16.1 Mehrere Ansätze

- Kriegshammer / Schwert: direkter Angriff.

- Bogen: Distanz und Positionierung.

- Illusion: Gegner manipulieren oder gegeneinander ausspielen.

- Feuer: Umwelt oder Gegner beeinflussen.

- Frost: Gegner kontrollieren oder Gelände verändern.

- Klettern und Gelände: alternative Zugänge.

- Physik: Gegner stoßen, Gegenstände nutzen, Umgebungsgefahren einsetzen.

### 16.2 Welt entscheidet anhand ihrer Systeme

Spieler sollen kreative Aktionen versuchen dürfen, auch wenn die Entwickler sie nicht als einzelne Lösung geplant haben. Erfolg hängt von Systemzuständen ab, etwa Stärke einer Fähigkeit, Widerstände, Glaubwürdigkeit einer Illusion, Umgebung und Beziehungen zwischen NPCs.

> Prinzip. „Das Spiel sagt nicht immer, was erlaubt ist. Die Systeme entscheiden, ob und wie gut die Idee funktioniert.“

## 17. Meta-Systeme, UI und Spielerkomfort

Die Meta-Systeme sollen grundsätzlich zugänglich und Skyrim-artig in ihrer Klarheit sein. Die UI muss schön, übersichtlich, intuitiv und leicht verständlich sein.

- Grundlegende Spielmechaniken dürfen direkt erklärt werden.

- Fortgeschrittene Möglichkeiten sollen möglichst durch die Welt, NPCs und Beobachtung vermittelt werden.

- Questlog und Karten helfen bei Orientierung, dürfen aber die Welt nicht vollständig „auflösen“.

- Selbst gesetzte Markierungen und entdeckte Orte sind wertvoll.

- Schnellreise dient Komfort, nicht als Ersatz für Exploration.

- Vermeide überladene UIs und Informationsspam.

> Lernprinzip. „Teach the tools. Let the world teach their possibilities.“

## 18. Endgame-Philosophie

Das Endgame soll nicht darin bestehen, dass jeder Spieler alle Systeme perfektioniert und alle Gegenstände besitzt. Der Wert der Spezialisierung muss bestehen bleiben.

- Spezialisierte Meisterschaften bleiben exklusiv genug, um Builds zu unterscheiden.

- Einige Endgame-Zauber sind für alle theoretisch erreichbar, aber Spezialisten verwenden sie stärker, effizienter und mit tieferen Synergien.

- Einzigartige Items bleiben wegen ihrer Mechaniken relevant.

- Geld bleibt nützlich.

- Neue Inhalte sollen eher neue Entscheidungen und Geschichten erzeugen als nur höhere Zahlen.

- Ein langfristiger Charakter soll seine eigene Vergangenheit widerspiegeln.

## 19. Astra Design Rules

Astra soll Systeme aus dieser kreativen Vision ableiten. Technische Entscheidungen dürfen konkrete Implementierungsdetails verändern, aber nicht die folgenden Leitplanken ohne erneute Game-Director-Entscheidung.

1. Kein System einführen, dessen Hauptzweck nur „mehr Simulation“ ist.

1. Keine unnötige Mikropflicht für den Spieler.

1. Bei Konflikten zwischen technischer Eleganz und Spielererlebnis gewinnt das Spielerlebnis.

1. Bei Unsicherheit lieber eine Option als eine harte Sperre, solange Balance und Lesbarkeit erhalten bleiben.

1. Neue Systeme sollen möglichst miteinander interagieren können, statt isolierte Minigames zu bilden.

1. Prozedurale Inhalte müssen innerhalb glaubwürdiger Regeln erzeugt werden.

1. Legendäre oder außergewöhnliche Inhalte müssen sich von generischem Loot abheben.

1. Physik und KI sollen kontrolliert genug bleiben, damit Kampf und Interaktion zuverlässig funktionieren.

1. NPC-Systeme simulieren nur, was für Glaubwürdigkeit, Reaktivität oder interessante Geschichten relevant ist.

1. Neue UI darf den Spieler nicht mit Informationen überladen, die die Welt bereits vermitteln kann.

1. Wenn eine technische Einschränkung eine gewünschte Spielerfahrung verhindert, soll sie als Designproblem erkannt und nicht stillschweigend ersetzt werden.

## 20. Konfliktregeln für zukünftige Entscheidungen

Wenn zwei gewünschte Eigenschaften miteinander kollidieren, gelten folgende Prioritäten als vorläufige Entscheidungslogik:

| Konflikt | Priorität |
| --- | --- |
| Immersion vs. Micromanagement | Immersion gewinnt, sofern die Simulation nicht nervt |
| Freiheit vs. Balance | Freiheit gewinnt, solange Systeme verständlich und fair reagieren |
| Realismus vs. Spielfluss | Spielfluss gewinnt, wenn zusätzlicher Realismus keinen Mehrwert liefert |
| Prozedurale Vielfalt vs. Storylogik | Storylogik gewinnt |
| Komplexität vs. Zugänglichkeit | Mehr Komplexität nur, wenn sie echten optionalen Mehrwert bietet |
| Konsequenzen vs. Frustration | Konsequenzen sollen real sein, aber die Welt soll weiter funktionieren |
| Seltenheit vs. Belohnungsgefühl | Besondere Dinge müssen sowohl schwer zu bekommen als auch sichtbar besonders sein |

## 21. Noch offene Detailentscheidungen

Die grundlegende Philosophie ist weitgehend geklärt. Folgende Punkte können in späteren Designpässen konkretisiert werden, ohne die Vision neu zu definieren:

- Konkrete Biome, Fraktionen, Kulturen und deren Item-Pools.

- Genaue Magieschulen und Zauberbäume.

- Exakte Progressionskurven, Skillkosten und Mastery-Regeln.

- Konkrete Economy-Formeln und Händlerinventare.

- Genauer Aufbau der Karten- und Quest-UI.

- Konkrete Fast-Travel-Punkte und Reisemechaniken.

- Welche Interaktionen zwischen Wetter, Umwelt, Magie und Physik technisch möglich sind.

- Konkrete Gegner- und Bossdesigns.

- Exacte Balance des Endgames und der legendären Item-Pools.

- Welche Systeme in der ersten spielbaren Version tatsächlich priorisiert werden.

> Wichtig. Diese Punkte sind offene Ausarbeitung, keine offenen Grundsatzfragen. Neue Details dürfen ergänzt werden, solange sie mit der Design-Bible vereinbar bleiben.

## 22. Design-Mantras

“Gefahr erzeugt Neugier. Neugier führt zu Entdeckung. Entdeckung erzeugt Staunen.”

“Die Welt soll sich wie ein Ort anfühlen, nicht wie ein Level.”

“Curiosity over Instruction.”

“Die Welt schreibt ihre eigenen Geschichten.”

“Der Spieler entdeckt Geschichten, statt sie nur zu erhalten.”

“Optionen vor Zwang.”

“Tiefe unter der Oberfläche.”

“Realismus nur dort, wo er Gameplay oder Immersion verbessert.”

“Alles lernen können ≠ alles meistern können.”

“Lege Werkzeuge in die Hand des Spielers; lass die Welt ihre Möglichkeiten zeigen.”

“Physik soll Gameplay bereichern, nicht Simulation um ihrer selbst willen sein.”

“Prozedurale Systeme sollen Geschichten variieren, nicht Geschichten ersetzen.”

“Die Welt vergisst nichts, aber sie bleibt nicht stehen.”

“Konsequenzen sollen Geschichten erzeugen, nicht nur bestrafen.”

“Der Spieler soll am Ende sagen können: „Das war meine Geschichte.“”

## Anhang: Designentscheidungen aus der laufenden Discovery-Phase

Dieser Anhang dokumentiert die wichtigsten Entscheidungen in komprimierter Form, damit spätere Iterationen nachvollziehbar bleiben.

| Bereich | Entscheidung |
| --- | --- |
| Atmosphäre | Gefährliche, unbekannte, schöne Welt mit echter Neugier |
| Exploration | selbstgesteuerte Entdeckung, Weltmarker statt Dauer-Questmarker |
| Environmental Storytelling | Ambiguität, Beobachtung, veränderbare Orte |
| Prozeduralität | Mix aus handgearbeiteten Archetypen und variablen Details |
| Gefahr | Regionen mit unterschiedlichen Schwierigkeitsgraden, frühe riskante Ausflüge möglich |
| Reisen | zu Fuß + Boot + Schwimmen + Klettern + Schnellreise; Mounts zunächst nicht priorisiert |
| Combat | realistisches Gewicht, flüssige Reaktionen, kontrollierte Physik |
| Progression | freie Lernrichtung, langfristige Spezialisierung |
| Magie | besonders, mehrere Schulen, Mana + Skills + Spezialisierung |
| Loot | regional logisch, kontrolliert zufällig, legendäre Items einzigartig |
| Crafting | optional, vertiefend |
| Economy | dauerhaft relevant, aber kein Wirtschaftssimulator |
| NPCs | Routinen + Erinnerungen + Reaktionen, ohne Vollsimulation |
| Quests | Hinweise und Untersuchung statt Voll-Handholding |
| Konsequenzen | real, zeitabhängig, aber Welt bleibt spielbar |
| UI | klar, schön, intuitiv, nicht überladen |
| Schwierigkeit | mehrere Presets + individuelle Anpassbarkeit |

Ende der Version 1.0 Foundation
