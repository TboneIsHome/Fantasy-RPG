extends SceneTree
var game
var checks: int = 0
var failures: Array[String] = []
const SAVE := "user://source_test_only.json"

func _initialize() -> void:
	call_deferred("verify")

func check(condition: bool, title: String) -> void:
	checks+=1
	if not condition: failures.append(title)
	print("PASS SOURCE: " if condition else "FAIL SOURCE: ",title)

func frames(count: int = 3) -> void:
	for i in count:
		await physics_frame
		await process_frame

func object(id: String) -> Landmark:
	for value in get_nodes_in_group("landmarks"):
		if value.id==id: return value
	return null

func go(id: String) -> void:
	game.handle_action("resume")
	game.player.position=object(id).position+Vector2(0,24)
	game.player.knockback=Vector2.ZERO

func stop_normal_enemies() -> void:
	for enemy in get_nodes_in_group("enemies"):
		if not enemy is SourceGuardian: enemy.set_physics_process(false)

func total_xp() -> int:
	return game.run.xp+30*game.run.level*(game.run.level-1)

func fits() -> bool:
	if not is_instance_valid(game.ui.panel): return false
	for panel in game.ui.panel.get_children():
		if panel is PanelContainer:
			var rect: Rect2=panel.get_global_rect()
			return rect.position.x>=0 and rect.position.y>=0 and rect.end.x<=640 and rect.end.y<=360
	return false

func fresh_vault() -> void:
	game.handle_action("new","LICHTERHAIN")
	stop_normal_enemies()
	game.interact(object("edda"))
	game.handle_action("accept")
	for id in SaveSystem.LIGHTS: game.interact(object(id))
	game.interact(object("edda"))
	game.handle_action("reward")
	game.handle_action("resume")
	game.interact(object("vault_entrance"))
	stop_normal_enemies()
	game.player.vitals.invulnerable=999
	await frames()

func wait_windup(boss: SourceGuardian) -> void:
	for i in 180:
		if boss.state==WildEnemy.Mode.WINDUP: return
		await frames(1)
	check(false,"Guardian starts its next windup within three seconds")

func wait_release(boss: SourceGuardian) -> void:
	for i in 120:
		if boss.state!=WildEnemy.Mode.WINDUP: return
		await frames(1)
	check(false,"Guardian releases its announced attack")

func verify() -> void:
	var started := Time.get_ticks_msec()
	var reachable := true
	for i in 100:
		var seen := DungeonGenerator.reachable(DungeonGenerator.generate("source-%d" % i))
		if not seen.has(Vector2i(78,43)) or not seen.has(Vector2i(78,51)): reachable=false
	check(reachable,"100 seeds keep the binding and guardian positions reachable through existing dungeon routes")
	for suffix in ["",".bak",".tmp",".pre-v03",".pre-v04"]:
		if FileAccess.file_exists(SAVE+suffix): DirAccess.remove_absolute(SAVE+suffix)
	var original := FileAccess.get_file_as_bytes("res://tests/fixtures/v03_completed_save.json")
	var old_original := FileAccess.get_file_as_bytes("res://tests/fixtures/v01_save.json")
	var old := SaveSystem.read("res://tests/fixtures/v03_completed_save.json")
	check(old.error.is_empty() and old.data.save_version==3 and old.migrated_from==2,"Genuine 0.3 save explicitly migrates to schema 3")
	check(old.data.run.source==SourceQuest.new().serialize() and old.data.run.inventory==RelicInventory.new().serialize(),"Old dungeon progress starts with an undecided source and empty equipment slot")
	game=load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path=SAVE
	DirAccess.copy_absolute("res://tests/fixtures/v03_completed_save.json",SAVE)
	DirAccess.copy_absolute("res://tests/fixtures/v01_save.json",SAVE+".pre-v03")
	check(game.load_game() and game.run.region=="vault" and game.player.vitals.hp==77 and game.player.vitals.mana==43 and game.player.vitals.stamina==67,"Actual old dungeon save preserves exact location and resources")
	check(game.run.vault.secret_open and game.run.vault.shortcut_open and game.run.vault.relics.size()==2 and game.run.source.has_evidence(game.run.vault),"Existing 0.3 memories and chart already qualify for investigation")
	check(game.save_game() and FileAccess.get_file_as_bytes(SAVE+".pre-v04")==original and FileAccess.get_file_as_bytes(SAVE+".pre-v03")==old_original,"Upgrade preserves both the exact 0.3 save and an existing older backup")
	check(game.save_game() and FileAccess.get_file_as_bytes(SAVE+".pre-v04")==original,"Later saves never replace the original 0.3 backup")
	check(FileAccess.get_file_as_bytes("res://tests/fixtures/v03_completed_save.json")==original,"The frozen original fixture remains unchanged")
	var recovery: String=SAVE+"_recovery"
	for suffix in ["",".bak",".tmp",".pre-v03",".pre-v04"]:
		if FileAccess.file_exists(recovery+suffix): DirAccess.remove_absolute(recovery+suffix)
	var broken_file := FileAccess.open(recovery,FileAccess.WRITE)
	broken_file.store_string("damaged primary"); broken_file.close()
	DirAccess.copy_absolute("res://tests/fixtures/v03_completed_save.json",recovery+".bak")
	var recovered := SaveSystem.read(recovery)
	check(recovered.error.is_empty() and recovered.migrated_from==2,"Damaged primary recovers and migrates a genuine 0.3 backup")
	check(SaveSystem.write(recovered.data,recovery).is_empty() and FileAccess.get_file_as_bytes(recovery+".pre-v04")==original,"Recovered 0.3 backup is permanently preserved before rotating files")
	for suffix in ["",".bak",".tmp",".pre-v03",".pre-v04"]:
		if FileAccess.file_exists(recovery+suffix): DirAccess.remove_absolute(recovery+suffix)
	await fresh_vault()
	check(game.run.quest_complete and game.run.region=="vault","First quest connects to the source story through real dialogue and landmark actions")
	var boss: SourceGuardian=game.source_story.guardian
	check(is_instance_valid(boss) and not boss.awake and not boss.is_in_group("enemies") and not boss.take_damage(99),"Dormant guardian does not attack or take accidental spell damage")
	go("source_binding")
	game.interact(object("source_binding"))
	await frames()
	check(game.run.source.seen and game.ui.page=="dialogue" and fits(),"First binding interaction records the discovery and offers both paths in the viewport")
	game.handle_action("source_tune")
	await frames()
	check(game.run.source.resolution.is_empty() and game.run.source.alignment==0 and fits(),"Missing evidence cannot repair the binding and is explained in a readable dialogue")
	game.handle_action("source_back")
	check(game.ui.page=="dialogue","Missing-clue screen returns to the actual path choice")
	for id in ["water_memory","root_memory","star_chart"]:
		go(id)
		game.interact(object(id))
		var saved := SaveSystem.read(SAVE)
		check(saved.error.is_empty() and (id in saved.data.run.vault.memories or id in saved.data.run.vault.relics),"New clue is immediately saved: "+id)
	go("source_binding")
	game.interact(object("source_binding"))
	game.handle_action("source_tune")
	await frames()
	check(fits(),"Three sign choices and a return button fit at 640 x 360")
	var before := total_xp()
	game.handle_action("source_align","star")
	check(game.run.source.alignment==0 and total_xp()==before,"Wrong sign order resets the attempt without damage or a duplicated reward")
	game.handle_action("source_align","water")
	check(game.run.source.alignment==1 and SaveSystem.read(SAVE).data.run.source.alignment==1,"First correct sign is a persistent checkpoint")
	check(game.load_game() and game.run.source.alignment==1 and not game.source_story.guardian.awake,"Reload resumes the investigation checkpoint with a dormant guardian")
	stop_normal_enemies()
	go("source_binding")
	game.interact(object("source_binding"))
	game.handle_action("source_tune")
	game.handle_action("source_align","roots")
	game.handle_action("source_align","star")
	await frames()
	check(game.run.source.resolution=="restored" and not game.run.source.guardian_defeated and not is_instance_valid(game.source_story.guardian),"Investigation completes without defeating the guardian")
	check(total_xp()==before+90 and game.run.inventory.owned==["source_heart"] and game.run.inventory.equipped=="source_heart","Investigation grants and equips its one-time relic and experience")
	check(fits() and game.source_story.grove.resolution=="restored" and game.source_story.site.resolution=="restored","Completion dialogue fits and the actual source becomes a garden")
	check(get_nodes_in_group("enemies").size()==5 and game.combat.peaceful_area.has_point(game.source_story.site.position),"Garden quiets its two sentries and becomes a protected area")
	game.handle_action("source_align","star")
	game.handle_action("source_challenge")
	check(game.run.source.resolution=="restored" and total_xp()==before+90,"Repeated actions cannot change the completed path or duplicate its reward")
	go("source_binding")
	game.player.vitals.hp=30; game.player.vitals.mana=25; game.player.vitals.stamina=40
	var motes: int=game.run.motes
	game.interact(object("source_binding"))
	check(game.player.vitals.hp==100 and game.player.vitals.mana==100 and game.player.vitals.stamina==100 and game.run.motes==motes,"Restored source provides free full recovery")
	game.player.vitals.hp=63; game.player.vitals.invulnerable=0
	game.combat._enemy_bolt(game.player.position-Vector2(28,0),Vector2.RIGHT,17,"test_outside_attacker")
	game.combat._thorns(game.player.position)
	await frames(30)
	check(game.player.vitals.hp==63,"Stray enemy projectiles and thorn zones cannot damage the player inside the garden")
	game.handle_action("equipment")
	await frames()
	check(fits() and paused,"Relic equipment view fits and pauses play")
	game.handle_action("equip_relic","")
	check(game.run.inventory.equipped.is_empty() and SaveSystem.read(SAVE).data.run.inventory.equipped.is_empty(),"Unequipping updates the actual slot and save")
	game.handle_action("resume")
	game.player.position=WorldGenerator.center(Vector2i(14,48))
	var nearby: Array=get_nodes_in_group("enemies")
	for i in 2:
		nearby[i].position=game.player.position+Vector2(25 if i==0 else -25,0)
		nearby[i].hp=100
	game.player.vitals.mana=80
	game.player.abilities.cooldowns.nova=0
	game.player.request_cast("nova",game.player.position)
	check(game.player.vitals.mana==52,"Unequipped relic gives no refund on a real Frostkreis hit")
	game.run.inventory.equip("source_heart")
	game.player.vitals.mana=80
	game.player.abilities.cooldowns.nova=0
	game.player.request_cast("nova",game.player.position)
	check(game.player.vitals.mana==58,"Equipped relic refunds exactly six mana once even when Frostkreis hits two enemies")
	game.player.vitals.mana=80
	game.player.abilities.cooldowns.nova=0
	game.player.request_cast("nova",game.player.position+Vector2(0,80))
	check(game.player.vitals.mana==52,"A Frostkreis miss never triggers a relic refund")
	check(game.save_game() and game.load_game() and game.run.source.resolution=="restored" and game.run.inventory.equipped=="source_heart" and get_nodes_in_group("enemies").size()==5,"Reload keeps the garden, quiet sentries and equipped relic")
	game.travel_to("forest")
	game.interact(object("edda"))
	await frames()
	check(game.run.source.reported and fits(),"Edda remembers and acknowledges the restored source in a readable dialogue")
	game.handle_action("resume")
	game.travel_to("vault")
	game.player.vitals.invulnerable=0
	game.player.take_damage(999)
	game.handle_action("respawn")
	check(game.run.region=="forest" and game.run.source.resolution=="restored" and game.run.inventory.equipped=="source_heart","Death and camp return preserve the source outcome and equipment")
	await fresh_vault()
	go("source_binding")
	game.interact(object("source_binding"))
	game.handle_action("source_challenge")
	boss=game.source_story.guardian
	check(boss.awake and boss.is_in_group("enemies") and not game.run.source.has_evidence(game.run.vault),"Combat path is available without the investigation clues")
	game.player.vitals.invulnerable=0
	game.handle_action("pause")
	var paused_timer := boss.timer
	await frames(10)
	check(boss.timer==paused_timer,"Pause freezes the guardian's attack timing")
	game.handle_action("resume")
	await wait_windup(boss)
	var marked := boss.attack_target
	game.player.position+=Vector2(70,0)
	await frames(20)
	check(boss.attack_target==marked and game.player.vitals.hp==100,"Quellenschlag locks its warning position and causes no early damage")
	await wait_release(boss)
	await frames(4)
	check(game.player.vitals.hp==100,"Moving out of the announced Quellenschlag avoids its impact")
	await wait_windup(boss)
	check(boss.attack_index%2==1,"Guardian alternates its slam with the projectile fan")
	await wait_release(boss)
	var fan := 0
	for effect in game.combat.get_children():
		if effect is MagicProjectile and effect.source_id==SourceQuest.GUARDIAN_ID: fan+=1
	check(fan==5,"The announced fan releases five actual hostile projectiles")
	game.combat.clear_guardian_effects()
	await wait_windup(boss)
	game.player.vitals.invulnerable=0
	await wait_release(boss)
	await frames(3)
	check(game.player.vitals.hp==79,"Remaining on the next Quellenschlag causes its configured damage")
	game.player.vitals.hp=100; game.player.vitals.invulnerable=0
	game.player.abilities.cooldowns.dash=0
	game.player.try_dash(Vector2.RIGHT)
	game.combat._source_slam(game.player.position,34,21)
	await frames(3)
	check(game.player.vitals.hp==100,"The normal dodge protects against the guardian's actual impact")
	game.player.vitals.invulnerable=999
	await frames(12)
	var casted: bool=game.player.request_cast("bolt",boss.global_position)
	await frames(40)
	check(casted and boss.hp<float(boss.definition.hp),"Normal player projectiles damage the awake guardian after the dodge ends")
	var combat_hp: float=game.player.vitals.hp
	var combat_mana: float=game.player.vitals.mana
	var saved_ok: bool=game.save_game()
	var loaded_ok: bool=game.load_game()
	print("MID-ENCOUNTER RESOURCE DELTA ",game.player.vitals.hp-combat_hp," / ",game.player.vitals.mana-combat_mana)
	check(saved_ok and loaded_ok and not game.source_story.guardian.awake and game.run.source.resolution.is_empty() and is_equal_approx(game.player.vitals.hp,combat_hp) and is_equal_approx(game.player.vitals.mana,combat_mana),"Mid-encounter load resets the guardian without healing the player or resolving the quest")
	stop_normal_enemies()
	go("source_binding")
	game.interact(object("source_binding"))
	game.handle_action("source_challenge")
	boss=game.source_story.guardian
	game.player.position=WorldGenerator.center(Vector2i(78,17))
	await frames(3)
	check(not boss.awake and boss.hp==float(boss.definition.hp) and not boss.is_in_group("enemies"),"Leaving the room safely resets the encounter")
	var hazards := 0
	for effect in game.combat.get_children():
		if effect is SourceImpact or (effect is MagicProjectile and effect.source_id==SourceQuest.GUARDIAN_ID): hazards+=1
	check(hazards==0 and game.run.source.resolution.is_empty(),"Retreat clears guardian hazards and leaves both quest paths available")
	go("source_binding")
	game.interact(object("source_binding"))
	game.handle_action("source_challenge")
	game.player.vitals.mana=100
	game.player.vitals.invulnerable=999
	before=total_xp()
	for tick in 2400:
		if not game.run.source.resolution.is_empty(): break
		if tick%45==0: game.player.request_cast("bolt",boss.global_position)
		await frames(1)
	check(game.run.source.resolution=="broken" and game.run.source.guardian_defeated,"Real projectiles and ordinary mana rules can complete the full combat path")
	check(total_xp()==before+90 and game.run.inventory.owned==["source_heart"],"Combat gives the same single relic and quest experience as investigation")
	check(game.source_story.site.resolution=="broken" and game.source_story.grove.resolution=="broken","Combat produces the distinct fractured source and ore artwork")
	go("source_binding")
	motes=game.run.motes
	game.interact(object("source_binding"))
	game.interact(object("source_binding"))
	check(game.run.source.ore_taken and game.run.motes==motes+4,"Exposed ore gives its light dust exactly once")
	check(game.save_game() and game.load_game() and game.run.source.ore_taken and not is_instance_valid(game.source_story.guardian),"Reload preserves harvested ore and keeps the defeated guardian absent")
	game.travel_to("forest")
	game.interact(object("edda"))
	await frames()
	check(game.run.source.reported and fits(),"Edda also remembers the combat outcome")
	var valid := SaveSystem.snapshot(game.run,game.player,game.settings)
	check(SaveSystem.validate(valid).is_empty(),"Complete combat-path snapshot is valid")
	for edit in [
		["source","resolution","unknown"],["source","alignment",3],["source","alignment",0.5],
		["source","guardian_defeated",false],["source","seen",false],
		["inventory","equipped","unowned_relic"],["inventory","owned",["source_heart","source_heart"]],["inventory","owned",[]]]:
		var invalid := valid.duplicate(true)
		invalid.run[edit[0]][edit[1]]=edit[2]
		check(not SaveSystem.validate(invalid).is_empty(),"Contradictory source save rejected: "+edit[0]+"."+edit[1])
	var invalid := valid.duplicate(true)
	invalid.run.source.resolution="restored"
	invalid.run.source.guardian_defeated=false
	invalid.run.source.ore_taken=false
	check(not SaveSystem.validate(invalid).is_empty(),"Repaired outcome cannot be forged without its investigation clues")
	paused=false
	game.queue_free()
	await frames(8)
	for suffix in ["",".bak",".tmp",".pre-v03",".pre-v04"]:
		if FileAccess.file_exists(SAVE+suffix): DirAccess.remove_absolute(SAVE+suffix)
	var report := FileAccess.open("res://test-output/source_results.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures,"duration_ms":Time.get_ticks_msec()-started},"  ")); report.close()
	print("SOURCE RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
