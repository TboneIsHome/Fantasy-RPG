class_name SaveSystem
extends RefCounted

const VERSION := 3
const DEFAULT_PATH := "user://lichtpfad_v1.json"
const LIGHTS := ["light_0","light_1","light_2"]
const MAX_BYTES := 1048576

static func snapshot(run: RunState, player: MagePlayer, settings: Dictionary) -> Dictionary:
	return {"save_version":VERSION,"generator_version":WorldGenerator.VERSION,"dungeon_version":DungeonGenerator.VERSION,
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
	if not (data.get("save_version")==1 or data.get("save_version")==2 or data.get("save_version")==VERSION) or data.get("generator_version") != WorldGenerator.VERSION:
		return "Dieser Spielstand gehört zu einer anderen Speicher- oder Generatorversion."
	if not data.get("run") is Dictionary or not data.get("player") is Dictionary or not data.get("settings") is Dictionary:
		return "Im Spielstand fehlen notwendige Daten."
	var run: Dictionary = data.run
	if not run.get("world_seed") is String or run.world_seed.strip_edges().is_empty() or run.world_seed.length()>64:
		return "Der Welt-Seed ist ungültig."
	var legacy: bool=data.save_version==1
	var enemy_ids: Array = []
	for i in range(1,4):
		for j in 3:
			enemy_ids.append("guard_%d_%d" % [i,j])
	if not legacy:
		for encounter in DungeonGenerator.content().encounters:
			enemy_ids.append(encounter.id)
	var discovery_ids: Array=["camp"]+LIGHTS
	if not legacy:
		discovery_ids.append("vault_entrance")
	for pair in [["active_lights",LIGHTS],["discoveries",discovery_ids],["defeated",enemy_ids],["learned",Content.section("skills").keys()]]:
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
	if not legacy:
		if data.get("dungeon_version")!=DungeonGenerator.VERSION:
			return "Dieser Spielstand gehört zu einer anderen Dungeonversion."
		if run.get("region") not in ["forest","vault"] or not run.get("vault") is Dictionary:
			return "Region oder Gruftfortschritt fehlen."
		var vault: Dictionary=run.vault
		for pair in [["visited",DungeonProgress.ROOM_IDS],["memories",DungeonProgress.MEMORY_IDS],["relics",DungeonProgress.RELIC_IDS]]:
			if not valid_list(vault.get(pair[0]),pair[1]):
				return "Ungültiger Gruftfortschritt: "+pair[0]
		for flag in ["shortcut_open","secret_open","reported"]:
			if not vault.get(flag) is bool:
				return "Ungültiger Gruftschalter: "+flag
		if (vault.secret_open and not "water_memory" in vault.memories) or ("amber_seed" in vault.relics and not vault.secret_open) or (vault.reported and not "star_chart" in vault.relics):
			return "Die Entdeckungen der Gruft widersprechen sich."
		if run.region=="vault":
			if not run.quest_complete:
				return "Der Zugang zur Gruft ist noch nicht geöffnet."
			var world := DungeonGenerator.generate(run.world_seed)
			if not DungeonGenerator.navigable(world,Vector2i(Vector2(player.x,player.y)/16),vault.shortcut_open,vault.secret_open):
				return "Der Speicherpunkt liegt außerhalb begehbarer Gruftwege."
	if data.save_version==VERSION:
		return validate_source(run)
	return ""

static func validate_source(run: Dictionary) -> String:
	if not run.get("source") is Dictionary or not run.get("inventory") is Dictionary:
		return "Quellengeschichte oder Reliktinventar fehlen."
	var source: Dictionary=run.source
	var bag: Dictionary=run.inventory
	for key in ["seen","guardian_defeated","reported","ore_taken"]:
		if not source.get(key) is bool: return "Ungültiger Zustand der Quellengeschichte: "+key
	if source.get("resolution") not in ["","restored","broken"] or not number_in(source.get("alignment"),0,2) or source.alignment!=floor(float(source.alignment)):
		return "Ungültige Entscheidung oder Zeichenfolge."
	if not valid_list(bag.get("owned"),Content.section("relics").keys()) or not bag.get("equipped") is String or (not bag.equipped.is_empty() and not bag.equipped in bag.owned):
		return "Das Reliktinventar ist ungültig."
	var resolved: bool=not source.resolution.is_empty()
	var evidence: bool="water_memory" in run.vault.memories and "root_memory" in run.vault.memories and "star_chart" in run.vault.relics
	if source.seen and not run.quest_complete:
		return "Die Quellengeschichte beginnt vor dem geöffneten Zugang."
	if (resolved and not source.seen) or (source.alignment>0 and (not evidence or not source.seen or resolved)):
		return "Die Bindung widerspricht ihren gefundenen Hinweisen."
	if (source.resolution=="restored" and (not evidence or source.guardian_defeated)) or (source.guardian_defeated!=(source.resolution=="broken")):
		return "Hüter und Lösung der Bindung widersprechen sich."
	if (source.reported and not resolved) or (source.ore_taken and source.resolution!="broken"):
		return "Die Folgen der Quellengeschichte sind ungültig."
	if resolved!=(Content.section("source_quest").reward_item in bag.owned):
		return "Quellengeschichte und Belohnung widersprechen sich."
	return ""

static func migrate(data: Dictionary) -> Dictionary:
	var updated: Dictionary=data.duplicate(true)
	if updated.save_version==1:
		updated.save_version=2
		updated.dungeon_version=DungeonGenerator.VERSION
		updated.run.region="forest"
		updated.run.vault=DungeonProgress.new().serialize()
	if updated.save_version==2:
		updated.save_version=VERSION
		updated.run.source=SourceQuest.new().serialize()
		updated.run.inventory=RelicInventory.new().serialize()
	return updated

static func write(data: Dictionary, path: String = DEFAULT_PATH) -> String:
	var error := validate(data)
	if not error.is_empty():
		return error
	# Preserve previous originals, including an old backup recovered from a damaged main file.
	for policy in [[".pre-v03",1],[".pre-v04",2]]:
		var preserved: String=path+str(policy[0])
		if FileAccess.file_exists(preserved): continue
		for source in [path,path+".bak"]:
			var previous := read_one(source)
			var previous_version: int=int(previous.get("migrated_from",0))
			if previous_version>0 and previous_version<=int(policy[1]):
				if DirAccess.copy_absolute(source,preserved)!=OK:
					return "Der ursprüngliche Spielstand konnte nicht gesichert werden."
				break
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
	if not error.is_empty():
		return {"error":error}
	var migrated: Dictionary=migrate(data)
	return {"data":migrated,"error":"","notice":"Dein bisheriger Lichtpfad wurde übernommen.","migrated_from":int(data.save_version)} if data.save_version<VERSION else {"data":migrated,"error":""}

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
