class_name Landmark
extends Node2D

var id: String
var kind: String
var title: String
var active: bool = false
var icon: Sprite2D
var phase: float = 0

func configure(point: Dictionary, is_active: bool) -> void:
	id = point.id
	kind = point.kind
	title = point.name
	position = WorldGenerator.center(point.tile)
	active = is_active
	icon = PixelArt.sprite("camp" if kind == "camp" else "npc" if kind == "npc" else "shrine",1 if active else 0)
	add_child(icon)
	add_to_group("landmarks")

func activate() -> void:
	active = true
	icon.texture = PixelArt.texture("shrine",1)

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	if kind == "npc":
		draw_circle(Vector2(0,-40),3,Color("e9c88b"))
	elif kind == "camp" or active:
		var color := Color("ffcf86") if kind == "camp" else Color("a3edce")
		for radius in [35,25,16]:
			color.a = 0.035
			draw_circle(Vector2(0,-13),radius+sin(phase)*2,color)
		color.a = 0.8
		draw_rect(Rect2(Vector2(sin(phase)*10,-27-fmod(phase*8,20)),Vector2(2,2)),color)
