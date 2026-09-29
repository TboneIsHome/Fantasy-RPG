extends RefCounted
var owner_ref: WeakRef
var running := false
var index := -1
var completed := 0
var delay := 0.0
var generation := -1

func _init(owner: Node) -> void:
	owner_ref = weakref(owner)

func start() -> void:
	var session: Node = owner_ref.get_ref()
	generation = session.generation
	index = -1
	completed = 0
	running = true
	delay = 0
	advance()

func stop() -> void:
	running = false
	delay = 0

func advance() -> void:
	var session: Node = owner_ref.get_ref()
	if not is_instance_valid(session) or not session.is_current(generation): stop(); return
	index += 1
	if index >= session.catalog.data.waves.size(): stop(); return
	var wave: Dictionary = session.catalog.data.waves[index]
	for i in wave.enemies.size():
		var preset: String = wave.enemies[i]
		var position: Vector2 = session.fixture.player.global_position + Vector2(125,(i-1)*40)
		session.spawn(preset,position,{"hp":session.catalog.data.enemies[preset].hp*wave.hp_scale,"damage_scale":wave.damage_scale})
	session.telemetry.record("wave",{"index":index+1,"definition":wave})

func tick(delta: float) -> void:
	if not running: return
	var session: Node = owner_ref.get_ref()
	if not is_instance_valid(session) or not session.is_current(generation): stop(); return
	if not session.fixture.enemies().is_empty(): return
	delay += delta
	if delay >= float(session.catalog.data.wave_delay):
		delay = 0
		completed += 1
		advance()
