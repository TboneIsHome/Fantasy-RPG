class_name DefenseOutcome
extends RefCounted
## Already decided by the caller. This class never detects a dodge/block/parry.
var kind: StringName
var damage_scale: float
var impact_scale: float

func _init(outcome: StringName = &"hit", damage: float = 1, impact: float = 1) -> void:
	kind = outcome
	damage_scale = damage
	impact_scale = impact

static func hit() -> DefenseOutcome:
	return DefenseOutcome.new()

static func block(damage: float, impact: float) -> DefenseOutcome:
	return DefenseOutcome.new(&"block", damage, impact)

static func parry() -> DefenseOutcome:
	return DefenseOutcome.new(&"parry", 0, 0)

static func evade() -> DefenseOutcome:
	return DefenseOutcome.new(&"evade", 0, 0)

static func miss() -> DefenseOutcome:
	return DefenseOutcome.new(&"miss", 0, 0)
