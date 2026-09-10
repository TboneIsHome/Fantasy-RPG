extends SceneTree
## Real rendered combat plus repeated world teardown; uses an isolated save path.
func _initialize() -> void:
	call_deferred("exercise")

func frames(count: int = 12) -> void:
	for i in count:
		await process_frame

func exercise() -> void:
	Engine.max_fps=60
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://vault_soak_only.json"
	game.handle_action("new","LICHTERHAIN")
	game.run.quest_accepted=true
	for id in SaveSystem.LIGHTS:
		game.run.activate_light(id)
	game.run.quest_complete=true
	var forest_counts: Array[int]=[]
	var vault_counts: Array[int]=[]
	for cycle in 3:
		game.travel_to("vault")
		await frames()
		vault_counts.append(get_node_count())
		game.travel_to("forest")
		await frames()
		forest_counts.append(get_node_count())
	game.travel_to("vault")
	game.player.position=WorldGenerator.center(Vector2i(78,17))
	game.player.vitals.invulnerable=999
	for enemy in get_nodes_in_group("enemies"):
		enemy.hp=1000000 # Keep actual enemy attacks active throughout the measurement.
	await frames()
	var started := Time.get_ticks_msec()
	var initial_nodes := get_node_count()
	var peak_nodes := initial_nodes
	var peak_thorns := 0
	var next_cast := 0
	var frame_times: Array[float]=[]
	var previous := Time.get_ticks_usec()
	while Time.get_ticks_msec()-started<60000:
		await process_frame
		var now := Time.get_ticks_usec()
		frame_times.append(float(now-previous)/1000)
		previous=now
		peak_nodes=maxi(peak_nodes,get_node_count())
		var thorns := 0
		for node in game.combat.get_children():
			if node is ThornPatch:
				thorns+=1
		peak_thorns=maxi(peak_thorns,thorns)
		var elapsed := Time.get_ticks_msec()-started
		if elapsed>=next_cast:
			next_cast=elapsed+500
			game.player.vitals.mana=100
			var target: Vector2=game.player.position+Vector2(65,0).rotated(elapsed*0.001)
			game.player.request_cast("bolt",target)
			game.player.request_cast("nova",target)
	var result := {"seconds":60,"frames":frame_times.size(),"mean_frame_ms":0.0,"initial_nodes":initial_nodes,"peak_nodes":peak_nodes,"end_nodes":get_node_count(),"peak_thorn_zones":peak_thorns,"forest_nodes_after_roundtrips":forest_counts,"vault_nodes_after_roundtrips":vault_counts,"renderer":"OpenGL Compatibility; software Mesa llvmpipe","headless":false}
	for duration in frame_times:
		result.mean_frame_ms+=duration/frame_times.size()
	frame_times.sort()
	result["p95_frame_ms"]=frame_times[int(frame_times.size()*0.95)]
	result["bounded_objects"]=peak_nodes<initial_nodes+80 and forest_counts.max()-forest_counts.min()<12 and vault_counts.max()-vault_counts.min()<12
	result["passed"]=result.bounded_objects and peak_thorns>0
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/vault_soak_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"  "))
	file.close()
	print("VAULT SOAK RESULT ",JSON.stringify(result))
	game.queue_free()
	await frames()
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists("user://vault_soak_only.json"+suffix):
			DirAccess.remove_absolute("user://vault_soak_only.json"+suffix)
	quit(0 if result.passed else 1)
