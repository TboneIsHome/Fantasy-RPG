class_name ForestAtmosphere
extends Node2D

var player: MagePlayer
var run: RunState
var phase: float = 0
var tint: CanvasModulate
var darkness: float = 0

func _ready() -> void:
	z_index = 30
	tint = CanvasModulate.new()
	add_child(tint)

func _process(delta: float) -> void:
	phase += delta
	if run:
		darkness = smoothstep(0.43,0.70,run.time_of_day)*(1-smoothstep(0.90,1.0,run.time_of_day))
		tint.color = Color("fff1d7").lerp(Color("7387b4"),darkness*0.70)
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(player):
		return
	var center := player.camera.get_screen_center_position()
	# Particles occupy a world grid so they do not slide with the moving camera.
	var sector := Vector2(floor(center.x/640)*640,floor(center.y/360)*360)
	for sy in range(-1,2):
		for sx in range(-1,2):
			for i in 14:
				var base := sector+Vector2(sx*640,sy*360)+Vector2(fposmod(i*97.7+sx*13,640),fposmod(i*61.1+sy*19,360))
				var p := base+Vector2(sin(phase*0.6+i)*15,cos(phase*0.35+i*2)*10)
				if absf(p.x-center.x)>330 or absf(p.y-center.y)>190:
					continue
				var alpha := (sin(phase*1.5+i)*0.5+0.5)*0.7
				draw_rect(Rect2(p.floor(),Vector2(2,1)),Color(0.99,0.89,0.63,alpha))
				if i%4==0:
					draw_circle(p,3,Color(0.80,0.95,0.68,alpha*0.12))
	# Restrained shafts of afternoon light, anchored to the forest.
	for i in range(-2,4):
		var x: float = floor(center.x/220)*220+i*220+sin(phase*0.08)*7
		var y: float = center.y-240
		var color := Color(1.0,0.94,0.70,0.032*(1-darkness))
		for width in [70,34]:
			var polygon := PackedVector2Array([Vector2(x,y),Vector2(x+width*0.5,y),Vector2(x+200+width,y+480),Vector2(x+200,y+480)])
			draw_colored_polygon(polygon,color)
	# Drifting petals follow their own path; keep combat silhouettes clear.
	for i in 8:
		var p := sector+Vector2(fposmod(i*177+phase*7,720)-40,fposmod(i*91+phase*11,420)-30)
		p.x += sin(phase+i)*8
		draw_line(p.floor(),p.floor()+Vector2(2,1),Color(0.89,0.76,0.53,0.55),1)
