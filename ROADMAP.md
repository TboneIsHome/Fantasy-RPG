# Roadmap

Stand: 2026-09-15, spielbarer Quellstand 0.4.0. Tim priorisiert jetzt robuste Kernsysteme und eine kleine, erweiterbare Weltsimulation. Langfristiges Ziel ist eine glaubwürdige, schöne und gefährliche prozedurale Fantasywelt, in der Neugier und Entscheidungen persönliche Geschichten ermöglichen. Größe und Systemtiefe werden schrittweise geprüft; der aktuelle Prototyp erfüllt diesen Umfang noch nicht.

## Verbindliche nächste Reihenfolge

| Meilenstein | Kleinster zusammenhängender Umfang | Abnahme / Status |
| --- | --- | --- |
| **M00 — Referenz und Audit** | Originalen 0.4-Code gegen Audit V1 prüfen; Quellstand, Reports, Exporte und verfügbare Saves sichern; Regression wiederholen | Audit und Sicherung **IMPLEMENTED**; 197 Checks und Export-Packs **TESTED**; Plattformabnahme **PARTIALLY TESTED**. Bericht und Grenzen: [FOUNDATION_M00.md](docs/FOUNDATION_M00.md). **STOP vor M01.** |
| **M01 — Save-System** | Den beschriebenen I/O-Fehlerfall reproduzieren, Test ergänzen und kleinsten sicheren Fix durchführen | **PLANNED.** Schreib-/Flush-/Renamefehler, kaputte Hauptdatei mit gültiger Sicherung, Erhalt des letzten gültigen Stands, Altstand-Migrationen, ungültige/beschädigte Daten |
| **M02 — Zustandsänderungen** | Dauerhafte Fortschrittsaktionen und vollständige Belohnungen beim fachlichen Besitzer bündeln | **PLANNED.** Voraussetzungen geprüft, Wiederholungen sicher, keine Doppelbelohnung, konsistente Bestätigung/Benachrichtigung und Speicherung |
| **M03 — Regionslebenszyklus** | Build/Activate/Deactivate/Unload/Travel aus der Sitzung heraus klar abgrenzen | **PLANNED.** Wald/Gruft, genau ein Spieler, keine doppelten Gegner, alte Referenzen/verspätete Aktionen verworfen, Save/Load erhalten |
| **M04 — Inhaltsdaten** | Bestehende JSON-Quellen validieren und Regeln mit Gameplay, HUD und Saveprüfung verbinden | **PLANNED.** Verständliche Release-Fehler; IDs, Felder, Typen, Bereiche und Querverweise geprüft; keine Balanceänderung durch die Migration |

Nach jedem Umbauschritt: relevante neue Prüfungen, gesamte bestehende Regression, Savegame-Prüfungen, Exportprüfung und dokumentierte manuelle Smoke-Runde. Eine offene Plattformprüfung wird offen ausgewiesen. Keine parallelen Umbauten unabhängiger Kernsysteme und kein Save-Reset als Abkürzung.

## Bisherige spielbare Referenzen

| Stand | Erhaltenswerter Umfang |
| --- | --- |
| 0.1 | Magierbewegung, zwei Zauber, Ausweichen, Gegnerfeedback, Seed-Wald, Edda, Waldlichter, Talente, Speichern/Laden; erster positiver Spieltest |
| 0.2 | Eigene überarbeitete Pixelgrafik, Licht, Umgebung und Oberfläche; ursprünglicher 0.1-Spielstand bleibt kompatibel |
| 0.3 | Quellengruft mit sechs Haupträumen und Geheimraum, Dornengegner, Navigation, Journal/Funde, geöffnete Wege, Format-2-Migration |
| 0.4 | Quellenhüter, Untersuchung oder Kampf, sichtbare Folgen, Reliktplatz, getrennte Quellen-/Inventarzustände und Format-3-Migration; positiver Nutzerbericht, 197 bestehende Checks |

Das unveränderte 0.4-Release liegt auf `reference/v0.4-original`. M00 baut darauf auf und verändert keine Laufzeitmechanik. 0.3 bleibt über die Git-Historie als Vergleich erhalten.

## Spätere Entwicklungsphasen — PLANNED

Nach M01–M04 werden konkrete nächste Anforderungen erneut bewertet: Interaktionen und Actor-Stats, Combat-Schnittstellen, begrenzte Zeit-/Wetterzustände, danach Inventar/Equipment/Magie/Status und NPC-/Questmodelle. Bestehende Module werden schrittweise erweitert, wo dies einen nachweisbaren Nutzen hat. JSON bleibt; kein universeller Eventbus und keine leeren Managergerüste.

Streaming, umfangreiche KI, Fraktionen, Wirtschaft, Crafting, Begleiter und große neue Regionen bleiben später. Ebenso warten neue Klassen, umfangreiche Talentnetze und Inhaltskataloge. Die vorhandenen Bedienungswünsche (Eingabebelegung, Controller, Reichweitenvorschau, Orientierung und Balancing) bleiben im Qualitätsbacklog von TASKS.md, verdrängen aber nicht die aktuelle Stabilisierung.

Eine größere Karte oder mehr Zufall allein schaffen keine interessante Welt. Die Foundation soll stabile Identitäten, nachvollziehbare Zustandsänderungen, kontrollierte Lebensdauer und miteinander kombinierbare Regeln tragen. Welche Begegnungen daraus entstehen, wird zuerst in kleinen, spielbaren Beispielen erprobt.
