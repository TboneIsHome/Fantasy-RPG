# Lichterhain · Version 0.3 — Unter den Wurzeln

Ein offline spielbares Fantasy-RPG mit einem Magier, einer seed-basierten Pixelwaldregion und der ersten Quellengruft. Auf die Grafikiteration 0.2 folgt ein neuer Erkundungsabschnitt mit Erinnerungen, dauerhaften Funden und einem dritten Gegner. Der Prototyp ist noch nicht der vollständige Vertical Slice oder eine mehrstündige Spielwelt.

## Direkt spielen unter Windows

1. Das gesamte Download-Archiv entpacken.
2. Im Ordner **Spielen** die Datei **Lichterhain.exe** öffnen.
3. **Neuen Lichtpfad beginnen** wählen. Der voreingestellte Seed eignet sich für die erste Runde.
4. Mit **WASD** zu Edda nördlich des Lagerfeuers gehen und **E** drücken.

Es sind keine Godot-Installation, Anmeldung oder Internetverbindung zum Spielen erforderlich. Die beigefügte Anwendung ist ein Windows-x86_64-Export. Version 0.1 wurde von Tim gespielt und positiv beurteilt. Version 0.3 wurde unter Linux automatisiert und visuell geprüft; der neue Windows-Export ist hier nicht nativ unter Windows ausgeführt.

## Neu in Version 0.3

- Die Quellengruft: sechs Haupträume, eine versteckte Nische, eine Schleife und eine freischaltbare Abkürzung.
- Zisterne, Wurzelarchiv, unterirdischer Garten und Sternensäle mit eigener Pixelgrafik, Wasserbecken und Lichtstimmung.
- Dornkobolde: Ihr angekündigter Angriff hinterlässt eine zeitlich begrenzte Dornenfläche. In der Gruft finden Gegner Wege um Wände.
- Entdeckungsjournal mit neun kurzen Orts- und Fundtexten. Unbekannte Inhalte bleiben verborgen.
- Sternenkarte, optionaler Fund, gelesene Hinweise und geöffnete Wege bleiben gespeichert. Edda reagiert auf die zurückgebrachte Karte.
- Lichtstaub erhält eine Verwendung: Zwei Einheiten füllen an der Sickerquelle Leben, Mana und Ausdauer auf.
- Die Dungeonkarte zeichnet besuchte Räume auf; die Weltzeit läuft auch unter der Erde weiter.

**Spielstände aus 0.1 und 0.2 bleiben verwendbar.** Starte die neue EXE und wähle „Am Speicherpunkt fortsetzen“. Originale Spielstände beider Versionen wurden tatsächlich geladen. Beim ersten Speichern wird das erweiterte Format 2 geschrieben und der bisherige gültige Stand zusätzlich als `.pre-v03` aufbewahrt. Ältere Spielversionen können Format 2 nicht lesen.

**So erreichst du die neuen Inhalte:** Drei Waldlichter wecken, bei Edda den Quellenfokus abholen und zum alten Sternengarten gehen. Wenige Schritte südöstlich seines Waldlichts führt ein Tor in die Quellengruft. Wer Eddas Auftrag schon abgeschlossen hat, kann direkt dorthin gehen.

## Steuerung

| Taste / Maus | Aktion |
|---|---|
| WASD oder Pfeiltasten | Bewegen |
| Maus | Zielen |
| Linke Maustaste / 1 | Lichtfunke; gedrückt halten ist möglich |
| Rechte Maustaste / 2 | Frostkreis am Zielpunkt innerhalb der Reichweite |
| Leertaste | Ausweichen in Bewegungsrichtung; im Stand in die letzte Bewegungsrichtung |
| E | Sprechen, rasten, Hinweise lesen, Funde aufnehmen und Übergänge benutzen |
| Tab | Journal mit Talenten, Beutel und Entdeckungen öffnen/schließen |
| M | Karte öffnen/schließen |
| Esc | Pause / Fenster schließen |
| F5 / F9 | Speichern / letzten Speicherpunkt laden |
| F11 | Vollbild umschalten |

**Kampftipp:** Mit Frost verlangsamen, mit Lichtfunken nachsetzen. Verlass die markierte Sprungbahn des Wolfes. Blaue/türkise Werte sind Mana; goldene Werte Ausdauer. Die Balken sind zusätzlich mit LP, MP und AU bezeichnet.

## Was du ausprobieren kannst

Eddas Auftrag annehmen, drei Waldlichter in beliebiger Reihenfolge finden und mit E entzünden. Gegner geben Erfahrung und Lichtstaub. Im Journal kannst du Talentpunkte ausgeben. Wenn alle Lichter erwacht sind, zu Edda zurückkehren und den Quellenfokus annehmen. Danach kannst du auch an Waldlichtern rasten.

Danach die Quellengruft erkunden, ihre Hinweise lesen und die Sternenkarte zu Edda bringen. Eine Abkürzung erleichtert die Rückkehr; aufmerksames Lesen kann einen weiteren Ort erschließen. Die kleine Welt bleibt nach Abschluss begehbar. Ein neuer Seed beginnt einen neuen Lauf.

## Speichern

Rasten, F5, Gebietswechsel, neue Dungeonhinweise/Funde, geöffnete Wege und die Rückgabe des Auftrags speichern. Beim regulären Schließen des laufenden Spiels wird ein lebender Charakter ebenfalls gespeichert. Der Menüpunkt „Speichern und zum Titel“ speichert zuerst. Es gibt **einen Speicherpunkt plus die vorherige Sicherung** und bei der Umstellung die unveränderte Altstand-Sicherung.

Ein neuer Lauf ersetzt diesen Speicherpunkt, sobald du speicherst. Beim Tod, auch in der Gruft, kannst du ohne Fundverlust am Lager zurückkehren. Noch lebende Gegner kehren beim Laden oder erneuten Betreten einer Region gesund an ihre Ausgangsorte zurück; besiegte bleiben verschwunden. Kurze Effekte und Abklingzeiten werden dabei zurückgesetzt.

Datei: `user://lichtpfad_v1.json`; der etablierte Dateiname bleibt trotz Format 2 erhalten. Godot legt sie im Benutzerordner des Spiels ab, nicht neben der EXE. Unter Windows ist das normalerweise `%APPDATA%\Godot\app_userdata\Lichterhain\`. Die rotierende Sicherung endet auf `.bak`, die einmalige alte Sicherung auf `.pre-v03`.

## Im Editor weiterentwickeln

1. [Godot 4.5.1 Standard](https://godotengine.org/download/archive/4.5.1-stable/) herunterladen und öffnen.
2. Dieses Repository klonen oder auf GitHub über **Code → Download ZIP** herunterladen und entpacken.
3. **Importieren** wählen und die Datei `project.godot` im Projektordner auswählen.
4. Den ersten Dateiimport abwarten, dann **F5** drücken.

GDScript wird verwendet; die .NET-Ausgabe ist nicht notwendig. Das Projekt kommt ohne Add-ons aus. Die ausführbaren Tests sind in `TESTING.md` beschrieben.

## Projektwissen

- `GAME_VISION.md`: bestätigte Richtung und Designpfeiler.
- `GAME_DESIGN.md`: tatsächliche Mechaniken und der geplante Slice.
- `TECHNICAL_DESIGN.md`: Module, Pixelregeln, Generierung und Speichergrenzen.
- `ROADMAP.md` und `TASKS.md`: nächste kleine Schritte und Abnahmekriterien.
- `DECISIONS.md`, `CHANGELOG.md`, `TESTING.md`: Entscheidungen, Änderungen und Prüfungen.
- `CREDITS.md` und `licenses/`: Herkunft und Engine-Lizenzhinweise.

## GitHub

Der vollständige Quellcode, die Tests und die Projektdokumentation liegen in [TboneIsHome/Fantasy-RPG](https://github.com/TboneIsHome/Fantasy-RPG). Jede Iteration erhält einen eigenen Commit. Binäre Builds und lokale Godot-Caches gehören nicht in den Quellcode-Stand.

Die spielbare Windows-Version wird als separates Download-Paket **Lichterhain_0.3_Windows.zip** bereitgestellt.
