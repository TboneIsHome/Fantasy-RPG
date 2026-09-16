class_name RunState
extends RefCounted

signal changed
const LIGHT_IDS := ["light_0", "light_1", "light_2"]
var world_seed: String = "LICHTERHAIN"
var active_lights: Array[String] = []
var defeated: Array[String] = []
var discoveries: Array[String] = []
var learned: Array[String] = []
var xp: int = 0
var level: int = 1
var skill_points: int = 0
var motes: int = 0
var quest_accepted: bool = false
var quest_complete: bool = false
var time_of_day: float = 0.22
var region: String = "forest"
var vault := DungeonProgress.new()
var source := SourceQuest.new()
var inventory := RelicInventory.new()

func advance_time(delta: float) -> void:
	time_of_day=fposmod(time_of_day+delta/float(Content.section("world").day_seconds),1)

func add_xp(amount: int) -> void:
	if amount <= 0: return
	_add_xp(amount)
	changed.emit()

# Compound actions publish only after every related field and reward is ready.
func _add_xp(amount: int) -> void:
	xp += maxi(0, amount)
	while xp >= level * 60:
		xp -= level * 60
		level += 1
		skill_points += 1

func learn(id: String) -> bool:
	if skill_points <= 0 or id in learned or not Content.section("skills").has(id):
		return false
	learned.append(id)
	skill_points -= 1
	changed.emit()
	return true

func discover(id: String) -> bool:
	if id in discoveries or (id not in LIGHT_IDS and id not in ["camp", "vault_entrance"]):
		return false
	discoveries.append(id)
	changed.emit()
	return true

func activate_light(id: String) -> bool:
	if id not in LIGHT_IDS or id in active_lights:
		return false
	active_lights.append(id)
	add_xp(20)
	return true

func accept_quest() -> bool:
	if quest_accepted: return false
	quest_accepted = true
	changed.emit()
	return true

func complete_quest() -> bool:
	if quest_complete: return false
	for id in LIGHT_IDS:
		if id not in active_lights: return false
	quest_complete = true
	quest_accepted = true
	_add_xp(45)
	changed.emit()
	return true

func defeat_enemy(id: String, kind: String) -> bool:
	if id in defeated or not Content.section("enemies").has(kind) or kind == "guardian": return false
	# Existing generator-1 identities; no scene node or terrain generation is needed.
	var known := false
	for i in range(1, LIGHT_IDS.size() + 1):
		for j in 3:
			if id == "guard_%d_%d" % [i,j] and kind == ("wisp" if j == 2 else "wolf"): known = true
	for encounter in DungeonGenerator.content().encounters:
		if id == encounter.id and kind == encounter.kind: known = true
	if not known: return false
	defeated.append(id)
	motes += 1
	_add_xp(int(Content.section("enemies")[kind].xp))
	changed.emit()
	return true

func spend_motes(amount: int) -> bool:
	if amount <= 0 or motes < amount: return false
	motes -= amount
	changed.emit()
	return true

func visit_room(id: String) -> bool:
	if not vault.visit(id): return false
	changed.emit()
	return true

func unlock_memory(id: String) -> bool:
	if not vault.remember(id): return false
	_add_xp(int(DungeonGenerator.content().memory_xp))
	changed.emit()
	return true

func collect_vault_relic(id: String) -> bool:
	if not vault.collect(id): return false
	var data := DungeonGenerator.content()
	_add_xp(int(data.chart_xp if id == "star_chart" else data.seed_xp))
	changed.emit()
	return true

func open_vault_shortcut() -> bool:
	if not vault.open_shortcut(): return false
	changed.emit()
	return true

func open_vault_secret() -> bool:
	if not vault.open_secret(): return false
	changed.emit()
	return true

func report_vault_chart() -> bool:
	if not vault.report_chart(): return false
	changed.emit()
	return true

func inspect_source() -> bool:
	if not quest_complete or not source.inspect(): return false
	changed.emit()
	return true

func prepare_source_challenge() -> bool:
	if not quest_complete or not source.seen or not source.resolution.is_empty(): return false
	if source.reset_alignment(): changed.emit()
	return true

func align_source(sign_id: String) -> bool:
	if not quest_complete or not source.seen or source.guardian_defeated: return false
	if not source.resolution.is_empty() or not inventory.can_grant(Content.section("source_quest").reward_item): return false
	var before := source.alignment
	var correct := source.align(sign_id, vault)
	if correct and source.alignment == SourceQuest.SIGNS.size():
		# No signal or await exposes alignment=3 or an outcome without its reward.
		source.resolve("restored", vault)
		_grant_source_reward()
	if source.alignment != before or not source.resolution.is_empty(): changed.emit()
	return correct

func defeat_source_guardian() -> bool:
	if not quest_complete or not inventory.can_grant(Content.section("source_quest").reward_item): return false
	if not source.defeat_guardian(vault): return false
	_grant_source_reward()
	changed.emit()
	return true

func _grant_source_reward() -> void:
	var reward := Content.section("source_quest")
	inventory.grant(reward.reward_item)
	_add_xp(int(reward.reward_xp))

func harvest_source_ore() -> bool:
	if not source.harvest_ore(): return false
	motes += int(Content.section("source_quest").ore_motes)
	changed.emit()
	return true

func report_source() -> bool:
	if source.resolution.is_empty(): return false
	var updated := source.report_outcome()
	updated = vault.report_chart() or updated
	if updated: changed.emit()
	return updated

func equip_relic(id: String) -> bool:
	if not inventory.equip(id): return false
	changed.emit()
	return true

func serialize() -> Dictionary:
	return {"world_seed":world_seed, "active_lights":active_lights.duplicate(),
		"defeated":defeated.duplicate(), "discoveries":discoveries.duplicate(),
		"learned":learned.duplicate(), "xp":xp, "level":level, "skill_points":skill_points,
		"motes":motes, "quest_accepted":quest_accepted, "quest_complete":quest_complete,
		"time_of_day":time_of_day,"region":region,"vault":vault.serialize(),
		"source":source.serialize(),"inventory":inventory.serialize()}

static func restore(data: Dictionary) -> RunState:
	var state := RunState.new()
	state.world_seed = data.world_seed
	state.active_lights.assign(data.active_lights)
	state.defeated.assign(data.defeated)
	state.discoveries.assign(data.discoveries)
	state.learned.assign(data.learned)
	state.xp = int(data.xp)
	state.level = int(data.level)
	state.skill_points = int(data.skill_points)
	state.motes = int(data.motes)
	state.quest_accepted = data.quest_accepted
	state.quest_complete = data.quest_complete
	state.time_of_day = float(data.time_of_day)
	state.region=data.get("region","forest")
	state.vault=DungeonProgress.restore(data.vault) if data.has("vault") else DungeonProgress.new()
	state.source=SourceQuest.restore(data.source) if data.has("source") else SourceQuest.new()
	state.inventory=RelicInventory.restore(data.inventory) if data.has("inventory") else RelicInventory.new()
	return state
