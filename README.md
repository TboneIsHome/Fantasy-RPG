# Lichterhain · Prototyp 0.1

Ein kleines, offline spielbares Fantasy-RPG mit einem Magier und einer seed-basierten Pixelwaldregion. Dieser Stand erprobt den Kampf und die erste Erkundungsrunde. Er ist noch nicht der vollständige Vertical Slice.

## Direkt spielen unter Windows

1. Das gesamte Download-Archiv entpacken.
2. Im Ordner **Spielen** die Datei **Lichterhain.exe** öffnen.
3. **Neuen Lichtpfad beginnen** wählen. Der voreingestellte Seed eignet sich für die erste Runde.
4. Mit **WASD** zu Edda nördlich des Lagerfeuers gehen und **E** drücken.

Es sind keine Godot-Installation, Anmeldung oder Internetverbindung zum Spielen erforderlich. Die beigefügte Anwendung ist ein Windows-x86_64-Export. Sie wurde hier erstellt; ein nativer Windows-Test steht noch aus. Der identische Spielcode wurde unter Linux ausgeführt und geprüft.

## Steuerung

| Taste / Maus | Aktion |
|---|---|
| WASD oder Pfeiltasten | Bewegen |
| Maus | Zielen |
| Linke Maustaste / 1 | Lichtfunke; gedrückt halten ist möglich |
| Rechte Maustaste / 2 | Frostkreis am Zielpunkt innerhalb der Reichweite |
| Leertaste | Ausweichen in Bewegungsrichtung; im Stand in die letzte Bewegungsrichtung |
| E | Sprechen, Waldlicht entzünden, am Lager rasten |
| Tab | Journal, Talente und Beutel öffnen/schließen |
| M | Karte öffnen/schließen |
| Esc | Pause / Fenster schließen |
| F5 / F9 | Speichern / letzten Speicherpunkt laden |
| F11 | Vollbild umschalten |

**Kampftipp:** Mit Frost verlangsamen, mit Lichtfunken nachsetzen. Verlass die markierte Sprungbahn des Wolfes. Blaue/türkise Werte sind Mana; goldene Werte Ausdauer. Die Balken sind zusätzlich mit LP, MP und AU bezeichnet.

## Was du ausprobieren kannst

Eddas Auftrag annehmen, drei Waldlichter in beliebiger Reihenfolge finden und mit E entzünden. Gegner geben Erfahrung und Lichtstaub. Im Journal kannst du Talentpunkte ausgeben. Wenn alle Lichter erwacht sind, zu Edda zurückkehren und den Quellenfokus annehmen. Danach kannst du auch an Waldlichtern rasten.

Die erste Runde hat ein Ende, die kleine Region bleibt danach begehbar. Gegner und Lichter werden innerhalb einer Sitzung nicht automatisch neu ausgewürfelt. Ein neuer Seed beginnt einen neuen Lauf.

## Speichern

Rasten, F5 und die Rückgabe des Auftrags speichern. Beim regulären Schließen des laufenden Spiels wird ein lebender Charakter ebenfalls gespeichert. Der Menüpunkt „Speichern und zum Titel“ speichert zuerst. Es gibt **einen Speicherpunkt plus die vorherige Sicherung**.

Ein neuer Lauf ersetzt diesen Speicherpunkt, sobald du speicherst. Beim Tod kannst du ohne Fundverlust am Lager zurückkehren. Noch lebende Gegner kehren beim Laden gesund an ihre Ausgangsorte zurück; besiegte bleiben verschwunden.

Datei: `user://lichtpfad_v1.json`; Godot legt sie im Benutzerordner des Spiels ab, nicht neben der EXE. Unter Windows ist das normalerweise `%APPDATA%\Godot\app_userdata\Lichterhain\`. Die Sicherung endet auf `.bak`.

## Im Editor weiterentwickeln

1. [Godot 4.5.1 Standard](https://godotengine.org/download/archive/4.5.1-stable/) herunterladen und öffnen.
2. Das bereitgestellte Archiv **Lichterhain_0.1_Quellprojekt.zip** entpacken.
3. **Importieren** wählen und `Lichterhain/project.godot` auswählen.
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

Das private Ziel ist [TboneIsHome/Fantasy-RPG](https://github.com/TboneIsHome/Fantasy-RPG). Dort liegt bisher nur diese Projektbeschreibung. Der Upload des gesamten Quellcodes wartet noch auf die ausdrückliche Freigabe für dieses Ziel. Die vollständige Umsetzung und die lokale Git-Historie sind im Quellprojekt-Download enthalten.

Das Quellprojekt enthält `Entwicklung/lichterhain-history.bundle`; damit kann die lokale Historie über `git clone lichterhain-history.bundle lichterhain` wiederhergestellt werden. Zum Öffnen in Godot genügt der Ordner `Lichterhain`. Die Windows-Anwendung wird separat bereitgestellt. Binäre Builds und lokale Godot-Caches gehören nicht in den Quellcode-Stand.
