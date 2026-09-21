extends SceneTree
## Unit doubles exercise only the protocol; real shipped chests prove its consumer.
const SAVE := "user://m05_contract_only.json"
var checks := 0
var failures: Array[String] = []
var game

class ProbeTarget extends InteractionTarget:
	var allowed := true
	var offered := true
	var discoveries := 0
	var validations := 0
	var resolutions := 0
	var last_context: InteractionContext
	var on_resolve: Callable
	var on_validate: Callable
	func discover(_context: InteractionContext) -> Dictionary:
		discoveries += 1
		return {"offers": [{"intent": &"inspect", "prompt": "Inspect"}, {"intent": &"local_special", "prompt": "Special"}] if offered else [], "notice": ""}
	func validate(context: InteractionContext) -> StringName:
		validations += 1
		last_context = context
		if on_validate.is_valid(): on_validate.call()
		return &"" if allowed else &"condition_failed"
	func resolve(context: InteractionContext) -> InteractionResult:
		resolutions += 1
		last_context = context
		if on_resolve.is_valid(): on_resolve.call()
		return InteractionResult.confirmed(&"observed", {"first": 1, "second": 2})

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS INTERACTION CONTRACT: " if ok else "FAIL INTERACTION CONTRACT: ", title)

func object(id: String) -> DungeonObject:
	for value in game.terrain.actors.get_children():
		if value is DungeonObject and value.id == id: return value
	return null

func verify() -> void:
	game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	game.handle_action("new", "LICHTERHAIN")
	for id in RunState.LIGHT_IDS: game.run.activate_light(id)
	game.run.complete_quest()
	game.travel_to("vault")
	paused = true
	var core: InteractionCore = game.interactions
	var node := Node2D.new()
	game.terrain.actors.add_child(node)
	node.position = game.player.position + Vector2(2, 0)
	var probe := ProbeTarget.new(node)
	var before: Dictionary = game.run.serialize()
	var discovery := core.discover(game.player, probe, game.run)
	check(discovery.offers.size() == 2 and discovery.offers[1].intent == &"local_special", "One target offers multiple consumer-local intents without a verb enum")
	check(probe.validations == 0 and probe.resolutions == 0 and game.run.serialize() == before, "Discovery neither validates expensive conditions nor mutates state")
	var request := core.request(game.player, probe, &"local_special")
	probe.allowed = false
	var result := core.execute(request, game.run)
	check(not result.resolved and result.code == &"condition_failed" and probe.resolutions == 0, "Changed condition between discovery and execution rejects before resolution")
	probe.allowed = true
	game.player.position += Vector2(1,0)
	result = core.execute(request, game.run)
	check(result.resolved and result.code == &"observed" and probe.resolutions == 1, "Valid request resolves through the provider")
	check(probe.last_context.actor == game.player and probe.last_context.target == node and probe.last_context.world_state == game.run and probe.last_context.intent == &"local_special", "Fresh context carries actor, target, local intent and the actual state owner")
	check(is_equal_approx(probe.last_context.distance(), 1) and probe.last_context.generation == game.regions.generation, "Execution observes current spatial context and originating generation")
	check(result.consequences == {"first":1, "second":2} and result.consequences.is_read_only(), "One confirmed outcome carries several descriptive consequences")
	check(not core.execute(core.request(game.player, probe, &"unknown"), game.run).resolved and probe.resolutions == 1, "Target rejects an intent it does not offer")
	check(core.execute(core.request(game.player, probe, &""), game.run).code == &"not_offered", "Empty intent is never a wildcard")
	probe.offered = false
	check(core.execute(request, game.run).code == &"not_offered" and probe.resolutions == 1, "Removed offer is checked again before execution")
	probe.offered = true
	var nested: Array[InteractionResult] = []
	probe.on_resolve = func(): nested.append(core.execute(request, game.run))
	result = core.execute(request, game.run)
	check(result.resolved and nested.size() == 1 and nested[0].code == &"busy" and probe.resolutions == 2, "Synchronous reentrant request cannot resolve twice")
	probe.on_resolve = Callable()
	check(core.execute(request, game.run).resolved and probe.resolutions == 3, "New requests after resolution remain allowed; core does not invent cooldowns")
	check(core.execute(null, game.run).code == &"invalid_request", "Null request fails safely")
	check(core.execute(request, null).code == &"invalid_state", "Missing current context fails safely")
	check(core.execute(core.request(null, probe, &"inspect"), game.run).code == &"invalid_actor", "Missing actor fails safely")
	check(core.execute(core.request(game.player, null, &"inspect"), game.run).code == &"invalid_target", "Missing target fails safely")
	var other := RegionLifecycle.new()
	game.add_child(other)
	var foreign := InteractionCore.new(other)
	check(foreign.execute(request, game.run).code == &"stale_region", "Generation only belongs to its originating lifecycle")
	other.queue_free()
	# Actual first consumer, its authoritative RunState and existing save checkpoint.
	var chest := object("star_chart")
	game.player.position = chest.position + Vector2(0,24)
	var chest_request := core.request(game.player, chest.interaction, &"open")
	var xp_before: int = game.run.xp + 30 * game.run.level * (game.run.level - 1)
	check(core.discover(game.player, chest.interaction, game.run).offers[0].intent == &"open", "Real chest advertises Open through its attached adapter")
	result = game.execute_interaction(chest_request)
	check(result.resolved and result.code == &"collected" and result.consequences.relic == "star_chart" and result.consequences.xp == 40, "Real chest returns its confirmed item and existing XP reward")
	check("star_chart" in game.run.vault.relics and game.run.xp + 30 * game.run.level * (game.run.level - 1) == xp_before + 40 and chest.active, "Domain owner applies reward once; presentation activates the chest")
	check(game.ui.page == "dialogue" and SaveSystem.read(SAVE).data.run.vault.relics == ["star_chart"], "Existing discovery dialogue and save checkpoint follow confirmation")
	before = game.run.serialize()
	check(not game.execute_interaction(chest_request).resolved and game.run.serialize() == before, "Repeated request does not issue another reward")
	check(core.discover(game.player, chest.interaction, game.run).offers.is_empty() and game.dungeon_prompt(chest) == "Der Fund liegt in deinem Journal.", "Consumed target supplies its own unchanged informational prompt")
	var twin := DungeonObject.new()
	twin.configure({"id":"star_chart", "kind":"chest", "name":"Old view", "tile":Vector2i(78,46)}, false)
	game.terrain.actors.add_child(twin)
	twin.interaction = DungeonInteraction.new(twin, game)
	check(core.discover(game.player, twin.interaction, game.run).offers.is_empty(), "Persistent state beats a stale inactive chest representation")
	twin.queue_free()
	# Recheck lifetimes before resolution even if a provider violates validation purity.
	probe.on_validate = func(): node.queue_free()
	result = core.execute(request, game.run)
	check(result.code == &"invalid_target" and probe.resolutions == 3, "Target queued during validation is not resolved")
	probe.on_validate = Callable()
	for i in 2: await process_frame
	check(not is_instance_valid(node) and probe.node() == null and core.execute(request, game.run).code == &"invalid_target", "Requests and adapters do not keep a destroyed target alive")
	# Same permanent region ID after a round trip is still a different instance.
	game.handle_action("resume")
	game.travel_to("forest")
	game.travel_to("vault")
	paused = true
	before = game.run.serialize()
	check(core.execute(chest_request, game.run).code == &"stale_region" and game.run.serialize() == before, "Old request cannot affect a replacement vault with the same stable IDs")
	check(game.nearest_request == null, "Region deactivation clears cached UI selection")
	check(game.save_game() and game.load_game() and "star_chart" in game.run.vault.relics and object("star_chart").active, "Save/load retains the real interaction result with schema 3")
	paused = false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
		if FileAccess.file_exists(SAVE + suffix): DirAccess.remove_absolute(SAVE + suffix)
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/interaction_contract_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures}, "  ")); report.close()
	print("INTERACTION CONTRACT RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
