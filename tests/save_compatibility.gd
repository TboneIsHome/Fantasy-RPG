extends SceneTree
## Frozen by the actual 0.1 code, not regenerated with the current serializer.
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, title: String) -> void:
	checks += 1
	if not condition:
		failures.append(title)
	print("PASS COMPAT: " if condition else "FAIL COMPAT: ",title)

func verify() -> void:
	var original := FileAccess.get_file_as_bytes("res://tests/fixtures/v01_save.json")
	var loaded := SaveSystem.read("res://tests/fixtures/v01_save.json")
	check(loaded.error.is_empty(),"0.1 save is accepted without migration")
	if not loaded.error.is_empty():
		quit(1)
		return
	var world := WorldGenerator.generate(loaded.data.run.world_seed)
	var digest := HashingContext.new()
	digest.start(HashingContext.HASH_SHA256)
	digest.update(world.tiles.to_byte_array())
	check(digest.finish().hex_encode()==FileAccess.get_file_as_string("res://tests/fixtures/v01_world_sha256.txt"),"Full terrain and collision raster matches the 0.1 world")
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://compatibility_test_only.json"
	game.build_run(loaded.data.run.world_seed,loaded.data)
	# Inspect before physics can regenerate resources or advance the clock.
	check(game.player.position==Vector2(248,726) and game.player.vitals.hp==73 and game.player.vitals.mana==41 and game.player.vitals.stamina==86,"Old position and all three resources restored exactly")
	check(game.run.level==2 and game.run.xp==18 and game.run.learned==["flow"] and game.run.skill_points==0 and game.run.motes==1,"Old talents, experience and inventory retained")
	check(game.run.active_lights==["light_0"] and game.run.quest_accepted and not game.run.quest_complete,"Old light and quest progress retained")
	check(game.settings=={"volume":0.25,"shake":false} and game.run.time_of_day==0.72,"Old settings and time retained")
	for i in 3:
		await process_frame
	var enemy_missing := true
	var lit := false
	for enemy in get_nodes_in_group("enemies"):
		if enemy.id=="guard_1_0":
			enemy_missing=false
	for landmark in get_nodes_in_group("landmarks"):
		if landmark.id=="light_0":
			lit = landmark.active and landmark.light.enabled
	check(enemy_missing and get_nodes_in_group("enemies").size()==8 and lit,"Loaded world displays the activated shrine and keeps the defeated enemy absent")
	check(FileAccess.get_file_as_bytes("res://tests/fixtures/v01_save.json")==original,"Loading leaves the original save bytes unchanged")
	paused=false
	game.queue_free()
	for i in 5:
		await process_frame
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/compatibility_results.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures,"fixture_source":"0.1 e646cf2"},"  "))
	report.close()
	print("COMPAT RESULT: ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
