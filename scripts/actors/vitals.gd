class_name Vitals
extends RefCounted

signal damaged(amount: float)
signal died
var hp: float = 100
var mana: float = 100
var stamina: float = 100
var mana_delay: float = 0
var invulnerable: float = 0

func tick(delta: float) -> void:
	var data := Content.section("player")
	invulnerable = maxf(0, invulnerable - delta)
	mana_delay = maxf(0, mana_delay - delta)
	if hp <= 0:
		return
	if mana_delay <= 0:
		mana = minf(float(data.mana), mana + float(data.mana_regen) * delta)
	stamina = minf(float(data.stamina), stamina + float(data.stamina_regen) * delta)

func spend_mana(amount: float) -> bool:
	if hp <= 0 or mana < amount:
		return false
	mana -= amount
	mana_delay = 0.65
	return true

func damage(amount: float) -> bool:
	if hp <= 0 or invulnerable > 0:
		return false
	hp = maxf(0, hp - maxf(0, amount))
	invulnerable = 0.65
	damaged.emit(amount)
	if hp <= 0:
		died.emit()
	return true

func refill() -> void:
	hp = float(Content.section("player").hp)
	mana = float(Content.section("player").mana)
	stamina = float(Content.section("player").stamina)
	invulnerable = 0
	mana_delay = 0
