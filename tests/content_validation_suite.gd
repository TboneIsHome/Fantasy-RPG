extends SceneTree
var checks := 0
var failures: Array[String] = []
var original: Array = []

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS CONTENT: " if ok else "FAIL CONTENT: ", title)

func rejected(document: int, path: Array, value: Variant, expected_path: String, problem: String, remove: bool = false) -> void:
	var data := original.duplicate(true)
	var owner: Variant = data[document]
	for index in range(path.size()-1): owner = owner[path[index]]
	if remove: owner.erase(path[-1])
	else: owner[path[-1]] = value
	var errors := ContentValidator.validate_bundle(data[0],data[1],data[2])
	var file: String = ["data/content.json","data/vault.json","data/discoveries.json"][document]
	var found := false
	for error in errors:
		if file in error and expected_path in error and problem in error and "Received:" in error: found = true
	check(found, "%s %s: %s" % [file,expected_path,problem])
	if not found: print(errors)

func verify() -> void:
	var started := Time.get_ticks_usec()
	check(Content.ensure_loaded(), "Real bundle loads through the release-safe gate")
	print("CONTENT LOAD MICROSECONDS ", Time.get_ticks_usec()-started)
	original = [Content.all().duplicate(true),Content.vault().duplicate(true),Content.discoveries().duplicate(true)]
	check(Content.all().is_read_only() and Content.section("player").is_read_only() and Content.vault().rooms.is_read_only() and Content.vault().rooms[0].center.is_read_only(), "Published bundle is recursively read-only")
	check("12 Mana" in Content.description(Content.section("skills").flow), "JSON float token preserves original Flow text")
	check("12 Leben" in Content.description(Content.section("skills").bloom), "JSON float token preserves original Bloom text")
	check("6 Mana" in Content.description(Content.section("relics").source_heart), "JSON float token preserves original relic text")
	check(Content.number_text(1.25) == "1.25", "Fractional text keeps its actual value")
	var before := original.duplicate(true)
	check(ContentValidator.validate_bundle(original[0],original[1],original[2]).is_empty() and original == before, "Pure validation accepts shipped content without mutation")
	for i in 3:
		var bad := original.duplicate(true)
		bad[i] = ["not an object"]
		check(not ContentValidator.validate_bundle(bad[0],bad[1],bad[2]).is_empty(), "Reject non-object document %d" % i)
	rejected(0,["player"],null,"player","Missing",true)
	rejected(0,["player","hp"],null,"player.hp","Missing",true)
	for value in ["100", true, null, -1, 0, NAN, INF, -INF, 10001]:
		rejected(0,["player","hp"],value,"player.hp","Expected number")
	rejected(0,["player","mana_regen"],-1,"player.mana_regen","Expected number")
	rejected(0,["spells","bolt","cooldown"],0,"spells.bolt.cooldown","Expected number")
	rejected(0,["spells","nova","cost"],-1,"spells.nova.cost","Expected number")
	rejected(0,["spells","nova","slow_multiplier"],1.1,"spells.nova.slow_multiplier","Expected number")
	rejected(0,["spells","nova","mana_cost"],28,"spells.nova.mana_cost","Unknown field")
	rejected(0,["enemies","wolf","mode"],"teleport","enemies.wolf.mode","Expected one of")
	rejected(0,["enemies","wisp","mode"],"thorns","enemies.wisp.mode","Expected one of")
	for value in [1, 2.5, 65, true, "5"]:
		rejected(0,["enemies","guardian","fan_count"],value,"enemies.guardian.fan_count","Expected integer")
	rejected(0,["enemies","wolf","leash"],10,"enemies.wolf.leash","Expected leash")
	rejected(0,["enemies","wolf","xp"],1.5,"enemies.wolf.xp","Expected integer")
	rejected(0,["quest","reward_xp"],-1,"quest.reward_xp","Expected integer")
	rejected(0,["source_quest","reward_item"],"missing","source_quest.reward_item","Missing relic reference")
	for value in ["", "Bad-ID", "two words", 3]:
		rejected(0,["source_quest","reward_item"],value,"source_quest.reward_item","Expected ID")
	rejected(0,["source_quest","ore_motes"],0.5,"source_quest.ore_motes","Expected integer")
	rejected(0,["skills","flow","description"],"{missing}","skills.flow.description","Unknown/non-numeric")
	rejected(0,["skills","bloom","description"],"{healing","skills.bloom.description","Unmatched")
	rejected(0,["skills","flow","description"],"Gibt 12 Mana", "skills.flow.description", "Missing numeric token")
	rejected(0,["relics","source_heart","description"],"Gibt 6 Mana", "relics.source_heart.description", "Missing numeric token")
	rejected(0,["relics","source_heart","frost_refund"],INF,"relics.source_heart.frost_refund","Expected number")
	rejected(0,["progression","xp_per_level"],0,"progression.xp_per_level","Expected integer")
	rejected(0,["world","day_seconds"],0,"world.day_seconds","Expected number")
	rejected(1,["rooms"],null,"rooms","Expected array")
	rejected(1,["rooms",0,"id"],"","rooms[0].id","Expected ID")
	rejected(1,["rooms",0,"id"],"cistern","rooms[1].id","Duplicate ID")
	rejected(1,["rooms",0,"id"],"new_room","rooms[0].id","Unsupported persistent")
	rejected(1,["rooms",0,"style"],"lava","rooms[0].style","Expected one of")
	rejected(1,["rooms",0,"center"],[2,2],"rooms[0].size","variation must fit")
	for value in [[-1,14],[14,INF],[14.5,14],[true,14],[14],[14,14,14]]:
		rejected(1,["rooms",0,"center"],value,"rooms[0].center","Expected integer pair")
	rejected(1,["rooms",0,"size"],[0,13],"rooms[0].size","Expected integer pair")
	rejected(1,["links",0],["threshold","missing"],"links[0]","Missing room reference")
	rejected(1,["links",0],[true,{}],"links[0]","Missing room reference")
	rejected(1,["links",0],["threshold"],"links[0]","Expected two")
	rejected(1,["links",0],["threshold","threshold"],"links[0]","Self/duplicate")
	rejected(1,["links",0],["observatory","cistern"],"links[1]","Self/duplicate")
	rejected(1,["links",7],["secret","cistern"],"links[7]","secret branch")
	rejected(1,["links"],[],"links","disconnected")
	rejected(1,["points",0,"kind"],"merchant","points[0].kind","Expected one of")
	rejected(1,["points",0,"tile"],[38,12],"points[0].tile","reachable")
	rejected(1,["points",7,"tile"],[14,30],"points[7].tile","collision cells")
	rejected(1,["encounters",0,"kind"],"dragon","encounters[0].kind","Missing enemy reference")
	rejected(1,["encounters",0,"kind"],"guardian","encounters[0].kind","Expected one of")
	rejected(1,["encounters",0,"tile"],[37,12],"encounters[0].tile","spawn jitter")
	rejected(1,["encounters",0,"id"],"vault_guard_1","encounters[1].id","Duplicate ID")
	rejected(1,["fountain_cost"],0,"fountain_cost","Expected integer")
	rejected(1,["memory_xp"],-1,"memory_xp","Expected integer")
	rejected(1,["chart_xp"],true,"chart_xp","Expected integer")
	rejected(2,["water_memory"],null,"water_memory","Missing",true)
	rejected(2,["camp","title"]," ","camp.title","non-empty text")
	rejected(2,["camp","text"],[],"camp.text","non-empty text")
	rejected(2,["camp","title"],null,"camp.title","Missing",true)
	rejected(2,["unused"],{"title":"X","text":"Y"},"unused","Unknown field")
	var changed := original.duplicate(true)
	changed[0].player.hp = 150
	changed[0].spells.nova.cost = 0
	changed[0].skills.flow.mana_refund = 17
	changed[0].enemies.guardian.fan_count = 2
	check(ContentValidator.validate_bundle(changed[0],changed[1],changed[2]).is_empty(), "Valid balance edits including zero cost and minimum fan count are accepted")
	const PATH := "user://content_parser_test_only.json"
	var file := FileAccess.open(PATH,FileAccess.WRITE)
	file.store_string("{\n broken json"); file.close()
	var parsed := Content.read_json(PATH)
	check(not parsed.errors.is_empty() and PATH in parsed.errors[0] and "line" in parsed.errors[0] and "Invalid JSON" in parsed.errors[0], "Parse failure reports actual file and line")
	DirAccess.remove_absolute(PATH)
	check(not Content.read_json(PATH).errors.is_empty(), "Missing file returns diagnostic without publishing content")
	check(Content.ensure_loaded() and Content.all() == original[0], "Pure invalid test inputs never poison the loaded runtime bundle")
	print("CONTENT VALIDATION RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
