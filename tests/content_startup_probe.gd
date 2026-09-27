extends SceneTree
## External release probe: a tiny resource overlay changes only test-process data.
var checks := 0
var failures: Array[String] = []
func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS STARTUP: " if ok else "FAIL STARTUP: ",title)

func overlay(path: String, text: String) -> bool:
	var source := "user://content_overlay_only.json"
	var destination := "user://content_overlay_only.pck"
	var file := FileAccess.open(source,FileAccess.WRITE)
	file.store_string(text); file.close()
	var packer := PCKPacker.new()
	return packer.pck_start(destination) == OK and packer.add_file(path,source) == OK and packer.flush() == OK and ProjectSettings.load_resource_pack(destination,true)

func verify() -> void:
	var scenario := str(OS.get_cmdline_user_args()[0])
	var path := "res://data/vault.json" if scenario == "geometry" else "res://data/content.json"
	var content: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
	var payload := "{ invalid JSON"
	var expected := "Invalid JSON"
	if scenario == "reference":
		content.source_quest.reward_item="missing_relic"
		payload=JSON.stringify(content)
		expected="source_quest.reward_item"
	elif scenario == "geometry":
		content.rooms[0].center=[2,2]
		payload=JSON.stringify(content)
		expected="rooms[0].size"
	elif scenario == "stats":
		content.player.defense.resistances={"light":99}
		payload=JSON.stringify(content)
		expected="player.defense.resistances.light"
	elif scenario == "active_combat":
		content.active_combat.defense.parry_window=0
		payload=JSON.stringify(content)
		expected="active_combat.defense.parry_window"
	elif scenario == "cache":
		check(Content.ensure_loaded(),"Initial valid load succeeds")
	var saved := FileAccess.open(SaveSystem.DEFAULT_PATH,FileAccess.WRITE)
	saved.store_string("M04 isolated profile sentinel; never replace on content failure"); saved.close()
	var original := FileAccess.get_file_as_bytes(SaveSystem.DEFAULT_PATH)
	check(overlay(path,payload),"Test resource overlay installed")
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	if scenario == "cache":
		check(is_instance_valid(game.player) and Content.ensure_loaded() and Content.error_text().is_empty(),"Loaded immutable cache is reused without reparsing changed disk files")
		for i in 10: await process_frame
		check(Content.all().is_read_only() and Content.section("player").hp == 100,"Normal frame activity keeps the one validated bundle")
	else:
		check(game.run == null and not is_instance_valid(game.regions) and get_nodes_in_group("player").is_empty(),"Invalid bundle builds no run, region or player")
		check(game.has_node("ContentError") and expected in game.get_node("ContentError").get_child(1).text and path.trim_prefix("res://") in Content.error_text(),"Visible startup diagnostic identifies file and actual problem")
		check(Content.all().is_empty() and Content.vault().is_empty() and Content.discoveries().is_empty(),"No partial content is published")
		check(not SaveSystem.write({}).is_empty() and not FileAccess.file_exists(SaveSystem.DEFAULT_PATH+".tmp"),"Content failure blocks saving before file operations")
		var old_errors := Content.error_text()
		check(not Content.ensure_loaded() and Content.error_text() == old_errors,"Failed load is cached; no repeated validation or duplicate errors")
	check(FileAccess.get_file_as_bytes(SaveSystem.DEFAULT_PATH) == original,"Existing save bytes remain untouched")
	paused=false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for file in [SaveSystem.DEFAULT_PATH,"user://content_overlay_only.json","user://content_overlay_only.pck"]:
		DirAccess.remove_absolute(file)
	print("CONTENT STARTUP RESULT ",checks-failures.size(),"/",checks," ",scenario)
	quit(0 if failures.is_empty() else 1)
