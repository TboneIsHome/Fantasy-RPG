class_name CombatStats
extends RefCounted
## A defense input snapshot. Health remains with Vitals/the actor.
var protection: float
var stability: float
var resistances: Dictionary

func _init(guard: float = 0, resist: Dictionary = {}, balance: float = 0) -> void:
	protection = guard
	stability = balance
	resistances = resist.duplicate(true)
	resistances.make_read_only()

static func from_definition(data: Dictionary) -> CombatStats:
	return CombatStats.new(float(data.protection), data.resistances, float(data.stability))
