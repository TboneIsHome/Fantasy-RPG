extends SceneTree

const SAVE := "user://m01_fault_test_only.json"
const FIXTURES := "res://tests/fixtures/"
const CURRENT := "v04_restored_equipped.json"
const OLDER := "v04_alignment_started.json"
const SUFFIXES := ["", ".bak", ".tmp", ".bak.tmp", ".pre-v03", ".pre-v04", ".pre-v03.tmp", ".pre-v04.tmp"]
var checks := 0
var failures: Array[String] = []

class FaultIO extends SaveFileIO:
	var kind: String
	var destination_suffix: String
	var delete_destination: bool
	var triggered := false

	func _init(mode: String, suffix: String = "", remove_target: bool = false) -> void:
		kind = mode; destination_suffix = suffix; delete_destination = remove_target

	func write_text(path: String, text: String) -> Error:
		if kind == "write":
			triggered = true
			super.write_text(path, text.left(16))
			return ERR_FILE_CANT_WRITE
		if kind == "flush":
			triggered = true
			super.write_text(path, text)
			return ERR_FILE_CANT_WRITE
		if kind == "short_success":
			triggered = true
			return super.write_text(path, text.left(16))
		if kind == "wrong_success":
			triggered = true
			var wrong: Dictionary = JSON.parse_string(text)
			wrong.run.motes += 1
			return super.write_text(path, JSON.stringify(wrong))
		if kind == "unreadable":
			triggered = true
			var result := super.write_text(path, text)
			DirAccess.remove_absolute(path)
			return result
		return super.write_text(path, text)

	func copy_file(source: String, destination: String) -> Error:
		if kind in ["copy", "short_copy"] and destination.ends_with(destination_suffix):
			triggered = true
			super.write_text(destination, "{ partial copy")
			return ERR_FILE_CANT_WRITE if kind == "copy" else OK
		return super.copy_file(source, destination)

	func rename_file(source: String, destination: String) -> Error:
		if kind == "rename" and destination.ends_with(destination_suffix):
			triggered = true
			# Fault injection also models the Windows delete-then-MoveFile path.
			if delete_destination: DirAccess.remove_absolute(destination)
			return FAILED
		return super.rename_file(source, destination)

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, title: String) -> void:
	checks += 1
	if not condition: failures.append(title)
	print("PASS SAVE FAULT: " if condition else "FAIL SAVE FAULT: ", title)

func clean() -> void:
	for suffix in SUFFIXES: DirAccess.remove_absolute(SAVE + suffix)

func raw_write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text); file.close()

func prepare(primary: String = CURRENT, backup: String = OLDER) -> void:
	clean()
	if not primary.is_empty(): DirAccess.copy_absolute(FIXTURES + primary, SAVE)
	if not backup.is_empty(): DirAccess.copy_absolute(FIXTURES + backup, SAVE + ".bak")

func same_bytes(path: String, original: PackedByteArray) -> bool:
	return FileAccess.file_exists(path) and FileAccess.get_file_as_bytes(path) == original

func verify() -> void:
	var originals := {}
	for name in ["v01_save.json", "v02_completed_save.json", "v03_completed_save.json",
		OLDER, CURRENT, "v04_broken_ore_unequipped.json"]:
		originals[name] = FileAccess.get_file_as_bytes(FIXTURES + name)
	var previous: Dictionary = SaveSystem.read_one(FIXTURES + CURRENT).data
	var next := previous.duplicate(true)
	next.run.motes += 1
	for mode in ["write", "flush", "short_success", "wrong_success", "unreadable"]:
		prepare()
		var io := FaultIO.new(mode)
		var error := SaveSystem.write(next, SAVE, io)
		check(io.triggered and not error.is_empty() and same_bytes(SAVE, originals[CURRENT])
			and same_bytes(SAVE + ".bak", originals[OLDER]),
			"Temporary " + mode + " failure leaves both existing saves untouched")
	for mode in ["copy", "short_copy"]:
		prepare()
		var io := FaultIO.new(mode, ".bak.tmp")
		check(not SaveSystem.write(next, SAVE, io).is_empty() and io.triggered
			and same_bytes(SAVE, originals[CURRENT]) and same_bytes(SAVE + ".bak", originals[OLDER]),
			"Backup " + mode + " failure stops before rotating valid files")
	for remove_target in [false, true]:
		prepare()
		var io := FaultIO.new("rename", ".bak", remove_target)
		check(not SaveSystem.write(next, SAVE, io).is_empty() and io.triggered
			and same_bytes(SAVE, originals[CURRENT]) and SaveSystem.read(SAVE).data == previous,
			"Backup rename failure preserves the latest main; target removed=" + str(remove_target))
		prepare()
		io = FaultIO.new("rename", "m01_fault_test_only.json", remove_target)
		check(not SaveSystem.write(next, SAVE, io).is_empty() and io.triggered
			and same_bytes(SAVE + ".bak", originals[CURRENT]) and SaveSystem.read(SAVE).data == previous,
			"Main rename failure keeps the latest save loadable; target removed=" + str(remove_target))
		check(SaveSystem.write(next, SAVE).is_empty() and SaveSystem.read(SAVE).data == next
			and same_bytes(SAVE + ".bak", originals[CURRENT]),
			"Retry after failed main replacement succeeds without consuming recovery")
		prepare("", CURRENT)
		raw_write(SAVE, "damaged primary")
		io = FaultIO.new("rename", "m01_fault_test_only.json", remove_target)
		check(not SaveSystem.write(next, SAVE, io).is_empty() and io.triggered
			and same_bytes(SAVE + ".bak", originals[CURRENT]) and SaveSystem.read(SAVE).data == previous,
			"Recovery commit failure preserves the valid format-3 backup; target removed=" + str(remove_target))
	prepare()
	DirAccess.remove_absolute(SAVE + ".bak")
	DirAccess.make_dir_absolute(SAVE + ".bak")
	raw_write(SAVE + ".bak/blocker.txt", "owned test blocker")
	check(not SaveSystem.write(next, SAVE).is_empty() and same_bytes(SAVE, originals[CURRENT]),
		"Real backup rename blocked by a nonempty directory leaves main intact")
	DirAccess.remove_absolute(SAVE + ".bak/blocker.txt")
	prepare("", CURRENT)
	DirAccess.make_dir_absolute(SAVE)
	raw_write(SAVE + "/blocker.txt", "owned test blocker")
	check(not SaveSystem.write(next, SAVE).is_empty() and same_bytes(SAVE + ".bak", originals[CURRENT])
		and SaveSystem.read(SAVE).data == previous, "Real main rename failure leaves backup recoverable")
	DirAccess.remove_absolute(SAVE + "/blocker.txt")
	prepare("", "")
	var first_failure := SaveSystem.write(next, SAVE, FaultIO.new("rename", "m01_fault_test_only.json"))
	check(not first_failure.is_empty() and "Sicherung erhalten" not in first_failure
		and not SaveSystem.read(SAVE).error.is_empty(), "Failed first save never claims a previous backup exists")
	check(SaveSystem.write(next, SAVE).is_empty() and SaveSystem.read(SAVE).data == next,
		"Retry creates the first readable save")
	for name in ["v01_save.json", "v02_completed_save.json", "v03_completed_save.json"]:
		var legacy: Dictionary = SaveSystem.read_one(FIXTURES + name).data
		# JSON loads numbers as floats; compare complete persisted values.
		var persisted: Dictionary = JSON.parse_string(JSON.stringify(legacy))
		var suffix := ".pre-v04" if name == "v03_completed_save.json" else ".pre-v03"
		for mode in ["copy", "short_copy", "rename"]:
			prepare(name, "")
			var destination := suffix if mode == "rename" else suffix + ".tmp"
			var io := FaultIO.new(mode, destination)
			check(not SaveSystem.write(legacy, SAVE, io).is_empty() and io.triggered
				and same_bytes(SAVE, originals[name]) and not FileAccess.file_exists(SAVE + suffix),
				name + ": migration " + mode + " failure preserves the raw original")
			check(SaveSystem.write(legacy, SAVE).is_empty() and same_bytes(SAVE + suffix, originals[name]),
				name + ": migration retry creates a complete permanent original")
		for from_backup in [false, true]:
			prepare("" if from_backup else name, name if from_backup else "")
			if from_backup: raw_write(SAVE, "damaged primary")
			check(SaveSystem.write(legacy, SAVE).is_empty() and SaveSystem.read(SAVE).get("data", {}) == persisted
				and same_bytes(SAVE + ".pre-v04", originals[name])
				and (suffix == ".pre-v04" or same_bytes(SAVE + ".pre-v03", originals[name])),
				name + ": migration retains exact originals; recovered=" + str(from_backup))
			check(SaveSystem.write(legacy, SAVE).is_empty() and same_bytes(SAVE + ".pre-v04", originals[name]),
				name + ": later save leaves permanent original unchanged")
	prepare("v03_completed_save.json", "")
	raw_write(SAVE + ".pre-v04", "{ old incomplete migration copy")
	var legacy: Dictionary = SaveSystem.read_one(FIXTURES + "v03_completed_save.json").data
	check(not SaveSystem.write(legacy, SAVE).is_empty() and same_bytes(SAVE, originals["v03_completed_save.json"])
		and FileAccess.get_file_as_string(SAVE + ".pre-v04") == "{ old incomplete migration copy",
		"Existing damaged migration original is reported and never overwritten")
	for field in ["run", "player", "settings", "save_version"]:
		prepare()
		var invalid := next.duplicate(true)
		invalid.erase(field)
		check(not SaveSystem.write(invalid, SAVE).is_empty() and same_bytes(SAVE, originals[CURRENT])
			and same_bytes(SAVE + ".bak", originals[OLDER]), "Missing " + field + " cannot overwrite either save")
	prepare()
	var huge := next.duplicate(true)
	huge.extra = "x".repeat(SaveSystem.MAX_BYTES)
	check(not SaveSystem.write(huge, SAVE).is_empty() and same_bytes(SAVE, originals[CURRENT]),
		"An oversized serialized save is rejected before overwriting the readable main")
	for invalid_text in ["", "{ damaged json", "[]", '{"save_version":3}']:
		prepare("", "")
		raw_write(SAVE, invalid_text)
		check(not SaveSystem.read(SAVE).error.is_empty(), "Corrupt or incomplete data is rejected: " + invalid_text)
	for field in ["save_version", "generator_version", "dungeon_version"]:
		prepare()
		var future := previous.duplicate(true)
		future[field] = 999
		raw_write(SAVE, JSON.stringify(future))
		check(not SaveSystem.read(SAVE).error.is_empty(), "Future " + field + " never silently falls back")
	for name in [OLDER, CURRENT, "v04_broken_ore_unequipped.json"]:
		prepare(name, "")
		var data: Dictionary = SaveSystem.read(SAVE).data
		check(SaveSystem.write(data, SAVE).is_empty() and SaveSystem.read(SAVE).data == data
			and same_bytes(SAVE + ".bak", originals[name]), name + ": full format-3 state survives load/save/load")
	clean()
	for name in originals:
		check(same_bytes(FIXTURES + name, originals[name]), "Frozen fixture unchanged: " + name)
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/save_fault_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks, "failures":failures}, "  ")); report.close()
	print("SAVE FAULT RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
