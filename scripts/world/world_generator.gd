class_name WorldGenerator
extends RefCounted

const WIDTH := 112
const HEIGHT := 88
const TILE := 16
const VERSION := 1
enum Tile {GRASS, PATH, WATER, TREE, ROCK, BRIDGE}

static func seed_number(text: String) -> int:
	# Explicit bounded arithmetic avoids platform-dependent String.hash changes.
	var value: int = 5381
	for index in text.length():
		value = (value * 33 + text.unicode_at(index)) & 0x7fffffff
	return value

static func generate(seed_text: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_number(seed_text)
	var noise := FastNoiseLite.new()
	noise.seed = seed_number(seed_text + "/terrain/v1")
	noise.frequency = 0.045
	var tiles := PackedInt32Array()
	tiles.resize(WIDTH * HEIGHT)
	for y in HEIGHT:
		for x in WIDTH:
			var index := y * WIDTH + x
			var river := 57 + int(sin(float(y) * 0.09) * 5)
			var pond := Vector2(x - 30, (y - 69) * 1.3).length() < 8.0
			if x < 2 or y < 2 or x >= WIDTH - 2 or y >= HEIGHT - 2:
				tiles[index] = Tile.ROCK
			elif absi(x - river) < 3 or pond:
				tiles[index] = Tile.WATER
			elif noise.get_noise_2d(x, y) > -0.18 and rng.randf() < 0.19:
				tiles[index] = Tile.TREE
			elif rng.randf() < 0.014:
				tiles[index] = Tile.ROCK
	var camp := Vector2i(15, 43)
	var points: Array[Dictionary] = [
		{"id":"camp", "name":"Laternenrast", "tile":camp, "kind":"camp"},
		{"id":"light_0", "name":"Die flüsternden Steine", "tile":Vector2i(42+rng.randi_range(-3,3),22+rng.randi_range(-3,3)), "kind":"shrine"},
		{"id":"light_1", "name":"Spiegel am Fluss", "tile":Vector2i(73+rng.randi_range(-3,3),60+rng.randi_range(-3,3)), "kind":"shrine"},
		{"id":"light_2", "name":"Der alte Sternengarten", "tile":Vector2i(96+rng.randi_range(-3,3),28+rng.randi_range(-3,3)), "kind":"shrine"}
	]
	# Guaranteed routes are carved after terrain. Water becomes a visible bridge.
	for i in range(1, points.size()):
		carve_route(tiles, points[i-1].tile, points[i].tile)
	carve_route(tiles, points[0].tile, points[2].tile)
	for point in points:
		clear_circle(tiles, point.tile, 8 if point.kind == "camp" else 4)
	var enemies: Array[Dictionary] = []
	for i in range(1, points.size()):
		var p: Vector2i = points[i].tile
		for j in 3:
			var cell := p + Vector2i(5 + j * 2, 1 if j % 2 == 0 else -3)
			cell.x = mini(cell.x, WIDTH - 5)
			clear_circle(tiles, cell, 2)
			carve_route(tiles, p, cell)
			enemies.append({"id":"guard_%d_%d" % [i,j], "kind":"wisp" if j == 2 else "wolf", "position":center(cell)})
	return {"seed":seed_text, "version":VERSION, "tiles":tiles, "points":points,
		"enemies":enemies, "spawn":center(camp)+Vector2(0,30)}

static func center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * TILE + Vector2.ONE * TILE * 0.5

static func passable(tiles: PackedInt32Array, cell: Vector2i) -> bool:
	if cell.x < 0 or cell.y < 0 or cell.x >= WIDTH or cell.y >= HEIGHT:
		return false
	return tiles[cell.y * WIDTH + cell.x] in [Tile.GRASS, Tile.PATH, Tile.BRIDGE]

static func carve_route(tiles: PackedInt32Array, from: Vector2i, to: Vector2i) -> void:
	var current := from
	# Bounded Manhattan walk, 3 tiles wide so a character has clearance.
	for step in WIDTH + HEIGHT:
		for dy in range(-1,2):
			for dx in range(-1,2):
				var cell := current + Vector2i(dx,dy)
				if cell.x <= 1 or cell.y <= 1 or cell.x >= WIDTH-2 or cell.y >= HEIGHT-2:
					continue
				var index := cell.y * WIDTH + cell.x
				tiles[index] = Tile.BRIDGE if tiles[index] in [Tile.WATER,Tile.BRIDGE] else Tile.PATH
		if current == to:
			break
		if current.x != to.x and (step % 3 != 0 or current.y == to.y):
			current.x += signi(to.x-current.x)
		else:
			current.y += signi(to.y-current.y)

static func clear_circle(tiles: PackedInt32Array, cell: Vector2i, radius: int) -> void:
	for dy in range(-radius,radius+1):
		for dx in range(-radius,radius+1):
			var target := cell + Vector2i(dx,dy)
			if target.x <= 1 or target.y <= 1 or target.x >= WIDTH-2 or target.y >= HEIGHT-2:
				continue
			if Vector2(dx,dy).length() <= radius:
				var index := target.y*WIDTH+target.x
				if tiles[index] != Tile.PATH:
					tiles[index] = Tile.GRASS

static func reachable(world: Dictionary) -> bool:
	var start: Vector2i = world.points[0].tile
	var queue: Array[Vector2i] = [start]
	var visited := {start:true}
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell + direction
			if not visited.has(next) and passable(world.tiles,next):
				visited[next] = true
				queue.append(next)
	for point in world.points:
		if not visited.has(point.tile):
			return false
	for enemy in world.enemies:
		if not visited.has(Vector2i(enemy.position / TILE)):
			return false
	return true
