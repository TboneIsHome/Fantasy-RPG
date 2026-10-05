# Developer Sandbox — Windows-Prüfliste

**Neuer Mausfix: MANUAL WINDOWS TESTED — NOT TESTED.** Tim hat den Eingabefehler im vorherigen Sandbox-Build unter Windows gefunden. Diese Prüfliste betrifft das korrigierte Paket vom 05.10.2026. M07 selbst ist bereits abgenommen.

## Gezielter Nachtest des Mausfixes

1. `Lichterhain_DeveloperSandbox_InputFix_Windows.zip` in einen neuen Ordner entpacken und die dortige EXE starten.
2. Maus in die Arena bewegen. **Linke Maustaste / 1 = Lichtfunke**, **rechte Maustaste / 2 = Frostkreis** — genau wie in der Produktion. Jeweils auf den Dummy zielen: Zauber, Mana-Kosten und sinkende Ziel-HP prüfen.
3. Eine Auswahl im Dropdown „Angriff“ treffen, Maus zurück in die Arena bewegen und rechts klicken. Der erste Klick soll Frostkreis auslösen. Das Dropdown bestimmt nur den Button „Auf Ziel zaubern“, nicht die Maustastenbelegung.
4. Mehrmals links klicken und rechts mit Loslassen erneut klicken; Cooldowns abwarten oder „Spieler auffüllen + Cooldowns zurücksetzen“ verwenden. Halten von RMB löst keine automatische Wiederholung aus.
5. Ein Zahlenfeld bearbeiten. Der erste Arena-Klick beendet nur die Bearbeitung; nach Loslassen muss der nächste Klick wieder zaubern. Mit beiden Maustasten prüfen.
6. Über dem Bedienfeld und während Pause dürfen die Maustasten keinen Zauber auslösen. Danach fortsetzen und erneut beide Zauber prüfen.

Die automatische Prüfung deckt diese Fokus-/Combat-Pfade ab; die native Windows-Eingabe wird mit dieser Runde abgenommen.

## Start

1. `Lichterhain_DeveloperSandbox_InputFix_Windows.zip` vollständig entpacken.
2. `Lichterhain_DeveloperSandbox.exe` öffnen. Die Arena mit Magier, Dummy und Testleiste soll direkt erscheinen. Keine Godot-Installation nötig.
3. Maus in die Arena bewegen: WASD/Pfeiltasten bewegen, Maus zielt, linke/rechte Maustaste oder 1/2 zaubern. Leertaste: Dodge. F halten: Block. Q: Parry. R: einzelner Gegnerangriff. P: Pause/Weiter. F2: vollständiger Reset.
4. Zahlen rechts ändern und „Übernehmen / Reset“ wählen. Nach Bearbeitung eines Zahlenfelds einmal in die Arena klicken; dieser Fokuswechsel soll keinen Zauber auslösen.

Eigener Benutzerordner: `%APPDATA%\Lichterhain_DeveloperSandbox\`. Normale Lichtpfad-Spielstände werden nicht geladen oder geschrieben. F5/F9 haben hier keine Speicherfunktion. „Diagnosebericht speichern“ schreibt ausschließlich `developer_sandbox\last_report.json` im Developer-Benutzerordner; der genaue Pfad erscheint in der Statuszeile.

## Abnahmerunde

| Schritt | Aktion | Erwartung |
| --- | --- | --- |
| Oberfläche | Beide Tabs und rechte Scrollleiste prüfen | Lesbare Controls; LP/MP/AU und Zielgesundheit unter der Arena sichtbar |
| Presets | Nahdistanz, Fernkampf, Magie und unterschiedliche Gegner wählen; jeweils Reset | Passender Abstand/Gegner; genau ein Spieler; keine alten Projektile. Nahdistanz nutzt den Magier mit Abwehr, noch keine M08-Waffe |
| Testwerte | Dummy-HP, Protection, Stability ändern; Reset | Werte gelten lokal; Produktionsbalance unverändert |
| Angriffe | Lichtfunke/Frostkreis wiederholt nutzen | Echte Kosten/Cooldowns; Treffer senken Ziel-HP; UI-Klicks zaubern nicht zusätzlich |
| Defense | Nahdistanz + Wolf/Dummy, R; F/Q/Leertaste unterschiedlich timen | Frontblock lässt Restwirkung; gelungene Parade unterbricht; falsches Timing schützt nicht; Dodge bewegt und schützt kurz |
| Magier | Irrlicht wählen; Geschosse mit F/Q/Leertaste testen | Nachvollziehbare Abwehr, keine dauerhafte Immunität oder automatische Gegenattacke |
| Reset | Mit aktiven Angriffen/Geschossen mehrmals F2 | Frische Ressourcen/Cooldowns/Position; keine alten Treffer oder doppelten Actors |
| Szenarien | Nach unten scrollen, „Alle A01–A12“ | „PASS · 12 Szenarien“, danach Pause. Jedes Szenario auch einzeln wiederholbar |
| Probe | Dummy-Abstand 24, Zielwinkel/Blick 0; Diagnose → Probe starten; Kontakt sofort, dann +50 ms mehrfach und Kontakt | Startup/Commit lehnen ab; Active trifft; Wiederholung meldet duplicate_hit; Recovery trifft nicht. Schritt bewegt Uhren, keine Körper |
| Geometrie | In Pause Abstand größer als 42 oder Blick weg vom Ziel; neue Probe bis Active | out_of_range bzw. wrong_direction. Fester Blick gilt in Pause; live übernimmt die Maus |
| Wellen | Start; Folgegegner prüfen; Stop + Pause; Reset | Drei endliche Wellen, kein Endlosspawn. Stop hält Actors an; Reset räumt auf |
| Bericht/Neustart | Diagnosebericht speichern, schließen, erneut starten | Lesbarer Bericht; neuer Sandbox-Startzustand; normaler Save unverändert |

Die Runde benötigt ungefähr 15–20 Minuten und prüft Funktion und Bedienung, noch keine finale Balance oder Grafik.

## Fehler melden und abnehmen

Bitte Windows-Version, Build-Prüfsumme aus `BUILD_INFO.json`, Szenario oder Schritte, Player-/Enemy-Preset, Angriff/Defense, Abstand und Zeitpunkt nennen. Möglichst `last_report.json` und Screenshot beilegen. Vollständige Kontaktablehnungen gibt es in gezielten Proben/Szenarien; freie Kämpfe liefern tatsächliche Defense-/M06-Ergebnisse, nicht jeden Miss.

Abnahme ausdrücklich als **PASSED** oder **FAILED** mit Beobachtungen bestätigen. Bis dahin bleibt der Sandbox-Windows-Test **NOT TESTED**. Danach gemeinsame Prüfung; M08 erst nach neuer Freigabe.
