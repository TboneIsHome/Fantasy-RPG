class_name DungeonGenerator
extends RefCounted
const VERSION := 1
const WIDTH := 96
const HEIGHT := 64
enum Tile {WALL, FLOOR, POOL}
static var definitions: Dictionary = {}

static func content() -> Dictionary:
	if definitions.is_empty():
		definitions=JSON.parse_string(FileAccess.get_file_as_string("res://data/vault.json"))
	return definitions

static func generate(seed_text: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed=WorldGenerator.seed_number(seed_text+"/vault/v1")
	var tiles := PackedInt32Array()
	tiles.resize(WIDTH*HEIGHT)
	var rooms: Array[Dictionary] = []
	var centers := {}
	for definition in content().rooms:
		var center := Vector2i(definition.center[0],definition.center[1])
		var size := Vector2i(definition.size[0],definition.size[1])
		if definition.id!="secret":
			size+=Vector2i(rng.randi_range(-1,1)*2,rng.randi_range(-1,1)*2)
		var rect := Rect2i(center-size/2,size)
		rooms.append({"id":definition.id,"name":definition.name,"center":center,"rect":rect,"style":definition.style})
		centers[definition.id]=center
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x):
				tiles[y*WIDTH+x]=Tile.FLOOR
	for link in content().links:
		var a: Vector2i=centers[link[0]]
		var b: Vector2i=centers[link[1]]
		# The secret branch joins the north/south corridor at y=31.
		if link[1]=="secret":
			a=Vector2i(46,31)
		carve(tiles,a,b)
	# Shallow-looking cistern basins are solid water, with a clear central aisle.
	for basin in [Rect2i(38,12,4,5),Rect2i(51,10,4,4)]:
		for y in range(basin.position.y,basin.end.y):
			for x in range(basin.position.x,basin.end.x):
				tiles[y*WIDTH+x]=Tile.POOL
	var points: Array[Dictionary] = []
	for definition in content().points:
		var point: Dictionary=definition.duplicate(true)
		point.tile=Vector2i(definition.tile[0],definition.tile[1])
		points.append(point)
	var enemies: Array[Dictionary] = []
	for definition in content().encounters:
		var cell := Vector2i(definition.tile[0],definition.tile[1])+Vector2i(rng.randi_range(-1,1),rng.randi_range(-1,1))
		enemies.append({"id":definition.id,"kind":definition.kind,"position":WorldGenerator.center(cell)})
	return {"region":"vault","seed":seed_text,"version":VERSION,"tiles":tiles,"rooms":rooms,"points":points,"enemies":enemies,"spawn":WorldGenerator.center(Vector2i(14,16)),"width":WIDTH,"height":HEIGHT}

static func carve(tiles: PackedInt32Array, start: Vector2i, end: Vector2i) -> void:
	var cell := start
	for i in WIDTH+HEIGHT:
		for dy in range(-1,2):
			for dx in range(-1,2):
				tiles[(cell.y+dy)*WIDTH+cell.x+dx]=Tile.FLOOR
		if cell==end:
			return
		if cell.x!=end.x:
			cell.x+=signi(end.x-cell.x)
		else:
			cell.y+=signi(end.y-cell.y)

static func gate_cells(id: String) -> Array[Vector2i]:
	var cells: Array[Vector2i]=[]
	cells.assign([Vector2i(13,31),Vector2i(14,31),Vector2i(15,31)] if id=="shortcut_gate" else [Vector2i(38,30),Vector2i(38,31),Vector2i(38,32)])
	return cells

static func navigable(world: Dictionary, cell: Vector2i, shortcut: bool, secret: bool) -> bool:
	if cell.x<0 or cell.y<0 or cell.x>=WIDTH or cell.y>=HEIGHT:
		return false
	if not shortcut and cell in gate_cells("shortcut_gate"):
		return false
	if not secret and cell in gate_cells("secret_gate"):
		return false
	return world.tiles[cell.y*WIDTH+cell.x]==Tile.FLOOR

static func reachable(world: Dictionary, shortcut: bool = false, secret: bool = false) -> Dictionary:
	var start := Vector2i(world.spawn/16)
	var seen := {start:true}
	var queue: Array[Vector2i]=[start]
	var cursor: int=0
	while cursor<queue.size():
		var cell := queue[cursor]
		cursor+=1
		for direction in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var next: Vector2i=cell+direction
			if not seen.has(next) and navigable(world,next,shortcut,secret):
				seen[next]=true
				queue.append(next)
	return seen
