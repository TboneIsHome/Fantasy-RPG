extends SceneTree
var game
var checks := 0
var failures: Array[String] = []
var created := {"players": 0, "views": 0, "combat": 0}
const SAVE := "user://region_lifecycle_only.json"

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS REGION: " if ok else "FAIL REGION: ", title)

func frames(count: int = 3) -> void:
	for i in count:
		await physics_frame
		await process_frame

func save_and_load() -> bool:
	if not game.save_game():
		print("REGION SAVE DIAGNOSTIC: ", game.ui.hud.toast_text)
		return false
	if not game.load_game():
		print("REGION LOAD DIAGNOSTIC: ", game.ui.hud.toast_text)
		return false
	return true

func object(id: String) -> Landmark:
	for node in get_nodes_in_group("landmarks"):
		if node.id == id: return node
	return null

func live(region_id: String) -> void:
	var current: RegionInstance = game.regions.current
	check(game.regions.is_current(current.generation) and game.regions.current_id == region_id and game.run.region == region_id and game.regions.get_child_count() == 1, region_id + ": one active region with matching persistent identity")
	check(get_nodes_in_group("player").size() == 1 and get_nodes_in_group("player")[0] == game.player and current.is_ancestor_of(game.player), region_id + ": exactly one current player")
	var expected: Array[String] = []
	for definition in game.terrain.data.enemies:
		if definition.id not in game.run.defeated and not (region_id == "vault" and game.run.source.resolution == "restored" and definition.id in SourceQuest.QUIET_ENEMIES):
			expected.append(definition.id)
	var found: Array[String] = []
	var inside := true
	for enemy in get_nodes_in_group("enemies"):
		found.append(enemy.id)
		inside = inside and current.is_ancestor_of(enemy) and enemy.target == game.player
	found.sort(); expected.sort()
	check(found == expected and inside, region_id + ": exact live enemy IDs without duplicates or old targets")
	check(game.combat.player == game.player and game.combat.run == game.run and game.ui.hud.player == game.player and game.ui.hud.run == game.run and game.ui.hud.map_data == game.terrain.data, region_id + ": combat and HUD reference the active instance")
	if region_id == "forest":
		check(game.source_story.site == null and game.source_story.guardian == null and game.source_story.grove == null and game.source_story.room_bounds == Rect2() and game.ui.hud.guardian == null, "Forest releases all SourceStory region references")
	else:
		check(current.is_ancestor_of(game.source_story.site) and current.is_ancestor_of(game.source_story.grove) and game.source_story.region_generation == current.generation, "Vault rebinds SourceStory to its current instance")

func invalidation_observer(region: RegionInstance) -> void:
	check(not game.regions.is_current(region.generation) and region.process_mode == Node.PROCESS_MODE_DISABLED and not region.player.input_enabled, "Deactivation rejects callbacks and stops old player before removal")
	check(game.source_story.site == null and game.ui.hud.player == null and game.ui.hud.guardian == null and game.nearest == null and game.ui.hud.map_data.is_empty(), "External references cleared before old tree leaves")
	check(not game.regions.travel("forest" if region.region_id == "vault" else "vault", game.settings), "Reentrant travel rejected during teardown")
	var original: RunState = game.run
	check(not game.build_run("REENTRANT") and game.run == original, "Reentrant session replacement cannot overwrite the persistent owner")

func verify() -> void:
	var started := Time.get_ticks_msec()
	game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	game.handle_action("new", "LICHTERHAIN")
	live("forest")
	var first: int = game.regions.generation
	check(not game.regions.travel("vault", game.settings) and not game.regions.travel("forest", game.settings) and not game.regions.travel("unknown", game.settings) and game.regions.generation == first, "Invalid, locked and same-region travel leave lifecycle untouched")
	for id in RunState.LIGHT_IDS: game.run.activate_light(id)
	game.run.accept_quest()
	game.run.complete_quest()
	game.player.vitals.hp = 0
	check(not game.regions.travel("vault", game.settings) and game.regions.generation == first, "Dead player cannot start ordinary travel")
	game.player.vitals.hp = 71; game.player.vitals.mana = 43; game.player.vitals.stamina = 67
	var old_player: MagePlayer = game.player
	var old_world: RegionInstance = game.world
	var old_combat: CombatSystem = game.combat
	var old_death: Callable = old_player.died.get_connections()[0].callable
	game.nearest = object("vault_entrance")
	game.regions.deactivating.connect(invalidation_observer)
	game.travel_to("vault")
	game.regions.deactivating.disconnect(invalidation_observer)
	check(game.regions.generation == first + 1 and not game.regions.is_current(first), "Forest to vault increments transient generation once")
	check(not old_world.is_inside_tree() and old_world.is_queued_for_deletion() and not old_player.is_inside_tree() and old_combat.player == null and old_combat.run == null, "Old region immediately detached and combat state references released")
	check(old_player.died.get_connections().is_empty() and old_player.cast_requested.get_connections().is_empty() and old_combat.sound_requested.get_connections().is_empty(), "Old player/combat session bridges disconnected")
	check(game.player != old_player and game.player.vitals.hp == 71 and game.player.vitals.mana == 43 and game.player.vitals.stamina == 67 and game.player.vitals.invulnerable == 0.8, "Fresh player preserves resources and arrival protection")
	live("vault")
	old_death.call()
	check(not paused and game.ui.page.is_empty(), "Already captured death callback cannot pause replacement region")
	await frames()
	check(not is_instance_valid(old_world) and not is_instance_valid(old_player) and not is_instance_valid(old_combat), "Detached tree and old player/combat freed after frame boundary")
	var fixture := SaveSystem.read("res://tests/fixtures/v04_alignment_started.json")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	var original_run: RunState = game.run
	var origin: int = game.regions.generation
	var previous_site: SourceSite = game.source_story.site
	var previous_guardian: SourceGuardian = game.source_story.guardian
	var previous_grove: SourceGrove = game.source_story.grove
	var withdrawal: Callable = previous_guardian.disengaged.get_connections()[0].callable
	game.player.position = previous_site.position + Vector2(0,24)
	game.interact(previous_site)
	var old_button: Button = game.ui.panel.find_children("*", "Button", true, false)[0]
	var queued_button: Callable = old_button.pressed.get_connections()[0].callable
	old_combat = game.combat
	var old_enemy: WildEnemy = get_nodes_in_group("enemies")[0]
	old_combat._enemy_bolt(game.player.position - Vector2(28,0), Vector2.RIGHT, 17)
	old_combat._source_slam(game.player.position, 34, 21)
	old_combat._thorns(game.player.position)
	var old_projectile: MagicProjectile
	var hazards: Array[WeakRef] = []
	for node in old_combat.get_children():
		if node is MagicProjectile: old_projectile = node
		if node is MagicProjectile or node is SourceImpact or node is ThornPatch: hazards.append(weakref(node))
	check(hazards.size() == 3, "Actual enemy projectile, source impact and thorn zone present at travel")
	# An engine timer outlives the old region. Its payload must carry the origin.
	create_timer(0.03).timeout.connect(game.source_story.finish_broken.bind(original_run, origin))
	game.travel_to("forest")
	live("forest")
	check(game.player.position.distance_to(object("vault_entrance").position) < 25, "Vault exit still arrives beside the forest entrance")
	check(previous_guardian.defeated.get_connections().filter(func(c): return c.callable.get_object() == game.source_story).is_empty() and previous_guardian.disengaged.get_connections().is_empty(), "Old guardian story connections released")
	game.travel_to("vault")
	live("vault")
	game.player.position = game.source_story.site.position + Vector2(0,24)
	game.combat._source_slam(game.player.position + Vector2(100,0), 34, 21)
	var current_impact: Node = game.combat.get_child(game.combat.get_child_count()-1)
	var hp_before: float = game.player.vitals.hp
	game.player.vitals.invulnerable = 0
	var state_before: Dictionary = game.run.serialize()
	var effect_count: int = game.combat.get_child_count()
	old_projectile.struck.emit(game.player, game.player.position, Vector2.RIGHT)
	old_combat._enemy_bolt(game.player.position, Vector2.RIGHT, 99)
	old_combat._source_slam(game.player.position, 99, 99)
	old_combat._thorns(game.player.position)
	old_combat.cast("nova", game.player.position, game.player.position)
	old_combat._defeated(old_enemy)
	withdrawal.call()
	game.interact(previous_site)
	queued_button.call()
	check(game.player.vitals.hp == hp_before and game.combat.get_child_count() == effect_count and not current_impact.is_queued_for_deletion() and game.run.serialize() == state_before and game.ui.page.is_empty(), "Old projectile, combat, withdrawal, interaction and queued UI action cannot affect new vault")
	await frames(5)
	check(game.run.source.resolution.is_empty() and game.run.inventory.owned.is_empty(), "Expired region timer cannot award current run's source reward")
	var all_freed := true
	for reference in hazards: all_freed = all_freed and reference.get_ref() == null
	check(all_freed and not is_instance_valid(previous_site) and not is_instance_valid(previous_guardian) and not is_instance_valid(previous_grove), "All old hazards and SourceStory scene objects freed")
	# A current callback must still work; cancellation must not disable normal victories.
	game.run.inspect_source()
	game.source_story.guardian.awaken()
	game.source_story.guardian.take_damage(999)
	await frames()
	check(game.run.source.resolution == "broken" and game.run.inventory.owned == ["source_heart"], "Current generation still completes real guardian death once")
	game.handle_action("resume")
	# Generation must also change on reload and new-run replacement, even in same region.
	game.build_run(fixture.data.run.world_seed, fixture.data)
	origin = game.regions.generation
	original_run = game.run
	create_timer(0.02).timeout.connect(game.source_story.finish_broken.bind(original_run, origin))
	check(save_and_load() and game.regions.generation == origin + 1 and game.run != original_run, "Same-region save/load creates one new instance and run")
	await frames(4)
	check(game.run.source.resolution.is_empty() and game.run.source.alignment == 1, "Pre-load timer cannot change reloaded investigation checkpoint")
	live("vault")
	origin = game.regions.generation
	original_run = game.run
	create_timer(0.02).timeout.connect(game.source_story.finish_broken.bind(original_run, origin))
	game.handle_action("new", "LICHTERHAIN")
	await frames(4)
	check(game.regions.generation == origin + 1 and game.run != original_run and game.run.source.resolution.is_empty() and game.run.inventory.owned.is_empty(), "New run keeps monotonic generation and rejects old actions")
	live("forest")
	game.build_run(fixture.data.run.world_seed, fixture.data)
	node_added.connect(func(node):
		if node is MagePlayer: created.players += 1
		if node is WorldView: created.views += 1
		if node is CombatSystem: created.combat += 1)
	origin = game.regions.generation
	for i in 6:
		game.travel_to("forest")
		game.travel_to("vault")
		live("vault")
	check(created == {"players": 12, "views": 12, "combat": 12} and game.regions.generation == origin + 12, "Twelve rapid changes build exactly twelve players, views and combat systems")
	await frames()
	check(save_and_load() and game.run.vault.serialize() == fixture.data.run.vault and game.run.inventory.serialize() == fixture.data.run.inventory and game.run.defeated == fixture.data.run.defeated, "Travel/save/load retains persistent dungeon, inventory and enemy state")
	var snapshot: Dictionary = SaveSystem.snapshot(game.run, game.player, game.settings)
	check(snapshot.save_version == 3 and not snapshot.run.has("generation") and not snapshot.run.has("instance") and SaveSystem.validate(snapshot).is_empty(), "Instance generation stays outside the unchanged save schema")
	# Travel remains successful in memory on disk failure; the prior save stays usable.
	var saved_bytes := FileAccess.get_file_as_bytes(SAVE)
	DirAccess.make_dir_absolute(SAVE + ".tmp")
	game.travel_to("forest")
	check(game.run.region == "forest" and FileAccess.get_file_as_bytes(SAVE) == saved_bytes and game.ui.hud.toast_text != "Zurück im Sternengarten.", "Travel save failure preserves disk and its visible error message")
	DirAccess.remove_absolute(SAVE + ".tmp")
	check(save_and_load() and game.run.region == "forest", "Save retry and load preserve the completed travel")
	game.travel_to("vault")
	origin = game.regions.generation
	game.player.vitals.invulnerable = 0
	game.player.take_damage(999)
	game.handle_action("respawn")
	check(game.regions.generation == origin + 1 and game.run.region == "forest" and game.player.position == game.terrain.data.spawn and game.player.vitals.hp == 100, "Dungeon death uses lifecycle once and returns a fresh mage to camp")
	live("forest")
	origin = game.regions.generation
	game.regions.unload()
	game.regions.unload()
	check(game.world == null and game.player == null and game.terrain == null and game.combat == null and game.regions.current_id.is_empty() and not game.regions.is_current(origin) and get_nodes_in_group("player").is_empty() and get_nodes_in_group("enemies").is_empty(), "Repeated unload is safe and leaves no active region or actor references")
	await frames()
	check(game.regions.get_child_count() == 0 and game.source_story.site == null and game.ui.hud.player == null, "Unloaded session retains no regional tree or external references")
	paused = false
	game.queue_free()
	await frames(5)
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(SAVE + suffix): DirAccess.remove_absolute(SAVE + suffix)
	var report := FileAccess.open("res://test-output/region_lifecycle_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks": checks, "failures": failures, "duration_ms": Time.get_ticks_msec()-started}, "  "))
	report.close()
	print("REGION LIFECYCLE RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
