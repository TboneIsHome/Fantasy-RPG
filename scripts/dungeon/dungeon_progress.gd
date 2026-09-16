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

func visit(id: String) -> bool:
	if id not in ROOM_IDS or id in visited: return false
	visited.append(id)
	return true

func remember(id: String) -> bool:
	if id not in MEMORY_IDS or id in memories: return false
	memories.append(id)
	return true

func collect(id: String) -> bool:
	if id not in RELIC_IDS or id in relics: return false
	if id == "amber_seed" and not secret_open: return false
	relics.append(id)
	return true

func open_shortcut() -> bool:
	if shortcut_open: return false
	shortcut_open = true
	return true

func open_secret() -> bool:
	if secret_open or "water_memory" not in memories: return false
	secret_open = true
	return true

func report_chart() -> bool:
	if reported or "star_chart" not in relics: return false
	reported = true
	return true

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
