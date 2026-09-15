class_name SourceGuardian
extends WildEnemy
signal slam_requested(point: Vector2, radius: float, amount: float)
signal disengaged
var arena: Rect2
var awake: bool = false
var attack_index: int = 0

func _ready() -> void:
	add_to_group("guardians")
	collision_layer=0
	collision_mask=1
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius=16
	collision.shape=circle
	add_child(collision)
	icon=SourceArt.sprite("guardian")
	add_child(icon)
	WorldView.add_glow(self,Vector2(0,-40),Color("a9e0bf"),0.45,1.1)

func awaken() -> bool:
	if awake or hp<=0:
		return false
	awake=true
	add_to_group("enemies")
	collision_layer=4
	attack_index=0
	state=Mode.RECOVER
	timer=1.0
	return true

func withdraw() -> void:
	awake=false
	remove_from_group("enemies")
	collision_layer=0
	hp=float(definition.hp)
	slowed=0
	state=Mode.IDLE
	timer=0
	disengaged.emit()

func _physics_process(delta: float) -> void:
	if hp<=0: return
	phase+=delta
	slowed=maxf(0,slowed-delta)
	if awake:
		if not is_instance_valid(target) or target.vitals.hp<=0 or not arena.has_point(target.global_position):
			withdraw()
		else:
			timer-=delta
			if timer<=0:
				if state==Mode.RECOVER:
					state=Mode.WINDUP
					attack_target=target.global_position
					attack_direction=global_position.direction_to(attack_target)
					timer=float(definition.windup if attack_index%2==0 else definition.fan_windup)
				elif state==Mode.WINDUP:
					if attack_index%2==0:
						slam_requested.emit(attack_target,float(definition.slam_radius),float(definition.damage))
					else:
						var origin := global_position+Vector2(0,-12)
						for i in int(definition.fan_count):
							var spread: float=lerpf(-float(definition.fan_spread),float(definition.fan_spread),float(i)/float(definition.fan_count-1))
							projectile_requested.emit(origin,origin.direction_to(attack_target).rotated(spread),float(definition.fan_damage))
					attack_index+=1
					state=Mode.RECOVER
					timer=float(definition.recovery)
	icon.texture=SourceArt.texture("guardian",1 if awake and state==Mode.WINDUP and attack_index%2==0 else 2 if awake and state==Mode.WINDUP else 0)
	icon.position.y=sin(phase*1.7)
	icon.modulate=Color("b4dbe0") if slowed>0 else Color.WHITE
	queue_redraw()

func take_damage(amount: float, direction: Vector2 = Vector2.ZERO, is_bolt: bool = false) -> bool:
	if not awake: return false
	return super.take_damage(amount,Vector2.ZERO,is_bolt)

func _draw() -> void:
	if not awake:
		draw_arc(Vector2.ZERO,25,0,TAU,32,Color(0.76,0.72,0.43,0.45),1)
		return
	if state==Mode.WINDUP:
		if attack_index%2==0:
			var at := to_local(attack_target)
			var radius: float=float(definition.slam_radius)
			var progress := clampf(1-timer/float(definition.windup),0,1)
			draw_circle(at,radius,Color(0.89,0.62,0.34,0.18))
			draw_arc(at,radius,0,TAU,48,Color("f3c78a"),2)
			draw_arc(at,radius*progress,0,TAU,48,Color("f4e0ab"),1)
			for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
				draw_line(at+direction*5,at+direction*11,Color("f4dfbd"),1)
		else:
			var origin := Vector2(0,-12)
			var direction := (to_local(attack_target)-origin).normalized()
			for i in int(definition.fan_count):
				var spread: float=lerpf(-float(definition.fan_spread),float(definition.fan_spread),float(i)/float(definition.fan_count-1))
				draw_line(origin+direction.rotated(spread)*22,origin+direction.rotated(spread)*110,Color(0.85,0.66,0.41,0.55),1)
			draw_arc(origin,22,0,TAU,24,Color("e6c17f"),2)
