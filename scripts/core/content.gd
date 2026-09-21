class_name Content
extends RefCounted

static var _cache: Dictionary = {}
static var _vault: Dictionary = {}
static var _discoveries: Dictionary = {}
static var _attempted: bool = false
static var _errors: Array[String] = []

static func read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"errors":[path + "\n$\nCannot open file (error %d)" % FileAccess.get_open_error()]}
	var parser := JSON.new()
	var result := parser.parse(file.get_as_text())
	if result != OK:
		return {"errors":[path + "\n$ (line %d)\nInvalid JSON: %s" % [parser.get_error_line(), parser.get_error_message()]]}
	return {"errors":[], "data":parser.data}

static func ensure_loaded() -> bool:
	if _attempted:
		return _errors.is_empty()
	_attempted = true
	var documents: Array = []
	for path in ["res://data/content.json", "res://data/vault.json", "res://data/discoveries.json"]:
		var result := read_json(path)
		_errors.append_array(result.errors)
		documents.append(result.get("data"))
	if _errors.is_empty():
		_errors = ContentValidator.validate_bundle(documents[0], documents[1], documents[2])
	if not _errors.is_empty():
		push_error(error_text())
		return false
	# Publish the whole validated bundle together. No partially usable content.
	for document in documents: _freeze(document)
	_cache = documents[0]
	_vault = documents[1]
	_discoveries = documents[2]
	return true

static func error_text() -> String:
	return "\n\n".join(_errors)

static func all() -> Dictionary:
	ensure_loaded()
	return _cache

static func section(key: String) -> Dictionary:
	return all().get(key, {})

static func vault() -> Dictionary:
	ensure_loaded()
	return _vault

static func discoveries() -> Dictionary:
	ensure_loaded()
	return _discoveries

static func description(definition: Dictionary) -> String:
	# Numeric text tokens are validated against fields in this very definition.
	var numbers := {}
	for key in definition:
		if definition[key] is float or definition[key] is int:
			numbers[key] = number_text(float(definition[key]))
	return str(definition.description).format(numbers)

static func number_text(value: float) -> String:
	return str(int(value)) if value == floorf(value) else str(value)

static func _freeze(value: Variant) -> void:
	if value is Dictionary:
		for child in value.values(): _freeze(child)
		value.make_read_only()
	elif value is Array:
		for child in value: _freeze(child)
		value.make_read_only()
