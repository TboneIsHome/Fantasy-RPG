class_name Vitals
extends RefCounted

signal damaged(amount: float)
signal died
var hp: float = maximum("hp")
var mana: float = maximum("mana")
var stamina: float = maximum("stamina")
var mana_delay: float = 0
var invulnerable: float = 0

static func maximum(resource: String) -> float:
	return float(Content.section("player").get(resource, 0))

static func replenished(current: float, amount: float, maximum_value: float) -> float:
	# Preserve imported over-cap resources. Replenishment can never reduce them.
	return current + minf(maxf(0, amount), maxf(0, maximum_value-current))

func restore_mana(amount: float) -> void:
	mana = replenished(mana, amount, maximum("mana"))

func heal(amount: float) -> void:
	hp = replenished(hp, amount, maximum("hp"))

func is_full() -> bool:
	return hp >= maximum("hp") and mana >= maximum("mana") and stamina >= maximum("stamina")

func tick(delta: float) -> void:
	var data := Content.section("player")
	invulnerable = maxf(0, invulnerable - delta)
	mana_delay = maxf(0, mana_delay - delta)
	if hp <= 0:
		return
	if mana_delay <= 0:
		restore_mana(float(data.mana_regen) * delta)
	stamina = replenished(stamina, float(data.stamina_regen) * delta, maximum("stamina"))

func spend_mana(amount: float) -> bool:
	if hp <= 0 or mana < amount:
		return false
	mana -= amount
	mana_delay = float(Content.section("player").mana_regen_delay)
	return true

func damage(amount: float) -> bool:
	# Compatibility entry for isolated Vitals callers. Each call is a new contact;
	# live attacks use an explicit HitInstance before applying this result.
	var defense := DefenseOutcome.evade() if invulnerable > 0 else DefenseOutcome.hit()
	var result := HitResolver.resolve(AttackProfile.new(amount,Content.section("combat").default_damage_type), CombatStats.from_definition(Content.section("player").defense), defense)
	return apply_hit(result)

func apply_hit(result: HitResolution) -> bool:
	if hp <= 0 or invulnerable > 0:
		return false
	if result == null or not result.resolved or not result.contact or result.outcome == &"parry":
		return false
	if result.damage <= 0: return true
	hp = maxf(0, hp - result.damage)
	invulnerable = float(Content.section("player").damage_invulnerability)
	damaged.emit(result.damage)
	if hp <= 0:
		died.emit()
	return true

func refill() -> void:
	hp = maxf(hp, maximum("hp"))
	mana = maxf(mana, maximum("mana"))
	stamina = maxf(stamina, maximum("stamina"))
	invulnerable = 0
	mana_delay = 0
