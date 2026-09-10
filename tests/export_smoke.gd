extends SceneTree
## Run this external script against each exported pack, never ship it in the pack.
func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://export_smoke_only.json"
	game.run.quest_accepted=true
	for id in SaveSystem.LIGHTS:
		game.run.activate_light(id)
	game.run.quest_complete=true
	game.travel_to("vault")
	for i in 5: await process_frame
	var passed: bool=ProjectSettings.get_setting("application/config/version")=="0.3.0" and game.run.region=="vault" and game.terrain.data.rooms.size()==7 and get_nodes_in_group("enemies").size()==7 and DiscoveryBook.entries().size()==9 and SaveSystem.read(game.save_path).error.is_empty()
	print("EXPORT SMOKE ","PASS" if passed else "FAIL")
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists("user://export_smoke_only.json"+suffix):
			DirAccess.remove_absolute("user://export_smoke_only.json"+suffix)
	quit(0 if passed else 1)
