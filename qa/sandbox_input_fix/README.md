# Sandbox-Mausfix: Nachweise 05.10.2026

Quellcommit `056d537adb3eda058a4927ee8f9c3cf0168c2da0`. Alle Protokolle stammen aus den tatsächlich erneut ausgeführten Prüfungen dieses Standes. Die drei Code-/Testdateien stimmen byteweise mit dem vorherigen geprüften Lauf überein; Details in results.json.

- `regression/`: vollständige 26 Stufen, 1.190 Checks.
- `old_pack_focus.*`: neuer Fokuscheck gegen alte unveränderte Windows-EXE, erwartete 121/122.
- `old_pack_visual.*`: dieselbe erweiterte UI-Prüfung gegen altes Pack, erwartete 23/34.
- `new_pack_visual.*`: neues Windows-Pack, 34/34. Leerer Ressourcenordner, externes Testscript, Linux/Xvfb/Mesa. Kein Quellcode-Fallback. PNG-Pfade im JSON bezeichnen lokale Lauf-Artefakte; Bilder werden nicht als neue Art-Assets eingecheckt.
- `developer_export/`: 5 Gates, beide Release-Packs mit 122/122, Save-Isolation und Binärhashes.
- `production_export/`: 8 Gates einschließlich Sandbox-Ausschluss aus beiden Packs.
- `package_results.json`: vollständige ZIP-Extraktion, CRC und Datei-Hashes.

Die erwarteten Fehlermeldungen der Baseline sind Reproduktionsnachweise; sie gehören nicht zum grünen neuen Build. In Content-Startup-/Save-Fehlertests sind absichtlich ausgelöste Fehlermeldungen Teil der jeweiligen Testfälle. Der einzige Render-Warnhinweis ist die vom virtuellen Grafiktreiber nicht unterstützte VSync-Umschaltung.

Native Windows-Ausführung des Fixes: NOT TESTED. Tims vorheriger Sandbox-Windows-Test hat den Eingabefehler gemeldet. M08 bleibt gestoppt.
