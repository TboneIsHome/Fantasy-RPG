class_name DiscoveryBook
extends RefCounted
static var _entries: Dictionary = {}

static func entries() -> Dictionary:
	if _entries.is_empty():
		_entries=JSON.parse_string(FileAccess.get_file_as_string("res://data/discoveries.json"))
	return _entries

static func known(run: RunState) -> Array[String]:
	var ids: Array[String]=[]
	for id in entries():
		if id in run.discoveries or id in run.vault.memories or id in run.vault.relics:
			ids.append(id)
	return ids
