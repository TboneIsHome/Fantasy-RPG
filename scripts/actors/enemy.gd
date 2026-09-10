class_name WildEnemy
extends CharacterBody2D

signal defeated(enemy: WildEnemy)
signal hit(enemy: WildEnemy, amount: float, shatter: bool)
signal projectile_requested(origin: Vector2, direction: Vector2, amount: float)
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
	icon = PixelArt.sprite(kind)
	add_child(icon)
	if kind=="wisp":
		WorldView.add_glow(self,Vector2(0,-20),Color("99cddd"),0.6,0.6)

func _physics_process(delta: float) -> void:
	if hp <= 0 or not is_instance_valid(target):
		return
	phase += delta
	slowed = maxf(0,slowed-delta)
	timer -= delta
	hit_stop = maxf(0,hit_stop-delta)
	var distance := global_position.distance_to(target.global_position)
	var direction := global_position.direction_to(target.global_position)
	var speed := float(definition.speed)*(0.4 if slowed>0 else 1.0)
	velocity = Vector2.ZERO
	if target.vitals.hp <= 0 or target.global_position.distance_to(camp)<110 or global_position.distance_to(home)>float(definition.leash):
		if state != Mode.RETURN:
			state = Mode.RETURN
	if hit_stop>0:
		queue_redraw()
		return
	match state:
		Mode.IDLE:
			if distance<float(definition.aggro) and target.global_position.distance_to(camp)>110 and target.vitals.hp>0:
				state = Mode.CHASE
		Mode.CHASE:
			var attack_range := 53.0 if kind == "wolf" else 112.0
			if distance<attack_range:
				state = Mode.WINDUP
				timer = float(definition.windup)
				attack_target = target.global_position
				attack_direction = direction
			elif distance>float(definition.leash):
				state = Mode.RETURN
			else:
				velocity = direction*speed
		Mode.WINDUP:
			if timer<=0:
				attack_connected = false
				if kind == "wolf":
					state = Mode.ATTACK
					timer = 0.34
				else:
					var origin := global_position+Vector2(0,-8)
					projectile_requested.emit(origin,origin.direction_to(attack_target),float(definition.damage))
					state = Mode.RECOVER
					timer = float(definition.recovery)
		Mode.ATTACK:
			velocity = attack_direction*175*(0.55 if slowed>0 else 1.0)
			if distance<19 and not attack_connected:
				attack_connected = true
				target.take_damage(float(definition.damage),attack_direction)
			if timer<=0 or is_on_wall():
				state = Mode.RECOVER
				timer = float(definition.recovery)
		Mode.RECOVER:
			if timer<=0:
				state = Mode.CHASE
		Mode.RETURN:
			velocity = global_position.direction_to(home)*speed
			if global_position.distance_to(home)<8:
				state = Mode.IDLE
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO,230*delta)
	move_and_slide()
	icon.flip_h = direction.x<0
	if kind=="wolf":
		icon.texture = PixelArt.texture("wolf",int(phase*10)%4 if velocity.length()>2 else 0)
	icon.position.y = sin(phase*4)*2 if kind=="wisp" else (-1 if velocity.length()>2 and sin(phase*12)>0 else 0)
	icon.modulate = Color("98ddf4") if slowed>0 else Color.WHITE
	queue_redraw()

func take_damage(amount: float, direction: Vector2 = Vector2.ZERO, is_bolt: bool = false) -> bool:
	if hp<=0:
		return false
	var shatter := is_bolt and slowed>0
	var final_amount := amount+10 if shatter else amount
	hp = maxf(0,hp-final_amount)
	knockback = direction*80
	hit_stop = 0.06
	hit.emit(self,final_amount,shatter)
	if hp<=0:
		defeated.emit(self)
		remove_from_group("enemies")
		collision_layer = 0
		queue_free()
	return true

func _draw() -> void:
	if state == Mode.WINDUP:
		var color := Color("f0b77f")
		var progress := 1.0-clampf(timer/float(definition.windup),0,1)
		draw_arc(Vector2.ZERO,13,-PI*0.5,TAU*progress-PI*0.5,24,color,2)
		if kind == "wolf":
			draw_line(Vector2.ZERO,to_local(attack_target),Color(0.96,0.64,0.46,0.4),2)
			draw_arc(to_local(attack_target),12,0,TAU,20,Color(0.96,0.64,0.46,0.65),1)
	if hp<float(definition.hp):
		draw_rect(Rect2(-12,-32,24,3),Color("183842"))
		draw_rect(Rect2(-12,-32,24*hp/float(definition.hp),2),Color("e2b783"))
	if slowed>0:
		draw_arc(Vector2.ZERO,10,0,TAU,12,Color(0.58,0.85,0.92,0.7),1)
