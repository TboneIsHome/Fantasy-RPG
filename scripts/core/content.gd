class_name Content
extends RefCounted

static var _cache: Dictionary = {}

static func all() -> Dictionary:
	if _cache.is_empty():
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/content.json"))
		assert(parsed is Dictionary, "content.json is missing or invalid")
		_cache = parsed
	return _cache

static func section(key: String) -> Dictionary:
	return all().get(key, {})
