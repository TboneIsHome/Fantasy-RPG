# Aktueller Spielentwurf

## Spielbar in 0.4

Eine begrenzte Waldregion mit Lager, Fluss, Brücken, drei Waldlichtern und neun Gegnern. Ein Seed verändert Gelände, Landmarkpositionen und Vegetation. Pfade und sichere Lichtungen sind nachgelagerte Regeln. Größere Regionen, Klimazonen und Chunk-Streaming sind noch nicht umgesetzt.

Nach Eddas erstem Auftrag öffnet der Quellenfokus die Quellengruft beim alten Sternengarten. Ihre sechs Haupträume, ein Geheimraum und sieben Gegner erweitern die bestehende Welt. Raumgrößen und Begegnungspositionen variieren begrenzt mit dem Seed; der Raumgraph und die Geschichten bleiben gestaltet.

### Magier

| Aktion | Verhalten |
|---|---|
| Lichtfunke | Schnelles Einzelprojektil, 8 Mana, 0,32 Sekunden Abklingzeit, 19 Schaden |
| Frostkreis | Am Mausziel bis 130 Pixel Reichweite, 48 Pixel Radius, 28 Mana, 4,5 Sekunden Abklingzeit; 16 Schaden und 3,5 Sekunden Verlangsamung |
| Splitterschaden | Lichtfunke gegen ein verlangsamtes Ziel: zusätzlich 10 Schaden, besondere Trefferanzeige |
| Ausweichschritt | Bewegung in Laufrichtung, bei Stillstand letzte Bewegungsrichtung; 28 Ausdauer, 0,16 Sekunden Schutz, 0,62 Sekunden Abklingzeit |
| Erholung | Mana regeneriert nach einer kurzen Zauberpause; Ausdauer regeneriert unabhängig |

Werte stehen in `data/content.json`. Physische Kollisionen begrenzen Bewegung und Projektile. Eine Sichtprüfung begrenzt Flächenzauber durch Hindernisse.

### Gegner

- **Dämmerwolf:** nähert sich, markiert seinen Sprung, springt auf die vorher festgelegte Position und benötigt danach Erholung.
- **Irrlicht:** kündigt einen langsamen Fernangriff an; sein Projektil lässt sich umgehen.
- **Dornkobold:** kündigt 0,9 Sekunden lang eine feste Zielstelle an. Dort bleiben 2,8 Sekunden Dornen: 9 Schaden pro angenommener Schadenspuls, 0,9 Sekunden Pulsabstand und 0,75 Sekunden Verlangsamung. Wände und Ausweichschutz werden berücksichtigt. Werte liegen in JSON.
- Alle haben ein Rückzugsgebiet und respektieren die sichere Lagerzone bzw. den Dungeon-Einstieg. In der Gruft führt ein Rasterpfad um Wände und gesperrte Tore; im Wald bleibt die lokale Steuerung bestehen.

### Erste Erkundungsrunde

Edda bittet um das Erwecken dreier Waldlichter. Jedes gibt einmalig 20 Erfahrung. Die Reihenfolge ist frei. Gegner zu besiegen ist keine Voraussetzung für die Interaktion. Das ist ein einfacher Erkundungsauftrag, noch keine verzweigte prozedurale Quest.

Nach der Rückkehr verleiht Edda den **Quellenfokus**: aktive Waldlichter werden zu Rastpunkten, die Leben, Mana und Ausdauer auffüllen und speichern. Das Relikt liegt im Journal-Beutel. Ein separates Ausrüstungsfenster fehlt noch.

### Fortschritt

Eine Stufe benötigt `aktuelle Stufe × 60` Erfahrung. Jede Stufe gibt einen Talentpunkt. Drei funktionierende erste Talente bilden eine vorläufige Talentliste:

- **Widerhall:** Ein Lichtfunke auf ein verlangsamtes Wesen trifft zusätzlich einen nahen zweiten Gegner.
- **Fließender Schritt:** Ausweichen gibt Mana zurück.
- **Quellenkreis:** Im eigenen Frostkreis stehen heilt.

Lichtstaub aus Kämpfen wird im Beutel gezählt. Die Sickerquelle am Dungeon-Einstieg nimmt zwei Einheiten für eine vollständige Erholung. Bei vollen Ressourcen oder zu wenig Staub wird nichts abgezogen. Es gibt keine zufällige Ausrüstungsflut.

### Unter den Wurzeln

Die Quellengruft führt über Zisterne und Sternensaal zur schlafenden Fassung. Ein zweiter Rückweg verbindet Archiv und unterirdischen Garten; von dort lässt sich eine kürzere Verbindung zum Eingang öffnen. Ein gelesener Hinweis erschließt eine freiwillige Nische. Eingang und Ausgang bleiben unabhängig von Talenten erreichbar.

Erinnerungen geben beim ersten Lesen je 10 Erfahrung, die Sternenkarte 40 und der optionale Bernsteinsamen 25. Wiederholtes Lesen oder Laden dupliziert keine Belohnung. Edda reagiert auf die zurückgebrachte Karte. Sternenkarte und Bernsteinsamen bleiben Entdeckungsfunde. Das neue Quellenherz ist davon getrennte, ausrüstbare Beute.

Tab bietet Talente/Beutel und Entdeckungen als getrennte Ansichten. Neun kurze Texte werden erst nach der jeweiligen Entdeckung sichtbar. M zeigt in der Gruft nur besuchte Räume; die geheime Nische wird vorher nicht aufgedeckt. Offene Wege, Funde, Erinnerungen und besiegte Gegner bleiben bei Rückkehr und Tod erhalten.

## Die Quelle — beide Wege seit 0.4

Die Fassung nördlich des ruhenden Hüters eröffnet die Entscheidung. Der Hüter wird erst durch „Herausfordern“ aktiv; ein zufälliger Zauber startet den Kampf nicht.

**Untersuchung:** Stimme im Wasser, Brief zwischen Wurzeln und Sternenkarte erklären drei Zeichen. Wasser → Wurzeln → Stern stellt die Bindung wieder her. Jeder richtige Zwischenschritt wird gespeichert. Eine falsche Reihenfolge setzt nur den Versuch zurück; Hinweise und Ressourcen bleiben erhalten. Keine Talentwahl und kein Sieg über einen Gegner sind für diese Lösung vorgeschrieben.

**Kampf:** Der Quellenhüter hat 280 Leben. Ein 1,1 Sekunden angekündigter Quellenschlag trifft eine feste Stelle mit 34 Pixel Radius für 21 Schaden. Darauf folgt nach Erholung ein 1,25 Sekunden angekündigter Fächer aus fünf langsamen Geschossen mit je 17 Schaden. Die bestehenden Ausweich- und Schadensschutzregeln gelten. Verlässt die Figur den Raum, ruht der Hüter wieder mit voller Gesundheit und seine verbleibenden Angriffe verschwinden. Der abgeschlossene Sieg zerbricht die Bindung.

**Folgen:** Reparieren schafft einen geschützten Quellengarten, beruhigt dessen zwei normalen Wächter und ermöglicht kostenlose Erholung. Auch verirrte Geschosse und Dornen verletzen die Figur in diesem Bereich nicht. Brechen legt eine Erzader frei, die einmalig vier Lichtstaub gibt. Der Ort erhält je nach Lösung andere Grafik und Kartenhinweise. Edda erinnert sich an den gewählten Weg. Eine spätere regionale Bedrohung ist weiterhin Entwurf, noch kein simuliertes Ereignis.

**Gleiche Hauptbelohnung:** Beide Wege geben einmalig 90 Erfahrung und das Quellenherz. Es wird zunächst angelegt und kann im Reliktreiter des Journals abgenommen werden. Trifft ein Frostkreis mindestens einen Gegner, gibt das getragene Relikt einmal sechs Mana zurück; Fehlschüsse und zusätzliche Ziele vervielfachen die Erstattung nicht. Es gibt einen Reliktplatz und einen ausrüstbaren Gegenstand, noch kein allgemeines Ausrüstungssystem mit vielen Slots.

Der Ausgang bleibt endgültig, sobald die Bindung vollständig repariert oder der Hüter besiegt ist. Vorher darf der Spieler erkunden, zurückweichen und den anderen Weg wählen. Speichern/Laden, Tod und Gebietswechsel erhalten Ergebnis, Zeichenfortschritt, Erzernte und Reliktplatz. Laufende Kämpfe werden beim Laden zurückgesetzt; Leben und Mana werden dabei nicht aufgefüllt.

Beide Abläufe wurden vom neuen Spiel über Eddas ersten Auftrag bis zur abschließenden Reaktion automatisiert geprüft. Spielzeit, Schwierigkeit und Atmosphäre müssen noch im menschlichen Spieltest bewertet werden.

## Weitere Klassen — Entwurf, noch nicht spielbar

| Archetyp | Eigener Schwerpunkt | Spätere Verbindung zum Magier |
|---|---|---|
| Krieger | Schutz, Parieren, Position kontrollieren | Runenrüstung, Nahkampfzauber |
| Waldläufer | Präzision, Fallen, Naturspuren | Elementarpfeile, Pflanzenmagie |
| Magier | Magieschulen und Ressourcenketten | Erste vollständig umgesetzte Grundlage |
| Wanderer | Werkzeuge, Heimlichkeit, Verhandlung | Illusion und Geistersicht |

Langfristig verbindet ein Netz aus gemeinsamen Grundlagen und Spezialisierungszweigen die Klassen. Ein großer Skill Tree ist geplant; die drei Talente in 0.4 sind kein solcher fertiger Baum.
