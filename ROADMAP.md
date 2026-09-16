# Roadmap

Stand: 2026-09-16, spielbarer Quellstand 0.4.0 / Foundation M02. Die [Design-Bible](docs/CREATIVE_DESIGN_BIBLE_V1.md) besitzt das langfristige Spielerlebnis. Aktuell priorisiert Tim robuste Kernsysteme und eine kleine, erweiterbare Weltsimulation. Größe und Systemtiefe werden schrittweise geprüft; der aktuelle Prototyp erfüllt die langfristige Vision noch nicht.

## Verbindliche nächste Reihenfolge

| Meilenstein | Kleinster zusammenhängender Umfang | Abnahme / Status |
| --- | --- | --- |
| **M00 — Referenz und Audit** | Originalen 0.4-Code gegen Audit V1 prüfen; Quellstand, Reports, Exporte und verfügbare Saves sichern | **COMPLETE** laut Tim. Historische Prüfergebnisse und Grenzen: [FOUNDATION_M00.md](docs/FOUNDATION_M00.md). Der damalige Stop-Punkt wurde durch Tims Auftrag zur Bible-Integration und M01 aufgehoben. |
| **M01 — Save-System** | I/O-Fehler reproduzieren, minimal absichern und Fehlermeldungen im Pausefenster sichtbar halten | **IMPLEMENTED**, insgesamt **PARTIALLY TESTED**. 290 Checks, echter OS-Schreibfehler und beide Export-Packs **TESTED**; native Windows-/manuelle Abnahme **NOT TESTED**. [Ergebnisse und Grenzen](docs/FOUNDATION_M01.md). Historischer Abschluss; anschließend von Tim zur nächsten Iteration freigegeben. |
| **M02 — Zustandsänderungen** | Dauerhafte Fortschrittsaktionen und vollständige Belohnungen beim fachlichen Besitzer bündeln | **IMPLEMENTED**, insgesamt **PARTIALLY TESTED**. 405 Checks, beide Export-Packs und drei visuell kontrollierte Aufnahmen; native Windows-/manuelle Abnahme offen. [Bericht](docs/FOUNDATION_M02.md). M03/M04 in dieser Iteration nicht begonnen. |
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
