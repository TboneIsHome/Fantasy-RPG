class_name DungeonObject
extends Landmark
var barrier: StaticBody2D

func configure(point: Dictionary, is_active: bool) -> void:
	id=point.id
	kind=point.kind
	title=point.name
	position=WorldGenerator.center(point.tile)
	active=is_active
	icon=DungeonArt.sprite(kind,active)
	icon.visible=kind!="secret_gate"
	add_child(icon)
	add_to_group("landmarks")
	if kind in ["gate","secret_gate"]:
		barrier=StaticBody2D.new()
		barrier.collision_layer=0 if active else 1
		barrier.collision_mask=0
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size=Vector2(48,16) if kind=="gate" else Vector2(16,48)
		shape.shape=rectangle
		barrier.add_child(shape)
		add_child(barrier)
	if kind in ["font","exit","entrance","memory","chest"]:
		light=WorldView.add_glow(self,Vector2(0,-17),Color("8bdccc") if kind!="chest" else Color("efc783"),0.45,1.05)

func activate() -> void:
	active=true
	icon.texture=DungeonArt.texture(kind,true)
	if barrier:
		barrier.collision_layer=0
	queue_redraw()

func _process(delta: float) -> void:
	phase+=delta
	if light:
		light.energy=0.42+sin(phase*1.6)*0.055
	queue_redraw()

func _draw() -> void:
	if kind=="secret_gate" and not active:
		for y in [-24,-8,8]:
			draw_rect(Rect2(-8,y,16,15),Color("486572"))
			draw_line(Vector2(-8,y),Vector2(7,y),Color("829b95"),1)
		draw_polyline(PackedVector2Array([Vector2(1,-18),Vector2(-2,-6),Vector2(2,-1),Vector2(-1,9),Vector2(1,18)]),Color("adc0a2"),1)
	elif kind in ["memory","chest"] and not active:
		var at := Vector2(0,-38 if kind=="chest" else -48)
		draw_line(at-Vector2(0,3),at+Vector2(0,3),Color(0.95,0.88,0.64,0.6+sin(phase*2)*0.2),1)
		draw_line(at-Vector2(3,0),at+Vector2(3,0),Color(0.95,0.88,0.64,0.6+sin(phase*2)*0.2),1)
