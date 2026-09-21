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
	if hp <= 0 or invulnerable > 0:
		return false
	hp = maxf(0, hp - maxf(0, amount))
	invulnerable = float(Content.section("player").damage_invulnerability)
	damaged.emit(amount)
	if hp <= 0:
		died.emit()
	return true

func refill() -> void:
	hp = maxf(hp, maximum("hp"))
	mana = maxf(mana, maximum("mana"))
	stamina = maxf(stamina, maximum("stamina"))
	invulnerable = 0
	mana_delay = 0
