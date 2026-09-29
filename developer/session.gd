extends Node
## Local developer orchestration. No production save/game-session dependency.
const Catalog = preload("res://developer/catalog.gd")
const Fixture = preload("res://developer/fixture.gd")
const Telemetry = preload("res://developer/telemetry.gd")
const Waves = preload("res://developer/waves.gd")
var catalog := Catalog.new()
var fixture: RegionInstance
var telemetry: RefCounted
var waves: RefCounted
var mount: Node
var generation := 0
var player_preset := "mage"
var enemy_preset := "dummy"
var start_overrides: Dictionary = {}
var paused := false
var resetting := false
var last_error := ""
var last_scenario: Dictionary = {}
var probe_action: AttackInstance

func initialize(world_mount: Node = null) -> bool:
	if not Content.ensure_loaded(): last_error = Content.error_text(); return false
	if not catalog.load_data(): last_error = "\n".join(catalog.errors); return false
	mount = world_mount if world_mount != null else self
	waves = Waves.new(self)
	return reset()

func is_current(origin: int) -> bool:
	return origin == generation and is_instance_valid(fixture) and fixture.combat._can_act()

func reset(profile: String = "", enemy: String = "", with_target: bool = true, overrides: Dictionary = {}) -> bool:
	if resetting or catalog.data.is_empty(): return false
	var settings := start_overrides if profile.is_empty() and enemy.is_empty() and overrides.is_empty() else overrides
	profile = player_preset if profile.is_empty() else profile
	enemy = enemy_preset if enemy.is_empty() else enemy
	if not catalog.data.players.has(profile) or not catalog.data.enemies.has(enemy) or not valid_overrides(settings): return false
	resetting = true
	waves.stop()
	unload()
	generation += 1
	player_preset = profile
	enemy_preset = enemy
	start_overrides = settings.duplicate(true)
	telemetry = Telemetry.new()
	telemetry.generation = generation
	telemetry.player_preset = profile
	fixture = Fixture.new()
	mount.add_child(fixture)
	fixture.configure(profile,catalog.data,generation,telemetry)
	if with_target: spawn(enemy,Fixture.START+Vector2(catalog.data.players[profile].distance,0),settings)
	probe_action = null
	last_scenario = {}
	set_paused(false)
	resetting = false
	return true

func unload() -> void:
	probe_action = null
	if not is_instance_valid(fixture): return
	fixture.deactivate()
	fixture.get_parent().remove_child(fixture)
	fixture.queue_free()
	fixture = null

func set_paused(value: bool) -> void:
	paused = value
	if is_instance_valid(fixture):
		fixture.process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
		fixture.player.input_enabled = false
		fixture.player.cast_armed = false

func valid_overrides(values: Dictionary) -> bool:
	for key in values:
		if not key in ["hp","protection","stability","damage_scale"]: return false
		if not Catalog.numeric(values[key],0.1 if key == "damage_scale" else 1 if key == "hp" else 0,4 if key == "damage_scale" else 10000): return false
	return true

func spawn(id: String, position: Vector2, overrides: Dictionary = {}) -> WildEnemy:
	if not is_current(generation) or not position.is_finite() or not valid_overrides(overrides): return null
	return fixture.spawn(id,position,overrides)

func refill_player() -> void:
	fixture.player.vitals.refill()
	fixture.player.abilities = MageAbilities.new()
	telemetry.record("developer_refill",{"hp":fixture.player.vitals.hp,"cooldowns_reset":true})

func position_target(distance: float, angle: float, facing: float) -> bool:
	var target: WildEnemy = fixture.target()
	if target == null or not Catalog.numeric(distance,0,250) or not Catalog.numeric(angle,-180,180) or not Catalog.numeric(facing,-180,180): return false
	var point := fixture.player.global_position + Vector2.from_angle(deg_to_rad(angle))*distance
	if not Fixture.BOUNDS.grow(-12).has_point(point): return false
	target.global_position = point
	target.home = point
	fixture.player.aim = Vector2.from_angle(deg_to_rad(facing))
	telemetry.record("developer_position",{"distance":distance,"angle":angle,"facing":facing,"target":target.get_instance_id()})
	return true

func cast(id: String) -> bool:
	if not id in catalog.data.actions: return false
	var target: WildEnemy = fixture.target()
	var point: Vector2 = target.global_position if target != null else fixture.player.global_position+fixture.player.aim*90
	var accepted := fixture.player.request_cast(id,point)
	telemetry.record("cast_request",{"action":id,"accepted":accepted})
	return accepted

func single_enemy_attack() -> bool:
	var enemy: WildEnemy = fixture.target()
	if enemy == null: return false
	enemy.attack_target = fixture.player.global_position
	enemy.attack_direction = enemy.global_position.direction_to(enemy.attack_target)
	var accepted := enemy.begin_attack()
	if accepted:
		enemy.single_attack = true
		enemy.passive = true
	telemetry.record("enemy_attack_request",{"accepted":accepted,"target":enemy.get_instance_id()})
	return accepted

func defense(id: String, direction: Vector2 = Vector2.RIGHT) -> bool:
	var accepted := false
	match id:
		"block": accepted = fixture.player.request_block(true)
		"release": accepted = fixture.player.request_block(false)
		"parry": accepted = fixture.player.try_parry()
		"dodge": accepted = fixture.player.try_dash(direction)
	telemetry.record("defense_request",{"defense":id,"accepted":accepted,"direction":str(direction)})
	return accepted

func start_probe() -> AttackInstance:
	var data: Dictionary = catalog.data.probe
	probe_action = fixture.combat.new_action(fixture.player,&"sandbox_probe",ActionProfiles.clock(data.startup,data.active,data.recovery),ActionProfiles.rules("direct"))
	fixture.player.track_action(probe_action)
	telemetry.record("developer_probe_start",{"attack_instance":probe_action.get_instance_id(),"definition":data})
	return probe_action

func advance_probe(seconds: float) -> bool:
	if not paused or probe_action == null or not Catalog.numeric(seconds,0.001,1): return false
	probe_action.tick(seconds)
	fixture.player.active_defense.tick(seconds)
	fixture.player.reaction.tick(seconds)
	fixture.player.vitals.tick(seconds)
	for enemy in fixture.enemies():
		enemy.active_defense.tick(seconds)
		enemy.reaction.tick(seconds)
	telemetry.elapsed += seconds
	telemetry.record("developer_clock_step",{"seconds":seconds,"movement":false})
	return true

func probe(impact: float = -1) -> CombatContact:
	if probe_action == null or not is_current(generation) or fixture.target() == null: return null
	var data: Dictionary = catalog.data.probe
	if impact == -1: impact = data.impact
	if not Catalog.numeric(impact,0,1000): return null
	var player := fixture.player
	var query := ContactContext.new(probe_action,fixture.target(),player.global_position,data.range,player.aim,0).follow(player)
	query.visibility = fixture.combat._clear_line
	var result := CombatContact.resolve(probe_action,query,AttackProfile.new(data.damage,Content.section("combat").default_damage_type,impact))
	telemetry.contact(probe_action,query,result)
	return result

func start_waves() -> void:
	reset(player_preset,enemy_preset,false,start_overrides)
	waves.start()

func stop_waves() -> void:
	waves.stop()
	set_paused(true)
	telemetry.record("waves_stopped")

func _physics_process(delta: float) -> void:
	if not paused and is_current(generation):
		telemetry.elapsed += delta
		waves.tick(delta)

func action_info(action: AttackInstance) -> Dictionary:
	if action == null: return {}
	return {"id":str(action.action_id),"instance":action.get_instance_id(),"generation":action.generation,"phase":ActionTimeline.State.keys()[action.timeline.state()],"time":snappedf(action.timeline.elapsed,0.001)}

func snapshot() -> Dictionary:
	if not is_current(generation): return {}
	var p := fixture.player
	var target: WildEnemy = fixture.target()
	return {"generation":generation,"paused":paused,"profile":player_preset,"enemies":fixture.enemies().size(),"player":{"id":p.get_instance_id(),"position":str(p.global_position),"aim":str(p.aim),"hp":p.vitals.hp,"mana":p.vitals.mana,"stamina":p.vitals.stamina,"cooldowns":p.abilities.cooldowns.duplicate(),"defense":ActiveDefense.Mode.keys()[p.active_defense.mode],"defense_remaining":p.active_defense.remaining,"reaction":CombatReaction.Kind.keys()[p.reaction.kind],"action":action_info(p.attack_action)},"target":{} if target == null else {"id":target.get_instance_id(),"preset":target.get_meta("sandbox_preset"),"hp":target.hp,"distance":p.global_position.distance_to(target.global_position),"position":str(target.global_position),"defense":ActiveDefense.Mode.keys()[target.active_defense.mode],"reaction":CombatReaction.Kind.keys()[target.reaction.kind],"action":action_info(target.attack_action)},"probe":action_info(probe_action),"wave":{"running":waves.running,"index":waves.index+1,"completed":waves.completed}}

func report() -> Dictionary:
	return {"version":1,"snapshot":snapshot(),"scenario_result":last_scenario.duplicate(true),"events":telemetry.events.duplicate(true)}

func write_report() -> String:
	var directory := "user://developer_sandbox"
	if DirAccess.make_dir_recursive_absolute(directory) != OK: return ""
	var path := directory + "/last_report.json"
	var file := FileAccess.open(path,FileAccess.WRITE)
	if file == null: return ""
	file.store_string(JSON.stringify(report(),"\t"))
	file.flush()
	return ProjectSettings.globalize_path(path) if file.get_error() == OK else ""

func _exit_tree() -> void:
	if waves != null: waves.stop()
	unload()
