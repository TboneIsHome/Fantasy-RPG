class_name CombatProfiles
extends RefCounted
## Adapter for the existing spells/attacks, not a weapon or magic catalog.
## The previous reaction magnitudes remain their single authoritative sources.

static func player_attack(amount: float, type_key: StringName, information: Dictionary = {}) -> AttackProfile:
	return AttackProfile.new(amount, type_key, float(Content.section("combat").enemy_knockback), information)

static func hostile_attack(amount: float, type_key: StringName = &"", information: Dictionary = {}) -> AttackProfile:
	var key := StringName(Content.section("combat").default_damage_type) if type_key.is_empty() else type_key
	return AttackProfile.new(amount, key, float(Content.section("player").knockback), information)
