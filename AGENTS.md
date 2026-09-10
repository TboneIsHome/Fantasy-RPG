# Working on Lichterhain

Read README.md, DECISIONS.md, TASKS.md, and TESTING.md before extending this project.

- Preserve Tim's choices: mysterious, colorful fantasy; slightly angled top-down pixel art; mage first; Godot 4 and GDScript; offline singleplayer.
- Target the next small playable milestone in ROADMAP.md. Version 0.3 adds the dungeon and third enemy; the full vertical slice still needs the elite, two quest solutions, and equipment.
- Keep balance definitions in data/content.json and actor/state/UI responsibilities separated.
- Pin development and export to Godot 4.5.1 for this baseline. Investigate and document any deliberate upgrade.
- Run the relevant Godot tests after gameplay changes. Tests write only their dedicated test save paths. Render affected UI before shipping layout changes.
- Preserve stable world IDs and save compatibility; a generator/schema change needs a deliberate migration or version policy.
- Update the short project documents when behavior or priorities change. Distinguish implementation, automated validation, and human playtesting.
- Work only in the RPG repository selected by the user. MyFire belongs to another project.
- Pixel graphics are original code-defined assets. The DejaVu heading font is bundled with its license. Track provenance for new external assets.
- Preserve the frozen 0.1 fixture: never regenerate it with current code just to pass the compatibility test.
- Preserve the completed 0.2 fixture as well. Schema 1 migrates explicitly to schema 2; never overwrite the original .pre-v03 backup during later saves.
