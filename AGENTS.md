# Working on Lichterhain

Read README.md, DECISIONS.md, TASKS.md, and TESTING.md before extending this project.

- Preserve Tim's choices: mysterious, colorful fantasy; slightly angled top-down pixel art; mage first; Godot 4 and GDScript; offline singleplayer.
- Target the next small playable milestone in ROADMAP.md. The full vertical slice still needs the dungeon, third enemy role, elite, and two quest solutions.
- Keep balance definitions in data/content.json and actor/state/UI responsibilities separated.
- Pin development and export to Godot 4.5.1 for this baseline. Investigate and document any deliberate upgrade.
- Run the relevant Godot tests after gameplay changes. Tests write only their dedicated test save paths. Render affected UI before shipping layout changes.
- Preserve stable world IDs and save compatibility; a generator/schema change needs a deliberate migration or version policy.
- Update the short project documents when behavior or priorities change. Distinguish implementation, automated validation, and human playtesting.
- Work only in the RPG repository selected by the user. MyFire belongs to another project.
- Assets in this version are original code-generated placeholders. Track provenance for new external assets.
