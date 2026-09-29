extends RegionInstance
const PlayerObserver = preload("res://developer/observed_player.gd")
const EnemyObserver = preload("res://developer/observed_enemy.gd")
const BOUNDS := Rect2(32,32,832,512)
const START := Vector2(400,290)
var actors: Node2D
var telemetry: RefCounted
var catalog: Dictionary
var serial := 0
var selected: WeakRef

func configure(profile: String, definitions: Dictionary, origin: int, observer: RefCounted) -> void:
	region_id = "developer_arena"
	generation = origin
	catalog = definitions
	telemetry = observer
	run = RunState.new()
	run.world_seed = "SANDBOX_FIXED"
	run.learned.assign(catalog.players[profile].learned)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	player = PlayerObserver.new()
	player.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
	player.run = run
	player.position = START
	player.shake_enabled = false
	player.telemetry = telemetry
	player.set_meta("sandbox_preset",profile)
	actors.add_child(player)
	player.camera.limit_right = 896
	player.camera.limit_bottom = 576
	combat = CombatSystem.new()
	combat.run = run
	combat.player = player
	add_child(combat)
	player.cast_requested.connect(combat.cast)
	for rect in [Rect2(16,16,864,16),Rect2(16,544,864,16),Rect2(16,32,16,512),Rect2(864,32,16,512)]:
		var wall := StaticBody2D.new()
		wall.position = rect.get_center()
		wall.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
		wall.collision_layer = 1
		var shape := CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = rect.size
		wall.add_child(shape)
		add_child(wall)
	activate()
	player.input_enabled = false
	telemetry.record("reset",{"seed":run.world_seed})

func spawn(id: String, point: Vector2, overrides: Dictionary = {}) -> WildEnemy:
	if not catalog.enemies.has(id) or not point.is_finite() or enemies().size() >= int(catalog.max_enemies): return null
	var preset: Dictionary = catalog.enemies[id]
	serial += 1
	var enemy := EnemyObserver.new()
	enemy.configure({"id":"sandbox_%d_%d" % [generation,serial],"kind":preset.kind,"position":point.clamp(BOUNDS.position+Vector2(12,12),BOUNDS.end-Vector2(12,12))},player,Vector2(-10000,-10000))
	enemy.definition = enemy.definition.duplicate(true)
	enemy.definition.hp = float(overrides.get("hp",preset.hp))
	enemy.definition.damage *= float(overrides.get("damage_scale",1.0))
	enemy.definition.defense.protection = float(overrides.get("protection",preset.protection))
	enemy.definition.defense.stability = float(overrides.get("stability",preset.stability))
	enemy.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
	enemy.hp = enemy.definition.hp
	enemy.passive = preset.passive
	enemy.telemetry = telemetry
	enemy.set_meta("sandbox_preset",id)
	actors.add_child(enemy)
	combat.connect_enemy(enemy)
	selected = weakref(enemy)
	telemetry.record("spawn",{"preset":id,"target":enemy.get_instance_id(),"position":str(enemy.position),"overrides":overrides})
	return enemy

func enemies() -> Array[WildEnemy]:
	var result: Array[WildEnemy] = []
	for node in actors.get_children():
		if node is WildEnemy and not node.is_queued_for_deletion() and node.combat_alive(): result.append(node)
	return result

func target() -> WildEnemy:
	var result := selected.get_ref() as WildEnemy if selected != null else null
	return result if is_instance_valid(result) and not result.is_queued_for_deletion() and result.combat_alive() else null

func _draw() -> void:
	draw_rect(Rect2(0,0,896,576),Color("101f24"))
	draw_rect(BOUNDS,Color("253b3b"))
	for x in range(32,865,32): draw_line(Vector2(x,32),Vector2(x,544),Color("304949"))
	for y in range(32,545,32): draw_line(Vector2(32,y),Vector2(864,y),Color("304949"))
	draw_rect(BOUNDS,Color("789780"),false,2)
	draw_arc(START,42,0,TAU,48,Color("557c75"))
	draw_line(START-Vector2(5,0),START+Vector2(5,0),Color("a1ccaf"))
	draw_line(START-Vector2(0,5),START+Vector2(0,5),Color("a1ccaf"))
