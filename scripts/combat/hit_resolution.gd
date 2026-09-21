class_name HitResolution
extends RefCounted
## Calculation result, never a command to apply again or a saved health value.
var resolved: bool = false
var contact: bool = false
var reason: StringName
var outcome: StringName
var damage: float = 0
var impact: float = 0
var damage_type: StringName
var immune: bool = false
var secondary: Dictionary = {}
var hit_id: int = 0
var action_id: StringName
var source_id: String
var target_id: int = 0
var generation: int = -1

static func rejected(code: StringName) -> HitResolution:
	var result := HitResolution.new()
	result.reason = code
	return result
