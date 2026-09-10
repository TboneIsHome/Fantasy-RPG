class_name HudCanvas
extends Control

var run: RunState
var player: MagePlayer
var location_name: String = "Laternenrast"
var prompt: String = ""
var toast_text: String = ""
var toast_left: float = 0
var game_visible: bool = false
var map_data: Dictionary = {}
var show_map: bool = false

const INK := Color("142d35")
const CREAM := Color("e9e1c5")
const MUTED := Color("a3b9ae")
const GOLD := Color("d6b77d")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	toast_left = maxf(0,toast_left-delta)
	queue_redraw()

func text(at: Vector2, value: String, size: int = 11, color: Color = CREAM) -> void:
	draw_string(ThemeDB.fallback_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func card(rectangle: Rect2, alpha: float = 0.94) -> void:
	var color := INK
	color.a = alpha
	draw_style_box(box_style(color,Color("637972")),rectangle)

static func box_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.set_border_width_all(1)
	style.border_color = border
	style.set_corner_radius_all(2)
	style.shadow_color=Color(0.025,0.07,0.09,0.4)
	style.shadow_size=3
	style.shadow_offset=Vector2(0,2)
	style.content_margin_left=12
	style.content_margin_right=12
	style.content_margin_top=10
	style.content_margin_bottom=10
	return style

func meter(point: Vector2, width: float, fraction: float, color: Color) -> void:
	draw_rect(Rect2(point-Vector2.ONE,Vector2(width+2,7)),Color("0d222a"))
	draw_rect(Rect2(point,Vector2(width,5)),Color("2d4549"))
	var fill := floorf(width*clampf(fraction,0,1))
	if fill>0:
		draw_rect(Rect2(point,Vector2(fill,5)),color.darkened(0.13))
		draw_rect(Rect2(point,Vector2(fill,2)),color.lightened(0.12))
		draw_line(point+Vector2(fill-1,0),point+Vector2(fill-1,4),color.lightened(0.35),1)

func diamond(at: Vector2, r: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([at+Vector2(0,-r),at+Vector2(r,0),at+Vector2(0,r),at+Vector2(-r,0)]),color)

func spell_icon(at: Vector2, id: int, color: Color) -> void:
	if id==0:
		draw_line(at+Vector2(-6,6),at+Vector2(4,-4),color.darkened(0.25),3)
		diamond(at+Vector2(3,-3),4,color)
		draw_line(at+Vector2(3,-10),at+Vector2(3,4),color,1)
		draw_line(at+Vector2(-4,-3),at+Vector2(10,-3),color,1)
	elif id==1:
		for i in 6:
			var d := Vector2.from_angle(i*TAU/6)
			draw_line(at,at+d*9,color,1)
			draw_line(at+d*5,at+d*6+d.rotated(0.9)*3,color,1)
			draw_line(at+d*5,at+d*6+d.rotated(-0.9)*3,color,1)
		diamond(at,2,CREAM)
	else:
		draw_polyline(PackedVector2Array([at+Vector2(-3,-7),at+Vector2(3,0),at+Vector2(-3,7)]),color,2)
		draw_polyline(PackedVector2Array([at+Vector2(3,-7),at+Vector2(9,0),at+Vector2(3,7)]),color,1)
		for i in 3:
			draw_line(at+Vector2(-10,i*4-4),at+Vector2(-6,i*4-4),color.darkened(0.25),1)

func _draw() -> void:
	if game_visible and is_instance_valid(player) and run:
		card(Rect2(10,10,172,63))
		draw_rect(Rect2(16,17,31,45),Color("28464b"))
		draw_texture_rect_region(PixelArt.texture("mage"),Rect2(16,19,32,47),Rect2(16,20,32,47))
		draw_line(Vector2(51,19),Vector2(51,63),Color("5a7169"),1)
		text(Vector2(59,24),"MAGIER",9,GOLD)
		text(Vector2(142,24),"St. %d" % run.level,9,CREAM)
		var values := [player.vitals.hp,player.vitals.mana,player.vitals.stamina]
		var colors := [Color("d78e80"),Color("79bfc9"),Color("d4b77b")]
		for i in 3:
			var y: float = 32+i*12
			meter(Vector2(60,y),67,values[i]/100,colors[i])
			text(Vector2(135,y+5),["LP ","MP ","AU "][i]+str(ceili(values[i])),8)
		draw_rect(Rect2(16,69,160,1),Color("30484c"))
		draw_rect(Rect2(16,69,160*run.xp/(run.level*60.0),1),GOLD)
		card(Rect2(455,10,175,52))
		text(Vector2(467,25),"DIE VERSTUMMTEN LICHTER",9,GOLD)
		text(Vector2(467,42),"Zurück zu Edda" if run.active_lights.size()==3 and not run.quest_complete else "Quelle wieder erwacht" if run.quest_complete else "Waldlichter",11)
		for i in 3:
			diamond(Vector2(593+i*10,51),2.5,GOLD if i<run.active_lights.size() else Color("496268"))
		if not run.quest_complete and run.active_lights.size()<3:
			text(Vector2(594,41),"%d / 3" % run.active_lights.size(),10,GOLD)
		var label_width: float = ThemeDB.fallback_font.get_string_size(location_name,HORIZONTAL_ALIGNMENT_LEFT,-1,11).x
		card(Rect2(320-label_width/2-14,12,label_width+28,23),0.86)
		text(Vector2(320-label_width/2,27),location_name,11,CREAM)
		draw_line(Vector2(300,38),Vector2(314,38),GOLD.darkened(0.3),1)
		diamond(Vector2(320,38),2,GOLD)
		draw_line(Vector2(326,38),Vector2(340,38),GOLD.darkened(0.3),1)
		for i in 3:
			var x: float = 11+i*89
			var ids := ["bolt","nova","dash"]
			var names := ["Lichtfunke","Frostkreis","Schritt"]
			var binds := ["LMT / 1","RMT / 2","LEER"]
			card(Rect2(x,308,84,41))
			var cooldown: float = player.abilities.cooldowns[ids[i]]
			var color := Color("aad9cd") if i==0 else Color("a0cddd") if i==1 else GOLD
			spell_icon(Vector2(x+17,327),i,color.darkened(0.5) if cooldown>0.1 else color)
			text(Vector2(x+33,320),binds[i],8,GOLD)
			text(Vector2(x+33,333),names[i],8)
			var cost: float = [8,28,28][i]
			var resource: float = player.vitals.mana if i<2 else player.vitals.stamina
			var ready: float = 1-clampf(cooldown/[0.32,4.5,0.62][i],0,1)
			draw_rect(Rect2(x+7,342,70,2),Color("29454b"))
			draw_rect(Rect2(x+7,342,70*ready,2),color if resource>=cost else Color("a46868"))
			if cooldown>0.1:
				text(Vector2(x+8,331),"%.1f" % cooldown,10,CREAM)
		card(Rect2(467,312,163,37),0.86)
		text(Vector2(478,327),"M  Karte    TAB  Journal",9,CREAM)
		text(Vector2(478,342),"ESC  Pause",9,MUTED)
		if run.skill_points>0:
			card(Rect2(289,316,163,27))
			text(Vector2(300,334),"%d Talentpunkt · TAB" % run.skill_points,11,GOLD)
		if not prompt.is_empty():
			var w := ThemeDB.fallback_font.get_string_size(prompt,HORIZONTAL_ALIGNMENT_LEFT,-1,11).x
			card(Rect2(320-w/2-11,271,w+22,26))
			text(Vector2(320-w/2,288),prompt,11)
		var mouse := get_local_mouse_position().floor()
		draw_arc(mouse,5,0,TAU,12,Color("eae2bb"),1)
		for direction in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
			draw_line(mouse+direction*8,mouse+direction*5,CREAM,1)
	if show_map and not map_data.is_empty():
		_draw_map()
	if toast_left>0:
		var w := ThemeDB.fallback_font.get_string_size(toast_text,HORIZONTAL_ALIGNMENT_LEFT,-1,11).x
		card(Rect2(320-w/2-13,78,w+26,28))
		text(Vector2(320-w/2,96),toast_text,11,GOLD)

func _draw_map() -> void:
	draw_rect(Rect2(0,0,640,360),Color(0.03,0.08,0.10,0.85))
	card(Rect2(126,29,388,302))
	text(Vector2(143,49),"DIE LICHTERHAINE",15,GOLD)
	text(Vector2(143,65),"Seed: "+run.world_seed,9,MUTED)
	var origin := Vector2(180,79)
	var colors := [Color("52735a"),Color("c3b581"),Color("497e8b"),Color("294c45"),Color("83948a"),Color("ddc497")]
	for y in WorldGenerator.HEIGHT:
		for x in WorldGenerator.WIDTH:
			draw_rect(Rect2(origin+Vector2(x,y)*2.5,Vector2(2.5,2.5)),colors[map_data.tiles[y*112+x]])
	for point in map_data.points:
		var p: Vector2 = origin+Vector2(point.tile)*2.5
		var known: bool = point.id in run.discoveries
		draw_circle(p,4,GOLD if point.id in run.active_lights else CREAM if known else Color("8faaa1"))
		text(p+Vector2(6,3),"Lager" if point.kind=="camp" else str(map_data.points.find(point)) if known else "?",9,CREAM)
	var p := origin+player.global_position/16*2.5
	draw_circle(p,3,Color("c3ffed"))
	draw_arc(p,5,0,TAU,12,Color("c3ffed"),1)
	text(Vector2(143,315),"Du: türkis   ·   Lichter: Kreise   ·   M / ESC schließen",9,MUTED)
