# Lichterhain · Version 0.4 — Das Gedächtnis der Quelle

Ein offline spielbares Fantasy-RPG mit einem Magier, einer seed-basierten Pixelwaldregion und der ersten Quellengruft. Der erste zusammenhängende Spielabschnitt führt nun bis zum Quellenhüter, zwei Questlösungen und einem ausrüstbaren Relikt. Sein Inhalt ist implementiert und automatisiert geprüft; menschliche Abnahme und mehrstündige Weltinhalte stehen noch aus.

## Direkt spielen unter Windows

1. Das gesamte Download-Archiv entpacken.
2. Im Ordner **Spielen** die Datei **Lichterhain.exe** öffnen.
3. **Neuen Lichtpfad beginnen** wählen. Der voreingestellte Seed eignet sich für die erste Runde.
4. Mit **WASD** zu Edda nördlich des Lagerfeuers gehen und **E** drücken.

Es sind keine Godot-Installation, Anmeldung oder Internetverbindung zum Spielen erforderlich. Die beigefügte Anwendung ist ein Windows-x86_64-Export. Version 0.1 wurde von Tim gespielt und positiv beurteilt. Version 0.4 wurde unter Linux automatisiert und visuell geprüft; der neue Windows-Export ist hier nicht nativ unter Windows ausgeführt.

## Neu in Version 0.4

- **Gebundener Quellenhüter:** ein eigener großer Gegner mit angekündigtem Quellenschlag und einem Fächer langsamer Geschosse. Verlassen des Raums beendet den Versuch; ein erneuter Versuch beginnt mit voller Hütergesundheit.
- **Zwei vollständige Wege:** Die Hinweise untersuchen und die Bindung stimmen oder den Hüter im Kampf besiegen. Beide Wege geben dieselbe Reliktbelohnung und 90 Erfahrung.
- **Sichtbare Folgen:** Eine reparierte Bindung schafft einen sicheren Quellengarten mit kostenloser Rast. Der Kampf legt eine Erzader frei, die einmalig vier Lichtstaub gibt.
- **Quellenherz:** ein an- und ablegbares Relikt. Ein Frostkreis mit mindestens einem Treffer gibt einmal pro Zauber sechs Mana zurück; ein Fehlschuss gibt nichts zurück.
- **Die Welt erinnert sich:** Edda reagiert auf deine Lösung. Hinweise, begonnene Zeichenfolge, Ergebnis, Erzernte und Reliktplatz bleiben gespeichert.
- Neue Hütergrafik, Angriffsmarkierungen, Garten-/Erzgestaltung, Bossanzeige und eigener Reliktreiter im Journal.
- Neu gelesene Dungeon-Erinnerungen werden jetzt unmittelbar gespeichert; hier fehlte in 0.3 noch der automatische Schreibaufruf.

**Spielstände aus 0.1, 0.2 und 0.3 bleiben verwendbar.** Wähle „Am Speicherpunkt fortsetzen“. Originale Spielstände aller drei Versionen wurden geladen. Vor dem ersten Speichern im erweiterten Format 3 wird der bisherige gültige Stand als `.pre-v04` aufbewahrt, auch beim Wiederherstellen aus einer Sicherung. Eine vorhandene `.pre-v03`-Sicherung bleibt unverändert. Ältere Spielversionen können Format 3 nicht lesen.

**So erreichst du die neuen Inhalte:** Nach Eddas erstem Auftrag öffnet der Quellenfokus die Gruft südöstlich des Waldlichts im alten Sternengarten. Untersuche mit E die leuchtende Fassung im hinteren Raum, nördlich des ruhenden Hüters. Deine Erinnerungen und Sternenkarte aus 0.3 zählen bereits für den Untersuchungsweg. Ein neuer Lauf ist nicht nötig.

## Steuerung

| Taste / Maus | Aktion |
|---|---|
| WASD oder Pfeiltasten | Bewegen |
| Maus | Zielen |
| Linke Maustaste / 1 | Lichtfunke; gedrückt halten ist möglich |
| Rechte Maustaste / 2 | Frostkreis am Zielpunkt innerhalb der Reichweite |
| Leertaste | Ausweichen in Bewegungsrichtung; im Stand in die letzte Bewegungsrichtung |
| E | Sprechen, rasten, Hinweise lesen, Funde aufnehmen und Übergänge benutzen |
| Tab | Journal mit Talenten, Beutel, Entdeckungen und Reliktplatz öffnen/schließen |
| M | Karte öffnen/schließen |
| Esc | Pause / Fenster schließen |
| F5 / F9 | Speichern / letzten Speicherpunkt laden |
| F11 | Vollbild umschalten |

**Kampftipp:** Mit Frost verlangsamen, mit Lichtfunken nachsetzen. Verlass die markierte Sprungbahn des Wolfes. Blaue/türkise Werte sind Mana; goldene Werte Ausdauer. Die Balken sind zusätzlich mit LP, MP und AU bezeichnet.

## Was du ausprobieren kannst

Eddas Auftrag annehmen, drei Waldlichter in beliebiger Reihenfolge finden und mit E entzünden. Gegner geben Erfahrung und Lichtstaub. Im Journal kannst du Talentpunkte ausgeben. Wenn alle Lichter erwacht sind, zu Edda zurückkehren und den Quellenfokus annehmen. Danach kannst du auch an Waldlichtern rasten.

Danach die Quellengruft erkunden, Erinnerungen und Sternenkarte finden und die gebrochene Fassung untersuchen. Du kannst die Bindung stimmen oder den Hüter herausfordern. Rückzug lässt beide Möglichkeiten offen; der abgeschlossene Weg bleibt eine dauerhafte Entscheidung. Kehre mit dem Ergebnis zu Edda zurück. Die kleine Welt bleibt danach begehbar. Ein neuer Seed beginnt einen neuen Lauf.

## Speichern

Rasten, F5, Gebietswechsel, neue Dungeonhinweise/Funde, geöffnete Wege, richtige Zeichen, die Lösung der Quelle, Reliktwechsel und die Rückgabe des Auftrags speichern. Beim regulären Schließen des laufenden Spiels wird ein lebender Charakter ebenfalls gespeichert. Der Menüpunkt „Speichern und zum Titel“ speichert zuerst. Es gibt **einen Speicherpunkt plus die vorherige Sicherung** und bei der Umstellung die unveränderte Altstand-Sicherung.

Ein neuer Lauf ersetzt diesen Speicherpunkt, sobald du speicherst. Beim Tod, auch in der Gruft, kannst du ohne Fundverlust am Lager zurückkehren. Noch lebende Gegner kehren beim Laden oder erneuten Betreten einer Region gesund an ihre Ausgangsorte zurück; besiegte bleiben verschwunden. Kurze Effekte und Abklingzeiten werden dabei zurückgesetzt.

Datei: `user://lichtpfad_v1.json`; der etablierte Dateiname bleibt trotz Format 3 erhalten. Godot legt sie im Benutzerordner des Spiels ab, nicht neben der EXE. Unter Windows ist das normalerweise `%APPDATA%\Godot\app_userdata\Lichterhain\`. Die rotierende Sicherung endet auf `.bak`, die alte Sicherung auf `.pre-v03` und die Sicherung vor diesem Update auf `.pre-v04`.

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

Die spielbare Windows-Version wird als separates Download-Paket **Lichterhain_0.4_Windows.zip** bereitgestellt.
