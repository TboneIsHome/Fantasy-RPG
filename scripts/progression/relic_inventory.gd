class_name RelicInventory
extends RefCounted
var owned: Array[String] = []
var equipped: String = ""

func grant(id: String) -> bool:
	if id in owned or not Content.section("relics").has(id):
		return false
	owned.append(id)
	if equipped.is_empty(): equipped=id
	return true

func equip(id: String) -> bool:
	if not id.is_empty() and id not in owned:
		return false
	if equipped==id:
		return false
	equipped=id
	return true

func frost_refund() -> float:
	return float(Content.section("relics")[equipped].frost_refund) if not equipped.is_empty() else 0.0

func serialize() -> Dictionary:
	return {"owned":owned.duplicate(),"equipped":equipped}

static func restore(data: Dictionary) -> RelicInventory:
	var bag := RelicInventory.new()
	bag.owned.assign(data.owned)
	bag.equipped=data.equipped
	return bag
