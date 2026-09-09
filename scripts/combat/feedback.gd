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

func _draw() -> void:
	for particle in particles:
		var color: Color = particle.color
		color.a = clampf(particle.life*3,0,1)
		draw_rect(Rect2(particle.p,Vector2(2,2)),color)
	for value in numbers:
		var color: Color = value.color
		color.a = clampf(value.life*3,0,1)
		draw_string(ThemeDB.fallback_font,value.p,value.text,HORIZONTAL_ALIGNMENT_LEFT,-1,11,color)
	for value in rings:
		var progress: float = 1-value.life/0.6
		var color: Color = value.color
		color.a = (1-progress)*0.15
		draw_circle(value.p,value.radius,color)
		color.a = 1-progress
		draw_arc(value.p,value.radius*(0.5+progress*0.5),0,TAU,48,color,2)
