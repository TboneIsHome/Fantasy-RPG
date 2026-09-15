# Working on Lichterhain

Read README.md, DECISIONS.md, TASKS.md, TESTING.md, and docs/FOUNDATION_M00.md before extending this project.

- Preserve Tim's choices: mysterious, colorful fantasy; slightly angled top-down pixel art; mage first; Godot 4 and GDScript; offline singleplayer.
- Follow the foundation sequence in ROADMAP.md: M00 audit/reference baseline, then M01 save safety, M02 state ownership, M03 region lifecycle, M04 content validation. Stop after presenting M00; do not start M01 or add gameplay systems without the next user instruction. Tim has reported a positive test of the new version; structured native Windows acceptance remains unrecorded.
- Preserve the original 0.4 release at GitHub reference/v0.4-original. M00 only adds documentation, baseline evidence and frozen reference saves. Do not regenerate or overwrite any frozen fixture to make a later test pass.
- Keep balance definitions in data/content.json and actor/state/UI responsibilities separated.
- Pin development and export to Godot 4.5.1 for this baseline. Investigate and document any deliberate upgrade.
- Run the relevant Godot tests after gameplay changes. Tests write only their dedicated test save paths. Render affected UI before shipping layout changes.
- Preserve stable world IDs and save compatibility; a generator/schema change needs a deliberate migration or version policy.
- Update the short project documents when behavior or priorities change. Distinguish implementation, automated validation, and human playtesting.
- Work only in the RPG repository selected by the user. MyFire belongs to another project.
- Pixel graphics are original code-defined assets. The DejaVu heading font is bundled with its license. Track provenance for new external assets.
- Preserve the frozen 0.1 fixture: never regenerate it with current code just to pass the compatibility test.
- Preserve the completed 0.2 fixture as well. Schema 1 migrates explicitly to schema 2; never overwrite the original .pre-v03 backup during later saves.
- Preserve the completed 0.3 fixture. Schema 3 explicitly migrates schemas 1/2 and keeps a permanent .pre-v04 original, including backup recovery. Do not overwrite prior migration backups.
- Quest rewards and source outcomes are one-time decisions. Scene reloads reset the live guardian, never the outcome, investigation checkpoint or equipped relic. Keep source progression separate from scene nodes.
