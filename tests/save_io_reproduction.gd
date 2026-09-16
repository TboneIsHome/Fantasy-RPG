extends SceneTree

# Same regression used before and after M01; disposable files only.
const SAVE := "user://m01_reproduction_only.json"
const FIXTURE := "res://tests/fixtures/v04_restored_equipped.json"
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, title: String) -> void:
	checks += 1
	if not condition: failures.append(title)
	print("PASS SAVE IO: " if condition else "FAIL SAVE IO: ", title)

func clean() -> void:
	for suffix in ["", ".bak", ".tmp", ".bak.tmp", ".pre-v03", ".pre-v04"]:
		DirAccess.remove_absolute(SAVE + suffix)

func prepare_recovery() -> void:
	clean()
	var file := FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string("{ damaged primary"); file.close()
	DirAccess.copy_absolute(FIXTURE, SAVE + ".bak")

func verify() -> void:
	var original := FileAccess.get_file_as_bytes(FIXTURE)
	var data: Dictionary = SaveSystem.read_one(FIXTURE).data
	prepare_recovery()
	check(SaveSystem.read(SAVE).error.is_empty(), "Damaged primary loads the valid format-3 backup")
	check(SaveSystem.write(data, SAVE).is_empty(), "Recovered save can be written")
	check(FileAccess.get_file_as_bytes(SAVE + ".bak") == original,
		"Saving after recovery preserves the valid backup byte for byte")
	prepare_recovery()
	check(DirAccess.make_dir_absolute(SAVE + ".tmp") == OK, "Temporary path blocked by a real directory")
	var error := SaveSystem.write(data, SAVE)
	check(not error.is_empty(), "Failure to open the temporary file is reported")
	check(FileAccess.get_file_as_bytes(SAVE + ".bak") == original, "Open failure keeps the original valid backup")
	check(SaveSystem.read(SAVE).error.is_empty(), "Previous save remains loadable after open failure")
	clean()
	check(FileAccess.get_file_as_bytes(FIXTURE) == original, "Frozen 0.4 fixture remains unchanged")
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/save_io_reproduction_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks, "failures":failures,
		"godot":Engine.get_version_info().string}, "  ")); report.close()
	print("SAVE IO RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
