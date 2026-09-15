extends SceneTree
## Rendered guardian battle and repeated scene teardown; artificial durability keeps attacks running.
func _initialize() -> void:
	call_deferred("exercise")

func frames(count: int = 12) -> void:
	for i in count: await process_frame

func exercise() -> void:
	Engine.max_fps=60
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://source_soak_only.json"
	game.handle_action("new","LICHTERHAIN")
	game.run.quest_accepted=true
	for id in SaveSystem.LIGHTS: game.run.activate_light(id)
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
	game.player.position=game.source_story.site.position+Vector2(0,24)
	game.player.vitals.invulnerable=999
	game.interact(game.source_story.site)
	game.handle_action("source_challenge")
	var boss: SourceGuardian=game.source_story.guardian
	boss.hp=1000000
	for enemy in get_nodes_in_group("enemies"): enemy.hp=1000000
	await frames()
	var started := Time.get_ticks_msec()
	var initial_nodes := get_node_count()
	var peak_nodes := initial_nodes
	var peak_guardian_projectiles := 0
	var saw_impact := false
	var next_cast := 0
	var frame_times: Array[float]=[]
	var previous := Time.get_ticks_usec()
	while Time.get_ticks_msec()-started<60000:
		await process_frame
		var now := Time.get_ticks_usec()
		frame_times.append(float(now-previous)/1000)
		previous=now
		peak_nodes=maxi(peak_nodes,get_node_count())
		var projectiles := 0
		for node in game.combat.get_children():
			if node is SourceImpact: saw_impact=true
			if node is MagicProjectile and node.source_id==SourceQuest.GUARDIAN_ID: projectiles+=1
		peak_guardian_projectiles=maxi(peak_guardian_projectiles,projectiles)
		var elapsed := Time.get_ticks_msec()-started
		if elapsed>=next_cast:
			next_cast=elapsed+500
			game.player.vitals.mana=100
			game.player.request_cast("bolt",boss.global_position)
			game.player.request_cast("nova",boss.global_position)
	var result := {"scenario":"source_guardian","seconds":60,"frames":frame_times.size(),"mean_frame_ms":0.0,"initial_nodes":initial_nodes,"peak_nodes":peak_nodes,"end_nodes":get_node_count(),"peak_guardian_projectiles":peak_guardian_projectiles,"saw_source_impact":saw_impact,"forest_nodes_after_roundtrips":forest_counts,"vault_nodes_after_roundtrips":vault_counts,"renderer":"OpenGL Compatibility; software Mesa llvmpipe","headless":false}
	for duration in frame_times: result.mean_frame_ms+=duration/frame_times.size()
	frame_times.sort()
	result["p95_frame_ms"]=frame_times[int(frame_times.size()*0.95)]
	result["bounded_objects"]=peak_nodes<initial_nodes+90 and forest_counts.max()-forest_counts.min()<12 and vault_counts.max()-vault_counts.min()<12
	result["passed"]=result.bounded_objects and saw_impact and peak_guardian_projectiles==5
	var file := FileAccess.open("res://test-output/source_soak_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(result,"  "));file.close()
	print("SOURCE SOAK RESULT ",JSON.stringify(result))
	game.queue_free()
	await frames()
	await create_timer(0.15).timeout
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists("user://source_soak_only.json"+suffix): DirAccess.remove_absolute("user://source_soak_only.json"+suffix)
	quit(0 if result.passed else 1)
