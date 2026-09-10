class_name WorldView
extends Node2D

var data: Dictionary
var actors: Node2D
var trees: Array[Sprite2D] = []
var water_tiles: Array[Vector2] = []
var water_phase: float = 0
var art_rng := RandomNumberGenerator.new()
var floor_image: Image

func tile_at(x: int, y: int) -> int:
	if x<0 or y<0 or x>=WorldGenerator.WIDTH or y>=WorldGenerator.HEIGHT:
		return WorldGenerator.Tile.ROCK
	return data.tiles[y*WorldGenerator.WIDTH+x]

func build(world: Dictionary) -> void:
	data = world
	art_rng.seed = WorldGenerator.seed_number(str(data.seed)+"/art/v2")
	floor_image = Image.create(WorldGenerator.WIDTH*16,WorldGenerator.HEIGHT*16,false,Image.FORMAT_RGBA8)
	var noise := FastNoiseLite.new()
	noise.seed = WorldGenerator.seed_number(str(data.seed)+"/moss")
	noise.frequency = 0.015
	# A continuous moss field removes the old checkerboard of individual tiles.
	for y in range(0,floor_image.get_height(),4):
		for x in range(0,floor_image.get_width(),4):
			var value := clampf(noise.get_noise_2d(x,y)*1.7+0.55,0,1)
			var color := Color("355546").lerp(Color("718551"),snappedf(value,0.08))
			floor_image.fill_rect(Rect2i(x,y,4,4),color)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	actors.name = "WorldActors"
	add_child(actors)
	var bodies := StaticBody2D.new()
	bodies.collision_layer = 1
	bodies.collision_mask = 0
	add_child(bodies)
	for y in WorldGenerator.HEIGHT:
		for x in WorldGenerator.WIDTH:
			var tile := tile_at(x,y)
			var px := x*16
			var py := y*16
			if tile == WorldGenerator.Tile.PATH:
				for row in 16:
					var edge := 2+int(sin((py+row)*0.29+x)*1.5)
					var left := edge if tile_at(x-1,y)!=WorldGenerator.Tile.PATH else 0
					var right := edge if tile_at(x+1,y)!=WorldGenerator.Tile.PATH else 0
					if (row<2 and tile_at(x,y-1)!=WorldGenerator.Tile.PATH) or (row>13 and tile_at(x,y+1)!=WorldGenerator.Tile.PATH):
						continue
					var value := noise.get_noise_2d(px,py+row)+0.5
					PixelArt.rect(floor_image,px+left,py+row,16-left-right,1,Color("9b885d").lerp(Color("baa475"),snappedf(value,0.15)).to_html())
				for i in 3:
					var p := Vector2i(px+art_rng.randi_range(4,12),py+art_rng.randi_range(3,12))
					PixelArt.rect(floor_image,p.x,p.y,2,1,"c5b185" if i==0 else "8f815c")
			elif tile==WorldGenerator.Tile.WATER:
				water_tiles.append(Vector2(px,py))
				var shore := false
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					if tile_at(x+d.x,y+d.y) not in [WorldGenerator.Tile.WATER,WorldGenerator.Tile.BRIDGE]:
						shore = true
				var water := Color("346979") if not shore else Color("508b8b")
				PixelArt.rect(floor_image,px,py,16,16,water.to_html())
				for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					if tile_at(x+d.x,y+d.y) in [WorldGenerator.Tile.WATER,WorldGenerator.Tile.BRIDGE]:
						continue
					var edge := Vector2i(px,py)+Vector2i(maxi(0,d.x)*14,maxi(0,d.y)*14)
					PixelArt.rect(floor_image,edge.x,edge.y,2 if d.x else 16,2 if d.y else 16,"97b8a1")
					if art_rng.randf()<0.38:
						stamp("fern",0,Vector2i(px+8-d.x*9,py+14-d.y*9))
			elif tile==WorldGenerator.Tile.BRIDGE:
				PixelArt.rect(floor_image,px,py,16,16,"5b5144")
				for row in [0,5,10]:
					PixelArt.rect(floor_image,px,py+row,16,4,"a5885e")
					PixelArt.rect(floor_image,px,py+row,16,1,"d0b180")
					PixelArt.rect(floor_image,px+3,py+row+2,8,1,"8c714e")
				PixelArt.rect(floor_image,px+1,py+1,1,1,"484a43")
				PixelArt.rect(floor_image,px+14,py+11,1,1,"484a43")
			if tile in [WorldGenerator.Tile.TREE,WorldGenerator.Tile.ROCK]:
				var sprite := PixelArt.sprite("tree" if tile==WorldGenerator.Tile.TREE else "rock",art_rng.randi_range(0,31) if tile==WorldGenerator.Tile.TREE else 0)
				sprite.position = WorldGenerator.center(Vector2i(x,y))
				actors.add_child(sprite)
				if tile==WorldGenerator.Tile.TREE:
					trees.append(sprite)
			if tile in [WorldGenerator.Tile.TREE,WorldGenerator.Tile.ROCK,WorldGenerator.Tile.WATER]:
				var shape := CollisionShape2D.new()
				var rectangle := RectangleShape2D.new()
				rectangle.size = Vector2(10,9) if tile==WorldGenerator.Tile.TREE else Vector2(16,16)
				shape.shape = rectangle
				shape.position = WorldGenerator.center(Vector2i(x,y))
				bodies.add_child(shape)
	# Bake fine vegetation and broad tree shadows once, without extra live nodes.
	for tree in trees:
		var p := Vector2i(tree.position)
		for r in [27,22,15]:
			shade_ellipse(p+Vector2i(9,2),r,int(r*0.3),Color(0.06,0.17,0.18,0.10))
	for y in WorldGenerator.HEIGHT:
		for x in WorldGenerator.WIDTH:
			if tile_at(x,y) not in [WorldGenerator.Tile.GRASS,WorldGenerator.Tile.TREE]:
				continue
			var p := Vector2i(x*16+art_rng.randi_range(3,12),y*16+art_rng.randi_range(4,12))
			for blade in 4:
				var g := p+Vector2i(art_rng.randi_range(-4,4),art_rng.randi_range(-3,3))
				PixelArt.line(floor_image,g,g+Vector2i(art_rng.randi_range(-1,1),-art_rng.randi_range(1,4)),"7a965f" if blade%2 else "4b7653")
			var choice := art_rng.randf()
			if choice<0.10:
				stamp("fern",0,p)
			elif choice<0.17:
				stamp("flowers",art_rng.randi_range(0,2),p)
			elif choice<0.195:
				stamp("mushrooms",art_rng.randi_range(0,1),p)
	for point in data.points:
		decorate_clearing(point)
	var ground := Sprite2D.new()
	ground.texture = ImageTexture.create_from_image(floor_image)
	ground.centered = false
	ground.z_index = -10
	add_child(ground)
	floor_image = null
	var camp: Vector2 = WorldGenerator.center(data.points[0].tile)
	for p in [Vector2(-56,-18),Vector2(52,-20)]:
		var tent := prop("tent",camp+p,1 if p.x<0 else 0)
		var body := StaticBody2D.new()
		body.position = tent.position
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(36,18)
		shape.shape = rectangle
		body.add_child(shape)
		actors.add_child(body)
	prop("supplies",camp+Vector2(-75,4))
	prop("supplies",camp+Vector2(76,-22))
	for p in [Vector2(-94,40),Vector2(91,35),Vector2(-35,-71)]:
		var lantern := prop("lantern",camp+p)
		add_glow(lantern,Vector2(8,-21),Color("ffd398"),0.38,0.65)
	z_index = 0

func prop(kind: String, point: Vector2, variant: int = 0) -> Sprite2D:
	var sprite := PixelArt.sprite(kind,variant)
	sprite.position = point
	actors.add_child(sprite)
	return sprite

func stamp(kind: String, variant: int, point: Vector2i) -> void:
	PixelArt.texture(kind,variant)
	var img: Image = PixelArt.images[kind+str(variant)]
	floor_image.blend_rect(img,Rect2i(0,0,64,72),point-Vector2i(32,65))

func shade_ellipse(center: Vector2i, rx: int, ry: int, color: Color) -> void:
	for y in range(maxi(0,center.y-ry),mini(floor_image.get_height(),center.y+ry+1)):
		for x in range(maxi(0,center.x-rx),mini(floor_image.get_width(),center.x+rx+1)):
			if Vector2(float(x-center.x)/rx,float(y-center.y)/ry).length_squared()<=1:
				floor_image.set_pixel(x,y,floor_image.get_pixel(x,y).lerp(Color(color,1),color.a))

func decorate_clearing(point: Dictionary) -> void:
	var center := Vector2i(WorldGenerator.center(point.tile))
	var radius := 60 if point.kind=="camp" else 36
	for i in 24:
		var angle := i*TAU/24
		var p := center+Vector2i(Vector2(cos(angle),sin(angle)*0.55)*radius)
		if point.kind=="camp":
			PixelArt.disk(floor_image,p.x,p.y,art_rng.randi_range(3,6),2,"8c9575")
		else:
			PixelArt.disk(floor_image,p.x,p.y,4,2,"8c9f8c")
			PixelArt.rect(floor_image,p.x-2,p.y-1,3,1,"c3c6a1")
	for i in 8:
		var angle := i*TAU/8+0.2
		var p := center+Vector2i(Vector2(cos(angle),sin(angle))*radius*1.6)
		if tile_at(p.x/16,p.y/16)==WorldGenerator.Tile.GRASS:
			stamp("flowers",0 if point.kind!="camp" else 1,p)
	if point.kind=="camp":
		stamp("rug",0,center+Vector2i(-39,24))
		stamp("rug",0,center+Vector2i(48,11))
	else:
		for i in 8:
			var p := center+Vector2i(Vector2.from_angle(i*TAU/8)*23)
			PixelArt.line(floor_image,p,p+Vector2i(2,-3),"8cafa3")
			PixelArt.line(floor_image,p+Vector2i(2,-3),p+Vector2i(4,0),"8cafa3")

static func add_glow(parent: Node2D, point: Vector2, color: Color, energy: float, size: float) -> PointLight2D:
	var glow := PointLight2D.new()
	glow.texture = PixelArt.glow()
	glow.position = point
	glow.color = color
	glow.energy = energy
	glow.texture_scale = size
	glow.blend_mode = Light2D.BLEND_MODE_ADD
	parent.add_child(glow)
	return glow

func _process(delta: float) -> void:
	water_phase += delta
	queue_redraw()

func _draw() -> void:
	var camera := get_viewport().get_camera_2d()
	if not camera:
		return
	var visible_area := Rect2(camera.get_screen_center_position()-Vector2(340,200),Vector2(680,400))
	for p in water_tiles:
		if not visible_area.has_point(p):
			continue
		var phase := water_phase*0.9+p.x*0.032+p.y*0.037
		var at := p+Vector2(fposmod(phase*2,8)+2,5+sin(phase)*3).floor()
		draw_line(at,at+Vector2(5+sin(phase)*3,0),Color(0.55,0.81,0.80,0.30+0.2*sin(phase)),1)
		if int(p.x+p.y)%64==0:
			draw_line(at+Vector2(-2,5),at+Vector2(2,5),Color(0.77,0.89,0.80,0.35),1)

func update_canopies(player_position: Vector2) -> void:
	for tree in trees:
		var difference := tree.position-player_position
		tree.modulate.a = 0.16 if absf(difference.x)<35 and difference.y>0 and difference.y<90 else 1.0
