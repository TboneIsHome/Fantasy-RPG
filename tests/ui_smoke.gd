extends SceneTree

var failures: Array[String] = []
var checks: int = 0

func _initialize() -> void:
	call_deferred("run_checks")

func check(condition: bool, title: String) -> void:
	checks+=1
	if not condition:
		failures.append(title)
		printerr("FAIL UI: "+title)
	else:
		print("PASS UI: "+title)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode=code
	event.pressed=true
	Input.parse_input_event(event)
	event=InputEventKey.new()
	event.physical_keycode=code
	event.pressed=false
	Input.parse_input_event(event)

func buttons(node: Node) -> Array[Button]:
	var list: Array[Button]=[]
	for child in node.get_children():
		if child is Button:
			list.append(child)
		list.append_array(buttons(child))
	return list

func frames() -> void:
	for i in 5:
		await process_frame

func fits(ui: GameUI) -> bool:
	if not is_instance_valid(ui.panel):
		return false
	for node in ui.panel.get_children():
		if node is PanelContainer:
			var bounds: Rect2 = node.get_global_rect()
			return bounds.position.x>=0 and bounds.position.y>=0 and bounds.end.x<=640 and bounds.end.y<=360
	return false

func run_checks() -> void:
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path="user://ui_smoke_only.json"
	await frames()
	check(fits(game.ui),"Title menu fits inside 640 x 360")
	for item in buttons(game.ui.panel):
		if item.text=="Neuen Lichtpfad beginnen":
			item.pressed.emit()
			break
	await frames()
	check(game.ui.page.is_empty() and not paused,"Start button opens a playable game")
	key(KEY_TAB)
	await frames()
	check(game.ui.page=="journal" and paused and fits(game.ui),"TAB opens the readable journal")
	key(KEY_TAB)
	await frames()
	check(game.ui.page.is_empty() and not paused,"TAB closes the journal even after a button has focus")
	key(KEY_M)
	await frames()
	check(game.ui.page=="map" and game.ui.hud.show_map and paused,"M opens the map and pauses")
	key(KEY_ESCAPE)
	await frames()
	check(game.ui.page.is_empty() and not game.ui.hud.show_map,"ESC closes the map")
	key(KEY_ESCAPE)
	await frames()
	check(game.ui.page=="pause" and fits(game.ui),"ESC opens the pause menu within the viewport")
	for item in buttons(game.ui.panel):
		if item.text=="Weitergehen":
			item.pressed.emit()
			break
	await frames()
	check(not paused and game.ui.page.is_empty(),"Continue button resumes the world")
	for landmark in get_nodes_in_group("landmarks"):
		if landmark.kind=="npc":
			game.interact(landmark)
			break
	await frames()
	check(game.ui.page=="dialogue" and fits(game.ui),"Edda dialogue fits the viewport")
	for item in buttons(game.ui.panel):
		if item.text=="Ich suche die Waldlichter":
			item.pressed.emit()
			break
	await frames()
	check(game.run.quest_accepted and not paused,"Dialogue button accepts the exploration objective")
	for id in SaveSystem.LIGHTS:
		game.run.activate_light(id)
	game.run.quest_complete=true
	game.handle_action("journal")
	await frames()
	check(fits(game.ui),"Journal still fits with the relic description")
	game.run.vault.memories.assign(DungeonProgress.MEMORY_IDS)
	game.run.vault.relics.assign(DungeonProgress.RELIC_IDS)
	for id in DiscoveryBook.entries():
		if not id in DungeonProgress.MEMORY_IDS and not id in DungeonProgress.RELIC_IDS:
			game.run.discoveries.append(id)
	for item in buttons(game.ui.panel):
		if item.text=="Entdeckungen":
			item.pressed.emit()
			break
	await frames()
	check(paused and fits(game.ui),"Discovery tab remains paused and fits with every lore entry")
	var scroll: ScrollContainer=game.ui.panel.find_children("*","ScrollContainer",true,false)[0]
	scroll.scroll_vertical=100000
	await frames()
	var last_text: Label=scroll.get_child(0).get_child(scroll.get_child(0).get_child_count()-1)
	check(scroll.scroll_vertical>0 and last_text.get_global_rect().end.y<=scroll.get_global_rect().end.y+1,"Last discovery is reachable by scrolling")
	key(KEY_TAB)
	await frames()
	check(game.ui.page.is_empty() and not paused,"TAB closes the scrolled discovery tab")
	paused=false
	game.queue_free()
	await frames()
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/ui_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures},"  "))
	file.close()
	print("UI RESULT: ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
