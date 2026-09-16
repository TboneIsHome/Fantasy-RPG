extends SceneTree
## A confirmed in-memory reward and a durable checkpoint are separate outcomes.
const SAVE := "user://m02_actions_scene_only.json"
var game
var checks := 0
var failures: Array[String] = []
var confirmed: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS STATE SCENE: " if ok else "FAIL STATE SCENE: ", title)

func observed() -> void:
	confirmed.append(SaveSystem.snapshot(game.run, game.player, game.settings))

func total_xp() -> int:
	return game.run.xp + 30 * game.run.level * (game.run.level - 1)

func verify() -> void:
	game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	var fixture := SaveSystem.read_one("res://tests/fixtures/v04_alignment_started.json")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	game.player.position = game.source_story.site.position + Vector2(0,24)
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	game.interact(game.source_story.site)
	while game.run.source.alignment < 2:
		game.handle_action("source_align", SourceQuest.SIGNS[game.run.source.alignment])
	check(game.save_game(), "Investigation checkpoint saved before completing the quest")
	var previous := FileAccess.get_file_as_bytes(SAVE)
	var xp := total_xp()
	game.run.changed.connect(observed)
	DirAccess.make_dir_absolute(SAVE + ".tmp")
	game.handle_action("source_align", "star")
	check(confirmed.size() == 1 and SaveSystem.validate(confirmed[0]).is_empty() and confirmed[0].run.source.resolution == "restored" and confirmed[0].run.inventory.equipped == "source_heart", "Scene observer receives one complete save-valid quest result")
	check(game.run.source.resolution == "restored" and total_xp() == xp + 90 and game.source_story.grove.resolution == "restored", "World presentation follows the confirmed in-memory outcome")
	check(FileAccess.get_file_as_bytes(SAVE) == previous and "nicht vollständig" in game.ui.hud.toast_text, "Failed autosave preserves the previous checkpoint and its error feedback")
	game.handle_action("source_align", "star")
	game.handle_action("source_challenge")
	check(confirmed.size() == 1 and total_xp() == xp + 90 and game.run.inventory.owned == ["source_heart"], "Repeated requests after a save failure cannot duplicate or replace the reward")
	DirAccess.remove_absolute(SAVE + ".tmp")
	check(game.save_game() and SaveSystem.read(SAVE).data.run.source.resolution == "restored", "Explicit retry durably saves the same completed result")
	game.run.changed.disconnect(observed)
	check(game.load_game() and total_xp() == xp + 90 and game.run.inventory.equipped == "source_heart", "Reload retains the exact single reward and equipment")
	check(not game.run.align_source("star") and not game.run.defeat_source_guardian(), "Replayed completion after reload is rejected")
	# The combat path's ore must follow the same rule across a failed autosave.
	var broken := SaveSystem.read_one("res://tests/fixtures/v04_broken_ore_unequipped.json")
	broken.data.run.source.ore_taken = false
	game.build_run(broken.data.run.world_seed, broken.data)
	game.player.position = game.source_story.site.position + Vector2(0,24)
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	check(game.save_game(), "Unharvested combat outcome saved as a disposable test checkpoint")
	var motes: int = game.run.motes
	previous = FileAccess.get_file_as_bytes(SAVE)
	DirAccess.make_dir_absolute(SAVE + ".tmp")
	game.interact(game.source_story.site)
	check(game.run.source.ore_taken and game.run.motes == motes + 4 and FileAccess.get_file_as_bytes(SAVE) == previous and "nicht vollständig" in game.ui.hud.toast_text, "Ore and dust commit together while the failed save stays visible")
	game.interact(game.source_story.site)
	check(game.run.motes == motes + 4, "Repeated harvest after failed autosave grants no extra dust")
	DirAccess.remove_absolute(SAVE + ".tmp")
	check(game.save_game() and game.load_game() and game.run.source.ore_taken and game.run.motes == motes + 4, "Retry and reload preserve exactly one ore reward")
	paused = false
	game.queue_free()
	for i in 5: await process_frame
	# As in save_scene_smoke, let the audio mixer release its last WAV playback.
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
		if FileAccess.file_exists(SAVE + suffix): DirAccess.remove_absolute(SAVE + suffix)
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/state_actions_scene_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures}, "  ")); report.close()
	print("STATE SCENE RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
