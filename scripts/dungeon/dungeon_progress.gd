class_name DungeonProgress
extends RefCounted
## Persistent state of this place; deliberately independent of the active scene.
const ROOM_IDS := ["threshold","cistern","observatory","garden","archive","sanctum","secret"]
const MEMORY_IDS := ["water_memory","root_memory"]
const RELIC_IDS := ["star_chart","amber_seed"]
var visited: Array[String] = []
var memories: Array[String] = []
var relics: Array[String] = []
var shortcut_open: bool = false
var secret_open: bool = false
var reported: bool = false

func serialize() -> Dictionary:
	return {"visited":visited.duplicate(),"memories":memories.duplicate(),"relics":relics.duplicate(),"shortcut_open":shortcut_open,"secret_open":secret_open,"reported":reported}

static func restore(data: Dictionary) -> DungeonProgress:
	var progress := DungeonProgress.new()
	progress.visited.assign(data.visited)
	progress.memories.assign(data.memories)
	progress.relics.assign(data.relics)
	progress.shortcut_open=data.shortcut_open
	progress.secret_open=data.secret_open
	progress.reported=data.reported
	return progress
