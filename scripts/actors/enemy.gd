class_name WildEnemy
extends CharacterBody2D

signal defeated(enemy: WildEnemy)
signal hit(enemy: WildEnemy, amount: float, shatter: bool)
signal projectile_requested(origin: Vector2, direction: Vector2, amount: float)
signal thorns_requested(point: Vector2)
enum Mode {IDLE, CHASE, WINDUP, ATTACK, RECOVER, RETURN}

var id: String
var kind: String
var definition: Dictionary
var hp: float
var home: Vector2
var target: MagePlayer
var camp: Vector2
var state: Mode = Mode.IDLE
var timer: float = 0
var phase: float = 0
var slowed: float = 0
var hit_stop: float = 0
var knockback := Vector2.ZERO
var attack_target := Vector2.ZERO
var attack_direction := Vector2.RIGHT
var attack_connected := false
var icon: Sprite2D
var pathfinder: AStarGrid2D
var route_timer: float = 0
var route_next := Vector2.ZERO
var peaceful_area: Rect2
var attack_hit: HitInstance

func configure(data: Dictionary, player: MagePlayer, camp_position: Vector2) -> void:
	id = data.id
	kind = data.kind
	definition = Content.section("enemies")[kind]
	hp = float(definition.hp)
	position = data.position
	home = position
	target = player
	camp = camp_position

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1 | 4
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7
	collision.shape = shape
	add_child(collision)
	icon = DungeonArt.sprite("kobold") if kind=="kobold" else PixelArt.sprite(kind)
	add_child(icon)
	if kind=="wisp":
		WorldView.add_glow(self,Vector2(0,-20),Color("99cddd"),0.6,0.6)

func _physics_process(delta: float) -> void:
	if hp <= 0 or not is_instance_valid(target):
		return
	phase += delta
	route_timer-=delta
	slowed = maxf(0,slowed-delta)
	timer -= delta
	hit_stop = maxf(0,hit_stop-delta)
	var distance := global_position.distance_to(target.global_position)
	var direction := global_position.direction_to(target.global_position)
	var speed := float(definition.speed)*(float(Content.section("spells").nova.slow_multiplier) if slowed>0 else 1.0)
	velocity = Vector2.ZERO
	if target.vitals.hp <= 0 or target_is_safe() or global_position.distance_to(home)>float(definition.leash):
		if state != Mode.RETURN:
			state = Mode.RETURN
	if hit_stop>0:
		queue_redraw()
		return
	match state:
		Mode.IDLE:
			if distance<float(definition.aggro) and not target_is_safe() and target.vitals.hp>0:
				state = Mode.CHASE
		Mode.CHASE:
			var attack_range: float = float(definition.attack_range)
			if distance<attack_range and clear_shot(target.global_position):
				state = Mode.WINDUP
				timer = float(definition.windup)
				attack_target = target.global_position
				attack_direction = direction
			elif distance>float(definition.leash):
				state = Mode.RETURN
			else:
				velocity = approach(target.global_position)*speed
		Mode.WINDUP:
			if timer<=0:
				attack_connected = false
				if kind == "wolf":
					state = Mode.ATTACK
					timer = float(definition.lunge_duration)
					attack_hit = new_hit(&"wolf_lunge")
				elif kind=="kobold":
					if clear_shot(attack_target):
						thorns_requested.emit(attack_target)
					state=Mode.RECOVER
					timer=float(definition.recovery)
				else:
					var origin := global_position+Vector2(0,-8)
					projectile_requested.emit(origin,origin.direction_to(attack_target),float(definition.damage))
					state = Mode.RECOVER
					timer = float(definition.recovery)
		Mode.ATTACK:
			velocity = attack_direction*float(definition.lunge_speed)*(float(definition.lunge_slow_multiplier) if slowed>0 else 1.0)
			if distance<float(definition.hit_range) and not attack_connected and clear_shot(target.global_position):
				attack_connected = true
				if attack_hit == null: attack_hit = new_hit(&"wolf_lunge")
				target.receive_hit(attack_hit, CombatProfiles.hostile_attack(float(definition.damage), definition.damage_type), attack_direction)
			if timer<=0 or is_on_wall():
				state = Mode.RECOVER
				timer = float(definition.recovery)
		Mode.RECOVER:
			if timer<=0:
				state = Mode.CHASE
		Mode.RETURN:
			velocity = approach(home)*speed
			if global_position.distance_to(home)<8:
				state = Mode.IDLE
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO,float(Content.section("combat").enemy_knockback_decay)*delta)
	move_and_slide()
	icon.flip_h = direction.x<0
	if kind=="wolf":
		icon.texture = PixelArt.texture("wolf",int(phase*10)%4 if velocity.length()>2 else 0)
	icon.position.y = sin(phase*4)*2 if kind=="wisp" else (-1 if velocity.length()>2 and sin(phase*12)>0 else 0)
	icon.modulate = Color("98ddf4") if slowed>0 else Color.WHITE
	queue_redraw()

func clear_shot(point: Vector2) -> bool:
	return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,point,1)).is_empty()

func target_is_safe() -> bool:
	return target.global_position.distance_to(camp)<float(Content.section("combat").camp_safe_radius) or peaceful_area.has_point(target.global_position)

func approach(point: Vector2) -> Vector2:
	if not pathfinder or clear_shot(point):
		return global_position.direction_to(point)
	if route_timer<=0 or global_position.distance_to(route_next)<3:
		route_timer=0.25
		var start := Vector2i(global_position/16)
		var goal := Vector2i(point/16)
		if not pathfinder.region.has_point(start) or not pathfinder.region.has_point(goal) or pathfinder.is_point_solid(start) or pathfinder.is_point_solid(goal):
			return Vector2.ZERO
		var route: Array[Vector2i]=pathfinder.get_id_path(start,goal)
		if route.size()<2:
			return Vector2.ZERO
		route_next=WorldGenerator.center(route[1])
	return global_position.direction_to(route_next)

func take_damage(amount: float, direction: Vector2 = Vector2.ZERO, is_bolt: bool = false) -> bool:
	var shatter := is_bolt and slowed>0
	var final_amount := amount+float(Content.section("spells").bolt.shatter_bonus) if shatter else amount
	var type_key := StringName(Content.section("spells").bolt.damage_type if is_bolt else Content.section("combat").default_damage_type)
	var instance := new_hit(&"direct_damage")
	if instance != null: instance.source_id = "" # Legacy diagnostic call has no known attacker.
	var result := receive_hit(instance, CombatProfiles.player_attack(final_amount, type_key, {"shatter":shatter}), direction)
	return result.resolved and result.contact

func new_hit(action: StringName) -> HitInstance:
	var scope := target.hit_scope.get_ref() as Node if is_instance_valid(target) and target.hit_scope != null else null
	return scope.new_hit(action, id) if is_instance_valid(scope) else null

func receive_hit(instance: HitInstance, attack: AttackProfile, direction: Vector2 = Vector2.ZERO, defense: DefenseOutcome = null) -> HitResolution:
	if hp <= 0 or instance == null: return HitResolution.rejected(&"unavailable_target")
	var result := instance.resolve(self, attack, CombatStats.from_definition(definition.defense), DefenseOutcome.hit() if defense == null else defense)
	if not result.resolved or not result.contact: return result
	hp = maxf(0, hp-result.damage)
	if result.outcome != &"parry":
		knockback = direction * result.impact
		if result.impact > 0: hit_stop = float(Content.section("combat").enemy_hit_stop)
	if result.damage > 0 or result.impact > 0:
		hit.emit(self, result.damage, bool(result.secondary.get("shatter", false)))
	if hp<=0:
		defeated.emit(self)
		remove_from_group("enemies")
		collision_layer = 0
		queue_free()
	return result

func _draw() -> void:
	if state == Mode.WINDUP:
		var color := Color("f0b77f")
		var progress := 1.0-clampf(timer/float(definition.windup),0,1)
		draw_arc(Vector2.ZERO,13,-PI*0.5,TAU*progress-PI*0.5,24,color,2)
		if kind=="kobold":
			var center := to_local(attack_target)
			var radius: float=float(definition.thorn_radius)
			draw_circle(center,radius,Color(0.89,0.42,0.27,0.15))
			draw_arc(center,radius,0,TAU,32,Color("efac7d"),1)
			draw_arc(center,radius*progress,0,TAU,32,Color("f1d28d"),1)
		elif kind == "wolf":
			draw_line(Vector2.ZERO,to_local(attack_target),Color(0.96,0.64,0.46,0.4),2)
			draw_arc(to_local(attack_target),12,0,TAU,20,Color(0.96,0.64,0.46,0.65),1)
	if hp<float(definition.hp):
		draw_rect(Rect2(-12,-32,24,3),Color("183842"))
		draw_rect(Rect2(-12,-32,24*hp/float(definition.hp),2),Color("e2b783"))
	if slowed>0:
		draw_arc(Vector2.ZERO,10,0,TAU,12,Color(0.58,0.85,0.92,0.7),1)
