class_name MageAbilities
extends RefCounted

var cooldowns: Dictionary = {"bolt":0.0, "nova":0.0, "dash":0.0}

static func definition(id: String) -> Dictionary:
	if id == "dash":
		var data := Content.section("player")
		return {"name":data.dash_name, "cost":data.dash_cost, "cooldown":data.dash_cooldown}
	return Content.section("spells").get(id, {})

func tick(delta: float) -> void:
	for key in cooldowns:
		cooldowns[key] = maxf(0, float(cooldowns[key]) - delta)

func cast(id: String, vitals: Vitals) -> bool:
	var data := definition(id) if id != "dash" else {}
	if data.is_empty() or float(cooldowns.get(id, 0)) > 0:
		return false
	if not vitals.spend_mana(float(data.cost)):
		return false
	cooldowns[id] = float(data.cooldown)
	return true

func dash(vitals: Vitals) -> bool:
	var data := Content.section("player")
	if cooldowns.dash > 0 or vitals.stamina < float(data.dash_cost) or vitals.hp <= 0:
		return false
	vitals.stamina -= float(data.dash_cost)
	cooldowns.dash = float(data.dash_cooldown)
	vitals.invulnerable = maxf(vitals.invulnerable, float(data.dash_duration))
	return true
