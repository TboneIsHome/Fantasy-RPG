extends SceneTree
const Session = preload("res://developer/session.gd")
const Trials = preload("res://developer/weapon_trials.gd")
var session: Node
var checks := 0
var failures: Array[String] = []
var baselines: Array = []
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, title: String) -> void:
	checks+=1
	if not ok: failures.append(title)
	print("PASS WEAPON INTEGRATION: " if ok else "FAIL WEAPON INTEGRATION: ",title)
func setup(id: String, off: String="") -> MagePlayer:
	session.reset("close_defense","dummy");session.set_paused(true)
	var p: MagePlayer=session.fixture.player
	p.vitals.invulnerable=0;p.aim=Vector2.RIGHT
	check(p.configure_weapons(id,off),"Loadout "+id+"/"+off)
	return p
func target_at(p: MagePlayer, offset: Vector2=Vector2(22,0)) -> WildEnemy:
	var target: WildEnemy=session.fixture.target()
	target.position=p.position+offset;target.home=target.position;target.hp=1000
	return target
func step(seconds: float) -> void: Trials.step(session,seconds)
func arrow_in() -> WeaponArrow:
	for child in session.fixture.combat.get_children():
		if child is WeaponArrow and not child.is_queued_for_deletion(): return child
	return null
func fly(arrow: WeaponArrow, frames: int=120) -> void:
	arrow.disable_mode=CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
	await physics_frame;await physics_frame
	for i in frames:
		if not is_instance_valid(arrow) or arrow.is_queued_for_deletion(): break
		arrow._physics_process(1.0/60)
func verify() -> void:
	InputSetup.install();session=Session.new();root.add_child(session)
	check(session.initialize(),"Real sandbox region initialized")
	await portfolios();await defenses();await dual();await groups();await input_path();await projectile_cases();await production_lifecycle()
	for id in Trials.CASES:
		var result: Dictionary=await Trials.compare(session,id)
		baselines.append(result);check(result.passed,"Identical target/distance baseline "+id)
		await process_frame
	session.queue_free()
	for i in 4: await process_frame
	var output := OS.get_environment("LICHTERHAIN_M08_OUTPUT")
	if output.is_empty(): output="res://test-output"
	DirAccess.make_dir_recursive_absolute(output)
	var file := FileAccess.open(output+"/weapon_integration.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"baselines":baselines},"  "));file.close()
	print("WEAPON INTEGRATION RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
func portfolios() -> void:
	for id in Content.weapons().weapons:
		for slot in Content.weapons().weapons[id].portfolio:
			if slot=="follow_up": continue
			var p := setup(id)
			var a: Dictionary=Content.weapons().actions[Content.weapons().weapons[id].portfolio[slot]]
			var target := target_at(p,Vector2(maxf(20,float(a.geometry.get("minimum_reach",0))+10),0))
			check(p.weapon_request(slot),id+" portfolio "+slot+" executable")
			if a.delivery=="projectile":
				check(p.weapons.contact(target).reason==&"projectile_delivery_required","Bow cannot bypass projectile delivery")
			else:
				step(a.startup+1)
				check(target.hp<1000,id+" "+slot+" reaches M06")
				var hp := target.hp;step(2)
				check(target.hp==hp,id+" "+slot+" no overlap repeat")
			await process_frame
	var original := Content._weapons
	var changed := original.duplicate(true)
	changed.actions.dagger_primary.geometry.reach=44;changed.actions.dagger_primary.hit.damage=7
	Content._freeze(changed);Content._weapons=changed
	var p := setup("dagger")
	var target := target_at(p,Vector2(40,0))
	p.weapon_request();step(.15)
	check(target.hp==993 and p.weapons.definition.geometry.reach==44,"Definition change affects gameplay, common UI source, no weapon-specific branch")
	Content._weapons=original
func incoming(p: MagePlayer, impact: float) -> CombatContact:
	var target := target_at(p,Vector2(15,0))
	var a: AttackInstance=session.fixture.combat.new_action(target,&"m08_defense_probe",ActionProfiles.clock(0,.5,.2),ActionProfiles.rules("direct"),target.id)
	target.attack_action=a
	return CombatContact.resolve(a,ContactContext.new(a,p,target.position,30,Vector2.LEFT,0).follow(target),AttackProfile.new(20,&"untyped",impact))
func defenses() -> void:
	for id in Content.weapons().weapons:
		for impact in [35,100,150]:
			var p := setup(id)
			var cfg := p.defense_config()
			var blocked := p.request_block(true)
			var r := incoming(p,impact)
			var outcome := DefenseOutcome.block(cfg.block_damage_scale,cfg.block_impact_scale) if cfg.block else DefenseOutcome.hit()
			var expected := HitResolver.resolve(AttackProfile.new(20,&"untyped",impact),CombatStats.from_definition(Content.section("player").defense),outcome)
			check(blocked==cfg.block and r.outcome==outcome.kind and r.resolution.damage==expected.damage and r.resolution.impact==expected.impact,id+" block vs "+str(impact)+" only M06 math")
		for timing in ["early","correct","late"]:
			var p := setup(id)
			var cfg := p.defense_config()
			if timing!="late":
				p.try_parry()
				if timing=="early":p.active_defense.tick(cfg.parry_window+.01)
			var r := incoming(p,20)
			check(r.outcome==(&"parry" if cfg.parry and timing=="correct" else &"hit"),id+" parry "+timing)
		var p := setup(id)
		p.weapon_request();step(p.weapons.definition.commit+.01)
		var hit := incoming(p,150)
		check(hit.confirmed() and p.weapons.current.timeline.state()==ActionTimeline.State.INTERRUPTED,id+" committed action interrupted by effective impact")
		await process_frame
	for direction in [Vector2.RIGHT,Vector2.UP,Vector2.LEFT]:
		var p := setup("sword")
		check(p.try_dash(direction) and incoming(p,35).outcome==&"evade","Dodge protection "+str(direction))
		check(not p.request_block(true) and not p.try_parry(),"No defense stacking")
		p.active_defense.tick(.17);p.vitals.tick(.17)
		check(incoming(p,35).outcome==&"hit","Early dodge expires including existing Vitals protection")
func dual() -> void:
	for pair in [["sword","sword"],["sword","dagger"],["axe","axe"]]:
		var p := setup(pair[0],pair[1]);var target := target_at(p)
		check(p.weapon_request("primary","main"),"Dual main request "+str(pair))
		var damage: float=p.weapons.definition.hit.damage;step(3)
		check(is_equal_approx(1000-target.hp,damage),"No implicit off-hand damage")
		var hp := target.hp
		check(p.weapon_request("primary","off"),"Alternating off-hand request")
		damage=p.weapons.definition.hit.damage;step(3)
		check(is_equal_approx(hp-target.hp,damage),"Off hand retains own profile")
		hp=target.hp
		check(p.weapon_request("combined"),"Explicit combined action")
		damage=p.weapons.definition.hit.damage
		var phases: int=p.weapons.definition.phases.size();step(3)
		check(is_equal_approx(hp-target.hp,damage*phases),"Only authored combined phases hit")
		check(p.defense_config()==Content.weapons().defenses.dual,"One explicit dual defense profile")
		await process_frame
	var p := setup("dagger","mace")
	check(p.weapon_request("primary","off"),"Other compatible configuration works by data")
	step(3);check(not p.weapon_request("combined"),"No implicit combined action")
	check(not p.configure_weapons("sword","bow"),"Two-handed pairing rejected")
	p=setup("sword","sword");var target := target_at(p)
	p.weapon_request("combined");p.weapons.current.tick(.28)
	var first := p.weapons.contact(target)
	check(first.confirmed() and first.resolution.secondary.hand=="main" and p.weapons.contact(target).reason==&"duplicate_hit","Main phase claims target exactly once")
	p.weapons.current.tick(.22)
	var second := p.weapons.contact(target)
	check(second.confirmed() and second.resolution.secondary.hand=="off" and first.resolution.hit_id!=second.resolution.hit_id,"Off phase explicitly creates next receipt")
func groups() -> void:
	for id in ["greatsword","greataxe","mace","spear","sword"]:
		var p := setup(id,"sword" if id=="sword" else "")
		var front := target_at(p,Vector2(27,0))
		var second: WildEnemy=session.spawn("dummy",p.position+Vector2(33,0))
		var rear: WildEnemy=session.spawn("dummy",p.position+Vector2(-20,0))
		var hp2 := second.hp;var hp3 := rear.hp
		p.weapon_request("combined" if id=="sword" else "primary");step(3)
		check(front.hp<1000 and second.hp<hp2 and rear.hp==hp3,id+" two front targets independently; rear misses")
		await process_frame
func input_path() -> void:
	var p := setup("dagger");target_at(p)
	p.input_enabled=true;p.weapon_input_armed=true
	Input.action_press("weapon_primary");p._physics_process(1.0/60)
	check(p.weapons.current!=null and p.weapons.current.action_id==&"dagger_primary","Shared Input to Action J path")
	Input.action_release("weapon_primary");await process_frame
	Input.action_press("move_down");p._physics_process(.05)
	check(p.velocity.y>70,"Dagger startup retains movement")
	Input.action_release("move_down")
	p=setup("warhammer");p.weapon_request();p.input_enabled=true
	Input.action_press("move_down");p._physics_process(.05)
	check(p.velocity.y<30 and p.velocity.y>0,"Hammer startup limits real movement")
	Input.action_release("move_down")
	p=setup("sword");Input.action_press("weapon_primary");p._physics_process(.016)
	check(p.weapons.current==null,"Disabled arena input cannot start action")
	Input.action_release("weapon_primary");await process_frame
	p=setup("bow");p.input_enabled=true;p.weapon_input_armed=true
	Input.action_press("weapon_primary");p._physics_process(.016)
	Input.action_release("weapon_primary");p._physics_process(.016);step(1)
	check(p.weapons.current!=null and p.weapons.current.timeline.state()==ActionTimeline.State.COMPLETED,"Early bow release completes Draw then Recovery")
func projectile_cases() -> void:
	var p := setup("bow");var target := target_at(p,Vector2(140,0))
	p.weapon_request();step(.6);p.weapons.request_release();p.weapons.update(0)
	var arrow := arrow_in()
	check(arrow!=null,"Actually released arrow for profile-lifetime reproduction")
	step(1);check(p.configure_weapons("warhammer"),"Fresh local profile allowed after recovery")
	await fly(arrow)
	check(target.hp==978,"Flying arrow survives adapter replacement and retains original 22 damage")
	p=setup("bow");target=target_at(p,Vector2(140,50))
	p.weapon_request();step(.6);p.weapons.request_release();p.weapons.update(0)
	await fly(arrow_in())
	check(target.hp==1000,"Visible arrow miss stays miss")
	p=setup("bow");target=target_at(p,Vector2(140,0))
	p.weapon_request();step(.6);p.weapons.request_release();p.weapons.update(0)
	arrow=arrow_in();var action := arrow.attack_action
	session.select_weapon_case("M08_A01")
	var hp: float=session.fixture.target().hp
	arrow.struck.emit(session.fixture.target(),session.fixture.target().position,Vector2.RIGHT)
	check(not action.is_current() and session.fixture.target().hp==hp,"Stale released callback rejected after reset")
	await process_frame
func production_lifecycle() -> void:
	var game=load("res://scenes/game.tscn").instantiate();root.add_child(game)
	game.save_path="user://m08_isolated_lifecycle.json"
	var saved := SaveSystem.read_one("res://tests/fixtures/v03_completed_save.json")
	game.build_run(saved.data.run.world_seed,saved.data);game.travel_to("vault");paused=true
	var p: MagePlayer=game.player
	check(p.configure_weapons("sword") and p.weapon_request(),"Same weapon adapter works in production region")
	var old_action := p.weapons.current
	var snapshot := SaveSystem.snapshot(game.run,p,game.settings)
	check(snapshot.save_version==3 and not JSON.stringify(snapshot).contains("weapon") and not JSON.stringify(snapshot).contains("attack_action"),"Production snapshot keeps format 3 without transient weapon/action state")
	game.travel_to("forest")
	check(not old_action.is_current() and game.player.weapons==null,"Travel rebuild clears local loadout and stale action")
	game.queue_free();paused=false
	for i in 4: await process_frame
	for suffix in ["",".bak",".tmp",".bak.tmp",".pre-v03",".pre-v04"]:
		if FileAccess.file_exists("user://m08_isolated_lifecycle.json"+suffix):DirAccess.remove_absolute("user://m08_isolated_lifecycle.json"+suffix)
