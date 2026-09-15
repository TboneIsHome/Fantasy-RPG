class_name SourceGrove
extends Node2D
var resolution: String = ""
var bounds: Rect2
var phase: float = 0

func _ready() -> void:
	z_index=-2

func set_outcome(value: String) -> void:
	if resolution==value: return
	resolution=value
	for child in get_children(): child.queue_free()
	if not value.is_empty():
		WorldView.add_glow(self,bounds.get_center(),Color("bdd9a1") if value=="restored" else Color("d5a775"),0.30,3.6)
	queue_redraw()

func _process(delta: float) -> void:
	phase+=delta
	if not resolution.is_empty(): queue_redraw()

func _draw() -> void:
	if resolution.is_empty(): return
	var center := bounds.get_center()
	if resolution=="restored":
		draw_style_box(HudCanvas.box_style(Color(0.27,0.43,0.30,0.5),Color(0.60,0.72,0.45,0.4)),bounds.grow(-12))
		for i in 28:
			var at := center+Vector2(sin(i*31)*bounds.size.x*0.40,cos(i*71)*bounds.size.y*0.39)
			draw_texture(PixelArt.texture("fern" if i%3==0 else "flowers",i%2),at.floor()-Vector2(32,65))
		for i in 13:
			var at := center+Vector2(sin(i*61+phase*0.13)*100,cos(i*39+phase*0.09)*75)
			draw_rect(Rect2(at.floor(),Vector2.ONE),Color(0.90,0.93,0.59,0.4+sin(phase+i)*0.3))
	else:
		draw_circle(center,85,Color(0.31,0.20,0.15,0.32))
		for i in 11:
			var dir := Vector2.from_angle(i*TAU/11)
			var points := PackedVector2Array([center+dir*22,center+dir*45+dir.orthogonal()*9,center+dir*67,center+dir*95+dir.orthogonal()*5])
			draw_polyline(points,Color("253844"),3)
			draw_polyline(points,Color(0.81,0.61,0.37,0.48+sin(phase+i)*0.09),1)
