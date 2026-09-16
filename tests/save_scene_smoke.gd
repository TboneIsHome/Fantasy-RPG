extends SceneTree

const SAVE := "user://m01_scene_smoke_only.json"
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, title: String) -> void:
	checks += 1
	if not condition: failures.append(title)
	print("PASS SAVE SCENE: " if condition else "FAIL SAVE SCENE: ", title)

func frames() -> void:
	for i in 5: await process_frame

func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://test-output/" + name + ".png")
	check(error == OK, "Rendered save feedback: " + name)

func clean() -> void:
	for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
		DirAccess.remove_absolute(SAVE + suffix)

func verify() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	for name in ["v04_alignment_started.json", "v04_restored_equipped.json", "v04_broken_ore_unequipped.json"]:
		clean()
		var fixture: String = "res://tests/fixtures/" + name
		var original := FileAccess.get_file_as_bytes(fixture)
		DirAccess.copy_absolute(fixture, SAVE)
		var expected: Dictionary = SaveSystem.read_one(SAVE).data
		var loaded: bool = game.load_game()
		var actual: Dictionary = JSON.parse_string(JSON.stringify(SaveSystem.snapshot(game.run, game.player, game.settings)))
		check(loaded and actual == expected, name + ": exact persisted state restored into the real scene")
		check(game.save_game() and game.load_game() and FileAccess.get_file_as_bytes(fixture) == original,
			name + ": playable save/reload leaves the frozen fixture unchanged")
		await frames()
	var previous := FileAccess.get_file_as_bytes(SAVE)
	DirAccess.make_dir_absolute(SAVE + ".tmp")
	check(not game.save_game() and "nicht vollständig" in game.ui.hud.toast_text
		and FileAccess.get_file_as_bytes(SAVE) == previous, "Failed save reaches the HUD and preserves the previous file")
	game.handle_action("pause")
	var same_run: RunState = game.run
	game.ui.requested.emit("title", "")
	check(game.ui.page == "pause" and game.run == same_run, "Save-and-title stays in the current session on failure")
	await frames()
	check(is_instance_valid(game.ui.pause_status) and game.ui.pause_status.text == game.ui.hud.toast_text
		and game.ui.pause_status.get_global_rect().end.y < 360,
		"Save failure is readable in the pause card instead of hidden behind it")
	var fits := true
	for child in game.ui.panel.get_children():
		if child is PanelContainer: fits = fits and child.get_global_rect().end.y <= 360
	check(fits, "Pause card with wrapped save error stays inside the viewport")
	await capture("m01_save_error")
	# Runner rejects missing completion marker if close incorrectly exits here.
	game._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await frames()
	check(is_instance_valid(game) and game.run == same_run, "Failed close-save leaves the session available for retry")
	DirAccess.remove_absolute(SAVE + ".tmp")
	check(game.save_game() and game.ui.hud.toast_text == "Lichtpfad gespeichert."
		and game.ui.pause_status.text == game.ui.hud.toast_text, "Retry updates both HUD and pause feedback after a complete save")
	var file := FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string("{ damaged primary"); file.close()
	check(game.load_game() and "wiederhergestellt" in game.ui.hud.toast_text,
		"Actual scene load recovers the backup and explains the recovery")
	await frames()
	await capture("m01_save_recovered")
	check(game.save_game() and SaveSystem.read_one(SAVE + ".bak").error.is_empty(),
		"Saving the recovered scene keeps a valid backup")
	paused = false
	game.queue_free()
	await frames()
	await create_timer(0.15).timeout
	clean()
	var report := FileAccess.open("res://test-output/save_scene_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks, "failures":failures,
		"renderer":DisplayServer.get_name()}, "  ")); report.close()
	print("SAVE SCENE RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
