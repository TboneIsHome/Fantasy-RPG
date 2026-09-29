extends RefCounted
## Separate developer test data. Never mutates the production Content cache.
const PATH := "res://developer/presets.json"
var data: Dictionary = {}
var errors: Array[String] = []

func load_data() -> bool:
	var document := Content.read_json(PATH)
	errors.assign(document.errors)
	if errors.is_empty(): errors = validate(document.get("data"))
	if not errors.is_empty(): return false
	data = document.data
	freeze(data)
	return true

static func numeric(value: Variant, minimum: float, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= minimum and value <= maximum

static func validate(value: Variant) -> Array[String]:
	var issues: Array[String] = []
	if not value is Dictionary: return [PATH + " $: Expected object"]
	for section in ["players", "enemies", "probe", "scenarios"]:
		if not value.get(section) is Dictionary or value[section].is_empty(): issues.append(PATH + " " + section + ": Expected nonempty object")
	for section in ["actions", "waves"]:
		if not value.get(section) is Array or value[section].is_empty(): issues.append(PATH + " " + section + ": Expected nonempty array")
	if not issues.is_empty(): return issues
	if not numeric(value.get("version"),1,1): issues.append(PATH + " version: Expected 1")
	if not numeric(value.get("max_enemies"),1,16) or float(value.max_enemies) != floorf(float(value.max_enemies)): issues.append(PATH + " max_enemies: Expected integer 1..16")
	if not numeric(value.get("wave_delay"),0.1,10): issues.append(PATH + " wave_delay: Expected finite 0.1..10")
	for action in value.actions:
		if not action in ["bolt", "nova"]: issues.append(PATH + " actions: Unknown live ability " + str(action))
	for group in ["players", "enemies"]:
		for id in value[group]:
			var entry: Variant = value[group][id]
			var path: String = PATH + " " + group + "." + str(id)
			if not id is String or id.is_empty() or not entry is Dictionary:
				issues.append(path + ": Expected nonempty ID and object")
				continue
			if not entry.get("label") is String or entry.label.is_empty(): issues.append(path + ".label: Expected text")
			if group == "players":
				if not numeric(entry.get("distance"),20,220): issues.append(path + ".distance: Expected finite 20..220")
				if not entry.get("note") is String: issues.append(path + ".note: Expected text")
				if not entry.get("learned") is Array: issues.append(path + ".learned: Expected array")
				else:
					for skill in entry.learned:
						if not skill is String or not Content.section("skills").has(skill): issues.append(path + ".learned: Unknown skill " + str(skill))
			else:
				if not entry.get("kind") in ["wolf", "wisp", "kobold"]: issues.append(path + ".kind: Unknown enemy kind")
				if not entry.get("passive") is bool: issues.append(path + ".passive: Expected boolean")
				for field in ["hp", "protection", "stability"]:
					if not numeric(entry.get(field),1 if field=="hp" else 0,10000): issues.append(path + "." + field + ": Expected finite permitted test value")
	for id in value.scenarios:
		if not id in ["A01","A02","A03","A04","A05","A06","A07","A08","A09","A10","A11","A12"] or not value.scenarios[id] is String: issues.append(PATH + " scenarios: Unknown ID/label " + str(id))
	for field in ["startup","active","recovery","range","damage","impact"]:
		if not numeric(value.probe.get(field),0.001,1000): issues.append(PATH + " probe." + field + ": Expected finite 0.001..1000")
	if value.waves.size() > 8: issues.append(PATH + " waves: Maximum 8 waves")
	for index in value.waves.size():
		var wave: Variant = value.waves[index]
		var path := PATH + " waves[%d]" % index
		if not wave is Dictionary: issues.append(path + ": Expected object"); continue
		if not wave.get("enemies") is Array or wave.enemies.is_empty(): issues.append(path + ".enemies: Expected nonempty array")
		else:
			if numeric(value.get("max_enemies"),1,16) and wave.enemies.size() > value.max_enemies: issues.append(path + ".enemies: Exceeds arena limit")
			for id in wave.enemies:
				if not id is String or not value.enemies.has(id): issues.append(path + ".enemies: Unknown preset " + str(id))
		for field in ["hp_scale","damage_scale"]:
			if not numeric(wave.get(field),0.1,4): issues.append(path + "." + field + ": Expected finite 0.1..4")
	return issues

static func freeze(value: Variant) -> void:
	if value is Dictionary:
		for child in value.values(): freeze(child)
		value.make_read_only()
	elif value is Array:
		for child in value: freeze(child)
		value.make_read_only()
