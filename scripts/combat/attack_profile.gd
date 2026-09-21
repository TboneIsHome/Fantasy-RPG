class_name AttackProfile
extends RefCounted
## Values for one confirmed contact. No trajectory, timing, actor or health state.
var damage: float
var impact: float
var damage_type: StringName
var secondary: Dictionary

func _init(raw_damage: float = 0, type_key: StringName = &"untyped", raw_impact: float = 0, information: Dictionary = {}) -> void:
	damage = raw_damage
	damage_type = type_key
	impact = raw_impact
	secondary = information.duplicate(true)
	secondary.make_read_only()
