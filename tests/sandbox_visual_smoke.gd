extends SceneTree
## Automated rendered UI exercise, not a manual Windows acceptance.
var ui
var checks := 0
var failures: Array[String] = []
var captures: Array[String] = []
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
	var path := "res://test-output/sandbox_"+name+".png"
	check(root.get_texture().get_image().save_png(path)==OK,"Rendered screenshot: "+name)
	captures.append(path)
func verify() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-output")
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
	var file := FileAccess.open("res://test-output/sandbox_visual_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"captures":captures,"native_windows_tested":false},"  "))
	file.close()
	print("SANDBOX VISUAL RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
