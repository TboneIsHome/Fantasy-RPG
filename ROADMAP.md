# Roadmap

Stand: 2026-10-05. Tim hat M07 einschließlich manuellem Windows-Spieltest ohne gefundene Fehler abgenommen. Aktueller Auftrag: ausschließlich der gemeldete Maus-/Fokusfehler der [Developer Sandbox](docs/DEVELOPER_SANDBOX_WORK_ORDER_V1.md). Creative Bible und [Future Systems Blueprint](docs/FUTURE_SYSTEMS_BLUEPRINT_V1.md) bleiben Leitplanken; keine späteren Systeme werden vorgezogen.

## Verbindliche nächste Reihenfolge

| Meilenstein | Kleinster zusammenhängender Umfang | Abnahme / Status |
| --- | --- | --- |
| **M00 — Referenz und Audit** | Originalen 0.4-Code gegen Audit V1 prüfen; Quellstand, Reports, Exporte und verfügbare Saves sichern | **COMPLETE** laut Tim. Historische Prüfergebnisse und Grenzen: [FOUNDATION_M00.md](docs/FOUNDATION_M00.md). Der damalige Stop-Punkt wurde durch Tims Auftrag zur Bible-Integration und M01 aufgehoben. |
| **M01 — Save-System** | I/O-Fehler reproduzieren, minimal absichern und Fehlermeldungen im Pausefenster sichtbar halten | **COMPLETE** als Teil der von Tim abgenommenen Foundation. 290 historische Checks und Linux-Dateifehler. Native Windows-Dateifehlerinjektion bleibt **NOT TESTED**; spätere Spieltests ersetzen sie nicht. [Ergebnisse und Grenzen](docs/FOUNDATION_M01.md). |
| **M02 — Zustandsänderungen** | Dauerhafte Fortschrittsaktionen und vollständige Belohnungen beim fachlichen Besitzer bündeln | **COMPLETE** laut Tim; zusätzlicher manueller Windows-Spieltest ausdrücklich bestätigt. 405 automatisierte Checks und historische Nachweise: [Bericht](docs/FOUNDATION_M02.md). Keine nachträgliche Behauptung einzelner nicht protokollierter Windows-Dateifehlertests. |
| **M03 — Regionslebenszyklus** | Build/Activate/Deactivate/Unload/Travel aus der Sitzung heraus klar abgrenzen | **COMPLETE / TESTED** laut Tim; manueller Windows-Test vor M04 ausdrücklich bestätigt. 504/504 historische Checks. [M03 Completion Report mit Nachtrag](docs/FOUNDATION_M03.md). |
| **M04 — Inhaltsdaten** | Bestehende JSON-Quellen validieren und Regeln mit Gameplay, HUD und Saveprüfung verbinden | **COMPLETE / TESTED** laut Tim einschließlich manueller Windows-Abnahme und Reportprüfung vor M05. 707/707 Checks. [Foundation Completion Report mit Nachtrag](docs/FOUNDATION_COMPLETION_REPORT.md). |
| **M05 — Interaction Foundation** | Kleiner Vertrag mit Discovery, frischer Execution und bestätigten Folgen | **COMPLETE** im vom Nutzer bestätigten M00–M06-Ausgangsstand; 789 historische Checks. Kein nachträglich erfundenes Einzeltestprotokoll. [Bericht](docs/FOUNDATION_M05.md). |
| **M06 — Stats & Trefferauflösung** | Gemeinsame numerische Damage-/Impact-Auflösung und HitInstance | **COMPLETE**, 931 historische Checks; manueller Windows-Spieltest von Tim vor M07 ausdrücklich bestätigt. [Bericht](docs/FOUNDATION_M06.md). |
| **M07 — Active Combat & Defense** | Action Lifecycle, Kontakt, Dodge/Block/Parry, explizite Phasen und kontrollierte Reaktion | **COMPLETE**: 1.070 historische Checks und Release-Gates; Tim bestätigt den manuellen Windows-Spieltest ohne gefundene Fehler. [Completion Report](docs/FOUNDATION_M07.md). |
| **Developer Sandbox Foundation** | Lokale Arena, Presets, echte Combat-Controls, Wellen, Diagnose und A01–A12; gezielte Maus-/Fokuskorrektur | **IMPLEMENTED / AUTOMATED TESTED**: 1.190 Checks, 34 gerenderte Bedienprüfungen und getrennte Exporte; siehe [Completion Report mit Bugfix-Nachtrag](docs/DEVELOPER_SANDBOX_COMPLETION_REPORT.md). Tim hat im alten Windows-Build den Eingabefehler gefunden. **Neuer Fix: MANUAL WINDOWS NOT TESTED**. |

Nach jedem Umbauschritt: relevante neue Prüfungen, gesamte bestehende Regression, Savegame-Prüfungen, Exportprüfung und dokumentierte manuelle Smoke-Runde. Eine offene Plattformprüfung wird offen ausgewiesen. Keine parallelen Umbauten unabhängiger Kernsysteme und kein Save-Reset als Abkürzung.

**Aktueller Stop:** Mausfix-Bericht und neues Developer-Windows-Paket gemeinsam prüfen; Windows-Nachtest des Fixes steht aus. M08 und alle weiteren Systeme bleiben **PLANNED** und benötigen eine neue Freigabe.

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
| M08 Weapon Foundation | **PLANNED**; kein vorgezogenes Waffenarsenal |
| M09 Magic Foundation | **PLANNED**; bestehende Fähigkeiten bis dahin erhalten |
| M10 Status Effects | **PLANNED**; konkrete Anforderungen und Abhängigkeiten zuerst prüfen |
| Living World Foundation → RPG Systems → Dynamic / Procedural World | **PLANNED**; später in kleine, genehmigte Milestones aufteilen |

Diese Reihenfolge stammt aus Tims Master Chat V2.0 und ist keine pauschale Umsetzungsfreigabe. Bestehende Module werden nur bei nachweisbarem Nutzen schrittweise erweitert. JSON bleibt; kein universeller Eventbus und keine leeren Managergerüste.

Streaming, umfangreiche KI, Fraktionen, Wirtschaft, Crafting, Begleiter und große neue Regionen bleiben später. Ebenso warten neue Klassen, umfangreiche Talentnetze und Inhaltskataloge. Die vorhandenen Bedienungswünsche (Eingabebelegung, Controller, Reichweitenvorschau, Orientierung und Balancing) bleiben im Qualitätsbacklog von TASKS.md, verdrängen aber nicht die aktuelle Stabilisierung.

Eine größere Karte oder mehr Zufall allein schaffen keine interessante Welt. Die Foundation soll stabile Identitäten, nachvollziehbare Zustandsänderungen, kontrollierte Lebensdauer und miteinander kombinierbare Regeln tragen. Welche Begegnungen daraus entstehen, wird zuerst in kleinen, spielbaren Beispielen erprobt.
