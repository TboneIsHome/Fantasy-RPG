extends RefCounted
## Reproducible fixtures, not alternative combat rules. All contacts go to M07.
var session: Node
var checks: Array[Dictionary] = []
var records: Array = []

func check(condition: bool, title: String) -> void:
	checks.append({"passed":condition,"check":title})
	session.telemetry.record("scenario_check",checks[-1])

func run(id: String, owner: Node) -> Dictionary:
	session = owner
	checks = []
	records = []
	if not session.catalog.data.scenarios.has(id): return {"id":id,"passed":false,"checks":[],"error":"Unknown scenario"}
	fresh()
	session.telemetry.scenario = id
	await session.get_tree().physics_frame
	await session.get_tree().process_frame
	match id:
		"A01": contact_phases()
		"A02": geometry()
		"A03": dodge()
		"A04": block()
		"A05": parry()
		"A06": mage_defense()
		"A07": await projectile()
		"A08": area()
		"A09": reactions()
		"A10": interruption()
		"A11": await lifecycle()
		"A12": await waves()
	var passed := true
	for entry in checks: passed = passed and entry.passed
	var result := {"id":id,"passed":passed,"checks":checks.duplicate(true),"mode":"controlled fixture / actual M07-M06","generation":session.generation,"events":records+session.telemetry.events.duplicate(true)}
	session.last_scenario = result
	return result

func fresh(enemy: String = "dummy") -> void:
	var scenario: String = session.telemetry.scenario if session.telemetry != null else "manual"
	if not checks.is_empty(): records.append_array(session.telemetry.events.duplicate(true))
	session.reset("mage",enemy,true,{})
	session.set_paused(true)
	session.telemetry.scenario = scenario
	session.position_target(24,0,0)

func action(actor: Node2D, clock: ActionTimeline = null, geometry_kind: String = "direct") -> AttackInstance:
	return session.fixture.combat.new_action(actor,&"sandbox_fixture",ActionProfiles.clock(0,1,0.2) if clock == null else clock,ActionProfiles.rules(geometry_kind),actor.id if actor is WildEnemy else "player")

func contact(attack: AttackInstance, target: Node2D, damage: float = 20, impact: float = 20, reach: float = 42, heading: Vector2 = Vector2.RIGHT, dot: float = -1) -> CombatContact:
	var query := ContactContext.new(attack,target,attack.actor().global_position,reach,heading,dot).follow(attack.actor())
	query.visibility = session.fixture.combat._clear_line
	return resolve(attack,query,AttackProfile.new(damage,Content.section("combat").default_damage_type,impact))

func resolve(attack: AttackInstance, query: ContactContext, profile: AttackProfile) -> CombatContact:
	var result := CombatContact.resolve(attack,query,profile)
	session.telemetry.contact(attack,query,result)
	return result

func hostile(impact: float = 20, geometry_kind: String = "direct") -> CombatContact:
	var enemy: WildEnemy = session.fixture.target()
	enemy.attack_action = action(enemy,null,geometry_kind)
	return contact(enemy.attack_action,session.fixture.player,20,impact,42,Vector2.LEFT)

func contact_phases() -> void:
	var attack: AttackInstance = session.start_probe()
	check(attack.timeline.state()==ActionTimeline.State.STARTUP and session.probe().reason==&"inactive_phase","Startup rejects contact")
	session.advance_probe(0.2)
	check(attack.timeline.state()==ActionTimeline.State.COMMIT and session.probe().reason==&"inactive_phase","Commit is not Active")
	session.advance_probe(0.2)
	var result: CombatContact = session.probe()
	check(attack.timeline.state()==ActionTimeline.State.ACTIVE and result.confirmed() and result.resolution.damage==20,"Active contact returns actual M06 damage")
	check(session.probe().reason==&"duplicate_hit","One target once per hit phase")
	attack.timeline.finish_active()
	check(attack.timeline.state()==ActionTimeline.State.RECOVERY and session.probe().reason==&"inactive_phase","Recovery rejects contact")
	session.advance_probe(0.5)
	check(attack.timeline.state()==ActionTimeline.State.COMPLETED,"Action completes")

func geometry() -> void:
	var p: MagePlayer = session.fixture.player
	var enemy: WildEnemy = session.fixture.target()
	var attack := action(p)
	var query := ContactContext.new(attack,enemy,p.position,42,Vector2.RIGHT,0).follow(p)
	enemy.position.x += 100
	check(resolve(attack,query,AttackProfile.new(20)).reason==&"out_of_range","Target moved out of range")
	enemy.position.x -= 100
	p.position.x -= 100
	check(resolve(attack,query,AttackProfile.new(20)).reason==&"out_of_range","Origin follows moving actor")
	p.position.x += 100
	check(contact(attack,enemy,20,20,42,Vector2.LEFT,0).reason==&"wrong_direction","Wrong facing misses deterministically")
	query.visibility = func(_from, _to): return false
	check(resolve(attack,query,AttackProfile.new(20)).reason==&"obstructed","Adapter-provided obstruction is checked")
	check(contact(attack,enemy,20,20,42,Vector2.RIGHT,0).confirmed(),"Correct range and facing hit")

func dodge() -> void:
	var p: MagePlayer = session.fixture.player
	check(p.try_dash(Vector2.DOWN),"Existing Dodge accepts direction")
	var result := hostile()
	check(result.outcome==&"evade" and result.resolution==null,"Protection rejects contact before M06")
	var before := p.position
	p.input_enabled = true
	p._physics_process(0.02)
	p.input_enabled = false
	check(p.position.y>before.y,"Dodge moves the actual CharacterBody")
	p.active_defense.tick(1)
	p.dash_remaining = 0
	p.vitals.invulnerable = 0
	session.position_target(24,0,0)
	check(hostile().outcome==&"hit","Expired protection permits a new hit")

func block() -> void:
	var p: MagePlayer = session.fixture.player
	p.input_enabled = true
	Input.action_press("block")
	Input.action_press("move_down")
	p._physics_process(0)
	check(p.active_defense.mode==ActiveDefense.Mode.BLOCK and is_equal_approx(p.velocity.length(),float(Content.section("player").speed)*float(Content.section("active_combat").defense.block_movement_scale)),"Held Block uses real reduced movement")
	Input.action_release("block")
	Input.action_release("move_down")
	p.input_enabled = false
	p.aim = Vector2.RIGHT
	p.request_block(true)
	var result := hostile()
	check(result.outcome==&"block" and result.resolution.damage==7 and result.resolution.impact==10,"M06 applies Block: 7 damage, 10 impact for test profile 20/20")
	check(not p.request_cast("bolt",session.fixture.target().position),"Block prevents free simultaneous offense")
	p.vitals.refill()
	p.aim = Vector2.LEFT
	p.request_block(true)
	check(hostile().outcome==&"hit","Rear contact bypasses front Block")

func parry() -> void:
	var p: MagePlayer = session.fixture.player
	p.try_parry()
	p.active_defense.tick(float(Content.section("active_combat").defense.parry_window)+0.01)
	check(hostile().outcome==&"hit","Early Parry expires before contact")
	fresh()
	p = session.fixture.player
	p.try_parry()
	check(not p.request_block(true) and not p.try_dash(Vector2.DOWN),"No defense stacking during Parry")
	var result := hostile()
	check(result.outcome==&"parry" and p.vitals.hp==Vitals.maximum("hp") and session.fixture.target().attack_action.timeline.state()==ActionTimeline.State.INTERRUPTED,"On-time Parry interrupts attacker without counterattack")
	check(session.fixture.target().reaction.locked() and p.active_defense.mode==ActiveDefense.Mode.RECOVERY,"Counter opportunity and Parry recovery use real states")
	fresh()
	p = session.fixture.player
	result = hostile()
	var hp := p.vitals.hp
	p.try_parry()
	check(result.outcome==&"hit" and p.vitals.hp==hp,"Late Parry cannot undo confirmed damage")

func mage_defense() -> void:
	var p: MagePlayer = session.fixture.player
	check(p.run.learned==session.catalog.data.players.mage.learned,"Mage profile uses actual existing talents")
	p.request_block(true)
	check(hostile().outcome==&"block","Mage blocks an eligible melee contact")
	fresh()
	p = session.fixture.player
	p.try_parry()
	var enemy: WildEnemy = session.fixture.target()
	enemy.attack_action = action(enemy)
	session.fixture.combat._enemy_bolt(enemy.position,Vector2.LEFT,13,enemy.id,&"untyped",&"sandbox_ranged",enemy.attack_action)
	var payload := session.fixture.combat.get_child(session.fixture.combat.get_child_count()-1) as MagicProjectile
	payload.struck.emit(p,p.position,Vector2.LEFT)
	check(p.vitals.hp==Vitals.maximum("hp") and payload.attack_action.timeline.state()==ActionTimeline.State.INTERRUPTED,"Mage parries actual hostile projectile adapter")
	fresh()
	check(session.cast("nova") and session.fixture.target().hp<250 and session.fixture.target().slowed>0,"Mage casts existing frost area with real cost and slow information")

func projectile() -> void:
	var p: MagePlayer = session.fixture.player
	var enemy: WildEnemy = session.fixture.target()
	enemy.attack_action = action(enemy)
	session.fixture.combat._enemy_bolt(enemy.position,Vector2.LEFT,13,enemy.id,&"untyped",&"sandbox_released",enemy.attack_action)
	var payload := session.fixture.combat.get_child(session.fixture.combat.get_child_count()-1) as MagicProjectile
	enemy.queue_free()
	await session.get_tree().process_frame
	payload.struck.emit(p,p.position,Vector2.LEFT)
	check(p.vitals.hp==Vitals.maximum("hp")-13,"Released payload survives caster in same generation")
	p.vitals.invulnerable = 0
	payload.struck.emit(p,p.position,Vector2.LEFT)
	check(p.vitals.hp==Vitals.maximum("hp")-13,"Repeated projectile callback cannot apply twice")
	check(payload.attack_action.parent_action.actor()==null,"Payload does not retain freed caster")

func area() -> void:
	var p: MagePlayer = session.fixture.player
	var first: WildEnemy = session.fixture.target()
	var second: WildEnemy = session.spawn("dummy",first.position+Vector2(0,16))
	check(p.request_cast("nova",first.position) and first.hp==234 and second.hp==234,"Live Frostkreis hits two targets once each")
	var attack := action(p,ActionTimeline.new(0,0,[{"start":0,"duration":0.2},{"start":0.4,"duration":0.2}],0.2))
	var one := contact(attack,first)
	check(contact(attack,first).reason==&"duplicate_hit","Persistent overlap cannot repeat current phase")
	attack.tick(0.4)
	var two := contact(attack,first)
	check(one.confirmed() and two.confirmed() and one.resolution.hit_id!=two.resolution.hit_id,"Explicit next hit phase owns new receipt")

func reactions() -> void:
	var p: MagePlayer = session.fixture.player
	var enemy: WildEnemy = session.fixture.target()
	for spec in [[65,CombatReaction.Kind.NORMAL],[100,CombatReaction.Kind.INTERRUPT],[130,CombatReaction.Kind.STAGGER]]:
		enemy.reaction.tick(2)
		var result := contact(action(p),enemy,1,spec[0])
		check(result.resolution.impact==spec[0] and enemy.reaction.kind==spec[1],"Actual effective impact %d produces %s" % [spec[0],CombatReaction.Kind.keys()[spec[1]]])
	var remaining := enemy.reaction.remaining
	for i in 8: contact(action(p),enemy,1,130)
	check(enemy.reaction.remaining==remaining,"Repeated impacts do not prolong stagger")
	enemy.reaction.tick(remaining+0.01)
	check(not enemy.reaction.locked() and enemy.reaction.guard_remaining>0,"Recovery preserves a controlled response opportunity")
	var stable: WildEnemy = session.spawn("stable",p.position+Vector2(24,0))
	var result := contact(action(p),stable,1,130)
	check(result.resolution.impact==65 and stable.reaction.kind==CombatReaction.Kind.NORMAL,"Stability influences reaction through M06 exactly once")

func interruption() -> void:
	var attack := action(session.fixture.player,ActionProfiles.clock(0.4,0.2,0.3))
	check(attack.timeline.cancel() and attack.timeline.state()==ActionTimeline.State.INTERRUPTED,"Before Commit a cancellation is allowed")
	attack = action(session.fixture.player,ActionProfiles.clock(0.4,0.2,0.3))
	attack.tick(0.2)
	check(not attack.timeline.cancel(),"After Commit free cancellation is denied")
	check(attack.timeline.interrupt(),"Valid interruption still ends committed action")
	check(contact(attack,session.fixture.target()).reason==&"inactive_phase","Interrupted action cannot deliver contact")

func lifecycle() -> void:
	var old: RegionInstance = session.fixture
	var attack := action(old.player)
	var query := ContactContext.new(attack,old.target(),old.player.position,42)
	old.combat._enemy_bolt(old.player.position,Vector2.RIGHT,10)
	var payload := old.combat.get_child(old.combat.get_child_count()-1) as MagicProjectile
	var old_player: WeakRef = weakref(old.player)
	var old_generation: int = session.generation
	var delayed: Array[CombatContact] = []
	session.get_tree().create_timer(0.03).timeout.connect(func(): delayed.append(CombatContact.resolve(attack,query,AttackProfile.new(20))))
	fresh()
	check(session.generation>old_generation and not attack.is_current(),"Reset invalidates old generation immediately")
	payload.struck.emit(session.fixture.player,session.fixture.player.position,Vector2.RIGHT)
	check(session.fixture.player.vitals.hp==Vitals.maximum("hp"),"Old projectile cannot damage replacement player")
	fresh()
	await session.get_tree().create_timer(0.05).timeout
	check(delayed.size()==1 and delayed[0].reason==&"stale_action","Real delayed callback rejects stale scope")
	check(old_player.get_ref()==null and session.get_tree().get_nodes_in_group("player").size()==1,"Old actors freed, exactly one current player")
	check(session.fixture.enemies().size()==1,"Rapid resets do not duplicate enemies")

func waves() -> void:
	session.start_waves()
	session.set_paused(true)
	session.telemetry.scenario = "A12"
	await session.get_tree().process_frame
	for index in session.catalog.data.waves.size():
		var enemies: Array = session.fixture.enemies()
		check(enemies.size()==session.catalog.data.waves[index].enemies.size(),"Wave %d spawns exactly its definition" % (index+1))
		var attack := action(session.fixture.player)
		for enemy in enemies:
			var result := contact(attack,enemy,1000,0,500)
			check(result.confirmed() and not contact(attack,enemy,1000,0,500).confirmed(),"Defeated wave actor cannot receive repeated contact")
		await session.get_tree().process_frame
		session.waves.tick(session.catalog.data.wave_delay)
	check(not session.waves.running and session.waves.completed==session.catalog.data.waves.size(),"Finite wave sequence completes and stops")
	check(session.fixture.enemies().is_empty(),"No surviving wave duplicates")
