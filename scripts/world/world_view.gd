class_name WorldView
extends Node2D

var data: Dictionary
var actors: Node2D
var trees: Array[Sprite2D] = []
var water_tiles: Array[Vector2] = []

func build(world: Dictionary) -> void:
	data = world
	var image := Image.create(WorldGenerator.WIDTH*16,WorldGenerator.HEIGHT*16,false,Image.FORMAT_RGB8)
	var rng := RandomNumberGenerator.new()
	rng.seed = WorldGenerator.seed_number(str(data.seed)+"/art")
	var palette := [Color("45664e"),Color("486b50"),Color("41634c"),Color("4b6e51")]
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
			var tile: int = data.tiles[y*WorldGenerator.WIDTH+x]
			var position_px := Vector2i(x,y)*16
			var grass: Color = palette[rng.randi_range(0,3)]
			image.fill_rect(Rect2i(position_px,Vector2i(16,16)),grass)
			if tile in [WorldGenerator.Tile.PATH,WorldGenerator.Tile.BRIDGE]:
				image.fill_rect(Rect2i(position_px,Vector2i(16,16)),Color("9d956e") if tile == WorldGenerator.Tile.PATH else Color("876f52"))
			elif tile == WorldGenerator.Tile.WATER:
				image.fill_rect(Rect2i(position_px,Vector2i(16,16)),Color("2e6672"))
				water_tiles.append(Vector2(position_px))
				for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					var neighbor: Vector2i = Vector2i(x,y)+offset
					if neighbor.x > 0 and neighbor.y > 0 and neighbor.x < 112 and neighbor.y < 88:
						if data.tiles[neighbor.y*112+neighbor.x] != WorldGenerator.Tile.WATER:
							var edge := position_px + Vector2i(maxi(0,offset.x)*14,maxi(0,offset.y)*14)
							image.fill_rect(Rect2i(edge,Vector2i(2 if offset.x else 16,2 if offset.y else 16)),Color("86ada0"))
			for dot in range(3 if tile == WorldGenerator.Tile.WATER else 5):
				var pixel := position_px+Vector2i(rng.randi_range(1,12),rng.randi_range(1,13))
				var color := grass.lightened(0.10)
				if tile == WorldGenerator.Tile.WATER:
					color = Color("467e85")
				elif tile in [WorldGenerator.Tile.PATH,WorldGenerator.Tile.BRIDGE]:
					color = Color("b6ae83")
				image.fill_rect(Rect2i(pixel,Vector2i(3,1)),color)
			if tile == WorldGenerator.Tile.BRIDGE:
				for row in [1,6,11]:
					image.fill_rect(Rect2i(position_px+Vector2i(0,row),Vector2i(16,1)),Color("b3a279"))
			if tile == WorldGenerator.Tile.GRASS and rng.randf() < 0.24:
				var p := position_px+Vector2i(rng.randi_range(2,11),rng.randi_range(3,12))
				image.fill_rect(Rect2i(p,Vector2i(1,3)),Color("729574"))
				image.fill_rect(Rect2i(p+Vector2i(-1,0),Vector2i(3,1)),Color("c6bb90") if rng.randf() > 0.5 else Color("a0c6ac"))
			if tile in [WorldGenerator.Tile.TREE,WorldGenerator.Tile.ROCK]:
				var sprite := PixelArt.sprite("tree" if tile == WorldGenerator.Tile.TREE else "rock",rng.randi_range(0,7))
				sprite.position = WorldGenerator.center(Vector2i(x,y))
				actors.add_child(sprite)
				if tile == WorldGenerator.Tile.TREE:
					trees.append(sprite)
			if tile in [WorldGenerator.Tile.TREE,WorldGenerator.Tile.ROCK,WorldGenerator.Tile.WATER]:
				var shape := CollisionShape2D.new()
				var rectangle := RectangleShape2D.new()
				rectangle.size = Vector2(10,9) if tile == WorldGenerator.Tile.TREE else Vector2(16,16)
				shape.shape = rectangle
				shape.position = WorldGenerator.center(Vector2i(x,y))
				bodies.add_child(shape)
	var ground := Sprite2D.new()
	ground.texture = ImageTexture.create_from_image(image)
	ground.centered = false
	ground.z_index = -10
	add_child(ground)
	var camp: Vector2 = WorldGenerator.center(data.points[0].tile)
	for p in [Vector2(-56,-18),Vector2(52,-20)]:
		var tent := PixelArt.sprite("tent")
		tent.position = camp+p
		actors.add_child(tent)
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

func update_canopies(player_position: Vector2) -> void:
	for tree in trees:
		var difference := tree.position-player_position
		tree.modulate.a = 0.18 if absf(difference.x)<28 and difference.y>0 and difference.y<59 else 1.0
