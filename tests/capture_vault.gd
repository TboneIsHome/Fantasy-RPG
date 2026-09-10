extends SceneTree
func _initialize() -> void:
	call_deferred("capture")

func frames(count: int = 5) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw

func shot(id: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-output/"+id+".png")
	print("CAPTURE VAULT ",id)

func capture() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://vault_capture_only.json"
	game.handle_action("new","LICHTERHAIN")
	for id in SaveSystem.LIGHTS:
		game.run.activate_light(id)
	game.run.quest_accepted=true
	game.run.quest_complete=true
	game.player.position=WorldGenerator.center(game.terrain.data.points[3].tile+Vector2i(2,3))
	await frames()
	game.ui.hud.toast_left=0
	await shot("vault_entrance")
	game.travel_to("vault")
	game.player.vitals.invulnerable=999
	await frames()
	game.ui.hud.toast_left=0
	await shot("vault_threshold")
	game.player.position=WorldGenerator.center(Vector2i(46,17))
	await frames(25)
	game.ui.hud.toast_left=0
	await shot("vault_cistern")
	game.player.position=WorldGenerator.center(Vector2i(78,17))
	await frames(8)
	game.ui.hud.toast_left=0
	game.player.request_cast("nova",game.player.position+Vector2(40,0))
	await frames(3)
	await shot("vault_combat")
	game.run.vault.visited.assign(DungeonProgress.ROOM_IDS)
	game.run.vault.memories.assign(DungeonProgress.MEMORY_IDS)
	game.run.vault.secret_open=true
	game.run.vault.shortcut_open=true
	game.open_dungeon_gates()
	game.player.position=WorldGenerator.center(Vector2i(29,33))
	await frames()
	game.ui.hud.toast_left=0
	await shot("vault_secret")
	game.handle_action("discoveries")
	await frames()
	await shot("vault_journal")
	game.handle_action("resume")
	game.handle_action("map")
	await frames()
	await shot("vault_map")
	paused=false
	game.queue_free()
	await frames()
	# Let the audio thread consume queued stop commands before terminating the engine.
	await create_timer(0.15).timeout
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists("user://vault_capture_only.json"+suffix):
			DirAccess.remove_absolute("user://vault_capture_only.json"+suffix)
	quit()
