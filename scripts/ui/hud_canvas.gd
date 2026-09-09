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

const INK := Color("132d36")
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
	draw_style_box(box_style(color,Color("527069")),rectangle)

static func box_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.set_border_width_all(1)
	style.border_color = border
	style.set_corner_radius_all(3)
	style.content_margin_left=12
	style.content_margin_right=12
	style.content_margin_top=10
	style.content_margin_bottom=10
	return style

func meter(point: Vector2, width: float, fraction: float, color: Color) -> void:
	draw_rect(Rect2(point,Vector2(width,4)),Color("29454b"))
	draw_rect(Rect2(point,Vector2(width*clampf(fraction,0,1),4)),color)

func _draw() -> void:
	if game_visible and is_instance_valid(player) and run:
		card(Rect2(10,10,152,62))
		text(Vector2(20,25),"MAGIER",10,GOLD)
		text(Vector2(118,25),"St. %d" % run.level,10,CREAM)
		meter(Vector2(20,33),93,player.vitals.hp/100,Color("d99b84"))
		text(Vector2(119,38),"LP "+str(ceili(player.vitals.hp)),8)
		meter(Vector2(20,45),93,player.vitals.mana/100,Color("85c7cb"))
		text(Vector2(119,50),"MP "+str(ceili(player.vitals.mana)),8)
		meter(Vector2(20,57),93,player.vitals.stamina/100,Color("d6bf83"))
		text(Vector2(119,62),"AU "+str(ceili(player.vitals.stamina)),8)
		card(Rect2(455,10,175,48))
		text(Vector2(466,26),"DIE VERSTUMMTEN LICHTER",9,GOLD)
		text(Vector2(466,43),"Zurück zu Edda" if run.active_lights.size()==3 and not run.quest_complete else "Quelle wieder erwacht" if run.quest_complete else "Waldlichter   %d / 3" % run.active_lights.size(),11)
		var label_width: float = ThemeDB.fallback_font.get_string_size(location_name,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x
		card(Rect2(320-label_width/2-14,12,label_width+28,24),0.80)
		text(Vector2(320-label_width/2,28),location_name,12)
		for i in 3:
			var x: float = 12+i*70
			card(Rect2(x,310,64,39))
			var ids := ["bolt","nova","dash"]
			var names := ["Lichtfunke","Frostkreis","Schritt"]
			var binds := ["LMT / 1","RMT / 2","LEER"]
			text(Vector2(x+7,322),binds[i],8,GOLD)
			text(Vector2(x+7,336),names[i],9)
			var cooldown: float = player.abilities.cooldowns[ids[i]]
			if cooldown>0.1:
				text(Vector2(x+45,322),"%.1f" % cooldown,8,MUTED)
			meter(Vector2(x+7,342),50,player.vitals.mana/100 if i<2 else player.vitals.stamina/100,Color("75b7b7") if i<2 else GOLD)
		card(Rect2(434,310,196,39))
		text(Vector2(446,332),"M  Karte    TAB  Journal",10,CREAM)
		text(Vector2(446,346),"ESC  Pause",9,MUTED)
		if run.skill_points>0:
			card(Rect2(251,318,147,25))
			text(Vector2(262,335),"%d Talentpunkt · TAB" % run.skill_points,11,GOLD)
		if not prompt.is_empty():
			var w := ThemeDB.fallback_font.get_string_size(prompt,HORIZONTAL_ALIGNMENT_LEFT,-1,11).x
			card(Rect2(320-w/2-11,274,w+22,26))
			text(Vector2(320-w/2,291),prompt,11)
		var mouse := get_local_mouse_position()
		draw_arc(mouse,5,0,TAU,12,Color("eae2bb"),1)
		draw_line(mouse+Vector2(-8,0),mouse+Vector2(-4,0),CREAM,1)
		draw_line(mouse+Vector2(4,0),mouse+Vector2(8,0),CREAM,1)
		draw_line(mouse+Vector2(0,-8),mouse+Vector2(0,-4),CREAM,1)
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
