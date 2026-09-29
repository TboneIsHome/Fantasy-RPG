extends SceneTree
func _initialize() -> void:
	var absent := not ResourceLoader.exists("res://developer/sandbox.tscn") and not ResourceLoader.exists("res://developer/session.gd") and not FileAccess.file_exists("res://developer/presets.json")
	var production := ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/game.tscn" and ProjectSettings.get_setting("application/config/name")=="Lichterhain"
	print("SANDBOX PRODUCTION EXCLUSION PASS" if absent and production else "FAIL: sandbox leaked into production export")
	quit(0 if absent and production else 1)
