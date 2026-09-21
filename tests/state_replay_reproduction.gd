extends SceneTree
## A second view of a collected chest must not become a second reward.
const SAVE := "user://m02_replay_only.json"
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS REPLAY: " if ok else "FAIL REPLAY: ", title)

func verify() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	var fixture := SaveSystem.read_one("res://tests/fixtures/v04_alignment_started.json")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	paused = true
	var before: Dictionary = game.run.serialize()
	check("star_chart" in game.run.vault.relics and SaveSystem.validate(SaveSystem.snapshot(game.run, game.player, game.settings)).is_empty(), "Frozen 0.4 reference starts with one valid collected chart")
	var stale := DungeonObject.new()
	stale.configure({"id":"star_chart", "kind":"chest", "name":"Die vergessene Sternenkarte", "tile":Vector2i(78,46)}, false)
	game.terrain.actors.add_child(stale)
	stale.interaction = DungeonInteraction.new(stale, game)
	game.player.position = stale.position + Vector2(0,24)
	game.interact_dungeon(stale)
	check(game.run.serialize() == before, "Repeated request from an inactive second chest view cannot grant another item or XP")
	check(SaveSystem.validate(SaveSystem.snapshot(game.run, game.player, game.settings)).is_empty(), "Repeated chest request leaves a saveable state")
	paused = false
	game.queue_free()
	for i in 5: await process_frame
	for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
		if FileAccess.file_exists(SAVE + suffix): DirAccess.remove_absolute(SAVE + suffix)
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/state_replay_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures}, "  ")); report.close()
	print("STATE REPLAY RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
