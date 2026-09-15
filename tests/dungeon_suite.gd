extends SceneTree
var checks: int=0
var failures: Array[String]=[]
var game
const SAVE := "user://vault_test_only.json"

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, title: String) -> void:
	checks+=1
	if not condition: failures.append(title)
	print("PASS VAULT: " if condition else "FAIL VAULT: ",title)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func object(id: String) -> DungeonObject:
	for value in get_nodes_in_group("landmarks"):
		if value is DungeonObject and value.id==id: return value
	return null

func go_to(id: String) -> void:
	game.player.position=object(id).position+Vector2(0,24)
	game.player.vitals.invulnerable=50

func stop_enemies() -> void:
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)

func verify() -> void:
	var started := Time.get_ticks_msec()
	var first := DungeonGenerator.generate("LICHTERHAIN")
	var duplicate := DungeonGenerator.generate("LICHTERHAIN")
	check(first==duplicate,"Same seed reproduces rooms, passages, landmarks and encounters")
	check(first.rooms!=DungeonGenerator.generate("ANDERER-HIMMEL").rooms,"Other seeds change room dimensions")
	var reachable_all := true
	var secret_sealed := true
	var exits_valid := true
	for i in 100:
		var generated := DungeonGenerator.generate("vault-reach-%d" % i)
		var seen := DungeonGenerator.reachable(generated)
		var open_seen := DungeonGenerator.reachable(generated,true,true)
		for room in generated.rooms:
			if room.id!="secret" and not seen.has(room.center): reachable_all=false
			if room.id=="secret" and seen.has(room.center): secret_sealed=false
			if not open_seen.has(room.center): reachable_all=false
		for enemy in generated.enemies:
			if not seen.has(Vector2i(enemy.position/16)): reachable_all=false
		for point in generated.points:
			if point.kind in ["exit","font","memory","lever"] and not seen.has(point.tile): exits_valid=false
	check(reachable_all,"100 seeds: main rooms, rewards and all encounters reachable; opened secret also reachable")
	check(secret_sealed,"100 seeds: closed secret cannot be bypassed around the wall")
	check(exits_valid,"100 seeds: exit, fountain, memories and shortcut lever accessible before opening gates")
	check(DungeonGenerator.reachable(DungeonGenerator.generate("Österreich ✨")).size()>0,"Dungeon supports Unicode seeds")
	var old_bytes := FileAccess.get_file_as_bytes("res://tests/fixtures/v01_save.json")
	var legacy := SaveSystem.read("res://tests/fixtures/v01_save.json")
	check(legacy.error.is_empty() and legacy.data.save_version==SaveSystem.VERSION and legacy.data.run.region=="forest" and legacy.data.run.vault.relics.is_empty(),"Version 1 migrates to the current schema with an untouched, undiscovered dungeon")
	check(FileAccess.get_file_as_bytes("res://tests/fixtures/v01_save.json")==old_bytes,"Migration does not overwrite the original save")
	game=load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path=SAVE
	game.handle_action("new","LICHTERHAIN")
	await frames(2)
	game.interact(object("vault_entrance"))
	check(game.run.region=="forest" and game.ui.page=="dialogue","Dungeon entry explains the missing focus without teleporting")
	game.handle_action("resume")
	for id in SaveSystem.LIGHTS: game.run.activate_light(id)
	game.run.quest_accepted=true
	game.run.quest_complete=true
	game.player.vitals.hp=73
	game.player.vitals.mana=47
	game.player.vitals.stamina=82
	game.travel_to("vault")
	check(game.run.region=="vault" and game.player.vitals.hp==73 and game.player.vitals.mana==47 and game.player.vitals.stamina==82,"Crossing the entrance preserves all player resources")
	await frames(3)
	stop_enemies()
	check(get_nodes_in_group("player").size()==1 and get_nodes_in_group("enemies").size()==7,"Region switch leaves exactly one player and only the dungeon encounters")
	check(game.terrain is DungeonView and game.player.camera.limit_right==1536 and game.player.camera.limit_bottom==1024,"Dungeon uses its own scene, bounds and camera")
	var closed_gate := object("shortcut_gate")
	var long_route: int=game.terrain.navigation.get_id_path(Vector2i(14,16),Vector2i(14,46)).size()
	game.player.position=closed_gate.position-Vector2(0,28)
	Input.action_press("move_down")
	await frames(30)
	Input.action_release("move_down")
	check(game.player.position.y<closed_gate.position.y-10,"The closed shortcut blocks a real moving player")
	go_to("shortcut_lever")
	game.interact(object("shortcut_lever"))
	check(game.run.vault.shortcut_open and closed_gate.barrier.collision_layer==0 and not game.terrain.navigation.is_point_solid(Vector2i(14,31)),"Lever opens the physical gate and enemy navigation together")
	check(game.terrain.navigation.get_id_path(Vector2i(14,16),Vector2i(14,46)).size()<long_route,"Opening the shortcut measurably shortens the return route")
	game.player.position=closed_gate.position-Vector2(0,25)
	Input.action_press("move_down")
	await frames(40)
	Input.action_release("move_down")
	check(game.player.position.y>closed_gate.position.y+8,"The opened shortcut can actually be crossed")
	go_to("secret_gate")
	game.interact(object("secret_gate"))
	check(not game.run.vault.secret_open,"Secret wall needs its actual clue")
	go_to("water_memory")
	var xp_before: int=game.run.xp
	game.interact(object("water_memory"))
	check("water_memory" in game.run.vault.memories and game.ui.page=="dialogue","Reading the tablet records the clue and shows its story")
	game.handle_action("resume")
	var xp_after: int=game.run.xp
	game.interact(object("water_memory"))
	check(game.run.xp==xp_after and xp_after!=xp_before,"Repeated reading never grants repeated experience")
	game.handle_action("resume")
	go_to("secret_gate")
	game.interact(object("secret_gate"))
	check(game.run.vault.secret_open and object("secret_gate").barrier.collision_layer==0,"The learned sign opens the hidden passage")
	go_to("amber_seed")
	game.interact(object("amber_seed"))
	game.handle_action("resume")
	xp_after=game.run.xp
	game.interact(object("amber_seed"))
	check(game.run.vault.relics==["amber_seed"] and game.run.xp==xp_after,"Hidden treasure is persistent and can be collected only once")
	go_to("star_chart")
	game.interact(object("star_chart"))
	check("star_chart" in game.run.vault.relics and game.ui.page=="dialogue","Main exploration reward is a recorded find with its own story")
	game.handle_action("resume")
	go_to("vault_font")
	game.player.vitals.hp=30
	game.run.motes=1
	game.interact(object("vault_font"))
	check(game.player.vitals.hp==30 and game.run.motes==1,"Fountain cannot be used without sufficient light dust")
	game.run.motes=4
	game.interact(object("vault_font"))
	check(game.player.vitals.hp==100 and game.run.motes==2,"Fountain spends light dust and restores resources")
	game.interact(object("vault_font"))
	check(game.run.motes==2,"Full resources never waste light dust")
	var enemy: WildEnemy=get_nodes_in_group("enemies")[0]
	var dead_id: String=enemy.id
	enemy.take_damage(999)
	await frames(2)
	check(game.save_game() and game.load_game(),"Dungeon position and progress survive a real save/load")
	await frames(3)
	stop_enemies()
	var absent := true
	for living in get_nodes_in_group("enemies"):
		if living.id==dead_id: absent=false
	check(game.run.region=="vault" and game.run.vault.shortcut_open and game.run.vault.secret_open and absent and object("star_chart").active,"Reload restores gates, treasure art and defeated dungeon enemies")
	var data := SaveSystem.snapshot(game.run,game.player,game.settings)
	var bad := data.duplicate(true)
	bad.run.region="unknown"
	check(not SaveSystem.validate(bad).is_empty(),"Unknown region rejected")
	bad=data.duplicate(true);bad.run.vault.relics.append("unknown")
	check(not SaveSystem.validate(bad).is_empty(),"Unknown dungeon relic rejected")
	bad=data.duplicate(true);bad.run.vault.secret_open="yes"
	check(not SaveSystem.validate(bad).is_empty(),"Wrong gate data types rejected")
	bad=data.duplicate(true);bad.run.vault.memories=[]
	check(not SaveSystem.validate(bad).is_empty(),"Secret progress without its clue rejected")
	bad=data.duplicate(true);bad.player.x=8;bad.player.y=8
	check(not SaveSystem.validate(bad).is_empty(),"Dungeon saves cannot place the player in a wall")
	bad=data.duplicate(true);bad.dungeon_version=999
	check(not SaveSystem.validate(bad).is_empty(),"Unknown dungeon version rejected")
	bad=data.duplicate(true);bad.save_version=999
	check(not SaveSystem.validate(bad).is_empty(),"Future save format rejected")
	# A real character follows the grid around a corner instead of pushing into stone.
	var cistern: Dictionary=game.terrain.data.rooms[1]
	var left: int=cistern.rect.position.x
	game.player.position=WorldGenerator.center(Vector2i(left+2,18))
	game.player.vitals.invulnerable=999
	var walker := WildEnemy.new()
	walker.configure({"id":"test-navigation","kind":"wolf","position":WorldGenerator.center(Vector2i(left-4,14))},game.player,game.terrain.data.spawn)
	walker.pathfinder=game.terrain.navigation
	game.terrain.actors.add_child(walker)
	walker.state=WildEnemy.Mode.CHASE
	check(not walker.clear_shot(game.player.position),"Navigation scenario starts with a solid corner between actor and target")
	var stayed_on_floor := true
	for i in 150:
		await frames(1)
		if not DungeonGenerator.navigable(game.terrain.data,Vector2i(walker.position/16),true,true): stayed_on_floor=false
	check(stayed_on_floor and walker.position.x>left*16,"Enemy navigates around the corner while remaining on walkable floor")
	walker.queue_free()
	# Real, telegraphed ground attack, then leaving the target and dash protection.
	for living in get_nodes_in_group("enemies"): living.queue_free()
	await frames(2)
	game.player.position=WorldGenerator.center(Vector2i(78,18))
	game.player.vitals.refill()
	var kobold := WildEnemy.new()
	kobold.configure({"id":"test-kobold","kind":"kobold","position":game.player.position+Vector2(50,0)},game.player,game.terrain.data.spawn)
	game.terrain.actors.add_child(kobold)
	game.combat.connect_enemy(kobold)
	kobold.state=WildEnemy.Mode.CHASE
	await frames(2)
	check(kobold.state==WildEnemy.Mode.WINDUP,"Dornkobold starts with a visible windup")
	var locked := kobold.attack_target
	await frames(20)
	check(game.player.vitals.hp==100,"Telegraph itself deals no damage")
	game.player.position=locked+Vector2(-60,0)
	await frames(42)
	check(game.player.vitals.hp==100 and kobold.attack_target==locked,"Leaving the fixed marked area avoids the attack")
	kobold.set_physics_process(false)
	game.player.position=locked
	await frames(58)
	check(game.player.vitals.hp<100 and game.player.hindered>0,"Remaining in active roots causes damage and temporary slowing")
	for child in game.combat.get_children():
		if child is ThornPatch: child.queue_free()
	await frames(2)
	game.player.vitals.refill()
	game.player.abilities=MageAbilities.new()
	game.player.try_dash(Vector2.LEFT)
	game.combat._thorns(game.player.position)
	await frames(2)
	check(game.player.vitals.hp==100,"Dash immunity protects against the thorn pulse")
	await frames(180)
	var no_patches := true
	for child in game.combat.get_children():
		if child is ThornPatch: no_patches=false
	check(no_patches,"Temporary control zones are removed after their lifetime")
	game.player.vitals.invulnerable=0
	game.player.take_damage(999)
	game.handle_action("respawn")
	await frames(3)
	check(game.run.region=="forest" and game.player.position==game.terrain.data.spawn and game.player.vitals.hp==100,"Dying in the dungeon returns the mage safely to Edda's camp")
	check("star_chart" in game.run.vault.relics and game.run.vault.shortcut_open,"Dungeon discoveries survive death")
	for landmark in get_nodes_in_group("landmarks"):
		if landmark.kind=="npc": game.interact(landmark);break
	check(game.run.vault.reported and game.ui.page=="dialogue","Edda responds specifically to the recovered star chart")
	game.handle_action("discoveries")
	check("water_memory" in DiscoveryBook.known(game.run) and "star_chart" in DiscoveryBook.known(game.run),"Discovery journal contains only actual discoveries and finds")
	game.handle_action("resume")
	game.travel_to("vault")
	await frames(3)
	check(game.run.vault.relics.size()==2 and object("star_chart").active and object("secret_gate").active,"Returning to the dungeon retains world changes")
	game.travel_to("forest")
	await frames(3)
	check(game.run.region=="forest" and game.player.position.distance_to(object("vault_entrance").position)<25,"Exit returns the player beside the forest entrance")
	paused=false
	game.queue_free()
	await frames(5)
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(SAVE+suffix): DirAccess.remove_absolute(SAVE+suffix)
	var file := FileAccess.open("res://test-output/dungeon_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"duration_ms":Time.get_ticks_msec()-started,"seeds":100},"  "))
	file.close()
	print("DUNGEON RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
