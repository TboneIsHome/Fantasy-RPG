class_name SourceSite
extends DungeonObject
var resolution: String = ""

func configure(point: Dictionary, is_active: bool) -> void:
	id=point.id
	kind="source_binding"
	title="Die gebrochene Bindung"
	position=WorldGenerator.center(point.tile)
	active=is_active
	icon=SourceArt.sprite("binding")
	add_child(icon)
	add_to_group("landmarks")
	light=WorldView.add_glow(self,Vector2(0,-24),Color("dbc998"),0.6,1.3)

func set_outcome(value: String, harvested: bool) -> void:
	resolution=value
	title="Quellengarten" if value=="restored" else "Freigelegtes Sternenerz" if value=="broken" else "Die gebrochene Bindung"
	icon.texture=SourceArt.texture(value if not value.is_empty() else "binding",1 if harvested else 0)
	light.color=Color("c4e8ae") if value=="restored" else Color("e4b475") if value=="broken" else Color("a5d1c3")
	queue_redraw()

func _draw() -> void:
	var color := Color(0.7,0.86,0.54,0.6) if resolution=="restored" else Color(0.84,0.60,0.33,0.6)
	draw_arc(Vector2(0,-4),28,0,TAU,32,color,1)
	for i in 6:
		var p := Vector2(sin(phase*0.5+i*61)*26,-14-fposmod(phase*7+i*13,30))
		draw_rect(Rect2(p.floor(),Vector2.ONE),color)
