extends RefCounted
## Developer fixtures only. No sandbox-specific combat resolution.
const CASES := {
	"M08_A01":["dagger",""], "M08_A02":["sword",""], "M08_A03":["greatsword",""],
	"M08_A04":["axe",""], "M08_A05":["greataxe",""], "M08_A06":["mace",""],
	"M08_A07":["warhammer",""], "M08_A08":["spear",""], "M08_A09":["bow",""],
	"M08_A10":["sword","sword"], "M08_A11":["sword","dagger"], "M08_A12":["axe","axe"]}

static func label_for(id: String) -> String:
	var pair: Array = CASES[id]
	var data: Dictionary = Content.weapons().weapons
	return id+" · "+str(data[pair[0]].name)+(" + "+str(data[pair[1]].name) if not pair[1].is_empty() else "")

static func attach(session: Node, id: String) -> bool:
	if not CASES.has(id) or not session.is_current(session.generation): return false
	var pair: Array = CASES[id]
	if not session.fixture.player.configure_weapons(pair[0],pair[1]): return false
	session.weapon_case = id
	session.fixture.player.weapons.contact_resolved.connect(session.telemetry.contact)
	session.fixture.combat.profile_contact_resolved.connect(session.telemetry.contact)
	session.telemetry.record("developer_loadout",{"case":id,"main":pair[0],"off":pair[1]})
	return true

static func step(session: Node, seconds: float) -> void:
	if not session.paused or not session.is_current(session.generation): return
	var p: MagePlayer = session.fixture.player
	var left := seconds
	while left > .000001:
		var dt := minf(left,1.0/60)
		for action in p.attack_actions.duplicate(): action.tick(dt)
		p.active_defense.tick(dt);p.reaction.tick(dt);p.vitals.tick(dt)
		if p.weapons != null: p.weapons.update(dt)
		session.telemetry.elapsed+=dt
		left-=dt

static func compare(session: Node, id: String) -> Dictionary:
	if not session.select_weapon_case(id): return {"passed":false,"case":id,"reason":"setup"}
	session.set_paused(true)
	session.telemetry.scenario=id
	var p: MagePlayer=session.fixture.player
	var target: WildEnemy=session.fixture.target()
	target.position=p.position+Vector2(30,0)
	target.home=target.position
	p.aim=Vector2.RIGHT
	var hp: float=target.hp
	var requested := p.weapon_request()
	var w: WeaponActions=p.weapons
	step(session, w.definition.startup+0.5)
	if w.definition.delivery=="projectile":
		w.request_release();w.update(0)
		for child in session.fixture.combat.get_children():
			if child is WeaponArrow: child.disable_mode=CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
		await session.get_tree().physics_frame;await session.get_tree().physics_frame
		for i in 120:
			for child in session.fixture.combat.get_children():
				if child is WeaponArrow and not child.is_queued_for_deletion(): child._physics_process(1.0/60)
	step(session,3)
	var hit := target.hp<hp
	var result := {"case":id,"passed":requested and (not hit if id=="M08_A01" else hit),"expected":"miss at 30 units" if id=="M08_A01" else "hit at 30 units","damage":hp-target.hp,"distance":30,"action":str(w.current.action_id),"shape":w.definition.geometry.shape,"startup":w.definition.startup,"recovery":w.definition.recovery,"main":w.main_id,"off":w.off_id,"events":session.telemetry.events.duplicate(true)}
	session.last_scenario=result
	return result
