extends SceneTree

func _initialize() -> void:
	call_deferred("exercise")

func exercise() -> void:
	Engine.max_fps=60
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://soak_never_written.json"
	game.handle_action("new","LICHTERHAIN")
	game.player.position=WorldGenerator.center(game.terrain.data.points[1].tile)
	game.player.vitals.invulnerable=999
	var started := Time.get_ticks_msec()
	var initial_nodes := get_node_count()
	var max_nodes := initial_nodes
	var next_cast: int=0
	var frame_times: Array[float]=[]
	var previous := Time.get_ticks_usec()
	while Time.get_ticks_msec()-started<60000:
		await process_frame
		var now := Time.get_ticks_usec()
		frame_times.append(float(now-previous)/1000)
		previous=now
		max_nodes=maxi(max_nodes,get_node_count())
		var elapsed := Time.get_ticks_msec()-started
		if elapsed>=next_cast:
			next_cast=elapsed+500
			var target: Vector2=game.player.position+Vector2(90,0).rotated(float(elapsed)*0.001)
			game.player.request_cast("bolt",target)
			game.player.request_cast("nova",target)
	var result := {"seconds":60,"frames":frame_times.size(),"mean_frame_ms":0.0,"initial_nodes":initial_nodes,"peak_nodes":max_nodes,"end_nodes":get_node_count(),"renderer":"OpenGL Compatibility; software Mesa llvmpipe","headless":false}
	for duration in frame_times:
		result.mean_frame_ms+=duration/frame_times.size()
	frame_times.sort()
	result["p95_frame_ms"]=frame_times[int(frame_times.size()*0.95)]
	result["bounded_objects"]=max_nodes<initial_nodes+80
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/soak_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"  "))
	file.close()
	print("SOAK RESULT ",JSON.stringify(result))
	game.queue_free()
	for i in 5:
		await process_frame
	quit(0 if result.bounded_objects else 1)
