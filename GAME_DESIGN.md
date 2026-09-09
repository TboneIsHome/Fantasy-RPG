# Aktueller Spielentwurf

## Spielbar in 0.1

Eine begrenzte Waldregion mit Lager, Fluss, Brücken, drei Waldlichtern und neun Gegnern. Ein Seed verändert Gelände, Landmarkpositionen und Vegetation. Pfade und sichere Lichtungen sind nachgelagerte Regeln. Größere Regionen, Klimazonen und Chunk-Streaming sind noch nicht umgesetzt.

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
- Beide haben ein Rückzugsgebiet und respektieren die sichere Lagerzone. Die Steuerung ist lokal; ein komplexes Rudel- oder Navigationssystem folgt später.

### Erste Erkundungsrunde

Edda bittet um das Erwecken dreier Waldlichter. Jedes gibt einmalig 20 Erfahrung. Die Reihenfolge ist frei. Gegner zu besiegen ist keine Voraussetzung für die Interaktion. Das ist ein einfacher Erkundungsauftrag, noch keine verzweigte prozedurale Quest.

Nach der Rückkehr verleiht Edda den **Quellenfokus**: aktive Waldlichter werden zu Rastpunkten, die Leben, Mana und Ausdauer auffüllen und speichern. Das Relikt liegt im Journal-Beutel. Ein separates Ausrüstungsfenster fehlt noch.

### Fortschritt

Eine Stufe benötigt `aktuelle Stufe × 60` Erfahrung. Jede Stufe gibt einen Talentpunkt. Drei funktionierende erste Talente bilden eine vorläufige Talentliste:

- **Widerhall:** Ein Lichtfunke auf ein verlangsamtes Wesen trifft zusätzlich einen nahen zweiten Gegner.
- **Fließender Schritt:** Ausweichen gibt Mana zurück.
- **Quellenkreis:** Im eigenen Frostkreis stehen heilt.

Lichtstaub aus Kämpfen wird im Beutel gezählt, hat in 0.1 noch keinen Verwendungszweck. Es gibt keine zufällige Ausrüstungsflut.

## Vollständiger Vertical Slice als nächstes Ziel

- Dieselbe Region erhält eine verlassene Quellengruft aus 5–7 zusammengesetzten Raumteilen.
- Dritter normaler Gegner: Dornkobold mit einem klaren Kontrollangriff.
- Elite: gebundener Quellenhüter mit zwei deutlich angekündigten Angriffen.
- Quest: Die Quelle wird durch eine beschädigte Bindung gestört. **Kampfweg:** Hüter brechen, Bindung entfernen. **Untersuchungsweg:** zwei Gedächtnissteine lesen und die Bindung im Dungeon reparieren.
- Beide Lösungen geben ein Relikt. Reparieren schafft einen sicheren Quellengarten; Brechen öffnet einen Abbauort, der später eine andere Gefahr anzieht.
- Dungeonzugang und beide Lösungen müssen ohne verpflichtende Talentwahl möglich bleiben. Talente verkürzen oder verändern Wege, sperren die Hauptlösung nicht.
- Erst nach spielerischer Prüfung dieses Ablaufs kommen weitere Biome und Klassen hinzu.

## Weitere Klassen — Entwurf, noch nicht spielbar

| Archetyp | Eigener Schwerpunkt | Spätere Verbindung zum Magier |
|---|---|---|
| Krieger | Schutz, Parieren, Position kontrollieren | Runenrüstung, Nahkampfzauber |
| Waldläufer | Präzision, Fallen, Naturspuren | Elementarpfeile, Pflanzenmagie |
| Magier | Magieschulen und Ressourcenketten | Erste vollständig umgesetzte Grundlage |
| Wanderer | Werkzeuge, Heimlichkeit, Verhandlung | Illusion und Geistersicht |

Langfristig verbindet ein Netz aus gemeinsamen Grundlagen und Spezialisierungszweigen die Klassen. Ein großer Skill Tree ist geplant; die drei Talente in 0.1 sind kein solcher fertiger Baum.
