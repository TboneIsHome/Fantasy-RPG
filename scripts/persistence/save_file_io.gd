class_name SaveFileIO
extends RefCounted

# Per-write dependency, not global mutable state. Tests override individual
# operations; production always uses these real filesystem calls.
func write_text(path: String, text: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var stored := file.store_string(text)
	var error := file.get_error()
	file.flush()
	if error == OK:
		error = file.get_error()
	file.close()
	# Godot 4.5.1 flush() does not propagate every OS error. SaveSystem also
	# reopens and compares the complete bytes before replacing any valid save.
	return ERR_FILE_CANT_WRITE if not stored and error == OK else error

func copy_file(source: String, destination: String) -> Error:
	return DirAccess.copy_absolute(source, destination)

func rename_file(source: String, destination: String) -> Error:
	return DirAccess.rename_absolute(source, destination)
