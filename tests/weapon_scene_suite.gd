extends SceneTree
const Session = preload("res://developer/session.gd")
var session: Node
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS WEAPON SCENE: " if ok else "FAIL WEAPON SCENE: ",title)
func setup(id: String, off: String = "") -> MagePlayer:
	session.reset("close_defense","dummy")
	session.set_paused(true)
	var p: MagePlayer = session.fixture.player
	p.vitals.invulnerable=0
	p.aim=Vector2.RIGHT
	check(p.configure_weapons(id,off),"Loadout accepted: "+id+"/"+off)
	return p
func step(p: MagePlayer, seconds: float, resolve_contacts: bool = true) -> void:
	var left := seconds
	while left > .00001:
		var dt := minf(left,1.0/60)
		for a in p.attack_actions.duplicate(): a.tick(dt)
		if resolve_contacts: p.weapons.update(dt)
		left -= dt
func target_at(p: MagePlayer, position: Vector2) -> WildEnemy:
	var target: WildEnemy = session.fixture.target()
	target.position=p.position+position
	target.home=target.position
	target.hp=1000
	return target
func verify() -> void:
	InputSetup.install()
	session=Session.new();root.add_child(session)
	check(session.initialize(),"Sandbox initialized using real region and combat")
	await archetypes()
	await bow()
	await safety()
	session.queue_free()
	for i in 4: await process_frame
	print("WEAPON SCENE RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
func archetypes() -> void:
	for id in ["dagger","sword","warhammer","spear"]:
		var p := setup(id)
		var target := target_at(p,Vector2(22 if id=="dagger" else 35 if id!="spear" else 60,0))
		check(p.weapon_request(),id+" starts real M07 action")
		var w := p.weapons
		check(w.contact(target).reason==&"inactive_phase" and target.hp==1000,id+" Startup has no damage")
		step(p,w.definition.startup+.04,false)
		var r := w.contact(target)
		var expected := HitResolver.resolve(w.profile(),CombatStats.from_definition(target.definition.defense),DefenseOutcome.hit())
		check(r.confirmed() and r.resolution.damage==expected.damage and r.resolution.impact==expected.impact,id+" M06 is sole numeric owner")
		check(w.contact(target).reason==&"duplicate_hit",id+" one receipt per phase")
		check(not p.try_dash(Vector2.RIGHT) and not p.try_parry() and not p.request_block(true) and not p.request_cast("bolt",target.position),id+" committed action cannot be bypassed")
		var expected_kind := CombatReaction.Kind.STAGGER if id=="warhammer" else CombatReaction.Kind.INTERRUPT if id=="spear" else CombatReaction.Kind.NORMAL
		check(target.reaction.kind==expected_kind,id+" effective impact maps to existing M07 reaction")
		step(p,3,false)
		check(not w.busy() and p.try_dash(Vector2.DOWN),id+" recovery restores active defense")
	var p := setup("dagger")
	var target := target_at(p,Vector2(25,0))
	p.weapon_request();step(p,.13,false)
	check(p.weapons.contact(target).reason==&"out_of_range","Short weapon misses outside authored reach")
	target.position=p.position+Vector2(23,6)
	check(p.weapons.contact(target).reason==&"outside_shape","Narrow contact rejects side target")
	target.position=p.position+Vector2(24,0)
	check(p.weapons.contact(target).confirmed(),"Exact reach boundary is hittable")
	p=setup("spear");target=target_at(p,Vector2(8,0))
	p.weapon_request();step(p,.31,false)
	check(p.weapons.contact(target).reason==&"inside_minimum_reach","Provisional spear close weakness is geometry, not damage multiplier")
	target.position=p.position+Vector2(60,7)
	check(p.weapons.contact(target).reason==&"outside_shape","Spear loses side coverage")
	target.position=p.position+Vector2(74,0)
	var query := p.weapons.context(target)
	target.position.x+=10
	check(CombatContact.resolve(p.weapons.current,query,p.weapons.profile()).reason==&"out_of_range","Target moves out before contact")
	target.position.x-=10;p.position.x-=10
	check(CombatContact.resolve(p.weapons.current,query,p.weapons.profile()).reason==&"out_of_range","Attacker movement changes live origin")
	p=setup("warhammer");p.weapon_request()
	check(p.weapons.cancel() and not p.weapons.busy(),"Heavy action can cancel before Commit")
	p=setup("sword");target=target_at(p,Vector2(30,0));p.weapon_request()
	check(not p.weapon_request("follow_up"),"Follow-up cannot skip current recovery")
	step(p,1)
	check(p.weapon_request("follow_up"),"Explicit follow-up after completed recovery")
	p=setup("sword");target=target_at(p,Vector2(30,0));p.weapon_request("heavy")
	step(p,.44,false)
	check(p.weapons.contact(target).reason==&"outside_shape","Sweep has not yet reached center")
	step(p,.12,false)
	check(p.weapons.contact(target).confirmed(),"Sweep progresses through center")
	await process_frame
func bow() -> void:
	var p := setup("bow")
	var target := target_at(p,Vector2(90,0))
	check(p.weapon_request(),"Bow begins Draw")
	step(p,1)
	check(p.weapons.current.timeline.awaiting_release() and session.fixture.combat.get_child_count()==1 and target.hp==1000,"Held aim cannot fire or damage")
	check(p.weapons.request_release(),"Explicit bow Release request")
	p.weapons.update(0)
	var arrow: MagicProjectile
	for child in session.fixture.combat.get_children():
		if child is WeaponArrow: arrow=child
	check(arrow!=null and arrow is MagicProjectile and p.weapons.current.timeline.state()==ActionTimeline.State.RECOVERY,"Bow reuses projectile carrier and keeps actor recovery")
	if arrow!=null:
		arrow.disable_mode=CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
		var old := p.position
		p.position+=Vector2(0,40)
		await physics_frame;await physics_frame
		for i in 60:
			if not is_instance_valid(arrow) or arrow.is_queued_for_deletion(): break
			arrow._physics_process(1.0/60)
		check(target.hp<1000 and p.vitals.mana==100,"Projectile hits after actor movement without spell cost/talent damage")
		p.position=old
	p=setup("bow");p.weapon_request();p.interrupt_actions();step(p,2)
	check(not p.weapons.request_release() and session.fixture.combat.get_child_count()==1,"Interrupted Draw cannot release")
	p=setup("bow")
	check(not p.request_block(true) and not p.try_parry() and p.try_dash(Vector2.LEFT),"Provisional bow profile emphasizes position and Dodge")
func safety() -> void:
	var p := setup("sword")
	var target := target_at(p,Vector2(30,0))
	p.weapon_request();step(p,.23,false)
	var w := p.weapons
	var action := w.current
	var query := w.context(target)
	var profile := w.profile()
	var saved: Dictionary = session.fixture.run.serialize()
	check(not saved.has("weapons") and not saved.has("attack_action"),"M08 transient state is absent from RunState snapshot")
	session.reset()
	check(not action.is_current() and CombatContact.resolve(action,query,profile).reason==&"stale_action","Reset rejects old action and target before M06")
	check(w.contact(session.fixture.target()).reason==&"stale_action","Old adapter cannot contact new region")
	await process_frame
