class_name CombatFeedback
extends Node2D

var particles: Array[Dictionary] = []
var numbers: Array[Dictionary] = []
var rings: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	z_index = 20
	rng.randomize()

func burst(point: Vector2, color: Color, count: int = 12) -> void:
	for i in count:
		particles.append({"p":point,"v":Vector2.from_angle(rng.randf()*TAU)*rng.randf_range(14,65),"life":0.45,"color":color})

func number(point: Vector2, value: String, color: Color) -> void:
	numbers.append({"p":point+Vector2(-6,-28),"text":value,"life":0.85,"color":color})

func ring(point: Vector2, radius: float, color: Color) -> void:
	rings.append({"p":point,"radius":radius,"life":0.6,"color":color})

func _process(delta: float) -> void:
	for particle in particles:
		particle.life -= delta
		particle.p += particle.v*delta
		particle.v *= maxf(0,1-delta*2)
	for value in numbers:
		value.life -= delta
		value.p.y -= delta*15
	for value in rings:
		value.life -= delta
	particles = particles.filter(func(p): return p.life>0)
	numbers = numbers.filter(func(p): return p.life>0)
	rings = rings.filter(func(p): return p.life>0)
	queue_redraw()

func diamond(at: Vector2, radius: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([at+Vector2(0,-radius),at+Vector2(radius*0.55,0),at+Vector2(0,radius),at+Vector2(-radius*0.55,0)]),color)

func _draw() -> void:
	for value in rings:
		var progress: float = 1-value.life/0.6
		var color: Color = value.color
		var radius: float = value.radius*(0.40+minf(1,progress*2.2)*0.6)
		color.a = (1-progress)*0.10
		draw_circle(value.p,radius,color)
		color.a = (1-progress)*0.8
		draw_arc(value.p,radius,0,TAU,64,color,1)
		color.a *= 0.55
		draw_arc(value.p,radius-4,0,TAU,64,color,1)
		for i in 12:
			var direction := Vector2.from_angle(i*TAU/12)
			var p: Vector2 = value.p+direction*radius
			color.a = (1-progress)*0.9
			diamond(p,3.5+sin(progress*PI)*3,color)
			draw_line(value.p+direction*(radius-9),p,color,1)
			if i%2==0:
				var inside: Vector2 = value.p+direction*radius*0.56
				draw_line(inside-direction*3,inside+direction*3,color,1)
				draw_line(inside-direction.orthogonal()*3,inside+direction.orthogonal()*3,color,1)
	for particle in particles:
		var color: Color = particle.color
		color.a = clampf(particle.life*3,0,1)
		var p: Vector2 = particle.p.floor()
		draw_line(p-particle.v*0.035,p,color,1)
		draw_rect(Rect2(p,Vector2(2,2)),color.lightened(0.2))
	for value in numbers:
		var color: Color = value.color
		color.a = clampf(value.life*3,0,1)
		draw_string(ThemeDB.fallback_font,value.p+Vector2(1,1),value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color(0.08,0.15,0.20,color.a))
		draw_string(ThemeDB.fallback_font,value.p,value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,11,color)
