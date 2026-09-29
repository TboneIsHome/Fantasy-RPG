extends SceneTree
## Runs only via verify_sandbox.py, in an isolated temporary user profile.
const Catalog = preload("res://developer/catalog.gd")
const Scenarios = preload("res://developer/scenarios.gd")
var checks := 0
var failures: Array[String] = []
var results: Array = []
var ui
var session

func _initialize() -> void: call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS SANDBOX: " if ok else "FAIL SANDBOX: ",title)

func verify() -> void:
	if OS.get_environment("LICHTERHAIN_SANDBOX_TEST_ISOLATED") != "1":
		print("FAIL: Use tools/verify_sandbox.py with its isolated user profile")
		quit(2)
		return
	ui = load("res://developer/sandbox.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	session = ui.session
	check(session.is_current(session.generation),"Actual sandbox scene initializes")
	check(session.fixture.region_id=="developer_arena" and session.fixture.terrain==null,"Arena has no quest-world generation dependency")
	check(session.fixture.run.source.resolution.is_empty() and session.fixture.run.learned==session.catalog.data.players.mage.learned,"Start uses transient preset, not sentinel production save")
	if OS.get_environment("LICHTERHAIN_SANDBOX_EXPORT")=="1":
		check(ProjectSettings.get_setting("application/run/main_scene")=="res://developer/sandbox.tscn","Developer export starts sandbox directly")
		check(OS.get_user_data_dir().ends_with("Lichterhain_DeveloperSandbox"),"Developer export uses isolated application directory")
	var original := JSON.stringify(Content.all())
	validate_catalog()
	for id in session.catalog.data.scenarios:
		var result: Dictionary = await Scenarios.new().run(id,session)
		results.append(result)
		for entry in result.checks: check(entry.passed,id+" "+entry.check)
	await controls_and_reset()
	check(JSON.stringify(Content.all())==original and Content.section("player").is_read_only(),"Test presets never mutate production definitions")
	check(ResourceLoader.load("res://scenes/game.tscn") != null,"Original production entry remains loadable")
	ui.queue_free()
	await process_frame
	await process_frame
	check(get_nodes_in_group("player").is_empty() and get_nodes_in_group("enemies").is_empty(),"Closing sandbox releases all actors")
	var file := FileAccess.open(OS.get_environment("LICHTERHAIN_SANDBOX_RESULT"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"scenarios":results,"native_windows_tested":false},"  "))
	file.close()
	print("SANDBOX RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)

func validate_catalog() -> void:
	var data: Dictionary = session.catalog.data
	check(Catalog.validate(data).is_empty() and data.is_read_only() and data.enemies.dummy.is_read_only(),"Validated presets are recursively immutable")
	for key in ["players","enemies","probe","scenarios","actions","waves"]:
		var broken := data.duplicate(true)
		broken.erase(key)
		check(not Catalog.validate(broken).is_empty(),"Missing section rejected: "+key)
	for value in [null,"100",true,NAN,INF,-1,10001]:
		var broken := data.duplicate(true)
		broken.enemies.dummy.hp = value
		check(not Catalog.validate(broken).is_empty(),"Invalid health rejected: "+str(value))
	for case in ["kind","skill","wave_reference","wave_count","action","distance","scenario","probe","max_enemies"]:
		var broken := data.duplicate(true)
		match case:
			"kind": broken.enemies.dummy.kind = "unknown"
			"skill": broken.players.mage.learned = ["unknown"]
			"wave_reference": broken.waves[0].enemies = ["unknown"]
			"wave_count": broken.waves[0].enemies = ["wolf","wolf","wolf","wolf","wolf","wolf","wolf","wolf","wolf"]
			"action": broken.actions = ["unknown"]
			"distance": broken.players.mage.distance = NAN
			"scenario": broken.scenarios.X = "unknown"
			"probe": broken.probe.erase("active")
			"max_enemies": broken.max_enemies = "bad"
		var errors := Catalog.validate(broken)
		check(not errors.is_empty() and errors[0].begins_with(Catalog.PATH),"Catalog path diagnostic: "+case)

func controls_and_reset() -> void:
	for profile in session.catalog.data.players:
		check(session.reset(profile,"dummy") and session.player_preset==profile and session.fixture.player.vitals.is_full(),"Supported player preset: "+profile)
		session.set_paused(true)
	for preset in session.catalog.data.enemies:
		check(session.reset("mage",preset) and session.fixture.target().definition.hp==session.catalog.data.enemies[preset].hp,"Supported enemy preset: "+preset)
		session.set_paused(true)
	var generation: int = session.generation
	check(not session.reset("unknown") and session.generation==generation,"Invalid reset leaves current fixture intact")
	check(session.spawn("dummy",Vector2(NAN,0))==null and session.spawn("unknown",Vector2.ZERO)==null,"Invalid spawn/reference rejected")
	check(not session.reset("mage","dummy",true,{"hp":NAN}) and not session.valid_overrides({"level":3}),"Invalid overrides do not start a fixture")
	session.reset("mage","dummy",true,{"hp":777,"protection":50,"stability":100})
	session.set_paused(true)
	check(session.fixture.target().hp==777 and session.fixture.target().definition.defense.stability==100,"Private enemy override reaches actual actor definition")
	session.cast("bolt")
	session.fixture.player.vitals.hp = 2
	session.start_probe()
	var old_action: AttackInstance = session.probe_action
	session.start_probe()
	check(old_action.timeline.state()==ActionTimeline.State.INTERRUPTED and not old_action in session.fixture.player.attack_actions,"Replacing probe does not retain paused old actions")
	var player_ref: WeakRef = weakref(session.fixture.player)
	session.reset()
	session.set_paused(true)
	check(session.fixture.target().hp==777 and session.fixture.player.vitals.is_full() and session.fixture.player.abilities.cooldowns.bolt==0,"Reset restores selected override/resources/cooldowns")
	check(session.fixture.combat.get_child_count()==1 and session.waves.index==-1 and session.waves.completed==0,"Reset clears payloads and complete wave state")
	await process_frame
	check(player_ref.get_ref()==null and get_nodes_in_group("player").size()==1,"Reset frees old player without duplicates")
	check(not session.advance_probe(0.1) and not session.position_target(INF,0,0),"Invalid diagnosis controls rejected")
	session.position_target(35,90,90)
	check(is_equal_approx(session.fixture.player.position.distance_to(session.fixture.target().position),35) and session.fixture.player.aim.is_equal_approx(Vector2.DOWN),"Position/facing control affects real actors")
	session.refill_player()
	check(session.single_enemy_attack(),"Single attack control starts real enemy lifecycle")
	for i in 10: session.spawn("dummy",session.fixture.player.position+Vector2(40+i*8,80))
	check(session.fixture.enemies().size()==int(session.catalog.data.max_enemies),"Enemy cap bounds manual spawning")
	session.start_waves()
	session.stop_waves()
	var count: int = session.fixture.enemies().size()
	session.waves.tick(10)
	check(not session.waves.running and session.paused and session.fixture.enemies().size()==count,"Wave stop prevents progression and pauses actors")
	ui.reset_selected()
	ui.session.set_paused(true)
	ui.spawn_selected()
	check(session.fixture.enemies().size()==2,"UI spawn control targets local fixture")
	ui.reset_selected()
	ui.start_probe()
	for i in 9: ui.step_probe()
	ui.distance.value = 24
	ui.angle.value = 0
	ui.facing.value = 0
	ui.apply_position()
	ui.contact_probe()
	check(session.fixture.target().hp<ui.hp.value and not session.telemetry.events.is_empty(),"UI probe buttons execute actual contact")
	var path: String = session.write_report()
	check(not path.is_empty() and path.ends_with("developer_sandbox/last_report.json") and JSON.parse_string(FileAccess.get_file_as_string(path)) is Dictionary,"Diagnostic report has dedicated path and valid JSON")
	for i in 150: session.telemetry.record("bounded_test",{"index":i})
	check(session.telemetry.events.size()==96,"Diagnostic history is bounded")
	Input.action_press("save_game")
	Input.action_press("load_game")
	await process_frame
	Input.action_release("save_game")
	Input.action_release("load_game")
	check(session.fixture.region_id=="developer_arena","Production save/load inputs do not enter game session")
