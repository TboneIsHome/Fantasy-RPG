# Working on Lichterhain

Read README.md, DECISIONS.md, TASKS.md, TESTING.md, docs/CREATIVE_DESIGN_BIBLE_V1.md, and the current foundation report before extending this project.

- Preserve Tim's choices: mysterious, colorful fantasy; slightly angled top-down pixel art; mage first; Godot 4 and GDScript; offline singleplayer.
- Follow the foundation sequence in ROADMAP.md. Tim accepted M00, authorized M01, then requested the next iteration after receiving its results. This authorizes M02 state ownership. Native Windows/manual acceptance remains open and must not be inferred from that continuation. Do not advance to M03/M04 or add gameplay in this iteration.
- Runtime progression requests go through RunState's domain actions. DungeonProgress, SourceQuest and RelicInventory retain their local rules; RunState coordinates their rewards and emits changed only after the complete persistent result. Scene code owns presentation and explicit save checkpoints. Tests/restoration may construct fields directly; do not add direct progress writes in scene/combat/UI code.
- The creative Bible owns the intended experience; TECHNICAL_DESIGN.md owns the implemented architecture. Flag conflicts instead of silently weakening the vision. Explicitly open design details remain open; new details are PROPOSAL until Tim confirms them. Before a future feature, check priority, dependencies, foundation readiness, architecture changes and tests.
- The mage is the first prototype playstyle, not a permanent class restriction. Preserve the Bible's freedom, meaningful consequences and optional depth.
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
