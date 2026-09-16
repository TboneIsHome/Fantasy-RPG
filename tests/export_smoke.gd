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
	# M02: compiled state actions retain their replay guards and complete rewards.
	var checkpoint: Dictionary = game.run.serialize()
	var replay_ok: bool = not game.run.collect_vault_relic("star_chart") and not game.run.align_source("star") and not game.run.defeat_source_guardian() and game.run.serialize() == checkpoint and SaveSystem.validate(SaveSystem.snapshot(game.run, game.player, game.settings)).is_empty()
	print("EXPORT STATE REPLAY ", "PASS" if replay_ok else "FAIL")
	passed = passed and replay_ok
	# M01: verify persistence inside the compiled release pack.
	var original := FileAccess.get_file_as_bytes(game.save_path)
	DirAccess.copy_absolute(game.save_path, game.save_path + ".bak")
	var damaged := FileAccess.open(game.save_path, FileAccess.WRITE)
	damaged.store_string("{ damaged primary"); damaged.close()
	var recovered := SaveSystem.read(game.save_path)
	var recovery_ok: bool = recovered.error.is_empty() and SaveSystem.write(recovered.data, game.save_path).is_empty() and FileAccess.get_file_as_bytes(game.save_path + ".bak") == original
	print("EXPORT SAVE RECOVERY ", "PASS" if recovery_ok else "FAIL")
	DirAccess.make_dir_absolute(game.save_path + ".tmp")
	var failure_ok: bool = not game.save_game() and SaveSystem.read(game.save_path).error.is_empty()
	DirAccess.remove_absolute(game.save_path + ".tmp")
	print("EXPORT SAVE ERROR ", "PASS" if failure_ok else "FAIL")
	passed = passed and recovery_ok and failure_ok
	print("EXPORT SMOKE ","PASS" if passed else "FAIL")
	paused=false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists("user://export_smoke_only.json"+suffix):
			DirAccess.remove_absolute("user://export_smoke_only.json"+suffix)
	quit(0 if passed else 1)
