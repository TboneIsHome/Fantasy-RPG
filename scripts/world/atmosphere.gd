class_name ForestAtmosphere
extends Node2D

var player: MagePlayer
var run: RunState
var phase: float = 0
var tint: CanvasModulate

func _ready() -> void:
	z_index = 30
	tint = CanvasModulate.new()
	add_child(tint)

func _process(delta: float) -> void:
	phase += delta
	if run:
		run.time_of_day = fposmod(run.time_of_day+delta/float(Content.section("world").day_seconds),1)
		var darkness := smoothstep(0.43,0.70,run.time_of_day)*(1-smoothstep(0.90,1.0,run.time_of_day))
		tint.color = Color.WHITE.lerp(Color("8297b8"),darkness*0.60)
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(player):
		return
	var center := player.global_position
	for i in 30:
		var p := center+Vector2(fposmod(i*97.7+phase*(3+i%4),700)-350,fposmod(i*61.1+phase*4,430)-215)
		var alpha := (sin(phase*1.5+i)*0.5+0.5)*0.7
		draw_rect(Rect2(p,Vector2(2,1)),Color(0.93,0.87,0.64,alpha))
	for i in 3:
		var x: float = floor(center.x/320)*320+i*220-300
		var y := center.y-240
		var polygon := PackedVector2Array([Vector2(x,y),Vector2(x+30,y),Vector2(x+225,y+470),Vector2(x+150,y+470)])
		draw_colored_polygon(polygon,Color(0.89,0.96,0.76,0.022))
