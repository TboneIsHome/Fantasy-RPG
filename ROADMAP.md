# Roadmap

Stand: 2026-09-21, spielbarer Quellstand 0.4.0 / Gameplay Foundation M06. Tim hat Foundation M00–M04 einschließlich manueller Windows-Abnahme bestätigt, danach M05 und anschließend ausdrücklich die [M06-Spezifikation V1.1](docs/M06_STATS_HIT_RESOLUTION_V1_1.md) freigegeben. Die [Design-Bible](docs/CREATIVE_DESIGN_BIBLE_V1.md) besitzt das langfristige Spielerlebnis. Aktuell priorisiert Tim robuste Kernsysteme und eine kleine, erweiterbare Weltsimulation. Größe und Systemtiefe werden schrittweise geprüft; der aktuelle Prototyp erfüllt die langfristige Vision noch nicht.

## Verbindliche nächste Reihenfolge

| Meilenstein | Kleinster zusammenhängender Umfang | Abnahme / Status |
| --- | --- | --- |
| **M00 — Referenz und Audit** | Originalen 0.4-Code gegen Audit V1 prüfen; Quellstand, Reports, Exporte und verfügbare Saves sichern | **COMPLETE** laut Tim. Historische Prüfergebnisse und Grenzen: [FOUNDATION_M00.md](docs/FOUNDATION_M00.md). Der damalige Stop-Punkt wurde durch Tims Auftrag zur Bible-Integration und M01 aufgehoben. |
| **M01 — Save-System** | I/O-Fehler reproduzieren, minimal absichern und Fehlermeldungen im Pausefenster sichtbar halten | **COMPLETE** als Teil der von Tim abgenommenen Foundation. 290 historische Checks und Linux-Dateifehler. Native Windows-Dateifehlerinjektion bleibt **NOT TESTED**; spätere Spieltests ersetzen sie nicht. [Ergebnisse und Grenzen](docs/FOUNDATION_M01.md). |
| **M02 — Zustandsänderungen** | Dauerhafte Fortschrittsaktionen und vollständige Belohnungen beim fachlichen Besitzer bündeln | **COMPLETE** laut Tim; zusätzlicher manueller Windows-Spieltest ausdrücklich bestätigt. 405 automatisierte Checks und historische Nachweise: [Bericht](docs/FOUNDATION_M02.md). Keine nachträgliche Behauptung einzelner nicht protokollierter Windows-Dateifehlertests. |
| **M03 — Regionslebenszyklus** | Build/Activate/Deactivate/Unload/Travel aus der Sitzung heraus klar abgrenzen | **COMPLETE / TESTED** laut Tim; manueller Windows-Test vor M04 ausdrücklich bestätigt. 504/504 historische Checks. [M03 Completion Report mit Nachtrag](docs/FOUNDATION_M03.md). |
| **M04 — Inhaltsdaten** | Bestehende JSON-Quellen validieren und Regeln mit Gameplay, HUD und Saveprüfung verbinden | **COMPLETE / TESTED** laut Tim einschließlich manueller Windows-Abnahme und Reportprüfung vor M05. 707/707 Checks. [Foundation Completion Report mit Nachtrag](docs/FOUNDATION_COMPLETION_REPORT.md). |
| **M05 — Interaction Foundation** | Kleiner Vertrag, getrennte Discovery/Execution, frische Validierung und bestätigte Folgen; bestehende reale Verbraucher anbinden | **IMPLEMENTED**, automatisiert **TESTED**, insgesamt **PARTIALLY TESTED**. 789/789 Checks, beide Exporte/Packs und Windows-Testpaket fertig. Eigener manueller M05-Windows-Test **NOT TESTED**. [M05 Completion Report](docs/FOUNDATION_M05.md). |
| **M06 — Stats & Trefferauflösung** | Gemeinsame Damage-/Impact-Rechnung, neutrale geprüfte Defense-Definitionen und einmalige Kontaktlieferung für bestehende Angriffe | **IMPLEMENTED**, automatisiert **TESTED**, insgesamt **PARTIALLY TESTED**. 931/931 Checks, beide Exporte/Packs und Windows-Testpaket. Manueller M06-Windows-Test **NOT TESTED**. [M06 Completion Report](docs/FOUNDATION_M06.md). |

Nach jedem Umbauschritt: relevante neue Prüfungen, gesamte bestehende Regression, Savegame-Prüfungen, Exportprüfung und dokumentierte manuelle Smoke-Runde. Eine offene Plattformprüfung wird offen ausgewiesen. Keine parallelen Umbauten unabhängiger Kernsysteme und kein Save-Reset als Abkürzung.

**Aktueller Stop:** M06-Windows-Spieltest und M06 Completion Report gemeinsam prüfen. Die ausdrückliche M06-Freigabe hebt den früheren M05-Entwicklungsstop auf, belegt aber keinen nachträglichen M05-Spieltest. M07 und spätere Systeme sind nicht begonnen und brauchen jeweils ein genehmigtes Design sowie eine neue Implementierungsfreigabe.

## Bisherige spielbare Referenzen

| Stand | Erhaltenswerter Umfang |
| --- | --- |
| 0.1 | Magierbewegung, zwei Zauber, Ausweichen, Gegnerfeedback, Seed-Wald, Edda, Waldlichter, Talente, Speichern/Laden; erster positiver Spieltest |
| 0.2 | Eigene überarbeitete Pixelgrafik, Licht, Umgebung und Oberfläche; ursprünglicher 0.1-Spielstand bleibt kompatibel |
| 0.3 | Quellengruft mit sechs Haupträumen und Geheimraum, Dornengegner, Navigation, Journal/Funde, geöffnete Wege, Format-2-Migration |
| 0.4 | Quellenhüter, Untersuchung oder Kampf, sichtbare Folgen, Reliktplatz, getrennte Quellen-/Inventarzustände und Format-3-Migration; positiver Nutzerbericht, 197 bestehende Checks |

Das unveränderte 0.4-Release liegt auf `reference/v0.4-original`. M00 baut darauf auf und verändert keine Laufzeitmechanik. 0.3 bleibt über die Git-Historie als Vergleich erhalten.

## Spätere Entwicklungsphasen — PLANNED

| Geplante Richtung | Status / Grenze |
| --- | --- |
| M07 aktive Combat Foundation | **PLANNED**; gemäß M06 V1.1 später Kontaktentstehung, aktive Defense-/Timing-Fenster und Combat-Reaktionen definieren; keine zweite Damage-Rechnung |
| M08 Weapon Foundation | **PLANNED**; kein vorgezogenes Waffenarsenal |
| M09 Magic Foundation | **PLANNED**; bestehende Fähigkeiten bis dahin erhalten |
| M10 Status Effects | **PLANNED**; konkrete Anforderungen und Abhängigkeiten zuerst prüfen |
| Living World Foundation → RPG Systems → Dynamic / Procedural World | **PLANNED**; später in kleine, genehmigte Milestones aufteilen |

Diese Reihenfolge stammt aus Tims Master Chat V2.0 und ist keine pauschale Umsetzungsfreigabe. Bestehende Module werden nur bei nachweisbarem Nutzen schrittweise erweitert. JSON bleibt; kein universeller Eventbus und keine leeren Managergerüste.

Streaming, umfangreiche KI, Fraktionen, Wirtschaft, Crafting, Begleiter und große neue Regionen bleiben später. Ebenso warten neue Klassen, umfangreiche Talentnetze und Inhaltskataloge. Die vorhandenen Bedienungswünsche (Eingabebelegung, Controller, Reichweitenvorschau, Orientierung und Balancing) bleiben im Qualitätsbacklog von TASKS.md, verdrängen aber nicht die aktuelle Stabilisierung.

Eine größere Karte oder mehr Zufall allein schaffen keine interessante Welt. Die Foundation soll stabile Identitäten, nachvollziehbare Zustandsänderungen, kontrollierte Lebensdauer und miteinander kombinierbare Regeln tragen. Welche Begegnungen daraus entstehen, wird zuerst in kleinen, spielbaren Beispielen erprobt.
