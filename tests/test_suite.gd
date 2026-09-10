extends SceneTree

var failures: Array[String] = []
var checks: int = 0
const TEST_SAVE := "user://automated_test_only.json"

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, title: String) -> void:
	checks+=1
	if not condition:
		failures.append(title)
		printerr("FAIL: "+title)
	else:
		print("PASS: "+title)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func run_tests() -> void:
	var started := Time.get_ticks_msec()
	var first := WorldGenerator.generate("LICHTERHAIN")
	var second := WorldGenerator.generate("LICHTERHAIN")
	check(first.tiles==second.tiles and first.points==second.points and first.enemies==second.enemies,"Identical seeds reproduce terrain, landmarks and enemies")
	check(first.tiles!=WorldGenerator.generate("OTHER-SEED").tiles,"Different seeds change the world")
	var all_reachable := true
	for i in 100:
		if not WorldGenerator.reachable(WorldGenerator.generate("reachability-%d" % i)):
			all_reachable=false
			printerr("Unreachable seed: ",i)
	check(all_reachable,"100 generated seeds: all landmarks and enemy clearings reachable")
	check(WorldGenerator.reachable(WorldGenerator.generate("Österreich ✨")),"Unicode seed stays valid and connected")
	check(not WorldGenerator.passable(first.tiles,Vector2i(-1,10)) and not WorldGenerator.passable(first.tiles,Vector2i(112,10)),"Map boundary rejects out-of-range coordinates")
	var vitals := Vitals.new()
	var abilities := MageAbilities.new()
	check(abilities.cast("bolt",vitals) and not abilities.cast("bolt",vitals),"Spell cooldown prevents repeated casts in one frame")
	vitals.mana=2
	abilities.tick(1)
	check(not abilities.cast("nova",vitals) and vitals.mana==2,"Insufficient mana cancels a spell without spending mana")
	vitals.refill()
	check(abilities.dash(vitals) and vitals.stamina==72 and not vitals.damage(20),"Dash spends stamina and provides invulnerability")
	check(not abilities.dash(vitals),"Dash cooldown cannot be bypassed")
	vitals.tick(1)
	check(vitals.damage(20) and not vitals.damage(20) and vitals.hp==80,"Damage immunity prevents overlapping hits")
	vitals.tick(2)
	check(vitals.mana<=100 and vitals.stamina<=100,"Regeneration is capped")
	var run := RunState.new()
	check(run.activate_light("light_0") and not run.activate_light("light_0") and run.xp==20,"Landmark rewards are granted exactly once")
	run.add_xp(40)
	check(run.level==2 and run.skill_points==1 and run.xp==0,"Experience grants a level and one talent point")
	check(run.learn("flow") and not run.learn("flow") and not run.learn("unknown"),"Talent points and duplicate/unknown skill rules enforced")
	var mage := MagePlayer.new()
	mage.position=first.spawn
	var data := SaveSystem.snapshot(run,mage,{"volume":0.4,"shake":true})
	check(SaveSystem.validate(data).is_empty(),"Valid save schema accepted")
	check(SaveSystem.write(data,TEST_SAVE).is_empty(),"Save written to dedicated test file")
	var loaded := SaveSystem.read(TEST_SAVE)
	check(loaded.error.is_empty() and loaded.data.run.learned==["flow"] and loaded.data.run.active_lights==["light_0"],"Save round-trip retains seed, skills and world changes")
	var bad := data.duplicate(true)
	bad.generator_version=999
	check(not SaveSystem.validate(bad).is_empty(),"Unknown generator version rejected")
	bad=data.duplicate(true)
	bad.player.mana="broken"
	check(not SaveSystem.validate(bad).is_empty(),"Wrong data types rejected")
	bad=data.duplicate(true)
	bad.run.active_lights=["light_0","light_0"]
	check(not SaveSystem.validate(bad).is_empty(),"Duplicate persistent world IDs rejected")
	bad=data.duplicate(true)
	bad.player.hp=NAN
	check(not SaveSystem.validate(bad).is_empty(),"Non-finite numeric save values rejected")
	SaveSystem.write(data,TEST_SAVE)
	var corrupt := FileAccess.open(TEST_SAVE,FileAccess.WRITE)
	corrupt.store_string("{not json")
	corrupt.close()
	check(SaveSystem.read(TEST_SAVE).get("notice","")!="","Corrupt primary save recovers from previous backup")
	bad=data.duplicate(true)
	bad.generator_version=2
	corrupt=FileAccess.open(TEST_SAVE,FileAccess.WRITE)
	corrupt.store_string(JSON.stringify(bad))
	corrupt.close()
	check(not SaveSystem.read(TEST_SAVE).error.is_empty(),"Future generator saves never silently fall back to an older backup")
	mage.free()
	var game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path=TEST_SAVE
	await process_frame
	check(game.ui.page=="title" and paused,"Game boots into a paused, usable title menu")
	game.handle_action("new","LICHTERHAIN")
	await frames(3)
	check(game.ui.page.is_empty() and not paused and game.player.input_enabled,"New game enables player control")
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	var old_position: Vector2=game.player.position
	Input.action_press("move_down")
	await frames(18)
	Input.action_release("move_down")
	check(game.player.position.y>old_position.y+10,"Movement input moves the real CharacterBody2D")
	game.player.position=Vector2(39,39)
	Input.action_press("move_left")
	await frames(30)
	Input.action_release("move_left")
	check(game.player.position.x>=36,"Solid map edge stops the player")
	game.player.position=game.terrain.data.spawn
	game.handle_action("pause")
	old_position=game.player.position
	var old_time: float=game.run.time_of_day
	Input.action_press("move_right")
	await frames(8)
	Input.action_release("move_right")
	check(game.player.position==old_position and game.run.time_of_day==old_time,"Pause stops movement and the world clock")
	game.handle_action("resume")
	var test_enemy := WildEnemy.new()
	test_enemy.configure({"id":"test-wolf","kind":"wolf","position":game.player.position+Vector2(35,0)},game.player,game.terrain.data.spawn)
	game.terrain.actors.add_child(test_enemy)
	# A controlled test enemy must not alter the serialized world IDs.
	await frames(2)
	var hp_before := test_enemy.hp
	game.player.vitals.refill()
	check(game.player.request_cast("nova",test_enemy.position),"Player casts the integrated area spell")
	check(test_enemy.hp<hp_before and test_enemy.slowed>0,"Frost circle damages and slows enemies in range")
	var damage_before := test_enemy.hp
	test_enemy.take_damage(1,Vector2.ZERO,true)
	check(is_equal_approx(damage_before-test_enemy.hp,11),"Light bolt on a slowed enemy adds shatter damage")
	test_enemy.queue_free()
	await frames(2)
	var target_enemy := WildEnemy.new()
	target_enemy.configure({"id":"test-projectile","kind":"wolf","position":game.player.position+Vector2(55,-10)},game.player,game.terrain.data.spawn)
	game.terrain.actors.add_child(target_enemy)
	await frames(2)
	hp_before=target_enemy.hp
	game.player.abilities.tick(10)
	game.player.request_cast("bolt",target_enemy.position)
	await frames(25)
	check(target_enemy.hp<hp_before,"Real moving projectile collides with and damages an enemy")
	var wall := StaticBody2D.new()
	wall.position=game.player.position+Vector2(25,-10)
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size=Vector2(8,38)
	wall_shape.shape=rectangle
	wall.add_child(wall_shape)
	game.world.add_child(wall)
	await frames(3)
	hp_before=target_enemy.hp
	game.player.abilities.tick(10)
	game.player.request_cast("bolt",target_enemy.position)
	await frames(25)
	check(target_enemy.hp==hp_before,"Solid cover blocks projectiles before they reach an enemy")
	game.player.abilities.tick(10)
	game.player.vitals.refill()
	game.player.request_cast("nova",target_enemy.position)
	check(target_enemy.hp==hp_before,"Frost targeting and its area damage respect solid cover")
	wall.queue_free()
	target_enemy.queue_free()
	await frames(2)
	game.run.add_xp(360)
	game.run.learn("flow")
	game.run.learn("bloom")
	game.run.learn("echo")
	game.player.vitals.mana=20
	game.player.abilities.tick(10)
	check(game.player.try_dash(Vector2.DOWN) and game.player.vitals.mana==32,"Flow talent converts a successful dash into mana")
	await frames(14)
	game.player.vitals.hp=50
	game.player.vitals.mana=100
	game.player.abilities.tick(10)
	game.player.request_cast("nova",game.player.position)
	check(game.player.vitals.hp==62,"Bloom talent heals a mage standing in their own frost circle")
	var echo_a := WildEnemy.new()
	var echo_b := WildEnemy.new()
	echo_a.configure({"id":"test-echo-a","kind":"wolf","position":game.player.position+Vector2(30,0)},game.player,game.terrain.data.spawn)
	echo_b.configure({"id":"test-echo-b","kind":"wolf","position":game.player.position+Vector2(55,0)},game.player,game.terrain.data.spawn)
	game.terrain.actors.add_child(echo_a)
	game.terrain.actors.add_child(echo_b)
	await frames(2)
	echo_a.slowed=3
	hp_before=echo_b.hp
	game.combat._bolt_hit(echo_a,echo_a.position,Vector2.RIGHT)
	check(echo_b.hp==hp_before-12,"Echo talent damages a second nearby enemy after a frost combo")
	echo_a.queue_free()
	echo_b.queue_free()
	await frames(2)
	game.player.position=WorldGenerator.center(game.terrain.data.points[1].tile)
	game.player.vitals.refill()
	var lunger := WildEnemy.new()
	lunger.configure({"id":"test-lunge","kind":"wolf","position":game.player.position+Vector2(35,0)},game.player,game.terrain.data.spawn)
	game.terrain.actors.add_child(lunger)
	lunger.state=WildEnemy.Mode.CHASE
	await frames(2)
	check(lunger.state==WildEnemy.Mode.WINDUP and game.player.vitals.hp==100,"Wolf telegraphs before dealing damage")
	var locked_target := lunger.attack_target
	game.player.position+=Vector2(0,55)
	await frames(45)
	check(lunger.attack_target==locked_target and game.player.vitals.hp==100,"Moving away from a telegraphed wolf attack avoids the hit")
	lunger.position=game.player.position+Vector2(4,0)
	lunger.state=WildEnemy.Mode.ATTACK
	lunger.timer=0.2
	lunger.attack_connected=false
	await frames(2)
	check(game.player.vitals.hp<100,"Wolf attack damages a player who stays in its path")
	lunger.queue_free()
	await frames(2)
	game.player.position=WorldGenerator.center(game.terrain.data.points[1].tile)
	game.player.vitals.refill()
	var shooter := WildEnemy.new()
	game.player.reset_transient()
	shooter.configure({"id":"test-wisp","kind":"wisp","position":game.player.position+Vector2(55,8)},game.player,game.terrain.data.spawn)
	game.terrain.actors.add_child(shooter)
	game.combat.connect_enemy(shooter)
	shooter.state=WildEnemy.Mode.CHASE
	await frames(2)
	check(shooter.state==WildEnemy.Mode.WINDUP,"Wisp has a distinct ranged attack windup")
	await frames(95)
	check(game.player.vitals.hp<100,"Wisp spawns a real hostile projectile that can hit the player")
	shooter.queue_free()
	game.player.position=game.terrain.data.spawn
	game.player.vitals.refill()
	await frames(2)
	for landmark in get_nodes_in_group("landmarks"):
		if landmark.kind=="shrine":
			game.interact(landmark)
	check(game.run.active_lights.size()==3,"Three world interactions advance the exploration objective")
	game.handle_action("reward")
	check(game.run.quest_complete and game.ui.page=="dialogue","Returning reward completes the objective and grants the relic")
	game.handle_action("resume")
	var living_before := get_nodes_in_group("enemies").size()
	var actual_enemy: WildEnemy=get_nodes_in_group("enemies")[0]
	var defeated_id := actual_enemy.id
	actual_enemy.take_damage(999)
	await frames(2)
	check(defeated_id in game.run.defeated and get_nodes_in_group("enemies").size()==living_before-1,"Enemy death grants persistent removal and experience")
	game.save_game()
	game.run.motes=999
	check(game.load_game(),"Integrated save reload succeeds")
	await frames(3)
	check(game.run.motes!=999 and game.run.quest_complete and defeated_id in game.run.defeated and get_nodes_in_group("enemies").size()==living_before-1,"Reload restores progression and keeps defeated enemies absent")
	game.player.vitals.invulnerable=0
	game.player.take_damage(999)
	check(game.ui.page=="death" and paused,"Death opens the recovery menu and pauses")
	game.handle_action("respawn")
	check(game.player.vitals.hp==100 and game.player.position==game.terrain.data.spawn and not paused,"Respawn restores a playable mage at the safe camp")
	check(game.run.quest_complete,"Death retains earned discoveries and quest progress")
	paused=false
	game.queue_free()
	for i in 5:
		await process_frame
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(TEST_SAVE+suffix):
			DirAccess.remove_absolute(TEST_SAVE+suffix)
	var report := {"checks":checks,"failures":failures,"duration_ms":Time.get_ticks_msec()-started,"godot":Engine.get_version_info().string}
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report_file := FileAccess.open("res://test-output/results.json",FileAccess.WRITE)
	report_file.store_string(JSON.stringify(report,"  "))
	report_file.close()
	print("RESULT: ",checks-failures.size(),"/",checks," checks passed; ",report.duration_ms," ms")
	quit(0 if failures.is_empty() else 1)
