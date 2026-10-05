extends Control
const Session = preload("res://developer/session.gd")
const Scenarios = preload("res://developer/scenarios.gd")
var session: Node
var arena: SubViewportContainer
var viewport: SubViewport
var players: OptionButton
var enemies: OptionButton
var attacks: OptionButton
var scenarios: OptionButton
var hp: SpinBox
var protection: SpinBox
var stability: SpinBox
var distance: SpinBox
var angle: SpinBox
var facing: SpinBox
var pause_button: Button
var diagnostic: RichTextLabel
var history: RichTextLabel
var status: Label
var profile_note: Label
var live_summary: Label
var busy := false
var refresh := 0.0

func _ready() -> void:
	get_window().content_scale_size = Vector2i(1280,720)
	InputSetup.install()
	process_physics_priority = -100
	build_ui()
	session = Session.new()
	add_child(session)
	var world := Node2D.new()
	viewport.add_child(world)
	if not session.initialize(world):
		say("Start abgelehnt: " + session.last_error)
		return
	for id in session.catalog.data.players: option(players,id,session.catalog.data.players[id].label)
	for id in session.catalog.data.enemies: option(enemies,id,session.catalog.data.enemies[id].label)
	for id in session.catalog.data.actions: option(attacks,id,Content.section("spells")[id].name)
	for id in session.catalog.data.scenarios: option(scenarios,id,id+" · "+session.catalog.data.scenarios[id])
	players.select(2)
	preset_fields()
	say("Bereit · Maus in die Arena zum Spielen. Rechts Presets und reproduzierbare Tests.")

func build_ui() -> void:
	var style_theme := Theme.new()
	style_theme.default_font_size = 16
	style_theme.set_color("font_color","Label",Color("dbe9e5"))
	for state in ["normal","hover","pressed","focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("294e4e") if state=="hover" else Color("1c343c")
		style.set_corner_radius_all(5)
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 7
		style.content_margin_bottom = 7
		style_theme.set_stylebox(state,"Button",style)
		style_theme.set_stylebox(state,"OptionButton",style)
	theme = style_theme
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,16)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation",10)
	margin.add_child(page)
	var header := row(page)
	var heading := label(header,"LICHTERHAIN  /  Entwickler-Sandbox",25)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button(header,"Reset  F2",reset_selected)
	pause_button = button(header,"Pause  P",toggle_pause)
	label(page,"M07 Combat-Labor  ·  echte M06/M07-Pfade  ·  keine Spielstände  ·  Testwerte sind keine Spielbalance",14)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",14)
	page.add_child(body)
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(left)
	arena = SubViewportContainer.new()
	arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.stretch = true
	arena.stretch_shrink = 2
	# Keep the previous editor focus visible to arena_input; the arena is not an editor.
	arena.focus_mode = Control.FOCUS_NONE
	arena.gui_input.connect(arena_input)
	left.add_child(arena)
	viewport = SubViewport.new()
	viewport.size = Vector2i(410,260)
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	arena.add_child(viewport)
	live_summary = label(left,"",14)
	var attack_row := row(left)
	attacks = select(attack_row)
	button(attack_row,"Auf Ziel zaubern",cast_selected)
	button(attack_row,"Gegnerangriff  R",enemy_attack)
	profile_note = label(left,"",14)
	label(left,"WASD bewegen · Maus zielen · L/R-Maus zaubern · Leertaste Dodge · F Block · Q Parry",14)
	var tabs := TabContainer.new()
	tabs.custom_minimum_size.x = 400
	body.add_child(tabs)
	var setup := scroll_tab(tabs,"Versuche")
	section(setup,"STARTZUSTAND")
	players = select(setup)
	players.item_selected.connect(func(_index): preset_fields())
	enemies = select(setup)
	enemies.item_selected.connect(func(_index): preset_fields())
	var values := row(setup)
	hp = number(values,"HP",1,10000,250)
	protection = number(values,"Protection",0,10000,0)
	stability = number(values,"Stability",0,10000,0)
	var actions := row(setup)
	button(actions,"Übernehmen / Reset",reset_selected)
	button(actions,"+ Gegner",spawn_selected)
	button(setup,"Spieler auffüllen + Cooldowns zurücksetzen",refill)
	section(setup,"POSITION / RICHTUNG")
	var positions := row(setup)
	distance = number(positions,"Abstand",0,250,85)
	angle = number(positions,"Zielwinkel °",-180,180,0)
	facing = number(positions,"Blickwinkel °",-180,180,0)
	button(setup,"Ziel versetzen / Blick setzen",apply_position)
	label(setup,"0° rechts · 90° unten · gilt sofort; freie KI bewegt sich danach weiter.",13)
	section(setup,"REPRODUZIERBARE SZENARIEN")
	scenarios = select(setup)
	var runs := row(setup)
	button(runs,"Szenario ausführen",run_selected)
	button(runs,"Alle A01–A12",run_all)
	label(setup,"Kontrollierte echte Pfade; danach pausiert. Reset kehrt zum gewählten Preset zurück.",13)
	section(setup,"BEGRENZTE WELLEN")
	var wave_row := row(setup)
	button(wave_row,"Start / Neustart",start_waves)
	button(wave_row,"Stop + Pause",stop_waves)
	label(setup,"3 Wellen · Wolf → Irrlicht → Dornkobold · steigende Testwerte",13)
	var inspect := scroll_tab(tabs,"Diagnose")
	section(inspect,"KONTAKTPROBE")
	label(inspect,"Explizite Test-Action mit M07-Kontakt. Zeitschritt bewegt keine Körper. Zielabstand ≤ 42; Blick zum Ziel.",13)
	button(inspect,"Probe starten + Pause",start_probe)
	var steps := row(inspect)
	button(steps,"+50 ms",step_probe)
	button(steps,"Kontakt",contact_probe)
	button(inspect,"Unterbrechen",interrupt_probe)
	section(inspect,"AKTUELLER ECHTER ZUSTAND")
	diagnostic = rich(inspect)
	section(inspect,"LETZTE EREIGNISSE")
	label(inspect,"Live: Defense und M06-Ergebnis. Vollständige Kontaktablehnungen: nur gezielte Probe / Szenario.",13)
	history = rich(inspect)
	button(inspect,"Diagnosebericht speichern",save_report)
	status = label(page,"Lade Sandbox …",14)
	status.custom_minimum_size.y = 32

func label(parent: Node, text: String, size: int = 16) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",size)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node

func button(parent: Node, text: String, callback: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.focus_mode = Control.FOCUS_NONE
	node.pressed.connect(callback)
	parent.add_child(node)
	return node

func row(parent: Node) -> HBoxContainer:
	var node := HBoxContainer.new()
	node.add_theme_constant_override("separation",6)
	parent.add_child(node)
	return node

func select(parent: Node) -> OptionButton:
	var node := OptionButton.new()
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node

func option(node: OptionButton, id: String, text: String) -> void:
	node.add_item(text)
	node.set_item_metadata(node.item_count-1,id)

func selected(node: OptionButton) -> String:
	return str(node.get_item_metadata(node.selected)) if node.selected>=0 else ""

func number(parent: Node, caption: String, minimum: float, maximum: float, value: float) -> SpinBox:
	var group := VBoxContainer.new()
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(group)
	label(group,caption,13)
	var node := SpinBox.new()
	node.min_value = minimum
	node.max_value = maximum
	node.value = value
	group.add_child(node)
	return node

func section(parent: Node, caption: String) -> void:
	var line := HSeparator.new()
	parent.add_child(line)
	var node := label(parent,caption,13)
	node.add_theme_color_override("font_color",Color("91c5b5"))

func scroll_tab(parent: Node, caption: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = caption
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",8)
	scroll.add_child(content)
	return content

func rich(parent: Node) -> RichTextLabel:
	var node := RichTextLabel.new()
	node.fit_content = true
	node.scroll_active = false
	node.bbcode_enabled = true
	node.add_theme_font_size_override("normal_font_size",14)
	parent.add_child(node)
	return node

func available() -> bool:
	return not busy and is_instance_valid(session) and session.is_current(session.generation)

func say(text: String) -> void:
	status.text = text

func preset_fields() -> void:
	if not available(): return
	var preset: Dictionary = session.catalog.data.enemies[selected(enemies)]
	hp.value = preset.hp
	protection.value = preset.protection
	stability.value = preset.stability
	distance.value = session.catalog.data.players[selected(players)].distance
	profile_note.text = session.catalog.data.players[selected(players)].note

func overrides() -> Dictionary:
	return {"hp":hp.value,"protection":protection.value,"stability":stability.value}

func reset_selected() -> void:
	if not available(): return
	session.reset(selected(players),selected(enemies),true,overrides())
	angle.value = 0
	facing.value = 0
	distance.value = session.catalog.data.players[selected(players)].distance
	say("Reset · frische Actors, Ressourcen, Cooldowns und Generation %d" % session.generation)

func toggle_pause() -> void:
	if available(): session.set_paused(not session.paused)

func cast_selected() -> void:
	if available(): say("Zauber angenommen" if session.cast(selected(attacks)) else "Zauber abgelehnt: Ressourcen, Cooldown oder Combat-State prüfen.")

func enemy_attack() -> void:
	if available(): say("Gegneraktion gestartet" if session.single_enemy_attack() else "Gegneraktion derzeit nicht möglich.")

func spawn_selected() -> void:
	if not available(): return
	var count: int = session.fixture.enemies().size()
	var point: Vector2 = session.fixture.player.position+Vector2(90,(count%5-2)*24)
	say("Gegner erzeugt" if session.spawn(selected(enemies),point,overrides()) != null else "Spawn abgelehnt; Arena-Limit oder Werte prüfen.")

func refill() -> void:
	if available(): session.refill_player(); say("Expliziter Entwickler-Reset: Spielerressourcen und Cooldowns.")

func apply_position() -> void:
	if available(): say("Position gesetzt" if session.position_target(distance.value,angle.value,facing.value) else "Kein gültiges Ziel oder Position außerhalb der Arena.")

func start_waves() -> void:
	if available(): session.start_waves(); say("Wellen gestartet; Reset beginnt erneut.")

func stop_waves() -> void:
	if available(): session.stop_waves(); say("Wellen beendet und Arena pausiert.")

func start_probe() -> void:
	if available(): session.set_paused(true); session.start_probe(); say("Probe: Startup · +50 ms und Kontakt schrittweise prüfen.")

func step_probe() -> void:
	if available(): session.advance_probe(0.05)

func contact_probe() -> void:
	if not available(): return
	var result: CombatContact = session.probe()
	say("Probe fehlt oder Ziel verbraucht" if result==null else "Kontakt: %s / %s" % [result.outcome,result.reason])

func interrupt_probe() -> void:
	if available() and session.probe_action != null: session.probe_action.timeline.interrupt()

func save_report() -> void:
	if not available(): return
	var path: String = session.write_report()
	say("Bericht: "+path if not path.is_empty() else "Bericht konnte nicht gespeichert werden.")

func run_selected() -> void:
	if available(): await execute([selected(scenarios)])

func run_all() -> void:
	if available(): await execute(session.catalog.data.scenarios.keys())

func execute(ids: Array) -> void:
	busy = true
	var results: Array = []
	var passed := true
	for id in ids:
		say("Prüfe "+id+" …")
		var result: Dictionary = await Scenarios.new().run(id,session)
		results.append(result)
		passed = passed and result.passed
	session.last_scenario = {"results":results,"passed":passed}
	busy = false
	say("PASS · %d Szenarien. Arena pausiert; Details im Diagnosebericht. Reset für freies Testen." % ids.size() if passed else "FAIL · Details im Diagnosebericht. Kein Erfolg wird übersprungen.")

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if get_viewport().gui_get_focus_owner() is LineEdit: return
	match event.physical_keycode:
		KEY_F2: reset_selected()
		KEY_P: toggle_pause()
		KEY_R: enemy_attack()

func arena_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or not event.pressed: return
	var focused := get_viewport().gui_get_focus_owner()
	if focused == null: return
	var editing := focused is LineEdit
	focused.release_focus()
	if editing and is_instance_valid(session) and session.is_current(session.generation):
		session.fixture.player.cast_armed = false

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(session) or not session.is_current(session.generation): return
	var enabled: bool = not busy and not session.paused and session.fixture.player.combat_alive() and arena.get_global_rect().has_point(get_global_mouse_position()) and not get_viewport().gui_get_focus_owner() is LineEdit
	session.fixture.player.input_enabled = enabled
	if not enabled: session.fixture.player.cast_armed = false

func _process(delta: float) -> void:
	refresh += delta
	if refresh < 0.1 or not is_instance_valid(session) or not session.is_current(session.generation): return
	refresh = 0
	pause_button.text = "Weiter  P" if session.paused else "Pause  P"
	var state: Dictionary = session.snapshot()
	var p: Dictionary = state.player
	var target: Dictionary = state.target
	live_summary.text = "LP %.0f · MP %.0f · AU %.0f   |   %s   |   Ziel %s   |   %d Gegner" % [p.hp,p.mana,p.stamina,p.defense,"–" if target.is_empty() else "%.0f LP" % target.hp,state.enemies]
	diagnostic.text = "[b]Generation %d · Welle %d[/b]\nLP %.1f · MP %.1f · AU %.1f\nPosition %s · Blick %s\nDefense %s (%.3f s)\nReaction %s\nCooldowns: Funke %.2f / Frost %.2f / Dodge %.2f\n\n[b]Player-Action[/b]\n%s\n\n[b]Ziel[/b]\n%s\n\n[b]Kontaktprobe[/b]\n%s" % [state.generation,state.wave.index,p.hp,p.mana,p.stamina,p.position,p.aim,p.defense,p.defense_remaining,p.reaction,p.cooldowns.bolt,p.cooldowns.nova,p.cooldowns.dash,action_text(p.action),"Kein lebendes Ziel" if target.is_empty() else "%s · ID %s\nHP %.1f · Abstand %.1f\nPosition %s\nDefense %s · Reaction %s\n%s" % [target.preset,target.id,target.hp,target.distance,target.position,target.defense,target.reaction,action_text(target.action)],action_text(state.probe)]
	var lines: PackedStringArray = []
	for item in session.telemetry.events.slice(-6): lines.append(JSON.stringify(item))
	history.text = "\n\n".join(lines)

func action_text(data: Dictionary) -> String:
	if data.is_empty(): return "Keine Action"
	return "%s · %s · %.3f s\nInstanz %s · Generation %d" % [data.id,data.phase,data.time,data.instance,data.generation]
