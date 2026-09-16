extends SceneTree

# Launched only in a disposable size-limited child by the Python helper.
const SAVE := "user://m01_limited_write_only.json"

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var fixture := "res://tests/fixtures/v04_restored_equipped.json"
	var bytes := FileAccess.get_file_as_bytes(fixture)
	var data: Dictionary = SaveSystem.read_one(fixture).data
	var probe := FileAccess.open(SAVE + ".probe", FileAccess.WRITE)
	if probe == null:
		print("WRITE LIMIT SETUP FAILED: ordinary file could not be opened")
		quit(2); return
	var stored := probe.store_string(JSON.stringify(data))
	probe.flush()
	var write_error := probe.get_error()
	probe.close()
	var length := FileAccess.get_file_as_bytes(SAVE + ".probe").size()
	print("REAL WRITE PROBE: open=true store=", stored, " get_error=", write_error,
		" bytes=", length, " expected=", JSON.stringify(data).to_utf8_buffer().size())
	if length != 64:
		print("WRITE LIMIT SETUP FAILED: expected the launcher's 64-byte file limit")
		quit(2); return
	var error := SaveSystem.write(data, SAVE)
	var backup_unchanged := FileAccess.get_file_as_bytes(SAVE + ".bak") == bytes
	var loadable: bool = SaveSystem.read(SAVE).error.is_empty()
	print("WRITE LIMIT RESULT: ", JSON.stringify({"reported_error":error,
		"backup_unchanged":backup_unchanged, "previous_save_loadable":loadable}))
	var passed := not error.is_empty() and backup_unchanged and loadable
	print("REAL WRITE ERROR PASS" if passed else "FAIL REAL WRITE ERROR")
	quit(0 if passed else 1)
