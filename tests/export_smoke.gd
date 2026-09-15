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
	var passed: bool=ProjectSettings.get_setting("application/config/version")=="0.4.0" and game.run.region=="vault" and game.terrain.data.rooms.size()==7 and get_nodes_in_group("enemies").size()==7 and DiscoveryBook.entries().size()==12 and is_instance_valid(game.source_story.guardian) and SaveSystem.read(game.save_path).error.is_empty()
	game.run.vault.memories.assign(DungeonProgress.MEMORY_IDS)
	game.run.vault.relics.assign(["star_chart"])
	game.player.position=game.source_story.site.position+Vector2(0,24)
	game.interact(game.source_story.site)
	game.handle_action("source_tune")
	for sign_id in SourceQuest.SIGNS: game.handle_action("source_align",sign_id)
	passed=passed and game.run.source.resolution=="restored" and game.run.inventory.equipped=="source_heart" and game.source_story.grove.resolution=="restored" and SaveSystem.read(game.save_path).data.save_version==3
	print("EXPORT SMOKE ","PASS" if passed else "FAIL")
	paused=false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists("user://export_smoke_only.json"+suffix):
			DirAccess.remove_absolute("user://export_smoke_only.json"+suffix)
	quit(0 if passed else 1)
