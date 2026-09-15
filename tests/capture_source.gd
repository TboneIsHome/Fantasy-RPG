extends SceneTree
var game

func _initialize() -> void:
	call_deferred("capture")

func frames(count: int = 6) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw

func shot(id: String) -> void:
	game.ui.hud.toast_left=0
	await frames(2)
	root.get_texture().get_image().save_png("res://test-output/"+id+".png")
	print("CAPTURE SOURCE ",id)

func setup() -> void:
	game.handle_action("new","LICHTERHAIN")
	game.run.quest_accepted=true
	for id in SaveSystem.LIGHTS: game.run.activate_light(id)
	game.run.quest_complete=true
	game.run.vault.memories.assign(DungeonProgress.MEMORY_IDS)
	game.run.vault.relics.assign(["star_chart"])
	game.run.vault.visited.assign(DungeonProgress.ROOM_IDS)
	game.travel_to("vault")
	for enemy in get_nodes_in_group("enemies"): enemy.set_physics_process(false)
	game.player.position=game.source_story.site.position+Vector2(0,24)
	game.player.vitals.invulnerable=999
	await frames()

func capture() -> void:
	Engine.max_fps=60
	game=load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://source_capture_only.json"
	await setup()
	await shot("source_dormant")
	game.interact(game.source_story.site)
	await frames()
	await shot("source_choices")
	game.handle_action("source_tune")
	game.handle_action("source_align","water")
	await frames()
	await shot("source_tuning")
	game.handle_action("source_align","roots")
	game.handle_action("source_align","star")
	game.handle_action("resume")
	game.player.position=WorldGenerator.center(Vector2i(76,47))
	await frames()
	await shot("source_garden")
	game.handle_action("equipment")
	await frames()
	await shot("source_equipment")
	await setup()
	game.interact(game.source_story.site)
	game.handle_action("source_challenge")
	var boss: SourceGuardian=game.source_story.guardian
	boss.timer=0
	await frames(3)
	boss.timer=0.7
	game.player.position+=Vector2(-22,18)
	await frames(6)
	await shot("source_guardian")
	game.run.source.guardian_defeated=true
	game.source_story.finish("broken")
	await frames()
	await shot("source_victory")
	game.handle_action("resume")
	game.player.position=WorldGenerator.center(Vector2i(76,47))
	await frames()
	await shot("source_ore")
	paused=false
	game.queue_free()
	await frames()
	await create_timer(0.15).timeout
	for suffix in ["",".bak",".tmp",".pre-v03",".pre-v04"]:
		if FileAccess.file_exists("user://source_capture_only.json"+suffix): DirAccess.remove_absolute("user://source_capture_only.json"+suffix)
	quit()
