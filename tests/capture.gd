extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://capture_never_written.json"
	DirAccess.make_dir_recursive_absolute("res://test-output")
	await rendered_frames(8)
	await screenshot("title")
	game.handle_action("new","LICHTERHAIN")
	await rendered_frames(8)
	game.ui.hud.toast_left=0
	await screenshot("camp")
	game.handle_action("journal")
	await rendered_frames(4)
	await screenshot("journal")
	game.handle_action("resume")
	var landmark_position: Vector2=WorldGenerator.center(game.terrain.data.points[1].tile)
	game.player.position=landmark_position+Vector2(-30,35)
	Input.warp_mouse(Vector2(400,180))
	await rendered_frames(12)
	game.player.request_cast("nova",landmark_position+Vector2(80,0))
	await rendered_frames(4)
	game.ui.hud.toast_left=0
	await screenshot("forest")
	game.handle_action("pause")
	await rendered_frames(4)
	await screenshot("pause")
	game.handle_action("resume")
	game.handle_action("map")
	await rendered_frames(4)
	await screenshot("map")
	paused=false
	game.queue_free()
	await process_frame
	quit()

func rendered_frames(count: int) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw

func screenshot(id: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var error := image.save_png("res://test-output/"+id+".png")
	print("SCREENSHOT ",id," ",image.get_size()," result=",error)
