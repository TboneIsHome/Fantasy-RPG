class_name DungeonView
extends WorldView
var navigation: AStarGrid2D
var progress: DungeonProgress
var phase: float = 0
var source_resolution: String = ""

func build(world: Dictionary) -> void:
	data=world
	actors=Node2D.new()
	actors.y_sort_enabled=true
	actors.name="VaultActors"
	add_child(actors)
	var rng := RandomNumberGenerator.new()
	rng.seed=WorldGenerator.seed_number(str(data.seed)+"/vault/art/v1")
	var img := Image.create(DungeonGenerator.WIDTH*16,DungeonGenerator.HEIGHT*16,false,Image.FORMAT_RGBA8)
	img.fill(Color("142b37"))
	var walls := StaticBody2D.new()
	walls.collision_layer=1
	walls.collision_mask=0
	add_child(walls)
	navigation=AStarGrid2D.new()
	navigation.region=Rect2i(0,0,DungeonGenerator.WIDTH,DungeonGenerator.HEIGHT)
	navigation.cell_size=Vector2(16,16)
	navigation.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
	navigation.update()
	for y in DungeonGenerator.HEIGHT:
		var wall_start: int=-1
		for x in range(DungeonGenerator.WIDTH+1):
			var solid: bool= x<DungeonGenerator.WIDTH and data.tiles[y*DungeonGenerator.WIDTH+x]!=DungeonGenerator.Tile.FLOOR
			if solid and wall_start<0:
				wall_start=x
			if not solid and wall_start>=0:
				var shape := CollisionShape2D.new()
				var box := RectangleShape2D.new()
				box.size=Vector2((x-wall_start)*16,16)
				shape.shape=box
				shape.position=Vector2((wall_start+x)*8,y*16+8)
				walls.add_child(shape)
				wall_start=-1
			if x==DungeonGenerator.WIDTH:
				continue
			navigation.set_point_solid(Vector2i(x,y),solid)
			var px := x*16
			var py := y*16
			if data.tiles[y*DungeonGenerator.WIDTH+x]==DungeonGenerator.Tile.POOL:
				PixelArt.rect(img,px,py,16,16,"285968")
				water_tiles.append(Vector2(px,py))
				for direction in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
					var cell: Vector2i=Vector2i(x,y)+direction
					if data.tiles[cell.y*DungeonGenerator.WIDTH+cell.x]!=DungeonGenerator.Tile.POOL:
						var edge := Vector2i(px,py)+Vector2i(maxi(0,direction.x)*14,maxi(0,direction.y)*14)
						PixelArt.rect(img,edge.x,edge.y,2 if direction.x else 16,2 if direction.y else 16,"93b4a2")
			elif not solid:
				var palette: Array=["405861","435d63","48636a","3d5660"]
				for room in data.rooms:
					if room.rect.has_point(Vector2i(x,y)):
						palette={"roots":["45594d","4d6252","526653","3f564c"],"garden":["465e49","4a6651","577156","415d4c"],"archive":["53564d","595e54","5e6356","4b5350"],"amber":["68654e","707156","77775a","626b51"],"sanctum":["535d67","5b666d","606e71","4c5a64"]}.get(room.style,palette)
				var floor_color: String=palette[rng.randi_range(0,3)]
				PixelArt.rect(img,px,py,16,16,Color(floor_color).darkened(0.12).to_html())
				PixelArt.rect(img,px+1,py+1,15,15,floor_color)
				if rng.randf()<0.2:
					PixelArt.line(img,Vector2i(px+3,py+5),Vector2i(px+7,py+8),"657c79")
				if rng.randf()<0.08:
					PixelArt.line(img,Vector2i(px+8,py+10),Vector2i(px+10,py+15),"293f4b")
				if y>0 and data.tiles[(y-1)*DungeonGenerator.WIDTH+x]==DungeonGenerator.Tile.WALL:
					PixelArt.rect(img,px,py,16,3,"233c48")
			else:
				var border := false
				for d in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
					var c: Vector2i=Vector2i(x,y)+d
					if c.x>=0 and c.y>=0 and c.x<DungeonGenerator.WIDTH and c.y<DungeonGenerator.HEIGHT and data.tiles[c.y*DungeonGenerator.WIDTH+c.x]==DungeonGenerator.Tile.FLOOR:
						border=true
				if not border and rng.randf()<0.05:
					PixelArt.line(img,Vector2i(px,py),Vector2i(px+14,py+12),"253d45",2)
				if border:
					PixelArt.rect(img,px,py,16,16,"36505e")
					PixelArt.rect(img,px+1,py,14,6,"68818a")
					PixelArt.rect(img,px+1,py,14,1,"9cafa6")
					PixelArt.rect(img,px+1,py+8,14,6,"415e6a")
					PixelArt.rect(img,px+3,py+10,7,1,"55747d")
					if rng.randf()<0.25:
						PixelArt.line(img,Vector2i(px+2,py+2),Vector2i(px+13,py+12),"7a8054",2)
	for room in data.rooms:
		var bounds: Rect2i=room.rect
		for cell in [bounds.position+Vector2i(-1,-1),Vector2i(bounds.end.x,bounds.position.y-1),Vector2i(bounds.position.x-1,bounds.end.y),bounds.end]:
			add_prop("pillar",WorldGenerator.center(cell))
		for i in 4:
			var cell: Vector2i=Vector2i(bounds.position.x+3+i*4,bounds.position.y-1)
			add_prop("shelf" if room.style=="archive" else "roots" if room.style in ["roots","garden"] else "banner" if room.style=="sanctum" else "crystal",WorldGenerator.center(cell))
		var glow_color := Color("84bfd0") if room.style in ["stars","water"] else Color("d0c48a") if room.style=="amber" else Color("8bb88f")
		WorldView.add_glow(self,WorldGenerator.center(room.center),glow_color,0.18,3.4)
		if room.style in ["stars","sanctum"]:
			var altar := PixelArt.sprite("shrine",1)
			altar.position=WorldGenerator.center(Vector2i(room.center.x,bounds.position.y-1))
			actors.add_child(altar)
			WorldView.add_glow(altar,Vector2(0,-28),Color("a4d9e5") if room.style=="stars" else Color("f0cb94"),0.65,1.2)
		if room.style=="archive":
			for i in 18:
				var p := Vector2i(rng.randi_range(bounds.position.x+2,bounds.end.x-3)*16,rng.randi_range(bounds.position.y+1,bounds.end.y-2)*16)
				PixelArt.rect(img,p.x,p.y,6,4,"b0a783")
				PixelArt.line(img,p+Vector2i(1,1),p+Vector2i(4,1),"7d846e")
		if room.style in ["roots","garden","amber"]:
			for i in 20:
				var p := Vector2i(rng.randi_range(bounds.position.x+1,bounds.end.x-2)*16,rng.randi_range(bounds.position.y+1,bounds.end.y-2)*16)
				var vegetation := PixelArt.texture("fern" if i%3==0 else "flowers" if room.style=="amber" else "mushrooms",0).get_image()
				img.blend_rect(vegetation,Rect2i(0,0,64,72),p-Vector2i(32,65))
	var ground := Sprite2D.new()
	ground.texture=ImageTexture.create_from_image(img)
	ground.centered=false
	ground.z_index=-10
	add_child(ground)
	var tint := CanvasModulate.new()
	tint.color=Color("b9ccd6")
	add_child(tint)
	refresh_gates()

func refresh_gates() -> void:
	for id in ["shortcut_gate","secret_gate"]:
		var opened: bool=progress.shortcut_open if id=="shortcut_gate" else progress.secret_open
		for cell in DungeonGenerator.gate_cells(id):
			navigation.set_point_solid(cell,not opened)

func add_prop(kind: String, at: Vector2) -> void:
	var sprite := DungeonArt.sprite(kind)
	sprite.position=at
	actors.add_child(sprite)

func _process(delta: float) -> void:
	phase+=delta
	queue_redraw()

func _draw() -> void:
	for p in water_tiles:
		var shift := sin(phase+p.x*0.03+p.y*0.07)
		draw_line(p+Vector2(3,7+shift*2),p+Vector2(10+shift*2,7+shift*2),Color(0.61,0.83,0.79,0.45),1)
	for room in data.get("rooms",[]):
		if room.id=="sanctum" and not source_resolution.is_empty(): continue
		var at := WorldGenerator.center(room.center)
		if room.style in ["stars","water","amber","sanctum"]:
			var color := Color(0.83,0.76,0.52,0.25) if room.style in ["amber","sanctum"] else Color(0.54,0.77,0.77,0.25)
			draw_arc(at,58,0,TAU,64,color,1)
			draw_arc(at,51,0,TAU,64,color,1)
			for i in 8:
				var a := at+Vector2.from_angle(i*TAU/8)*51
				var b := at+Vector2.from_angle((i+3)*TAU/8)*51
				draw_line(a,b,color,1)
			if room.style=="water":
				for i in 10:
					var p := at+Vector2(sin(i*71)*43,cos(i*51)*35)
					draw_line(p,p+Vector2(5+sin(phase+i)*3,0),Color(0.67,0.84,0.84,0.4),1)
		for i in 5:
			var p := at+Vector2(sin(i*83+phase*0.10)*65,cos(i*73+phase*0.07)*60)
			draw_rect(Rect2(p.floor(),Vector2.ONE),Color(0.71,0.87,0.78,0.3+sin(phase+i)*0.25))
