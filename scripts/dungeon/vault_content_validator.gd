class_name VaultContentValidator
extends RefCounted
## Generator-1 contracts: IDs are persistent; geometry must support every size/jitter.
var check: ContentValidator

func validate(data: Variant, content: Variant, discoveries: Variant) -> Array[String]:
	check = ContentValidator.new()
	check.file = "data/vault.json"
	if not check.fields(data, "", {"name":"text","rooms":"array","links":"array","points":"array","encounters":"array","fountain_cost":[1,10000,true],"chart_xp":ContentValidator.COUNT,"seed_xp":ContentValidator.COUNT,"memory_xp":ContentValidator.COUNT}): return check.errors
	var rooms := {}
	var rects := {}
	for i in data.rooms.size():
		var path := "rooms[%d]" % i
		var room: Variant = data.rooms[i]
		if not check.fields(room, path, {"id":"id","name":"text","center":"array","size":"array","style":"id"}): continue
		unique_id(room.id, path + ".id", rooms, DungeonProgress.ROOM_IDS)
		check.enum_value(room.style, path + ".style", ["roots","water","stars","garden","archive","sanctum","amber"])
		var valid_center := pair(room.center, path + ".center", 1, DungeonGenerator.WIDTH-2, DungeonGenerator.HEIGHT-2)
		var valid_size := pair(room.size, path + ".size", 5, DungeonGenerator.WIDTH-2, DungeonGenerator.HEIGHT-2)
		if not valid_center or not valid_size: continue
		var center := Vector2i(room.center[0],room.center[1])
		var size := Vector2i(room.size[0],room.size[1])
		var variation := Vector2i.ZERO if room.id == "secret" else Vector2i(2,2)
		var largest := Rect2i(center-(size+variation)/2,size+variation)
		if not Rect2i(1,1,DungeonGenerator.WIDTH-2,DungeonGenerator.HEIGHT-2).encloses(largest):
			check.fail(path + ".size", "Room including +/-2 size variation must fit inside grid border", room.size)
		rects[room.id] = Rect2i(center-(size-variation)/2,size-variation)
		rooms[room.id] = center
	require_ids(rooms, DungeonProgress.ROOM_IDS, "rooms")
	var connections := {}
	for i in data.links.size():
		var path := "links[%d]" % i
		var link: Variant = data.links[i]
		if not link is Array or link.size() != 2:
			check.fail(path, "Expected two room IDs", link)
			continue
		if not link[0] is String or not link[1] is String or not rooms.has(link[0]) or not rooms.has(link[1]):
			check.fail(path, "Missing room reference", link)
			continue
		var key: String = "|".join([link[0],link[1]] if link[0] < link[1] else [link[1],link[0]])
		if link[0] == link[1] or connections.has(key): check.fail(path, "Self/duplicate link is invalid", link)
		connections[key] = true
		if "secret" in link and link != ["cistern","secret"]:
			check.fail(path, "Generator 1 secret branch must run cistern -> secret", link)
	var point_kinds := {"vault_exit":"exit","vault_font":"font","water_memory":"memory","root_memory":"memory","star_chart":"chest","amber_seed":"chest","shortcut_lever":"lever","shortcut_gate":"gate","secret_gate":"secret_gate"}
	var points := {}
	for i in data.points.size():
		var path := "points[%d]" % i
		var point: Variant = data.points[i]
		if not check.fields(point, path, {"id":"id","kind":"id","name":"text","tile":"array"}): continue
		unique_id(point.id, path + ".id", points, point_kinds.keys())
		if point_kinds.has(point.id): check.enum_value(point.kind, path + ".kind", [point_kinds[point.id]])
		pair(point.tile, path + ".tile", 1, DungeonGenerator.WIDTH-2, DungeonGenerator.HEIGHT-2)
		if point.kind in ["memory","chest"] and (not discoveries is Dictionary or not discoveries.has(point.id)):
			check.fail(path + ".id", "Missing discovery reference in data/discoveries.json", point.id)
		points[point.id] = true
	require_ids(points, point_kinds.keys(), "points")
	var enemies := {}
	var required_enemies: Array[String] = []
	for i in 7: required_enemies.append("vault_guard_%d" % i)
	for i in data.encounters.size():
		var path := "encounters[%d]" % i
		var enemy: Variant = data.encounters[i]
		if not check.fields(enemy, path, {"id":"id","kind":"id","tile":"array"}): continue
		unique_id(enemy.id, path + ".id", enemies, required_enemies)
		check.enum_value(enemy.kind, path + ".kind", ["wolf","wisp","kobold"])
		if not content is Dictionary or not content.get("enemies") is Dictionary or not content.enemies.has(enemy.kind):
			check.fail(path + ".kind", "Missing enemy reference in data/content.json", enemy.kind)
		pair(enemy.tile, path + ".tile", 2, DungeonGenerator.WIDTH-3, DungeonGenerator.HEIGHT-3)
		enemies[enemy.id] = true
	require_ids(enemies, required_enemies, "encounters")
	if check.errors.is_empty(): geometry(data, rooms, rects)
	return check.errors

func pair(value: Array, path: String, low: int, high_x: int, high_y: int) -> bool:
	if value.size() != 2 or not check.number(value[0],[low,high_x,true]) or not check.number(value[1],[low,high_y,true]):
		check.fail(path, "Expected integer pair within [%d..%d, %d..%d]" % [low,high_x,low,high_y], value)
		return false
	return true

func unique_id(id: String, path: String, seen: Dictionary, allowed: Array) -> void:
	if seen.has(id): check.fail(path, "Duplicate ID", id)
	if not id in allowed: check.fail(path, "Unsupported persistent generator-1 ID; requires explicit migration", id)
	seen[id] = true

func require_ids(seen: Dictionary, required: Array, path: String) -> void:
	for id in required:
		if not seen.has(id): check.fail(path, "Missing required ID " + id, seen.keys())

func geometry(data: Dictionary, rooms: Dictionary, rects: Dictionary) -> void:
	# The smallest rooms are a subset of every possible seeded layout. Corridors
	# and basins use the actual generator primitives, not an independent topology.
	var tiles := PackedInt32Array()
	tiles.resize(DungeonGenerator.WIDTH*DungeonGenerator.HEIGHT)
	for rect in rects.values():
		for y in range(rect.position.y,rect.end.y):
			for x in range(rect.position.x,rect.end.x): tiles[y*DungeonGenerator.WIDTH+x] = DungeonGenerator.Tile.FLOOR
	for link in data.links:
		DungeonGenerator.carve(tiles, DungeonGenerator.SECRET_JOIN if link[1] == "secret" else rooms[link[0]], rooms[link[1]])
	for basin in DungeonGenerator.BASINS:
		for y in range(basin.position.y,basin.end.y):
			for x in range(basin.position.x,basin.end.x): tiles[y*DungeonGenerator.WIDTH+x] = DungeonGenerator.Tile.POOL
	var world := {"tiles":tiles,"spawn":WorldGenerator.center(DungeonGenerator.SPAWN)}
	if not DungeonGenerator.navigable(world,DungeonGenerator.SPAWN,true,true):
		check.fail("rooms", "Spawn must be walkable for every size variation", DungeonGenerator.SPAWN)
		return
	var reached := DungeonGenerator.reachable(world,true,true)
	for id in rooms:
		if not reached.has(rooms[id]): check.fail("links", "Room disconnected from spawn", id)
	for i in data.points.size():
		var point: Dictionary = data.points[i]
		var cell := Vector2i(point.tile[0],point.tile[1])
		if not reached.has(cell): check.fail("points[%d].tile" % i, "Point must be reachable in every size variation (gates open)", point.tile)
		if point.kind in ["gate","secret_gate"] and cell != DungeonGenerator.gate_cells(point.id)[1]:
			check.fail("points[%d].tile" % i, "Gate must match generator-1 collision cells", point.tile)
	for i in data.encounters.size():
		var point: Array = data.encounters[i].tile
		for dy in range(-1,2):
			for dx in range(-1,2):
				if not reached.has(Vector2i(point[0]+dx,point[1]+dy)):
					check.fail("encounters[%d].tile" % i, "All +/-1 spawn jitter must be on reachable floor", point)
	for cell in [SourceStory.SITE_CELL, SourceStory.GUARDIAN_CELL]:
		if not reached.has(cell) or not rects.sanctum.has_point(cell):
			check.fail("rooms", "Sanctum must contain the reachable source site and guardian for every variation", cell)
