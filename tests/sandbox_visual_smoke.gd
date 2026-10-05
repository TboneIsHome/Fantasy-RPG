extends SceneTree
## Automated rendered UI exercise, not a manual Windows acceptance.
var ui
var checks := 0
var failures: Array[String] = []
var captures: Array[String] = []
var casts: Array[String] = []
var output := "res://test-output"
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS SANDBOX VISUAL: " if ok else "FAIL SANDBOX VISUAL: ",title)
func frames(count: int) -> void:
	for i in count:
		await process_frame
		await RenderingServer.frame_post_draw
func capture(name: String) -> void:
	await frames(2)
	var path := output+"/sandbox_"+name+".png"
	check(root.get_texture().get_image().save_png(path)==OK,"Rendered screenshot: "+name)
	captures.append(path)
func verify() -> void:
	if not OS.get_environment("LICHTERHAIN_SANDBOX_VISUAL_OUTPUT").is_empty():
		output = OS.get_environment("LICHTERHAIN_SANDBOX_VISUAL_OUTPUT")
	DirAccess.make_dir_recursive_absolute(output)
	ui = load("res://developer/sandbox.tscn").instantiate()
	root.add_child(ui)
	await frames(10)
	check(ui.arena.size.x>600 and ui.arena.size.y>350,"Playable arena retains usable viewport")
	check(Rect2(Vector2.ZERO,Vector2(1280,720)).encloses(ui.status.get_global_rect()),"Status is inside the 1280x720 window")
	await capture("arena")
	var p: MagePlayer = ui.session.fixture.player
	ui.hp.get_line_edit().grab_focus()
	Input.warp_mouse(ui.arena.get_global_rect().get_center()+Vector2(100,0))
	await frames(2)
	var click := InputEventMouseButton.new()
	click.position = ui.arena.get_global_rect().get_center()+Vector2(100,0)
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	Input.parse_input_event(click)
	await frames(3)
	click = click.duplicate()
	click.pressed = false
	Input.parse_input_event(click)
	await frames(2)
	check(p.input_enabled and not root.gui_get_focus_owner() is LineEdit and p.vitals.mana==Vitals.maximum("mana"),"Arena click exits value editing without firing a spell")
	var start := p.position
	Input.action_press("move_down")
	await create_timer(0.15).timeout
	Input.action_release("move_down")
	check(p.position.y>start.y,"Arena pointer enables real movement input")
	Input.action_press("block")
	await create_timer(0.05).timeout
	check(p.active_defense.mode==ActiveDefense.Mode.BLOCK,"Held F reaches real player defense")
	Input.action_release("block")
	await frames(2)
	Input.warp_mouse(Vector2(1100,180))
	await frames(3)
	var mana := p.vitals.mana
	Input.action_press("bolt")
	await create_timer(0.05).timeout
	Input.action_release("bolt")
	check(p.vitals.mana==mana and not p.input_enabled,"Pointer over controls prevents accidental cast")
	await mouse_cast_paths()
	ui.reset_selected()
	ui.distance.value = 24
	ui.apply_position()
	ui.start_probe()
	for i in 9: ui.step_probe()
	ui.contact_probe()
	var tabs := ui.find_children("*","TabContainer",true,false)[0] as TabContainer
	tabs.current_tab = 1
	await create_timer(0.15).timeout
	check("ACTIVE" in ui.diagnostic.text and "contact_probe" in ui.history.text,"Diagnostics show actual phase and contact event")
	await capture("diagnostics")
	var scroll := tabs.get_child(1) as ScrollContainer
	scroll.scroll_vertical = 10000
	await capture("history")
	await ui.run_all()
	check(ui.session.last_scenario.passed,"Rendered scenario runner completes A01–A12")
	check(ui.session.paused and "PASS" in ui.status.text,"Scenario completion is explicit and paused")
	tabs.current_tab = 0
	(tabs.get_child(0) as ScrollContainer).scroll_vertical = 10000
	await capture("scenarios")
	ui.reset_selected()
	ui.start_waves()
	await create_timer(0.5).timeout
	check(ui.session.waves.running and ui.session.fixture.enemies().size()==1,"Live wave starts in rendered arena")
	ui.stop_waves()
	check(ui.session.paused and not ui.session.waves.running,"Wave Stop pauses the current encounter")
	ui.reset_selected()
	check(ui.session.fixture.enemies().size()==1 and ui.session.fixture.player.vitals.is_full(),"UI Reset returns to selected full preset")
	ui.queue_free()
	await frames(3)
	var file := FileAccess.open(output+"/sandbox_visual_results.json",FileAccess.WRITE)
	if file == null:
		push_error("Cannot write sandbox visual results: "+output)
		quit(2)
		return
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"captures":captures,"native_windows_tested":false},"  "))
	file.close()
	print("SANDBOX VISUAL RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)

func mouse_button(button: int, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = ui.get_global_mouse_position()
	event.global_position = event.position
	event.button_index = button
	event.pressed = pressed
	event.button_mask = (MOUSE_BUTTON_MASK_LEFT if button==MOUSE_BUTTON_LEFT else MOUSE_BUTTON_MASK_RIGHT) if pressed else 0
	Input.parse_input_event(event)

func prepare_mouse_cast() -> MagePlayer:
	ui.reset_selected()
	casts.clear()
	var p: MagePlayer = ui.session.fixture.player
	p.cast_requested.connect(func(id,_origin,_target): casts.append(id))
	var target: Vector2 = ui.session.fixture.target().global_position
	Input.warp_mouse(ui.arena.global_position+(ui.viewport.get_canvas_transform()*target)*ui.arena.stretch_shrink)
	await frames(4)
	return p

func mouse_cast_paths() -> void:
	# Real mouse events travel through GUI focus, InputMap, MagePlayer, and CombatSystem.
	# No direct request_cast/session.cast or Input.action_press substitutes here.
	for button in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
		var id := "bolt" if button==MOUSE_BUTTON_LEFT else "nova"
		var p := await prepare_mouse_cast()
		var enemy: WildEnemy = ui.session.fixture.target()
		var health := enemy.hp
		if button==MOUSE_BUTTON_RIGHT: ui.attacks.grab_focus()
		mouse_button(button,true)
		await create_timer(0.08).timeout
		check(casts==[id],"Mouse binding casts exactly once: "+id)
		check(is_equal_approx(p.vitals.mana,Vitals.maximum("mana")-float(MageAbilities.definition(id).cost)),"Mouse cast uses existing mana cost: "+id)
		check(p.attack_action!=null and p.attack_action.action_id==StringName(id+"_cast"),"Mouse cast creates real M07 action: "+id)
		mouse_button(button,false)
		await create_timer(0.3).timeout
		check(enemy.hp<health,"Mouse cast reaches M06 resolution and target health: "+id)
		check(casts==[id],"Mouse release does not duplicate action: "+id)
	var p := await prepare_mouse_cast()
	mouse_button(MOUSE_BUTTON_RIGHT,true)
	await create_timer(0.08).timeout
	ui.refill()
	await create_timer(0.08).timeout
	check(casts==["nova"],"Held RMB remains edge-triggered even after cooldown reset")
	mouse_button(MOUSE_BUTTON_RIGHT,false)
	await frames(4)
	mouse_button(MOUSE_BUTTON_RIGHT,true)
	await create_timer(0.08).timeout
	check(casts==["nova","nova"],"Releasing and pressing RMB permits the next cast")
	mouse_button(MOUSE_BUTTON_RIGHT,false)
	await frames(4)
	for button in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
		p = await prepare_mouse_cast()
		ui.hp.get_line_edit().grab_focus()
		await frames(2)
		mouse_button(button,true)
		await create_timer(0.08).timeout
		check(casts.is_empty() and p.vitals.is_full() and not root.gui_get_focus_owner() is LineEdit,"Leaving numeric edit consumes only the focus click: "+str(button))
		mouse_button(button,false)
		await frames(4)
		mouse_button(button,true)
		await create_timer(0.08).timeout
		check(casts==["bolt" if button==MOUSE_BUTTON_LEFT else "nova"],"Next mouse press casts after numeric edit: "+str(button))
		mouse_button(button,false)
		await frames(4)
	p = await prepare_mouse_cast()
	ui.session.set_paused(true)
	mouse_button(MOUSE_BUTTON_RIGHT,true)
	await create_timer(0.08).timeout
	check(casts.is_empty() and p.vitals.is_full(),"Paused arena rejects mouse cast")
	mouse_button(MOUSE_BUTTON_RIGHT,false)
	await frames(4)
	p = await prepare_mouse_cast()
	Input.warp_mouse(Vector2(1100,180))
	await frames(4)
	mouse_button(MOUSE_BUTTON_RIGHT,true)
	await create_timer(0.08).timeout
	check(casts.is_empty() and p.vitals.is_full(),"RMB over controls cannot cast into arena")
	mouse_button(MOUSE_BUTTON_RIGHT,false)
	await frames(4)
