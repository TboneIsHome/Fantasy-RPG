class_name GameUI
extends CanvasLayer

signal requested(action: String, argument: String)
signal volume_changed(value: float)
signal shake_changed(enabled: bool)
var hud: HudCanvas
var root: Control
var panel: Control
var page: String = "title"
var settings: Dictionary = {"volume":0.4,"shake":true}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	hud = HudCanvas.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(hud)

func clear() -> void:
	if is_instance_valid(panel):
		root.remove_child(panel)
		panel.queue_free()
	panel = null
	hud.show_map = false
	page = ""

func toast(message: String) -> void:
	hud.toast_text = message
	hud.toast_left = 4.5

func shell(kind: String, title: String, subtitle: String, width: float = 360) -> VBoxContainer:
	clear()
	page = kind
	panel = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(panel)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.025,0.065,0.082,0.72)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(shade)
	var container := PanelContainer.new()
	container.position = Vector2((640-width)/2,27)
	container.size = Vector2(width,0)
	container.add_theme_stylebox_override("panel",HudCanvas.box_style(Color("142e37"),Color("78836a")))
	panel.add_child(container)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",8)
	container.add_child(box)
	label(box,title,21,HudCanvas.GOLD)
	if not subtitle.is_empty():
		label(box,subtitle,11,HudCanvas.MUTED)
	return box

func label(parent: Node, value: String, size: int = 12, color: Color = HudCanvas.CREAM) -> Label:
	var item := Label.new()
	item.text = value
	item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item.add_theme_font_size_override("font_size",size)
	item.add_theme_color_override("font_color",color)
	parent.add_child(item)
	return item

func button(parent: Node, title: String, action: String, argument: String = "") -> Button:
	var item := Button.new()
	item.text = title
	item.custom_minimum_size.y = 27
	item.add_theme_font_size_override("font_size",12)
	item.add_theme_color_override("font_color",HudCanvas.CREAM)
	item.add_theme_stylebox_override("normal",HudCanvas.box_style(Color("24444a"),Color("526c65")))
	item.add_theme_stylebox_override("hover",HudCanvas.box_style(Color("35605d"),HudCanvas.GOLD))
	item.add_theme_stylebox_override("focus",HudCanvas.box_style(Color(0,0,0,0),HudCanvas.GOLD))
	item.add_theme_stylebox_override("pressed",HudCanvas.box_style(Color("537065"),HudCanvas.GOLD))
	item.pressed.connect(func(): requested.emit(action,argument))
	parent.add_child(item)
	return item

func title_menu(has_save: bool) -> void:
	hud.game_visible = false
	var box := shell("title","L I C H T E R H A I N","Ein Licht erlischt. Ein Weg beginnt.",354)
	label(box,"Erkunde einen alten Wald als Magier. Finde drei verlorene Lichter und bringe ihre Kraft zur Quelle zurück.",12)
	var field := LineEdit.new()
	field.text = "LICHTERHAIN"
	field.placeholder_text = "Welt-Seed"
	field.max_length = 64
	field.add_theme_font_size_override("font_size",12)
	box.add_child(field)
	var start := button(box,"Neuen Lichtpfad beginnen","unused")
	for connection in start.pressed.get_connections():
		start.pressed.disconnect(connection.callable)
	start.pressed.connect(func(): requested.emit("new",field.text))
	button(box,"Am Speicherpunkt fortsetzen","load").disabled = not has_save
	label(box,"WASD bewegen · Maus zielen · E interagieren\nLinksklick Lichtfunke · Rechtsklick Frostkreis · Leertaste ausweichen",10,HudCanvas.MUTED)
	label(box,"Prototyp 0.1 · Magier und erste Erkundungsrunde\nEin neuer Lauf ersetzt den Speicherpunkt beim Speichern.",9,HudCanvas.MUTED)
	start.grab_focus()

func pause_menu() -> void:
	var box := shell("pause","Eine kurze Rast","Die Welt wartet auf dich.",330)
	button(box,"Weitergehen","resume").grab_focus()
	var row := HBoxContainer.new()
	box.add_child(row)
	button(row,"Speichern · F5","save").size_flags_horizontal=Control.SIZE_EXPAND_FILL
	button(row,"Laden · F9","load").size_flags_horizontal=Control.SIZE_EXPAND_FILL
	label(box,"Lautstärke",11,HudCanvas.MUTED)
	var slider := HSlider.new()
	slider.min_value=0
	slider.max_value=1
	slider.step=0.05
	slider.value=settings.volume
	box.add_child(slider)
	slider.value_changed.connect(func(value): settings.volume=value; volume_changed.emit(value))
	var check := CheckButton.new()
	check.text="Bildschirmerschütterung"
	check.button_pressed=settings.shake
	check.add_theme_font_size_override("font_size",11)
	check.toggled.connect(func(value): settings.shake=value; shake_changed.emit(value))
	box.add_child(check)
	button(box,"Speichern und zum Titel","title")
	label(box,"F11 Vollbild · ESC weiter",10,HudCanvas.MUTED)

func dialogue(title: String, body: String, choices: Array) -> void:
	var box := shell("dialogue",title,body,370)
	for choice in choices:
		button(box,choice[0],choice[1])

func journal(run: RunState) -> void:
	var box := shell("journal","Dein Lichtpfad","Talente, Funde und Erinnerungen",470)
	label(box,"Stufe %d · %d / %d Erfahrung · %d Talentpunkte" % [run.level,run.xp,run.level*60,run.skill_points],11)
	for id in Content.section("skills"):
		var data: Dictionary = Content.section("skills")[id]
		var row := HBoxContainer.new()
		box.add_child(row)
		var copy := VBoxContainer.new()
		copy.custom_minimum_size.x=320
		copy.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		row.add_child(copy)
		label(copy,data.name,12,HudCanvas.GOLD)
		label(copy,data.description,10,HudCanvas.MUTED)
		var learn := button(row,"Gelernt" if id in run.learned else "Lernen","learn",id)
		learn.disabled = id in run.learned or run.skill_points<=0
	label(box,"Beutel: %d Lichtstaub · %d / 3 Waldlichter" % [run.motes,run.active_lights.size()],11)
	if run.quest_complete:
		label(box,"Relikt: Quellenfokus — aktive Waldlichter werden zu Rastpunkten.",10,HudCanvas.GOLD)
	else:
		label(box,"Eddas Auftrag: Drei Waldlichter wecken, dann zur Laternenrast zurückkehren.",10,HudCanvas.MUTED)
	button(box,"Zurück in den Wald · TAB","resume")

func death_menu() -> void:
	var box := shell("death","Das Licht trägt dich heim","Du behältst deine Funde. Edda bringt dich zur Laternenrast zurück.",370)
	button(box,"Am Lager erwachen","respawn").grab_focus()
	button(box,"Letzten Speicherpunkt laden","load")

func map_menu() -> void:
	clear()
	page="map"
	hud.show_map=true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode==DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause_game"):
		requested.emit("pause" if page.is_empty() else "resume" if page in ["pause","journal","map","dialogue"] else "none","")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("journal") and page in ["","journal"]:
		requested.emit("journal" if page.is_empty() else "resume","")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("map") and page in ["","map"]:
		requested.emit("map" if page.is_empty() else "resume","")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("save_game") and page in ["","pause"]:
		requested.emit("save","")
	elif event.is_action_pressed("load_game") and page in ["","pause"]:
		requested.emit("load","")
