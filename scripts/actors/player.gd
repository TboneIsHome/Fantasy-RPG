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
	cast_flash = maxf(0,cast_flash-delta)
	vitals.tick(delta)
	abilities.tick(delta)
	dash_remaining = maxf(0,dash_remaining-delta)
	shake = maxf(0,shake-delta*15)
	camera.offset = Vector2(sin(phase*120),cos(phase*99))*shake if shake_enabled else Vector2.ZERO
	if not input_enabled:
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
	if not Input.is_action_pressed("bolt") and not Input.is_action_pressed("nova"):
		cast_armed=true
	if dash_remaining<=0 and cast_armed:
		if Input.is_action_pressed("bolt"):
			request_cast("bolt",get_global_mouse_position())
		if Input.is_action_just_pressed("nova"):
			request_cast("nova",get_global_mouse_position())
	velocity = dash_direction*float(Content.section("player").dash_speed) if dash_remaining>0 else movement*float(Content.section("player").speed)
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO,500*delta)
	move_and_slide()
	update_visual()

func request_cast(id: String, target: Vector2) -> bool:
	if dash_remaining>0 or not abilities.cast(id,vitals):
		return false
	cast_flash = 0.18
	cast_requested.emit(id,global_position+Vector2(0,-10),target)
	return true

func try_dash(direction: Vector2) -> bool:
	if not abilities.dash(vitals):
		return false
	dash_direction = direction.normalized()
	dash_remaining = float(Content.section("player").dash_duration)
	if run and "flow" in run.learned:
		vitals.mana = minf(100,vitals.mana+12)
	dash_performed.emit()
	return true

func take_damage(amount: float, direction: Vector2 = Vector2.ZERO) -> bool:
	if vitals.damage(amount):
		knockback = direction*65
		return true
	return false

func reset_transient() -> void:
	dash_remaining = 0
	knockback = Vector2.ZERO
	velocity = Vector2.ZERO
	abilities = MageAbilities.new()
	vitals.invulnerable = 1.0
	shake = 0

func update_visual() -> void:
	if not is_instance_valid(icon):
		return
	icon.flip_h = aim.x < 0
	var frame := int(phase*10)%4 if velocity.length()>1 else 0
	icon.texture = PixelArt.texture("mage",frame+(4 if aim.y<-0.65 else 0))
	staff_light.position.x = -13 if icon.flip_h else 13
	staff_light.energy = 0.20+cast_flash*3
	icon.position.y = -1 if velocity.length()>1 and sin(phase*15)>0 else 0
	icon.modulate = Color("dcffff") if vitals.invulnerable>0 and fmod(phase,0.12)<0.06 else Color.WHITE
	queue_redraw()

func _draw() -> void:
	if vitals.hp<=0:
		return
	if cast_flash>0:
		var point := Vector2(-13 if aim.x<0 else 13,-28)
		draw_line(point-aim*3,point+aim*(6+cast_flash*40),Color("efffcd"),2)
	if dash_remaining>0:
		for i in 4:
			draw_circle(-dash_direction*(i*6+4)+Vector2(0,-8),4-i*0.7,Color(0.65,0.91,0.87,0.35-i*0.07))
