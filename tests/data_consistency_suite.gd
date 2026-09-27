extends SceneTree
## Test-only replacement of the private bundle. No shipped JSON or fixture is edited.
var checks := 0
var failures: Array[String] = []
const SAVE := "user://m04_consistency_only.json"
var original: Dictionary
var original_vault: Dictionary
var game: Node2D

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS DATA: " if ok else "FAIL DATA: ",title)

func labels(node: Node) -> String:
	var result: String = node.text + "\n" if node is Label else ""
	for child in node.get_children(): result += labels(child)
	return result

func total_xp(run: RunState) -> int:
	return run.xp + int(Content.section("progression").xp_per_level)*run.level*(run.level-1)/2

func earned(run: RunState, action: Callable, xp: int, title: String) -> void:
	var before := total_xp(run)
	check(action.call() and total_xp(run) == before + xp,title + " uses definition")
	var state := run.serialize()
	check(not action.call() and run.serialize() == state,title + " cannot be awarded twice")

func verify() -> void:
	Content.ensure_loaded()
	original = Content.all().duplicate(true)
	original_vault = Content.vault().duplicate(true)
	var data := original.duplicate(true)
	data.player.hp = 150
	data.player.mana = 160
	data.player.stamina = 170
	data.player.dash_cost = 35
	data.player.dash_cooldown = 0.8
	data.spells.bolt.cost = 11
	data.spells.bolt.cooldown = 0.5
	data.spells.bolt.speed = 300
	data.spells.bolt.range = 260
	data.spells.bolt.damage = 23
	data.spells.bolt.shatter_bonus = 7
	data.spells.nova.cost = 31
	data.spells.nova.cooldown = 5.2
	data.spells.nova.damage = 18
	data.skills.flow.mana_refund = 19
	data.skills.bloom.healing = 15
	data.skills.echo.chain_damage = 13
	data.skills.echo.chain_range = 70
	data.relics.source_heart.frost_refund = 9
	data.quest.light_xp = 23
	data.quest.reward_xp = 51
	data.source_quest.reward_xp = 101
	data.source_quest.ore_motes = 7
	data.progression.xp_per_level = 70
	data.progression.enemy_motes = 2
	data.enemies.wolf.hp = 69
	data.enemies.wolf.xp = 31
	data.combat.enemy_projectile_speed = 123
	data.combat.enemy_projectile_range = 220
	var vault := original_vault.duplicate(true)
	vault.memory_xp = 11
	vault.chart_xp = 41
	vault.seed_xp = 26
	vault.fountain_cost = 3
	check(ContentValidator.validate_bundle(data,vault,Content.discoveries()).is_empty(),"Altered definitions remain valid before consumer checks")
	Content._cache = data
	Content._vault = vault
	game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	game.build_run("LICHTERHAIN")
	paused = true
	var p: MagePlayer = game.player
	check(p.vitals.hp == 150 and p.vitals.mana == 160 and p.vitals.stamina == 170,"New region player starts at all three configured maxima")
	p.vitals.hp=75; p.vitals.mana=80; p.vitals.stamina=85
	check(game.ui.hud.resource_fraction("hp") == 0.5 and game.ui.hud.resource_fraction("mana") == 0.5 and game.ui.hud.resource_fraction("stamina") == 0.5,"Actual HUD meters use the same changed maxima")
	p.vitals.refill()
	check(p.vitals.hp == 150 and p.vitals.mana == 160 and p.vitals.stamina == 170 and p.vitals.is_full(),"Refill and full-resource interaction check share maxima")
	p.vitals.mana=159; p.vitals.stamina=169
	p.vitals.tick(1)
	check(p.vitals.mana == 160 and p.vitals.stamina == 170,"Regeneration caps at changed maxima")
	for id in ["bolt","nova","dash"]:
		var ability := MageAbilities.definition(id)
		p.abilities = MageAbilities.new()
		p.vitals.refill()
		var before := p.vitals.stamina if id == "dash" else p.vitals.mana
		var cast_ok := p.abilities.dash(p.vitals) if id == "dash" else p.abilities.cast(id,p.vitals)
		var after := p.vitals.stamina if id == "dash" else p.vitals.mana
		check(cast_ok and is_equal_approx(before-after,ability.cost) and is_equal_approx(p.abilities.cooldowns[id],ability.cooldown),id + " spends changed cost and starts changed cooldown")
		p.abilities.tick(float(ability.cooldown)/2)
		check(is_equal_approx(game.ui.hud.ability_readiness(id),0.5),id + " HUD cooldown uses definition")
		p.vitals.set("stamina" if id == "dash" else "mana",float(ability.cost)-1)
		check(not game.ui.hud.ability_affordable(id),id + " HUD affordability follows changed cost")
		p.abilities.cooldowns[id]=0
		check(not (p.abilities.dash(p.vitals) if id == "dash" else p.abilities.cast(id,p.vitals)),id + " gameplay rejects the same insufficient resource")
	p.abilities=MageAbilities.new()
	p.vitals.refill()
	p.vitals.mana=30
	game.run.learned.assign(["flow","bloom","echo"])
	game.run.level=4
	check(p.try_dash(Vector2.RIGHT) and p.vitals.mana == 49,"Flow applies changed refund exactly once on successful dash")
	check(not p.try_dash(Vector2.RIGHT) and p.vitals.mana == 49,"Rejected dash does not refund again")
	p.dash_remaining=0
	p.active_defense.reset()
	p.abilities=MageAbilities.new()
	p.vitals.hp=50; p.vitals.mana=90
	game.run.inventory.grant("source_heart")
	var targets: Array[WildEnemy] = []
	for i in 2:
		var enemy := WildEnemy.new()
		enemy.configure({"id":"m04_target_%d" % i,"kind":"wolf","position":p.position+Vector2(10+i*10,0)},p,Vector2(-1000,-1000))
		enemy.process_mode=Node.PROCESS_MODE_DISABLED
		game.terrain.actors.add_child(enemy)
		targets.append(enemy)
	check(targets[0].hp == 69 and targets[0].definition.hp == 69,"Enemy spawn and displayed health denominator share changed definition")
	check(p.request_cast("nova",p.position),"Real Frostkreis request with changed definition succeeds")
	check(p.vitals.mana == 68 and p.vitals.hp == 65,"Multi-target Frostkreis applies one changed relic refund and one changed heal")
	check(targets[0].hp == 51 and targets[1].hp == 51,"Both targets take changed spell damage")
	check(not p.request_cast("nova",p.position) and p.vitals.mana == 68 and p.vitals.hp == 65,"Cooldown refusal applies no duplicate heal/refund")
	game.combat._bolt_hit(targets[0],targets[0].position,Vector2.RIGHT)
	check(targets[0].hp == 21 and targets[1].hp == 38,"Changed bolt, shatter and echo each apply exactly once")
	for enemy in targets:
		enemy.remove_from_group("enemies")
		enemy.queue_free()
	p.abilities.cooldowns.nova=0
	check(p.request_cast("nova",p.position) and p.vitals.mana == 37,"Missed Frostkreis grants no relic refund")
	p.abilities.cooldowns.bolt=0
	p.request_cast("bolt",p.position+Vector2(90,0))
	var projectile: MagicProjectile
	for child in game.combat.get_children():
		if child is MagicProjectile and not child.hostile: projectile=child
	check(is_instance_valid(projectile) and projectile.speed == 300 and projectile.remaining == 260,"Actual player projectile uses changed speed/range")
	game.combat._enemy_bolt(p.position+Vector2(80,0),Vector2.LEFT,1)
	for child in game.combat.get_children():
		if child is MagicProjectile and child.hostile: projectile=child
	check(projectile.speed == 123 and projectile.remaining == 220,"Actual enemy projectile uses shared changed definition")
	game.ui.journal(game.run)
	var text := labels(game.ui)
	check("19 Mana" in text and "15 Leben" in text and "0 / 280 Erfahrung" in text,"Actual journal labels derive talent numbers and XP curve")
	game.ui.journal(game.run,false,true)
	check("9 Mana" in labels(game.ui),"Actual equipment description derives relic refund")
	var state := RunState.new()
	for id in RunState.LIGHT_IDS: earned(state,state.activate_light.bind(id),23,"Light " + id)
	earned(state,state.complete_quest,51,"Main quest reward")
	earned(state,state.defeat_enemy.bind("guard_1_0","wolf"),31,"Enemy XP")
	check(state.motes == 2,"Enemy light-dust reward comes from definition once")
	earned(state,state.unlock_memory.bind("water_memory"),11,"Memory XP")
	earned(state,state.collect_vault_relic.bind("star_chart"),41,"Chart XP")
	state.open_vault_secret()
	earned(state,state.collect_vault_relic.bind("amber_seed"),26,"Seed XP")
	state.inspect_source()
	earned(state,state.defeat_source_guardian,101,"Source outcome XP")
	check(state.inventory.owned == ["source_heart"] and state.inventory.frost_refund() == 9,"One source relic gives one configured refund")
	check(state.harvest_source_ore() and state.motes == 9 and not state.harvest_source_ore() and state.motes == 9,"Changed ore reward is issued only once")
	check(RunState.xp_required(2) == 140,"Level threshold uses configured XP multiplier")
	var invalid := SaveSystem.snapshot(state,p,game.settings)
	invalid.run.xp=RunState.xp_required(state.level)
	check(not SaveSystem.validate(invalid).is_empty(),"Save validation shares the XP curve")
	# A real fountain interaction must not mistake >100 HP for the configured max.
	game.build_run(state.world_seed,SaveSystem.snapshot(state,p,game.settings))
	game.travel_to("vault")
	paused=true
	game.run.motes=10
	game.player.vitals.refill()
	var font: DungeonObject
	for node in get_nodes_in_group("landmarks"):
		if node.id == "vault_font": font=node
	game.player.position=font.position+Vector2(0,24)
	game.interact_dungeon(font)
	check(game.run.motes == 10,"Full changed maxima do not charge fountain cost")
	game.player.vitals.hp=120
	game.interact_dungeon(font)
	check(game.run.motes == 7 and game.player.vitals.hp == 150,"Fountain uses changed cost and restores changed maximum above 100")
	check(SaveSystem.read(SAVE).error.is_empty() and SaveSystem.read(SAVE).data.player.hp == 150,"Changed high maxima persist in unchanged schema 3")
	game.source_story.present_completion()
	check("+101 Erfahrung" in labels(game.ui) and "9 Mana" in labels(game.ui),"Actual source completion dialogue uses current reward/refund")
	await save_compatibility()
	paused=false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp", ".pre-v03", ".pre-v04"]:
		if FileAccess.file_exists(SAVE+suffix): DirAccess.remove_absolute(SAVE+suffix)
	Content._cache=original
	Content._vault=original_vault
	print("DATA CONSISTENCY RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)

func save_compatibility() -> void:
	Content._cache=original.duplicate(true)
	Content._vault=original_vault
	for resource in ["hp","mana","stamina"]: Content._cache.player[resource]=60
	check(ContentValidator.validate_bundle(Content.all(),Content.vault(),Content.discoveries()).is_empty(),"Lower maxima are valid content, independent of archived resources")
	for name in ["v01_save", "v02_completed_save", "v03_completed_save", "v04_alignment_started", "v04_restored_equipped", "v04_broken_ore_unequipped"]:
		var path: String = "res://tests/fixtures/"+name+".json"
		var bytes := FileAccess.get_file_as_bytes(path)
		var old: Dictionary=JSON.parse_string(bytes.get_string_from_utf8())
		var loaded := SaveSystem.read(path)
		check(loaded.error.is_empty() and loaded.data.player == old.player,name + " remains valid and exact below original maxima")
		game.build_run(loaded.data.run.world_seed,loaded.data)
		paused=true
		check(game.player.vitals.hp == old.player.hp and game.player.vitals.mana == old.player.mana and game.player.vitals.stamina == old.player.stamina,name + " restores absolute resources without clamp")
		check(FileAccess.get_file_as_bytes(path) == bytes,name + " original bytes are untouched")
	# Save above the original 100 limit, then lower definitions and load/back up again.
	var snapshot := SaveSystem.snapshot(game.run,game.player,game.settings)
	snapshot.player.hp=150; snapshot.player.mana=160; snapshot.player.stamina=170
	check(SaveSystem.write(snapshot,SAVE).is_empty(),"Schema 3 preserves earlier higher maxima within serialization envelope")
	var result := SaveSystem.read(SAVE)
	check(result.error.is_empty() and "Maximalwerten" in result.get("notice","") and result.data.save_version == 3,"Over-cap restore is explicit and keeps save version 3")
	game.load_game()
	paused=true
	game.player.vitals.tick(10)
	game.player.vitals.refill()
	game.player.vitals.restore_mana(19)
	game.player.vitals.heal(15)
	check(game.player.vitals.hp == 150 and game.player.vitals.mana == 160 and game.player.vitals.stamina == 170,"Tick, rest and bonuses neither erase nor increase inherited excess")
	check(game.save_game() and game.load_game() and game.player.vitals.mana == 160,"Repeated save/load retains excess exactly")
	var bad := snapshot.duplicate(true)
	for value in [NAN,INF,-1,SaveSystem.MAX_STORED_RESOURCE+1]:
		bad.player.mana=value
		check(not SaveSystem.validate(bad).is_empty(),"Save rejects invalid resource " + str(value))
	bad=snapshot.duplicate(true)
	bad.player.hp=0
	check(not SaveSystem.validate(bad).is_empty(),"Dead player remains unsaveable")
	bad.player.hp=0.001
	check(SaveSystem.validate(bad).is_empty(),"Finite positive fractional HP is compatible with numeric definitions")
	game.player.vitals.mana=50
	game.player.vitals.tick(10)
	check(game.player.vitals.mana == 60,"Regeneration resumes at new limit after resources have been spent")
	var exact := FileAccess.get_file_as_bytes(SAVE)
	DirAccess.copy_absolute(SAVE,SAVE+".bak")
	var broken := FileAccess.open(SAVE,FileAccess.WRITE)
	broken.store_string("{ corrupt"); broken.close()
	result=SaveSystem.read(SAVE)
	check(result.error.is_empty() and "wiederhergestellt" in result.notice and "Maximalwerten" in result.notice,"Backup recovery retains the over-cap notice")
	check(SaveSystem.write(result.data,SAVE).is_empty() and FileAccess.get_file_as_bytes(SAVE+".bak") == exact,"Recovery still preserves the exact valid higher-resource backup")
