class_name SaveSystem
extends RefCounted

const VERSION := 1
const DEFAULT_PATH := "user://lichtpfad_v1.json"
const LIGHTS := ["light_0","light_1","light_2"]
const MAX_BYTES := 1048576

static func snapshot(run: RunState, player: MagePlayer, settings: Dictionary) -> Dictionary:
	return {"save_version":VERSION,"generator_version":WorldGenerator.VERSION,
		"run":run.serialize(),"player":{"x":player.position.x,"y":player.position.y,
		"hp":player.vitals.hp,"mana":player.vitals.mana,"stamina":player.vitals.stamina},
		"settings":settings.duplicate()}

static func number_in(value: Variant, low: float, high: float) -> bool:
	return (value is float or value is int) and is_finite(float(value)) and float(value)>=low and float(value)<=high

static func valid_list(value: Variant, allowed: Array) -> bool:
	if not value is Array or value.size()>allowed.size():
		return false
	var seen := {}
	for item in value:
		if not item is String or not item in allowed or seen.has(item):
			return false
		seen[item] = true
	return true

static func validate(data: Variant) -> String:
	if not data is Dictionary:
		return "Der Spielstand ist beschädigt."
	if data.get("save_version") != VERSION or data.get("generator_version") != WorldGenerator.VERSION:
		return "Dieser Spielstand gehört zu einer anderen Speicher- oder Generatorversion."
	if not data.get("run") is Dictionary or not data.get("player") is Dictionary or not data.get("settings") is Dictionary:
		return "Im Spielstand fehlen notwendige Daten."
	var run: Dictionary = data.run
	if not run.get("world_seed") is String or run.world_seed.strip_edges().is_empty() or run.world_seed.length()>64:
		return "Der Welt-Seed ist ungültig."
	var enemy_ids: Array = []
	for i in range(1,4):
		for j in 3:
			enemy_ids.append("guard_%d_%d" % [i,j])
	for pair in [["active_lights",LIGHTS],["discoveries",["camp"]+LIGHTS],["defeated",enemy_ids],["learned",Content.section("skills").keys()]]:
		if not valid_list(run.get(pair[0]),pair[1]):
			return "Eine Liste im Spielstand ist ungültig: "+pair[0]
	for key in ["xp","level","skill_points","motes"]:
		if not number_in(run.get(key),1 if key=="level" else 0,10000) or float(run[key])!=floor(float(run[key])):
			return "Ungültiger Fortschrittswert: "+key
	if run.xp>=run.level*60 or run.learned.size()+run.skill_points!=run.level-1:
		return "Stufe, Erfahrung und Talentpunkte widersprechen sich."
	if not number_in(run.get("time_of_day"),0,1) or not run.get("quest_accepted") is bool or not run.get("quest_complete") is bool:
		return "Zeit oder Auftragsstatus sind ungültig."
	if run.quest_complete and run.active_lights.size()!=3:
		return "Auftrag und aktivierte Lichter widersprechen sich."
	var player: Dictionary = data.player
	for pair in [["x",0,WorldGenerator.WIDTH*16],["y",0,WorldGenerator.HEIGHT*16],["hp",0.01,100],["mana",0,100],["stamina",0,100]]:
		if not number_in(player.get(pair[0]),pair[1],pair[2]):
			return "Ungültiger Spielerwert: "+pair[0]
	if not data.settings.get("shake") is bool or not number_in(data.settings.get("volume"),0,1):
		return "Die gespeicherten Einstellungen sind ungültig."
	return ""

static func write(data: Dictionary, path: String = DEFAULT_PATH) -> String:
	var error := validate(data)
	if not error.is_empty():
		return error
	var temporary := path+".tmp"
	var file := FileAccess.open(temporary,FileAccess.WRITE)
	if file==null:
		return "Spielstand konnte nicht geschrieben werden."
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	var backup := path+".bak"
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup) and DirAccess.remove_absolute(backup)!=OK:
			return "Die Sicherung konnte nicht ersetzt werden."
		if DirAccess.rename_absolute(path,backup)!=OK:
			return "Der bisherige Spielstand konnte nicht gesichert werden."
	if DirAccess.rename_absolute(temporary,path)!=OK:
		if FileAccess.file_exists(backup):
			DirAccess.rename_absolute(backup,path)
		return "Speichern fehlgeschlagen; der vorige Stand wurde beibehalten."
	return ""

static func read_one(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"error":"Noch kein Spielstand vorhanden."}
	var file := FileAccess.open(path,FileAccess.READ)
	if file==null or file.get_length()>MAX_BYTES:
		return {"error":"Spielstand ist unlesbar oder unerwartet groß."}
	var parser := JSON.new()
	if parser.parse(file.get_as_text())!=OK:
		return {"error":"Der Spielstand ist beschädigt."}
	var data = parser.data
	var error := validate(data)
	return {"error":error} if not error.is_empty() else {"data":data,"error":""}

static func read(path: String = DEFAULT_PATH) -> Dictionary:
	var result := read_one(path)
	if result.error.is_empty():
		return result
	# Unsupported versions are intentionally rejected, never silently downgraded.
	if "Version" in result.error or "version" in result.error:
		return result
	var backup := read_one(path+".bak")
	if backup.error.is_empty():
		backup["notice"] = "Der letzte gesicherte Speicherpunkt wurde wiederhergestellt."
		return backup
	return result
