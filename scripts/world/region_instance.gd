class_name RegionInstance
extends Node2D
## One disposable 2D region tree. Persistent progress stays in the supplied RunState.
var region_id: String
var generation: int
var run: RunState
var terrain: WorldView
var player: MagePlayer
var combat: CombatSystem

func build(state: RunState, instance_generation: int, settings: Dictionary, saved_player: Dictionary, returning_to_forest: bool) -> void:
	run = state
	region_id = run.region
	generation = instance_generation
	var generated: Dictionary=DungeonGenerator.generate(run.world_seed) if region_id=="vault" else WorldGenerator.generate(run.world_seed)
	if region_id=="vault":
		var vault_view := DungeonView.new()
		vault_view.progress=run.vault
		terrain=vault_view
	else:
		terrain=WorldView.new()
	add_child(terrain)
	terrain.build(generated)
	player=MagePlayer.new()
	player.run=run
	var spawn: Vector2 = generated.spawn
	if returning_to_forest:
		spawn = WorldGenerator.center(generated.points[3].tile + Vector2i(2,3))
	player.position=spawn
	player.position=Vector2(saved_player.get("x",player.position.x),saved_player.get("y",player.position.y))
	player.shake_enabled=settings.shake
	terrain.actors.add_child(player)
	player.camera.limit_right=int(generated.get("width",WorldGenerator.WIDTH))*16
	player.camera.limit_bottom=int(generated.get("height",WorldGenerator.HEIGHT))*16
	player.vitals.hp=float(saved_player.get("hp",100))
	player.vitals.mana=float(saved_player.get("mana",100))
	player.vitals.stamina=float(saved_player.get("stamina",100))
	combat=CombatSystem.new()
	combat.run=run
	combat.player=player
	add_child(combat)
	player.cast_requested.connect(combat.cast)
	var camp: Vector2=generated.spawn if region_id=="vault" else WorldGenerator.center(generated.points[0].tile)
	for definition in generated.enemies:
		if definition.id in run.defeated:
			continue
		if region_id=="vault" and run.source.resolution=="restored" and definition.id in SourceQuest.QUIET_ENEMIES:
			continue
		var enemy := WildEnemy.new()
		enemy.configure(definition,player,camp)
		if terrain is DungeonView:
			enemy.pathfinder=terrain.navigation
		terrain.actors.add_child(enemy)
		combat.connect_enemy(enemy)
	for point in generated.points:
		var landmark: Landmark
		if region_id=="vault":
			landmark=DungeonObject.new()
			landmark.configure(point,dungeon_object_active(point.id))
		else:
			landmark=Landmark.new()
			landmark.configure(point,point.id in run.active_lights)
		terrain.actors.add_child(landmark)
	if region_id=="forest":
		var npc := Landmark.new()
		npc.configure({"id":"edda","kind":"npc","name":"Edda, Hüterin der Quelle","tile":generated.points[0].tile+Vector2i(0,-3)},false)
		terrain.actors.add_child(npc)
		var entrance := DungeonObject.new()
		entrance.configure({"id":"vault_entrance","kind":"entrance","name":"Eingang zur Quellengruft","tile":generated.points[3].tile+Vector2i(2,2)},run.quest_complete)
		terrain.actors.add_child(entrance)
		var atmosphere := ForestAtmosphere.new()
		atmosphere.player=player
		atmosphere.run=run
		add_child(atmosphere)

func dungeon_object_active(id: String) -> bool:
	if id in ["shortcut_gate","shortcut_lever"]:
		return run.vault.shortcut_open
	if id=="secret_gate":
		return run.vault.secret_open
	return id in run.vault.memories or id in run.vault.relics

func activate() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	player.input_enabled = true
	player.cast_armed = false
	player.camera.reset_smoothing()

func deactivate() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	player.input_enabled = false
	player.cast_armed = false
	if player.cast_requested.is_connected(combat.cast):
		player.cast_requested.disconnect(combat.cast)
	combat.deactivate()
