extends SceneTree
## Identical M02/M03 workload: warm caches, then six round trips with normal saves.
const SAVE := "user://region_measure_only.json"

func _initialize() -> void:
	call_deferred("measure")

func measure() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	var fixture := SaveSystem.read("res://tests/fixtures/v04_alignment_started.json")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	var samples: Array = []
	var added := {"players": 0, "views": 0, "combat": 0}
	node_added.connect(func(node):
		if node is MagePlayer: added.players += 1
		if node is WorldView: added.views += 1
		if node is CombatSystem: added.combat += 1)
	for i in 14:
		var region := "forest" if i % 2 == 0 else "vault"
		var started := Time.get_ticks_usec()
		game.travel_to(region)
		var duration := Time.get_ticks_usec() - started
		paused = true
		for frame in 4: await process_frame
		if i >= 2:
			samples.append({"region": region, "travel_ms": duration / 1000.0,
				"nodes": get_node_count(), "objects": Performance.get_monitor(Performance.OBJECT_COUNT),
				"players": get_nodes_in_group("player").size(), "enemies": get_nodes_in_group("enemies").size()})
	var report := FileAccess.open("res://test-output/region_measure_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"transitions": 14, "created": added, "samples": samples}, "  "))
	report.close()
	paused = false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(SAVE + suffix): DirAccess.remove_absolute(SAVE + suffix)
	print("REGION MEASURE COMPLETE")
	quit()
