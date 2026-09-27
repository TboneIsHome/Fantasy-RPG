class_name MagePlayer
extends CharacterBody2D

signal cast_requested(id: String, origin: Vector2, target: Vector2)
signal dash_performed
signal died
signal was_hit

var vitals := Vitals.new()
var abilities := MageAbilities.new()
var run: RunState
var input_enabled: bool = false
var aim := Vector2.RIGHT
var dash_direction := Vector2.ZERO
var dash_remaining: float = 0
var knockback := Vector2.ZERO
var icon: Sprite2D
var camera: Camera2D
var phase: float = 0
var shake: float = 0
var shake_enabled: bool = true
var last_movement := Vector2.DOWN
var cast_armed: bool = false
var cast_flash: float = 0
var staff_light: PointLight2D
var hindered: float = 0
var hit_scope: WeakRef
var active_defense := ActiveDefense.new()
var reaction := CombatReaction.new()
var attack_action: AttackInstance
var attack_actions: Array[AttackInstance] = []

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5
	collision.shape = circle
	add_child(collision)
	icon = PixelArt.sprite("mage")
	var outline := ShaderMaterial.new()
	outline.shader = preload("res://scripts/art/player_outline.gdshader")
	icon.material = outline
	add_child(icon)
	staff_light = WorldView.add_glow(self,Vector2(13,-28),Color("a7efd8"),0.20,0.42)
	camera = Camera2D.new()
	camera.position_smoothing_enabled = false
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = WorldGenerator.WIDTH*16
	camera.limit_bottom = WorldGenerator.HEIGHT*16
	add_child(camera)
	vitals.died.connect(func(): input_enabled = false; died.emit())
	vitals.damaged.connect(func(_amount): shake=2.5; was_hit.emit())

func _physics_process(delta: float) -> void:
	phase += delta
	hindered=maxf(0,hindered-delta)
	cast_flash = maxf(0,cast_flash-delta)
	vitals.tick(delta)
	abilities.tick(delta)
	active_defense.tick(delta)
	reaction.tick(delta)
	for action in attack_actions.duplicate():
		action.tick(delta)
		if action.timeline.state() in [ActionTimeline.State.COMPLETED,ActionTimeline.State.INTERRUPTED]: attack_actions.erase(action)
	dash_remaining = maxf(0,dash_remaining-delta)
	shake = maxf(0,shake-delta*15)
	camera.offset = Vector2(sin(phase*120),cos(phase*99))*shake if shake_enabled else Vector2.ZERO
	if not input_enabled:
		active_defense.block(false,aim)
		velocity = Vector2.ZERO
		update_visual()
		return
	var movement := Input.get_vector("move_left","move_right","move_up","move_down")
	if movement.length_squared() > 0.01:
		last_movement = movement
	var direction := get_global_mouse_position()-global_position
	if direction.length_squared()>1:
		aim = direction.normalized()
	if Input.is_action_just_pressed("dash"):
		try_dash(movement if movement.length_squared()>0.01 else last_movement)
	elif Input.is_action_just_pressed("parry"):
		try_parry()
	request_block(Input.is_action_pressed("block"))
	if not Input.is_action_pressed("bolt") and not Input.is_action_pressed("nova"):
		cast_armed=true
	if dash_remaining<=0 and cast_armed:
		if Input.is_action_pressed("bolt"):
			request_cast("bolt",get_global_mouse_position())
		if Input.is_action_just_pressed("nova"):
			request_cast("nova",get_global_mouse_position())
	velocity = dash_direction*float(Content.section("player").dash_speed) if dash_remaining>0 else movement*float(Content.section("player").speed)*(float(Content.section("player").hindered_speed) if hindered>0 else 1.0)
	if active_defense.mode == ActiveDefense.Mode.BLOCK: velocity *= float(Content.section("active_combat").defense.block_movement_scale)
	if reaction.locked(): velocity = Vector2.ZERO
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO,float(Content.section("player").knockback_decay)*delta)
	move_and_slide()
	update_visual()

func request_cast(id: String, target: Vector2) -> bool:
	if reaction.locked() or active_defense.blocks_offense() or dash_remaining>0 or not abilities.cast(id,vitals):
		return false
	cast_flash = 0.18
	cast_requested.emit(id,global_position+Vector2(0,-10),target)
	return true

func track_action(action: AttackInstance) -> void:
	attack_action = action
	attack_actions.append(action)

func interrupt_actions() -> void:
	for action in attack_actions: action.timeline.interrupt()

func try_dash(direction: Vector2) -> bool:
	if reaction.locked() or not active_defense.can_start() or not direction.is_finite() or direction.length_squared() < 0.000001: return false
	if not abilities.dash(vitals):
		return false
	dash_direction = direction.normalized()
	dash_remaining = float(Content.section("player").dash_duration)
	active_defense.dodge(dash_remaining,maxf(0,float(Content.section("player").dash_cooldown)-dash_remaining))
	if run and "flow" in run.learned:
		vitals.restore_mana(float(Content.section("skills").flow.mana_refund))
	dash_performed.emit()
	return true

func request_block(held: bool) -> bool:
	if not held: return active_defense.block(false,aim)
	if not combat_alive() or reaction.locked(): return false
	return active_defense.block(true,aim)

func try_parry() -> bool:
	if not combat_alive() or reaction.locked(): return false
	var config: Dictionary = Content.section("active_combat").defense
	return active_defense.parry(float(config.parry_window),float(config.parry_recovery),aim)

func take_damage(amount: float, direction: Vector2 = Vector2.ZERO) -> bool:
	var scope := hit_scope.get_ref() as Node if hit_scope != null else null
	if not is_instance_valid(scope): return false
	var result := receive_hit(scope.new_hit(&"direct_damage", ""), CombatProfiles.hostile_attack(amount), direction)
	return result.resolved and result.contact

func receive_hit(instance: HitInstance, attack: AttackProfile, direction: Vector2 = Vector2.ZERO, defense: DefenseOutcome = null) -> HitResolution:
	if vitals.hp <= 0 or instance == null: return HitResolution.rejected(&"unavailable_target")
	# Existing damage/dash immunity is decided here, never by the resolver.
	if vitals.invulnerable > 0: defense = DefenseOutcome.evade()
	elif defense == null: defense = DefenseOutcome.hit()
	var result := instance.resolve(self, attack, CombatStats.from_definition(Content.section("player").defense), defense)
	if result.resolved and result.contact:
		# Set transient response before damaged/died signals can rebuild the region.
		if result.outcome != &"parry":
			var tier := reaction.apply(result, direction, Content.section("active_combat").reaction)
			knockback = reaction.displacement
			if tier != CombatReaction.Kind.NORMAL:
				interrupt_actions()
				active_defense.reset()
		vitals.apply_hit(result)
	return result

func combat_alive() -> bool:
	return vitals.hp > 0

func combat_defense(incoming: Vector2, rules: Dictionary) -> DefenseOutcome:
	return active_defense.outcome(incoming, rules, vitals.invulnerable > 0, Content.section("active_combat").defense)

func confirm_parry() -> void:
	active_defense.parry_confirmed()
	defense_feedback(&"parry")

func defense_feedback(kind: StringName) -> void:
	var scope: Node = hit_scope.get_ref() if hit_scope != null else null
	if is_instance_valid(scope) and scope._can_act():
		scope.effects.number(global_position, "Parade" if kind == &"parry" else "Block", Color("b3edeb"))

func parried_action(action: AttackInstance) -> void:
	if not action in attack_actions or not action.is_current(): return
	if action.timeline.interrupt():
		var config: Dictionary = Content.section("active_combat")
		reaction.counter(float(config.defense.counter_window), float(config.reaction.recovery_guard))
		active_defense.reset()

func reset_transient() -> void:
	interrupt_actions()
	attack_actions.clear()
	attack_action = null
	active_defense = ActiveDefense.new()
	reaction = CombatReaction.new()
	dash_remaining = 0
	hindered = 0
	knockback = Vector2.ZERO
	velocity = Vector2.ZERO
	abilities = MageAbilities.new()
	vitals.invulnerable = float(Content.section("player").respawn_invulnerability)
	shake = 0

func update_visual() -> void:
	if not is_instance_valid(icon):
		return
	icon.flip_h = aim.x < 0
	var frame := int(phase*10)%4 if velocity.length()>1 else 0
	icon.texture = PixelArt.texture("mage",frame+(4 if aim.y<-0.65 else 0))
	staff_light.position.x = -13 if icon.flip_h else 13
	staff_light.energy = 0.20+cast_flash*3+(0.12 if run and not run.inventory.equipped.is_empty() else 0.0)
	icon.position.y = -1 if velocity.length()>1 and sin(phase*15)>0 else 0
	icon.modulate = Color("dcffff") if vitals.invulnerable>0 and fmod(phase,0.12)<0.06 else Color.WHITE
	queue_redraw()

func _draw() -> void:
	if vitals.hp<=0:
		return
	if hindered>0:
		draw_arc(Vector2.ZERO,9,0,TAU,16,Color("d8ae78"),1)
	if cast_flash>0:
		var point := Vector2(-13 if aim.x<0 else 13,-28)
		draw_line(point-aim*3,point+aim*(6+cast_flash*40),Color("efffcd"),2)
	if dash_remaining>0:
		for i in 4:
			draw_circle(-dash_direction*(i*6+4)+Vector2(0,-8),4-i*0.7,Color(0.65,0.91,0.87,0.35-i*0.07))
