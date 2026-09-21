class_name ContentValidator
extends RefCounted
## Pure, once-at-load validation. Never changes input or publishes partial data.
const POS := [0.000001, 10000]
const NONNEG := [0, 10000]
const COUNT := [0, 10000, true]
const UNIT := [0, 1]
var errors: Array[String] = []
var file: String = "data/content.json"

static func validate_bundle(content: Variant, vault: Variant, discoveries: Variant) -> Array[String]:
	var check := ContentValidator.new()
	check.content_rules(content)
	var vault_check := VaultContentValidator.new()
	check.errors.append_array(vault_check.validate(vault, content, discoveries))
	check.discovery_rules(discoveries)
	return check.errors

func fail(path: String, expected: String, received: Variant) -> void:
	errors.append("%s\n%s\n%s\nReceived: %s" % [file, path, expected, str(received).left(180)])

func number(value: Variant, bounds: Array) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= bounds[0] and value <= bounds[1] and (bounds.size() < 3 or float(value) == floorf(float(value)))

func id_valid(value: Variant) -> bool:
	if not value is String or value.is_empty() or value.length() > 64: return false
	if not value[0] in "abcdefghijklmnopqrstuvwxyz": return false
	for character in value:
		if not character in "abcdefghijklmnopqrstuvwxyz0123456789_": return false
	return true

func fields(value: Variant, path: String, schema: Dictionary) -> bool:
	var before := errors.size()
	if not value is Dictionary:
		fail(path, "Expected object", value)
		return false
	for key in schema:
		var field: String = path + "." + key if not path.is_empty() else str(key)
		if not value.has(key):
			fail(field, "Missing required field", "<missing>")
			continue
		var rule: Variant = schema[key]
		var item: Variant = value[key]
		if rule is Array:
			if not number(item, rule):
				fail(field, "Expected %s in [%s, %s], finite" % ["integer" if rule.size() == 3 else "number", rule[0], rule[1]], item)
		elif rule == "object" and not item is Dictionary:
			fail(field, "Expected object", item)
		elif rule == "array" and not item is Array:
			fail(field, "Expected array", item)
		elif rule == "text" and (not item is String or item.strip_edges().is_empty()):
			fail(field, "Expected non-empty text", item)
		elif rule == "id" and not id_valid(item):
			fail(field, "Expected ID [a-z][a-z0-9_]* (1–64 characters)", item)
	for key in value:
		if not schema.has(key): fail(path + "." + str(key), "Unknown field", value[key])
	return errors.size() == before

func enum_value(value: Variant, path: String, choices: Array) -> void:
	if not value in choices: fail(path, "Expected one of " + str(choices), value)

func definition(value: Variant, path: String, schema: Dictionary, tokens: Array = []) -> void:
	if not fields(value, path, schema): return
	if value.has("description"):
		for token in tokens:
			if not ("{" + str(token) + "}") in value.description:
				fail(path + ".description", "Missing numeric token {" + str(token) + "}", value.description)
		var pattern := RegEx.new()
		pattern.compile("\\{([^{}]+)\\}")
		var remaining: String = value.description
		for token in pattern.search_all(value.description):
			var key := token.get_string(1)
			if not value.has(key) or not number(value[key], NONNEG):
				fail(path + ".description", "Unknown/non-numeric description token " + token.get_string(), value.description)
			remaining = remaining.replace(token.get_string(), "")
		if "{" in remaining or "}" in remaining:
			fail(path + ".description", "Unmatched description token braces", value.description)

func content_rules(data: Variant) -> void:
	var sections := {}
	for key in ["player", "spells", "enemies", "skills", "world", "quest", "source_quest", "relics", "progression", "combat"]:
		sections[key] = "object"
	if not fields(data, "", sections): return
	fields(data.player, "player", {"hp":POS,"mana":POS,"stamina":POS,"speed":POS,"dash_name":"text","dash_speed":POS,"dash_duration":POS,"dash_cost":NONNEG,"dash_cooldown":POS,"mana_regen":NONNEG,"stamina_regen":NONNEG,"mana_regen_delay":NONNEG,"damage_invulnerability":NONNEG,"hindered_speed":UNIT,"knockback":NONNEG,"knockback_decay":POS,"respawn_invulnerability":NONNEG})
	fields(data.world, "world", {"day_seconds":POS})
	fields(data.progression, "progression", {"xp_per_level":[1,10000,true],"enemy_motes":COUNT})
	fields(data.combat, "combat", {"enemy_projectile_speed":POS,"enemy_projectile_range":POS,"enemy_knockback":NONNEG,"enemy_knockback_decay":POS,"enemy_hit_stop":NONNEG,"camp_safe_radius":NONNEG})
	if fields(data.quest, "quest", {"id":"id","title":"text","reward":"text","light_xp":COUNT,"reward_xp":COUNT}):
		enum_value(data.quest.id, "quest.id", ["lights"])
	if fields(data.spells, "spells", {"bolt":"object","nova":"object"}):
		fields(data.spells.bolt, "spells.bolt", {"name":"text","cost":NONNEG,"cooldown":POS,"damage":NONNEG,"speed":POS,"range":POS,"shatter_bonus":NONNEG})
		fields(data.spells.nova, "spells.nova", {"name":"text","cost":NONNEG,"cooldown":POS,"damage":NONNEG,"radius":POS,"range":POS,"slow_duration":NONNEG,"slow_multiplier":UNIT})
	if fields(data.skills, "skills", {"echo":"object","flow":"object","bloom":"object"}):
		definition(data.skills.echo, "skills.echo", {"name":"text","description":"text","chain_range":POS,"chain_damage":NONNEG})
		definition(data.skills.flow, "skills.flow", {"name":"text","description":"text","mana_refund":NONNEG}, ["mana_refund"])
		definition(data.skills.bloom, "skills.bloom", {"name":"text","description":"text","healing":NONNEG}, ["healing"])
	if fields(data.enemies, "enemies", {"wolf":"object","wisp":"object","kobold":"object","guardian":"object"}):
		for id in data.enemies:
			var schema := {"name":"text","hp":POS,"speed":NONNEG,"damage":NONNEG,"xp":COUNT,"aggro":POS,"leash":POS,"windup":POS,"recovery":POS,"mode":"id"}
			var modes := {"wolf":"lunge","wisp":"ranged","kobold":"thorns","guardian":"guardian"}
			if id != "guardian": schema.attack_range = POS
			if id == "wolf": schema.merge({"lunge_duration":POS,"lunge_speed":POS,"lunge_slow_multiplier":UNIT,"hit_range":POS})
			if id == "kobold": schema.merge({"thorn_radius":POS,"thorn_duration":POS,"thorn_slow":NONNEG,"thorn_interval":POS})
			if id == "guardian": schema.merge({"slam_radius":POS,"fan_windup":POS,"fan_damage":NONNEG,"fan_count":[2,64,true],"fan_spread":[0,PI],"awaken_delay":NONNEG})
			if fields(data.enemies[id], "enemies." + id, schema):
				enum_value(data.enemies[id].mode, "enemies." + id + ".mode", [modes[id]])
				if data.enemies[id].leash < data.enemies[id].aggro:
					fail("enemies." + id + ".leash", "Expected leash >= aggro", data.enemies[id].leash)
	# Only the existing relic ID is save-compatible with this source outcome.
	if fields(data.relics, "relics", {"source_heart":"object"}):
		definition(data.relics.source_heart, "relics.source_heart", {"name":"text","description":"text","frost_refund":NONNEG}, ["frost_refund"])
	if fields(data.source_quest, "source_quest", {"reward_xp":COUNT,"reward_item":"id","ore_motes":COUNT}):
		if not data.relics.has(data.source_quest.reward_item):
			fail("source_quest.reward_item", "Missing relic reference", data.source_quest.reward_item)

func discovery_rules(data: Variant) -> void:
	file = "data/discoveries.json"
	var schema := {}
	for id in ["camp","vault_entrance","source_binding","source_restored","source_broken"] + RunState.LIGHT_IDS + DungeonProgress.MEMORY_IDS + DungeonProgress.RELIC_IDS:
		schema[id] = "object"
	if not fields(data, "", schema): return
	for id in data:
		fields(data[id], id, {"title":"text","text":"text"})
