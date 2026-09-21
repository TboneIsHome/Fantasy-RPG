class_name HitResolver
extends RefCounted
## Pure M06 mathematics. No nodes, health writes, clocks, effects or persistence.

static func resolve(attack: AttackProfile, stats: CombatStats, defense: DefenseOutcome) -> HitResolution:
	if attack == null or stats == null or defense == null:
		return HitResolution.rejected(&"missing_input")
	if attack.damage_type.is_empty() or not is_finite(attack.damage) or attack.damage < 0 or not is_finite(attack.impact) or attack.impact < 0:
		return HitResolution.rejected(&"invalid_attack")
	if not is_finite(stats.protection) or not is_finite(stats.stability):
		return HitResolution.rejected(&"invalid_stats")
	var resistance: Variant = stats.resistances.get(attack.damage_type, 0)
	if not (resistance is int or resistance is float) or not is_finite(float(resistance)):
		return HitResolution.rejected(&"invalid_resistance")
	if not defense.kind in [&"hit", &"block", &"parry", &"miss", &"evade"] or not is_finite(defense.damage_scale) or defense.damage_scale < 0 or not is_finite(defense.impact_scale) or defense.impact_scale < 0:
		return HitResolution.rejected(&"invalid_defense")
	if defense.kind == &"parry" and (defense.damage_scale != 0 or defense.impact_scale != 0):
		return HitResolution.rejected(&"invalid_parry_scales")
	var result := HitResolution.new()
	result.resolved = true
	result.outcome = defense.kind
	result.damage_type = attack.damage_type
	result.contact = not defense.kind in [&"miss", &"evade"]
	if not result.contact:
		return result
	result.immune = float(resistance) == 100
	var protection := 100.0 / (100.0 + maxf(0, stats.protection))
	var resistance_factor := 1.0 - clampf(float(resistance), -50, 90) / 100.0
	var stability := 100.0 / (100.0 + maxf(0, stats.stability))
	# Apply mitigation before amplification to avoid unnecessary intermediate overflow.
	var damage := 0.0 if result.immune else attack.damage * protection * resistance_factor * defense.damage_scale
	var impact := attack.impact * stability * defense.impact_scale
	if not is_finite(damage) or not is_finite(impact):
		return HitResolution.rejected(&"non_finite_result")
	result.damage = roundf(damage)
	if not result.immune and attack.damage > 0 and defense.damage_scale > 0:
		result.damage = maxf(1, result.damage)
	result.impact = roundf(impact)
	result.secondary = attack.secondary.duplicate(true)
	result.secondary.make_read_only()
	return result
