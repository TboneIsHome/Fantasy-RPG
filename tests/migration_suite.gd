extends SceneTree
var checks: int=0
var failures: Array[String]=[]
const SAVE := "user://migration_test_only.json"
const RECOVERY := "user://migration_recovery_only.json"

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, title: String) -> void:
	checks+=1
	if not condition: failures.append(title)
	print("PASS MIGRATION: " if condition else "FAIL MIGRATION: ",title)

func verify() -> void:
	for path in [SAVE,RECOVERY]:
		for suffix in ["",".bak",".tmp",".pre-v03",".pre-v04"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	var original := FileAccess.get_file_as_bytes("res://tests/fixtures/v02_completed_save.json")
	var loaded := SaveSystem.read("res://tests/fixtures/v02_completed_save.json")
	check(loaded.error.is_empty() and loaded.data.save_version==SaveSystem.VERSION and loaded.data.dungeon_version==1,"Completed 0.2 save migrates to both explicit current version fields")
	check(loaded.data.run.quest_complete and loaded.data.run.active_lights.size()==3 and loaded.data.run.learned==["bloom"] and loaded.data.run.defeated.size()==2,"Completed quest, talent and defeated foes remain intact")
	check(loaded.data.run.vault==DungeonProgress.new().serialize(),"Old completed games begin with a genuinely undiscovered dungeon")
	DirAccess.copy_absolute("res://tests/fixtures/v02_completed_save.json",SAVE)
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path=SAVE
	check(game.load_game() and game.player.vitals.hp==81 and game.player.vitals.mana==55,"Actual old save loads into the new playable scene without healing or progress reset")
	check(game.save_game() and FileAccess.get_file_as_bytes(SAVE+".pre-v03")==original,"First new-format write preserves an exact permanent copy of the original")
	game.run.motes=3
	check(game.save_game() and FileAccess.get_file_as_bytes(SAVE+".pre-v03")==original,"Later saves never overwrite the pre-update copy")
	game.travel_to("vault")
	check(game.run.region=="vault","Old quest completion unlocks the new entrance immediately")
	var previous: float=game.run.time_of_day
	for i in 10: await process_frame
	check(game.run.time_of_day>previous,"World time continues while exploring underground")
	game.handle_action("pause")
	previous=game.run.time_of_day
	for i in 10: await process_frame
	check(game.run.time_of_day==previous,"Pausing also pauses the shared world clock")
	game.handle_action("resume")
	var future := SaveSystem.snapshot(game.run,game.player,game.settings)
	future.dungeon_version=999
	var file := FileAccess.open(SAVE,FileAccess.WRITE)
	file.store_string(JSON.stringify(future));file.close()
	check(not SaveSystem.read(SAVE).error.is_empty(),"Future dungeon versions never silently fall back to an older backup")
	file=FileAccess.open(RECOVERY,FileAccess.WRITE)
	file.store_string("damaged primary");file.close()
	DirAccess.copy_absolute("res://tests/fixtures/v02_completed_save.json",RECOVERY+".bak")
	var recovered := SaveSystem.read(RECOVERY)
	check(recovered.error.is_empty() and recovered.get("migrated_from")==1,"Damaged primary can recover and migrate a genuine legacy backup")
	check(SaveSystem.write(recovered.data,RECOVERY).is_empty() and FileAccess.get_file_as_bytes(RECOVERY+".pre-v03")==original,"Backup recovery also preserves the exact legacy bytes before rotating files")
	paused=false
	game.queue_free()
	for i in 5: await process_frame
	for path in [SAVE,RECOVERY]:
		for suffix in ["",".bak",".tmp",".pre-v03",".pre-v04"]:
			if FileAccess.file_exists(path+suffix): DirAccess.remove_absolute(path+suffix)
	var report := FileAccess.open("res://test-output/migration_results.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures},"  "));report.close()
	print("MIGRATION RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
