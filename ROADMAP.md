# Roadmap

Stand: 0.4. Reihenfolge nach Spielbarkeit und technischen Risiken; keine festen Zeitversprechen. Langfristiges Ziel: eine schöne, geheimnisvolle Welt, die auch nach vielen Stunden echte Entdeckungen ermöglicht. Der aktuelle Prototyp legt dafür die Grundlage, erfüllt diesen Umfang aber noch nicht.

| Priorität / Meilenstein | Inhalt | Abnahme | Status |
|---|---|---|---|
| P0 · Richtung und Basis | Vision, Magier, Godot, Pixelregeln, modulare Struktur | Projekt startet reproduzierbar | Fertig |
| P0 · Erster Spielkern | Bewegung, Kamera, Lichtfunke, Frostkreis, Ausweichen, Gegnerfeedback | Bedienen, kämpfen, sterben und wieder einsteigen funktioniert | Fertig |
| P0 · Kleine Erkundungsrunde | Seed-Wald, Lager, zwei Gegnertypen, Edda, drei Waldlichter, Karte, Talente, Speicherstand | Runde integrierbar abgeschlossen; Generator- und Speichertests grün | Automatisiert geprüft; erster Spieltest von Tim positiv |
| P0 · Der Wald erwacht | Eigene Pixelgrafik, Vegetation, Lagerdetails, Licht, Zauber und Oberfläche | Spielbilder geprüft, Kampftests bestehen, 0.1-Spielstand ladbar | Fertig in 0.2 |
| P1 · Kampf und Orientierung prüfen | Tim spielt die Runde; Reichweiten, Tempo, Sichtbarkeit und Ressourcen abstimmen | Angriffe wirken fair; Wege sind lesbar; Magier macht Spaß | Menschlicher Spieltest der aktuellen Iteration ausstehend |
| P1 · Unter den Wurzeln | 6 Haupträume + Geheimraum, Schleife, Abkürzung, Dornkobold, Journal und persistente Funde | 100 Seeds: Hauptorte/Gegner erreichbar, Geheimraum korrekt gesperrt; Übergänge und Altstände geprüft | Fertig in 0.3 |
| P1 · Vollständiger Vertical Slice | Quellenhüter, Untersuchung oder Kampf, Relikt/Ausrüstung, sichtbare Konsequenz | Beide Questwege vom neuen Spiel bis Belohnung spielbar; Speichern in jedem Abschnitt | Inhalt in 0.4 implementiert; automatisiert geprüft; menschliche Abnahme offen |
| P1 · Spielgefühl und Bedienbarkeit | Frei belegbare Eingaben, Reichweitenvorschau, Orientierung und abgestimmter Kampfrhythmus | Bedienen ohne vermeidbare Reibung; Effekte und Entscheidungen verständlich | Nächste Qualitätsiteration 0.5 |
| P2 · Erweiterte Entwicklung | Zweite Klasse, größerer Talentgraph, zweites Biom | Unterschiede verändern Entscheidungen statt nur Zahlen | Offen |
| P2 · Glaubwürdige Weltentwicklung | Eine regionale Bedrohung, Ereigniswarteschlange, NPC-Erinnerungen | Veränderungen nachvollziehbar und persistent; keine Dauerberechnung ferner Figuren | Offen |
| P3 · Mehr Inhalte | Fraktionen, strukturierte Questfamilien, weitere Dungeons und seltene Orte | Logik- und Erreichbarkeitsprüfungen; Wiederholungen im Spieltest bewertet | Offen |
| Fortlaufend | Audio, Zugriffsmöglichkeiten, Balancing, Performance | Keine kritischen Regressionen im geprüften Umfang | Laufend |

## Grenze des ersten Vertical Slice

Ein Magier, eine Region, ein Lager, drei normale Gegnertypen, ein kleiner Dungeon und ein Elitegegner. Eine Quest mit zwei Lösungswegen, wenige sinnvolle Talente, einfaches Inventar und ausrüstbares Relikt. Tag/Nacht, eigenes kohärentes Pixelbild und zuverlässige Speicherung. Kein Crafting-Baum, kein Multiplayer, keine Vollsimulation, kein riesiger Inhaltskatalog vor dieser Abnahme.

## Ausbau ohne austauschbare Masse

Zuerst die vorhandene Region vertiefen: eigene Ortsgeschichten, Hinweise, freiwillige Umwege und dauerhafte Konsequenzen. Danach einen zweiten Ort mit anderer Spielidee ergänzen. Wiederkehrende NPC-Reaktionen und regionale Ereignisse erhalten explizite, speicherbare Zustände. Eine größere Karte oder mehr Zufall allein gelten nicht als neue Entdeckung.

Jede Iteration endet mit einem spielbaren Paket, überprüften Altständen und einer klaren nächsten Frage für den Spieltest. Die Minuten- und Stundenwirkung wird durch menschliche Spieltests beurteilt; automatisierte Erreichbarkeit belegt sie nicht.
