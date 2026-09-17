extends SceneTree
## Same scenario runs against M02 and M03; no lifecycle internals required.
var checks := 0
var failures: Array[String] = []
const SAVE := "user://region_replay_only.json"

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS REGION REPLAY: " if ok else "FAIL REGION REPLAY: ", title)

func verify() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	var fixture := SaveSystem.read("res://tests/fixtures/v04_alignment_started.json")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	var original_run: RunState = game.run
	var xp_before: int = game.run.xp
	var level_before: int = game.run.level
	var guardian: SourceGuardian = game.source_story.guardian
	guardian.awaken()
	guardian.take_damage(999) # Emits the real signal and queues story completion.
	game.travel_to("forest")
	game.travel_to("vault") # Same persistent ID, different live instance, no frame between.
	check(game.run == original_run and game.run.region == "vault", "Round trip retains the same persistent run and region ID")
	for i in 3: await process_frame
	check(game.run.source.resolution.is_empty() and not game.run.source.guardian_defeated, "Old deferred victory cannot resolve the replacement vault")
	check(game.run.inventory.owned.is_empty() and game.run.xp == xp_before and game.run.level == level_before, "Old deferred victory cannot grant a relic or XP")
	check(is_instance_valid(game.source_story.guardian) and not game.source_story.guardian.awake, "Replacement vault keeps its own dormant guardian")
	paused = false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(SAVE + suffix): DirAccess.remove_absolute(SAVE + suffix)
	var report := FileAccess.open("res://test-output/region_replay_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks": checks, "failures": failures}, "  "))
	report.close()
	print("REGION REPLAY RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
