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
	# M04: definitions, HUD consumers and explicit validation survive release compilation.
	var malformed := Content.all().duplicate(true)
	malformed.enemies.guardian.fan_count=1
	var errors := ContentValidator.validate_bundle(malformed,Content.vault(),Content.discoveries())
	var data_ok: bool = Content.all().is_read_only() and Content.section("player").is_read_only() and Vitals.maximum("hp") == Content.section("player").hp
	data_ok = data_ok and game.ui.hud.resource_fraction("hp") == game.player.vitals.hp/Vitals.maximum("hp") and not errors.is_empty() and "enemies.guardian.fan_count" in "\n".join(errors)
	data_ok = data_ok and "6 Mana" in Content.description(Content.section("relics").source_heart) and SaveSystem.VERSION == 3
	print("EXPORT DATA CONSISTENCY ", "PASS" if data_ok else "FAIL")
	passed = passed and data_ok
	# M05: real consumers and execution guards survive release compilation.
	game.handle_action("resume")
	var gate: DungeonObject
	var chest: DungeonObject
	var font: DungeonObject
	for object in game.terrain.actors.get_children():
		if not object is DungeonObject: continue
		if object.id == "secret_gate": gate = object
		if object.id == "amber_seed": chest = object
		if object.id == "vault_font": font = object
	game.player.position = gate.position + Vector2(0,24)
	var opening: InteractionResult = game.execute_interaction(game.interactions.request(game.player,gate.interaction,&"inspect"))
	game.player.position = chest.position + Vector2(0,24)
	var collecting: InteractionResult = game.execute_interaction(game.interactions.request(game.player,chest.interaction,&"open"))
	game.player.position = font.position + Vector2(0,24)
	game.player.vitals.hp = 60
	game.run.motes = 4
	var old_request: InteractionRequest = game.interactions.request(game.player,font.interaction,&"rest")
	var resting: InteractionResult = game.execute_interaction(old_request)
	var interaction_ok: bool = opening.resolved and gate.barrier.collision_layer == 0 and collecting.resolved and "amber_seed" in game.run.vault.relics
	interaction_ok = interaction_ok and resting.resolved and resting.consequences.motes_spent == 2 and game.run.motes == 2 and game.player.vitals.is_full()
	interaction_ok = interaction_ok and not game.execute_interaction(old_request).resolved and game.run.motes == 2 and game.source_story.site.interaction is SourceInteraction
	print("EXPORT INTERACTION CONTRACT ", "PASS" if interaction_ok else "FAIL")
	passed = passed and interaction_ok
	# M02: compiled state actions retain their replay guards and complete rewards.
	var checkpoint: Dictionary = game.run.serialize()
	var replay_ok: bool = not game.run.collect_vault_relic("star_chart") and not game.run.align_source("star") and not game.run.defeat_source_guardian() and game.run.serialize() == checkpoint and SaveSystem.validate(SaveSystem.snapshot(game.run, game.player, game.settings)).is_empty()
	print("EXPORT STATE REPLAY ", "PASS" if replay_ok else "FAIL")
	passed = passed and replay_ok
	# M03: compiled lifecycle replaces trees once and rejects a prior generation.
	game.handle_action("resume")
	var origin: int = game.regions.generation
	var previous: Node = game.world
	game.travel_to("forest")
	game.travel_to("vault")
	var region_ok: bool = game.regions.generation == origin + 2 and not game.regions.is_current(origin) and not previous.is_inside_tree() and get_nodes_in_group("player").size() == 1 and get_nodes_in_group("enemies").size() == 5 and game.ui.hud.player == game.player and game.source_story.grove.resolution == "restored"
	region_ok = region_ok and game.execute_interaction(old_request).code == &"stale_region"
	region_ok = region_ok and game.save_game() and game.load_game() and game.run.region == "vault" and game.run.inventory.equipped == "source_heart"
	print("EXPORT REGION LIFECYCLE ", "PASS" if region_ok else "FAIL")
	passed = passed and region_ok
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
