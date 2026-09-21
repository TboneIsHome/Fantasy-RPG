extends SceneTree
## Integration uses only the existing world objects, state owners and UI.
const SAVE := "user://m05_interactions_only.json"
var checks := 0
var failures: Array[String] = []
var game

class CountingFountain extends DungeonInteraction:
	var discovery_calls := 0
	func discover(context: InteractionContext) -> Dictionary:
		discovery_calls += 1
		return super.discover(context)

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS INTERACTION SCENE: " if ok else "FAIL INTERACTION SCENE: ", title)

func object(id: String) -> DungeonObject:
	for value in game.terrain.actors.get_children():
		if value is DungeonObject and value.id == id: return value
	return null

func near(id: String) -> DungeonObject:
	var target := object(id)
	game.player.position = target.position + Vector2(0,24)
	game.player.knockback = Vector2.ZERO
	return target

func verify() -> void:
	game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	var fixture := SaveSystem.read_one("res://tests/fixtures/v03_completed_save.json")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	game.travel_to("vault")
	paused = true
	await fountain()
	await passage()
	await source_site()
	await lifecycle_and_selection()
	paused = false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp", ".bak.tmp", ".pre-v03", ".pre-v04"]:
		if FileAccess.file_exists(SAVE + suffix): DirAccess.remove_absolute(SAVE + suffix)
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/interaction_scene_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures}, "  ")); report.close()
	print("INTERACTION SCENE RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)

func fountain() -> void:
	var font := near("vault_font")
	var core: InteractionCore = game.interactions
	game.run.motes = 4
	game.player.vitals.hp = 30
	var before: Dictionary = game.run.serialize()
	var offer := core.discover(game.player, font.interaction, game.run)
	check(offer.offers.size() == 1 and offer.offers[0].intent == &"rest" and "2 Lichtstaub" in offer.offers[0].prompt, "Existing fountain offers Rest with its definition-owned cost")
	for i in 100: core.discover(game.player, font.interaction, game.run)
	check(game.run.serialize() == before and game.player.vitals.hp == 30, "Repeated fountain discovery neither spends currency nor restores resources")
	var request := core.request(game.player, font.interaction, &"rest")
	game.run.motes = 1
	var result: InteractionResult = game.execute_interaction(request)
	check(not result.resolved and result.code == &"insufficient_motes" and game.run.motes == 1 and game.player.vitals.hp == 30, "Resource condition changed after discovery is rechecked before execution")
	game.run.motes = 4
	game.player.vitals.refill()
	result = game.execute_interaction(request)
	check(result.code == &"already_full" and game.run.motes == 4, "Full actor is rejected without a charge")
	game.player.vitals.hp = 30
	game.player.position += Vector2(0,50)
	result = game.execute_interaction(request)
	check(result.code == &"out_of_reach" and game.run.motes == 4 and game.player.vitals.hp == 30, "Execution rechecks distance after the actor moved")
	near("vault_font")
	game.player.vitals.hp = 0
	check(game.execute_interaction(request).code == &"actor_unavailable" and game.run.motes == 4, "Dead actor cannot use the fountain")
	game.player.vitals.hp = 30
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(10,2)
	shape.shape = rectangle
	wall.add_child(shape)
	game.terrain.actors.add_child(wall)
	wall.position = font.position + Vector2(0,12)
	for i in 2: await physics_frame
	check(game.execute_interaction(request).code == &"obstructed" and game.run.motes == 4, "New obstruction after selection is checked at execution")
	wall.free()
	var nested: Array[InteractionResult] = []
	var callback := func(): nested.append(core.execute(request, game.run))
	game.run.changed.connect(callback)
	result = game.execute_interaction(request)
	game.run.changed.disconnect(callback)
	check(result.resolved and result.code == &"rested" and result.consequences.motes_spent == 2 and result.consequences.resources_refilled, "Real fountain returns both applied consequences")
	check(game.run.motes == 2 and game.player.vitals.is_full() and nested.size() == 1 and nested[0].code == &"busy", "Existing currency signal cannot reenter the interaction while resolution is incomplete")
	check(SaveSystem.read(SAVE).data.run.motes == 2 and SaveSystem.read(SAVE).data.player.hp == 100, "Fountain checkpoint includes both currency and restored resources")
	check(not game.execute_interaction(request).resolved and game.run.motes == 2, "Repeated full-health request never charges twice")
	game.player.vitals.hp = 80
	check(game.execute_interaction(request).resolved and game.run.motes == 0 and game.player.vitals.hp == 100, "Repeatable fountain remains usable after later damage")
	# Failed disk write does not roll back confirmed gameplay or replace its error.
	game.run.motes = 4
	game.player.vitals.hp = 20
	var good_bytes := FileAccess.get_file_as_bytes(SAVE)
	DirAccess.make_dir_absolute(SAVE + ".tmp")
	result = game.execute_interaction(request)
	check(result.resolved and game.run.motes == 2 and game.player.vitals.hp == 100 and FileAccess.get_file_as_bytes(SAVE) == good_bytes, "Save failure preserves both confirmed in-memory action and last good file")
	check(not game.execute_interaction(request).resolved and game.run.motes == 2, "Save failure does not turn retry into a duplicate charge")
	DirAccess.remove_absolute(SAVE + ".tmp")
	check(game.save_game() and game.load_game() and game.run.motes == 2 and game.player.vitals.hp == 100, "Explicit save retry persists the existing result without replaying it")
	paused = true

func fresh_vault() -> void:
	game.handle_action("new", "LICHTERHAIN")
	for id in RunState.LIGHT_IDS: game.run.activate_light(id)
	game.run.complete_quest()
	game.travel_to("vault")
	paused = true

func passage() -> void:
	fresh_vault()
	var gate := near("secret_gate")
	var core: InteractionCore = game.interactions
	var request := core.request(game.player, gate.interaction, &"inspect")
	var before: Dictionary = game.run.serialize()
	var result: InteractionResult = game.execute_interaction(request)
	check(result.resolved and result.code == &"unreadable" and result.consequences.is_empty() and game.run.serialize() == before, "Investigating sealed passage is a valid action with an unchanged-world outcome")
	check(not gate.active and gate.barrier.collision_layer == 1, "An unreadable sign keeps the actual passage closed")
	game.run.unlock_memory("water_memory")
	result = game.execute_interaction(request)
	check(result.resolved and result.code == &"opened" and result.consequences.gate == "secret_gate", "Same intent uses newly learned evidence during resolution")
	check(game.run.vault.secret_open and gate.active and gate.barrier.collision_layer == 0, "Confirmed opening updates persistent state and the real barrier")
	check(not game.terrain.navigation.is_point_solid(Vector2i(gate.position / 16)), "Existing gate presentation refreshes navigation")
	before = game.run.serialize()
	check(not game.execute_interaction(request).resolved and game.run.serialize() == before, "Already opened passage is not resolved again")
	check(game.dungeon_prompt(gate) == "Der Stein hat den Weg freigegeben.", "Target supplies the unchanged opened-passage notice")
	var chest := near("amber_seed")
	request = core.request(game.player, chest.interaction, &"open")
	result = game.execute_interaction(request)
	check(result.resolved and result.consequences.relic == "amber_seed" and result.consequences.xp == 25, "Second existing chest uses the same adapter with its own unchanged reward")
	check(game.save_game() and game.load_game() and object("secret_gate").active and object("amber_seed").active, "Passage and collected reward survive save/load together")
	paused = true

func source_site() -> void:
	fresh_vault()
	var site := near("source_binding")
	var core: InteractionCore = game.interactions
	var request := core.request(game.player, site.interaction, &"inspect")
	check(core.discover(game.player, site.interaction, game.run).offers[0].intent == &"inspect", "Unresolved source offers Inspect through the same contract")
	var result: InteractionResult = game.execute_interaction(request)
	check(result.resolved and result.consequences.inspection_changed and game.run.source.seen and game.ui.page == "dialogue", "Source inspection confirms its checkpoint before opening existing choices")
	check(SaveSystem.read(SAVE).data.run.source.seen, "Source inspection retains the existing save checkpoint")
	result = game.execute_interaction(request)
	check(result.resolved and not result.consequences.inspection_changed, "Inspecting again remains possible without inventing another discovery reward")
	game.handle_action("source_challenge")
	paused = true
	var before: Dictionary = game.run.serialize()
	result = game.execute_interaction(request)
	check(result.code == &"source_busy" and game.run.serialize() == before, "Awakened guardian blocks source execution after discovery")
	game.travel_to("forest")
	game.travel_to("vault")
	paused = true
	site = near("source_binding")
	request = core.request(game.player, site.interaction, &"inspect")
	game.run.unlock_memory("water_memory")
	game.run.unlock_memory("root_memory")
	game.run.collect_vault_relic("star_chart")
	game.execute_interaction(request)
	game.handle_action("source_tune")
	for sign_id in SourceQuest.SIGNS: game.handle_action("source_align", sign_id)
	check(game.run.source.resolution == "restored" and game.run.inventory.equipped == "source_heart" and game.source_story.grove.resolution == "restored", "Existing tuning dialogue still resolves the quest and relic through their owners")
	check(core.execute(request, game.run).code == &"not_offered", "Old Inspect intent does not silently become Rest after an outcome change")
	check(core.discover(game.player, site.interaction, game.run).offers[0].intent == &"rest", "Same live source target now offers Rest from persistent state")
	game.player.vitals.hp = 12
	var motes: int = game.run.motes
	request = core.request(game.player, site.interaction, &"rest")
	result = game.execute_interaction(request)
	check(result.resolved and result.code == &"source_rested" and game.player.vitals.is_full() and game.run.motes == motes, "Garden rest preserves full restoration without a cost")
	check(game.execute_interaction(request).resolved and game.run.motes == motes, "Free garden rest remains repeatable even with full resources")
	check(game.save_game() and game.load_game() and game.dungeon_prompt(object("source_binding")) == "E · Im Quellengarten rasten", "Loaded garden keeps its state-derived offer")
	paused = true
	# Frozen existing combat outcome already contains harvested ore; never rewrite it.
	var fixture := SaveSystem.read_one("res://tests/fixtures/v04_broken_ore_unequipped.json")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	paused = true
	site = near("source_binding")
	check(core.discover(game.player, site.interaction, game.run).offers.is_empty(), "Original consumed-source save offers no second harvest")
	# A disposable in-memory copy supplies the immediately preceding checkpoint.
	fixture.data.run.source.ore_taken = false
	game.build_run(fixture.data.run.world_seed, fixture.data)
	paused = true
	site = near("source_binding")
	check(core.discover(game.player, site.interaction, game.run).offers[0].intent == &"gather", "Unharvested combat outcome offers Gather")
	request = core.request(game.player, site.interaction, &"gather")
	motes = game.run.motes
	result = game.execute_interaction(request)
	check(result.resolved and result.consequences.ore_taken and result.consequences.motes_granted == 4 and game.run.motes == motes + 4, "Actual source ore confirms its one-time flag and unchanged reward")
	check(not game.execute_interaction(request).resolved and game.run.motes == motes + 4 and game.run.source.ore_taken, "Repeated source request cannot grant ore twice")
	check(core.discover(game.player, site.interaction, game.run).offers.is_empty() and game.dungeon_prompt(site) == "Die Erzader ist abgeerntet.", "Consumed source advertises no Gather action and retains its notice")
	check(game.save_game() and game.load_game() and game.run.source.ore_taken and game.dungeon_prompt(object("source_binding")) == "Die Erzader ist abgeerntet.", "Save/load retains consumed source state and offer suppression")
	paused = true

func lifecycle_and_selection() -> void:
	fresh_vault()
	var core: InteractionCore = game.interactions
	var font := near("vault_font")
	var request := core.request(game.player, font.interaction, &"rest")
	var old_target: WeakRef = weakref(font.interaction)
	var delivered: Array[InteractionResult] = []
	create_timer(0.03).timeout.connect(func(): delivered.append(game.execute_interaction(request)))
	game.travel_to("forest")
	game.travel_to("vault")
	paused = true
	near("vault_font")
	game.player.vitals.hp = 45
	game.run.motes = 10
	var before: Dictionary = game.run.serialize()
	await create_timer(0.08).timeout
	check(delivered.size() == 1 and delivered[0].code == &"stale_region" and game.run.serialize() == before and game.player.vitals.hp == 45, "Actual delayed request cannot charge or heal a replacement region")
	check(old_target.get_ref() == null and request.actor() == null and request.target() == null, "Old requests do not retain the actor or interaction adapter after unload")
	check(get_nodes_in_group("player").size() == 1 and game.source_story.site == object("source_binding"), "Interaction wiring leaves one player and current SourceStory references")
	font = near("vault_font")
	var original := font.interaction
	var counted := CountingFountain.new(font, game)
	font.interaction = counted
	game.ui.clear()
	game.scan_time = 0
	for i in 120: game._process(0.01)
	check(counted.discovery_calls >= 9 and counted.discovery_calls <= 11, "Real nearby discovery stays on the existing 0.12-second scan, not every frame")
	check(game.nearest == font and game.nearest_request.intent == &"rest" and game.ui.hud.prompt == "E · Rasten für 2 Lichtstaub", "Actual HUD and cached request use the target-provided offer")
	font.interaction = original
	# Choose Inspect, then change the site's meaning before the input is delivered.
	var site := near("source_binding")
	game.player.position = site.position - Vector2(0,24)
	game._scan_landmarks()
	check(game.nearest == site and game.nearest_request.intent == &"inspect", "Actual nearby selection captures the source's offered intent")
	var selected: InteractionRequest = game.nearest_request
	game.run.inspect_source()
	game.run.defeat_source_guardian()
	game.source_story.apply_outcome()
	game.scan_time = 0.1
	Input.action_press("interact")
	game._process(0)
	Input.action_release("interact")
	check(not game.run.source.ore_taken and core.execute(selected, game.run).code == &"not_offered", "E executes the selected intent; it never turns stale Inspect into an unsolicited Gather")
	game._scan_landmarks()
	check(game.nearest_request.intent == &"gather" and game.ui.hud.prompt == "E · Sternenerz bergen", "Next regular discovery updates both request and prompt to Gather")
	selected = game.nearest_request
	game.travel_to("forest")
	paused = true
	check(game.nearest_request == null and game.execute_interaction(selected).code == &"stale_region" and game.ui.page.is_empty(), "Travel clears selection and old feedback cannot open UI in the new region")
	# Destroyed and removed real targets fail closed before their domain methods.
	game.travel_to("vault")
	paused = true
	var chest := near("star_chart")
	request = core.request(game.player, chest.interaction, &"open")
	game.terrain.actors.remove_child(chest)
	check(core.execute(request, game.run).code == &"invalid_target", "Detached real target is rejected immediately")
	game.terrain.actors.add_child(chest)
	chest.queue_free()
	check(core.execute(request, game.run).code == &"invalid_target", "Real target queued for deletion is rejected before frame-end")
	for i in 2: await process_frame
	check(core.execute(request, game.run).code == &"invalid_target" and "star_chart" not in game.run.vault.relics, "Freed target remains rejected without state changes")
