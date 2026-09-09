class_name RunState
extends RefCounted

signal changed
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

func add_xp(amount: int) -> void:
	xp += maxi(0, amount)
	while xp >= level * 60:
		xp -= level * 60
		level += 1
		skill_points += 1
	changed.emit()

func learn(id: String) -> bool:
	if skill_points <= 0 or id in learned or not Content.section("skills").has(id):
		return false
	learned.append(id)
	skill_points -= 1
	changed.emit()
	return true

func discover(id: String) -> bool:
	if id in discoveries:
		return false
	discoveries.append(id)
	changed.emit()
	return true

func activate_light(id: String) -> bool:
	if id in active_lights:
		return false
	active_lights.append(id)
	add_xp(20)
	return true

func serialize() -> Dictionary:
	return {"world_seed":world_seed, "active_lights":active_lights.duplicate(),
		"defeated":defeated.duplicate(), "discoveries":discoveries.duplicate(),
		"learned":learned.duplicate(), "xp":xp, "level":level, "skill_points":skill_points,
		"motes":motes, "quest_accepted":quest_accepted, "quest_complete":quest_complete,
		"time_of_day":time_of_day}

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
	return state
