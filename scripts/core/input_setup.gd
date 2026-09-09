class_name InputSetup
extends RefCounted

static func install() -> void:
	var keys := {
		"move_left":[KEY_A, KEY_LEFT], "move_right":[KEY_D, KEY_RIGHT],
		"move_up":[KEY_W, KEY_UP], "move_down":[KEY_S, KEY_DOWN],
		"dash":[KEY_SPACE], "interact":[KEY_E], "journal":[KEY_TAB],
		"pause_game":[KEY_ESCAPE], "save_game":[KEY_F5], "load_game":[KEY_F9],
		"map":[KEY_M], "bolt":[KEY_1], "nova":[KEY_2], "fullscreen":[KEY_F11]
	}
	for action in keys:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in keys[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for pair in [["bolt", MOUSE_BUTTON_LEFT], ["nova", MOUSE_BUTTON_RIGHT]]:
		var event := InputEventMouseButton.new()
		event.button_index = pair[1]
		InputMap.action_add_event(pair[0], event)
