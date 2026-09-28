extends SceneTree
## Real regional actors and existing attack adapters. Dedicated save only.
const SAVE := "user://m07_combat_only.json"
var checks := 0
var failures: Array[String] = []
var game
var original: Dictionary
var serial := 0
func _initialize() -> void: call_deferred("verify")
func check(ok: bool, title: String) -> void:
	checks+=1
	if not ok: failures.append(title)
	print("PASS ACTIVE SCENE: " if ok else "FAIL ACTIVE SCENE: ",title)
func fixture() -> void:
	Content._cache=original.duplicate(true)
	var saved := SaveSystem.read_one("res://tests/fixtures/v03_completed_save.json")
	game.build_run(saved.data.run.world_seed,saved.data)
	game.travel_to("vault")
	paused=true
	game.player.vitals.refill()
	game.player.knockback=Vector2.ZERO
	for enemy in get_nodes_in_group("enemies"):
		enemy.remove_from_group("enemies")
		enemy.collision_layer=0
		enemy.set_physics_process(false)
func enemy_at(offset: Vector2=Vector2(16,0)) -> WildEnemy:
	serial+=1
	var enemy := WildEnemy.new()
	enemy.configure({"id":"m07_target_%d" % serial,"kind":"wolf","position":game.player.position+offset},game.player,Vector2(-1000,-1000))
	game.terrain.actors.add_child(enemy)
	enemy.hp=100
	enemy.set_physics_process(false)
	return enemy
func action_for(actor: Node2D, clock: ActionTimeline=null, geometry: String="direct") -> AttackInstance:
	return game.combat.new_action(actor,&"m07_test",ActionProfiles.clock(0,1,0.2) if clock==null else clock,ActionProfiles.rules(geometry),actor.id if actor is WildEnemy else "player")
func query_for(action: AttackInstance, target: Node2D, reach: float=30, heading: Vector2=Vector2.RIGHT, dot: float=-1) -> ContactContext:
	return ContactContext.new(action,target,action.actor().global_position,reach,heading,dot).follow(action.actor())
func hit_player(enemy: WildEnemy, profile: AttackProfile=null, geometry: String="direct") -> CombatContact:
	enemy.attack_action=action_for(enemy,null,geometry)
	return CombatContact.resolve(enemy.attack_action,query_for(enemy.attack_action,game.player,30,Vector2.LEFT,0),AttackProfile.new(20,&"untyped",20) if profile==null else profile)
func verify() -> void:
	original=Content.all().duplicate(true)
	game=load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path=SAVE
	fixture();await contacts()
	fixture();await defenses()
	fixture();reactions()
	fixture();await deliveries()
	fixture();await lifecycle()
	Content._cache=original
	paused=false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["",".bak",".tmp",".bak.tmp",".pre-v03",".pre-v04"]:
		if FileAccess.file_exists(SAVE+suffix): DirAccess.remove_absolute(SAVE+suffix)
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/active_combat_scene_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures},"  "));file.close()
	print("ACTIVE COMBAT SCENE RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)
func contacts() -> void:
	var p: MagePlayer=game.player
	var enemy := enemy_at()
	var profile := AttackProfile.new(15,&"test",20)
	var action := action_for(p,ActionProfiles.clock(1,1,0.2))
	var early := query_for(action,enemy)
	check(CombatContact.resolve(action,early,profile).reason==&"inactive_phase" and enemy.hp==100,"Startup never reaches M06")
	action.tick(0.5)
	check(CombatContact.resolve(action,query_for(action,enemy),profile).reason==&"inactive_phase","Commit alone is not a contact window")
	action.tick(0.5)
	check(CombatContact.resolve(action,early,profile).reason==&"inactive_phase","Captured pre-active query does not become valid later")
	var query := query_for(action,enemy)
	enemy.position.x+=100
	check(CombatContact.resolve(action,query,profile).reason==&"out_of_range","Target moving away is revalidated at contact")
	enemy.position.x-=100;p.position.x-=100
	check(CombatContact.resolve(action,query,profile).reason==&"out_of_range","Actor moving away changes the live query origin")
	p.position.x+=100
	check(CombatContact.resolve(action,query_for(action,enemy,30,Vector2.LEFT,0),profile).reason==&"wrong_direction","Wrong facing remains a miss without accuracy roll")
	query.visibility=func(_from,_to): return false
	check(CombatContact.resolve(action,query,profile).reason==&"obstructed" and enemy.hp==100,"Fresh obstruction rejects contact")
	query.visibility=Callable()
	var result := CombatContact.resolve(action,query,profile)
	check(result.confirmed() and result.outcome==&"hit" and result.resolution.damage==15 and result.resolution.impact==20 and enemy.hp==85,"Valid contact uses M06 and actor-owned health")
	check(result.resolution.source_id=="player" and result.resolution.generation==game.regions.generation,"Confirmed result retains M06 source and generation")
	check(CombatContact.resolve(action,query,profile).reason==&"duplicate_hit" and enemy.hp==85,"Same target is claimed once per phase")
	action.timeline.finish_active()
	check(CombatContact.resolve(action,query,profile).reason==&"inactive_phase","Recovery cannot deliver a contact")
	action.tick(1)
	check(CombatContact.resolve(action,query,profile).reason==&"inactive_phase","Completed action cannot deliver a contact")
	action=action_for(p);action.timeline.interrupt()
	check(CombatContact.resolve(action,query_for(action,enemy),profile).reason==&"inactive_phase","Interrupted action cannot deliver a contact")
	action=action_for(p,ActionTimeline.new(0,0,[{"start":0,"duration":0.2},{"start":0.4,"duration":0.2}],0.2))
	var first := CombatContact.resolve(action,query_for(action,enemy),profile)
	action.tick(0.4)
	var second := CombatContact.resolve(action,query_for(action,enemy),profile)
	check(first.confirmed() and second.confirmed() and first.resolution.hit_id!=second.resolution.hit_id and enemy.hp==55,"Explicit next phase creates a new M06 receipt")
	var other := enemy_at(Vector2(0,16))
	check(CombatContact.resolve(action,query_for(action,other),profile).confirmed() and other.hp==85,"One AoE phase can independently hit multiple targets")
	check(CombatContact.resolve(action,query_for(action,other),profile).reason==&"duplicate_hit","AoE cannot replay a target within its phase")
	var doomed := enemy_at()
	var weak_target: WeakRef=weakref(doomed)
	var discarded_query := query_for(action,doomed)
	doomed.queue_free()
	check(CombatContact.resolve(action,discarded_query,profile).reason==&"invalid_target","Queued target is rejected")
	await process_frame
	check(weak_target.get_ref()==null and CombatContact.resolve(action,discarded_query,profile).reason==&"invalid_target","Query does not retain freed targets")
	var outside := Node2D.new();root.add_child(outside)
	check(CombatContact.resolve(action,query_for(action,outside),profile).reason==&"invalid_target","Target outside the originating region is invalid")
	outside.queue_free()
	action=action_for(p)
	query=query_for(action,enemy)
	var repeated: Array[CombatContact]=[]
	var callback := func(_enemy,_amount,_shatter): repeated.append(CombatContact.resolve(action,query,profile))
	enemy.hit.connect(callback)
	CombatContact.resolve(action,query,profile)
	enemy.hit.disconnect(callback)
	check(repeated.size()==1 and repeated[0].reason==&"duplicate_hit" and enemy.hp==40,"Reentrant hit signals cannot double-apply confirmed damage")
	var stale_actor := enemy_at()
	var stale_action := action_for(stale_actor)
	var stale_query := query_for(stale_action,p)
	stale_actor.queue_free()
	check(CombatContact.resolve(stale_action,stale_query,profile).reason==&"stale_action","Queued attacker invalidates unreleased actions")
	var invalid := query_for(action,enemy);invalid.reach=NAN
	check(CombatContact.resolve(action,invalid,profile).reason==&"invalid_geometry","Nonfinite spatial context is rejected")
func defenses() -> void:
	var p: MagePlayer=game.player
	var enemy := enemy_at()
	p.input_enabled=true
	Input.action_press("block");Input.action_press("move_down")
	p._physics_process(0)
	check(p.active_defense.mode==ActiveDefense.Mode.BLOCK and is_equal_approx(p.velocity.length(),float(Content.section("player").speed)*float(Content.section("active_combat").defense.block_movement_scale)),"Actual held input activates Block and reduces movement")
	Input.action_release("block");Input.action_release("move_down")
	p._physics_process(0)
	check(p.active_defense.mode==ActiveDefense.Mode.NORMAL,"Input release ends the stance")
	await process_frame
	Input.action_press("parry");p._physics_process(0)
	check(p.active_defense.mode==ActiveDefense.Mode.PARRY,"Actual Q action opens the Parry window")
	Input.action_release("parry")
	p.input_enabled=false;p.active_defense.reset();p.aim=Vector2.RIGHT
	enemy.position=p.position+Vector2(16,0)
	check(InputMap.has_action("block") and InputMap.has_action("parry"),"Defensive actions are bound in the current input setup")
	p.request_block(true)
	check(not p.request_cast("bolt",enemy.position),"Block cannot freely attack at the same time")
	var result := hit_player(enemy)
	check(result.outcome==&"block" and result.confirmed() and result.resolution.damage==7 and result.resolution.impact==10 and p.vitals.hp==93,"Block passes authored scales to M06, retaining damage and impact")
	check(game.combat.effects.numbers[-1].text=="Block","Confirmed block reaches existing presentation")
	p.vitals.refill();p.aim=Vector2.LEFT;p.request_block(true)
	check(hit_player(enemy).outcome==&"hit" and p.vitals.hp==80,"Rear hit bypasses the held block")
	p.vitals.refill();p.request_block(false);p.aim=Vector2.RIGHT
	check(p.try_parry() and not p.try_parry() and not p.try_dash(Vector2.RIGHT) and not p.request_block(true),"Active Parry rejects defense stacking and refresh requests")
	result=hit_player(enemy)
	check(result.outcome==&"parry" and result.confirmed() and p.vitals.hp==100 and enemy.attack_action.timeline.state()==ActionTimeline.State.INTERRUPTED and enemy.reaction.locked(),"Parry interrupts the current attacker and creates a counter opportunity")
	check(game.combat.effects.numbers[-1].text=="Parade" and p.active_defense.mode==ActiveDefense.Mode.RECOVERY,"Confirmed parry is presented then consumed")
	check(hit_player(enemy).outcome==&"hit" and p.vitals.hp==80,"Consumed parry grants no protection against another contact")
	p.vitals.refill();p.active_defense.reset();p.try_parry()
	p.active_defense.tick(float(Content.section("active_combat").defense.parry_window)+0.01)
	check(hit_player(enemy).outcome==&"hit" and not p.request_cast("bolt",enemy.position),"Mistimed parry remains exposed with offensive recovery")
	p.active_defense.tick(1)
	check(p.active_defense.mode==ActiveDefense.Mode.NORMAL,"Recovery returns to normal control")
	p.vitals.refill()
	var stamina := p.vitals.stamina
	check(p.try_dash(Vector2.DOWN) and p.vitals.stamina==stamina-float(Content.section("player").dash_cost),"Dodge preserves the existing resource cost")
	result=hit_player(enemy)
	check(result.outcome==&"evade" and result.resolution==null and p.vitals.hp==100,"Dodge rejects contact before invoking M06")
	var position := p.position
	p.input_enabled=true;p._physics_process(0.02);p.input_enabled=false
	check(p.position.distance_to(position)>0,"Dodge produces actual position change")
	p.active_defense.tick(1);p.dash_remaining=0;p.vitals.invulnerable=0
	enemy.position=p.position+Vector2(16,0)
	check(hit_player(enemy).outcome==&"hit","Protection expires; dodge is not a permanent miss state")
	p.vitals.refill();p.aim=Vector2.RIGHT;p.request_block(true)
	check(hit_player(enemy,null,"ground").outcome==&"hit","Ground pulse eligibility cannot inherit an unrelated Block")
func reactions() -> void:
	var p: MagePlayer=game.player
	var enemy := enemy_at()
	var result := hit_player(enemy)
	check(result.confirmed() and p.reaction.kind==CombatReaction.Kind.NORMAL and p.knockback.length()==20,"Normal contact retains controlled actor response")
	p.vitals.refill()
	var offense := action_for(p);p.track_action(offense)
	result=hit_player(enemy,AttackProfile.new(1,&"test",100))
	check(result.resolution.impact==100 and p.reaction.kind==CombatReaction.Kind.INTERRUPT and offense.timeline.state()==ActionTimeline.State.INTERRUPTED and not p.try_parry(),"Effective impact interrupts player action and temporarily denies defense")
	p.reaction.tick(2);p.vitals.refill()
	result=hit_player(enemy,AttackProfile.new(1,&"test",130))
	check(result.resolution.impact==130 and p.reaction.kind==CombatReaction.Kind.STAGGER and p.knockback.length()==130,"Stronger effective impact creates bounded Stagger")
	var remaining := p.reaction.remaining
	for i in 8:
		p.vitals.invulnerable=0
		hit_player(enemy,AttackProfile.new(1,&"test",130))
	check(p.reaction.remaining==remaining and p.vitals.hp==91,"Repeated real hits still apply damage but cannot prolong stagger")
	p.reaction.tick(remaining+0.01)
	check(not p.reaction.locked() and p.reaction.guard_remaining>0 and p.try_parry(),"Player regains an actual defensive opportunity after reaction")
	p.active_defense.reset();p.reaction.tick(2);p.vitals.refill()
	Content._cache.player.defense.stability=100
	result=hit_player(enemy,AttackProfile.new(1,&"test",130))
	check(result.resolution.impact==65 and p.reaction.kind==CombatReaction.Kind.NORMAL and p.knockback.length()==65,"Authored Stability changes live reaction through M06 exactly once")
	Content._cache.player.defense.stability=0
	enemy.reaction.tick(2);enemy.attack_action=action_for(enemy)
	var action := action_for(p)
	result=CombatContact.resolve(action,query_for(action,enemy),AttackProfile.new(1,&"test",130))
	check(result.confirmed() and enemy.reaction.kind==CombatReaction.Kind.STAGGER and enemy.attack_action.timeline.state()==ActionTimeline.State.INTERRUPTED,"NPC consumes the same effective impact and interrupts its current action")
	enemy.reaction.tick(enemy.reaction.remaining+0.01);enemy.hit_stop=0.05
	enemy._physics_process(0)
	check(enemy.state==WildEnemy.Mode.CHASE and not enemy.reaction.locked(),"Presentation hit stop cannot steal the post-stagger AI control window")
func deliveries() -> void:
	var p: MagePlayer=game.player
	var enemy := enemy_at()
	game.combat.cast("bolt",p.position,enemy.position)
	var bolt: MagicProjectile=game.combat.get_child(game.combat.get_child_count()-1)
	check(p.attack_action.timeline.state()==ActionTimeline.State.RECOVERY and bolt.attack_action.timeline.state()==ActionTimeline.State.ACTIVE,"Released bolt has its own action while caster recovers")
	bolt.struck.emit(enemy,enemy.position,Vector2.RIGHT)
	bolt.struck.emit(enemy,enemy.position,Vector2.RIGHT)
	check(enemy.hp==81,"Repeated live projectile signal applies one existing 19-damage hit")
	bolt.queue_free()
	p.vitals.refill();p.aim=Vector2.RIGHT;p.try_parry()
	enemy.attack_action=action_for(enemy)
	game.combat._enemy_bolt(enemy.position,Vector2.LEFT,13,enemy.id,&"untyped",&"m07_hostile",enemy.attack_action)
	var hostile: MagicProjectile=game.combat.get_child(game.combat.get_child_count()-1)
	hostile.struck.emit(p,p.position,Vector2.LEFT)
	check(p.vitals.hp==100 and enemy.attack_action.timeline.state()==ActionTimeline.State.INTERRUPTED and hostile.attack_action.timeline.state()==ActionTimeline.State.INTERRUPTED,"Parrying a real hostile projectile invalidates payload and current source action")
	hostile.queue_free()
	p.active_defense.reset();p.try_parry();enemy.reaction.tick(2)
	var previous := action_for(enemy);enemy.attack_action=previous
	game.combat._enemy_bolt(enemy.position,Vector2.LEFT,13,enemy.id,&"untyped",&"old_payload",previous)
	hostile=game.combat.get_child(game.combat.get_child_count()-1)
	previous.timeline.finish_active();previous.tick(1)
	enemy.attack_action=action_for(enemy)
	hostile.struck.emit(p,p.position,Vector2.LEFT)
	check(enemy.attack_action.timeline.state()==ActionTimeline.State.ACTIVE and not enemy.reaction.locked(),"Parrying an older projectile cannot interrupt the caster's newer action")
	hostile.queue_free();p.active_defense.reset();p.vitals.refill()
	game.combat._enemy_bolt(enemy.position,Vector2.LEFT,13,enemy.id,&"untyped",&"released",enemy.attack_action)
	hostile=game.combat.get_child(game.combat.get_child_count()-1)
	enemy.queue_free()
	await process_frame
	hostile.struck.emit(p,p.position,Vector2.LEFT)
	check(p.vitals.hp==87,"Explicitly released projectile can finish after caster death in the same region")
	hostile.queue_free();p.vitals.refill()
	game.combat._thorns(p.position,"m07_kobold")
	var patch: ThornPatch=game.combat.get_child(game.combat.get_child_count()-1)
	patch._physics_process(0)
	var first := patch.attack_action.hit_for_phase(0)
	check(p.vitals.hp==91,"Existing ground attack enters its first explicit phase")
	p.vitals.invulnerable=0;patch._physics_process(0.1)
	check(p.vitals.hp==91,"Continuous ground overlap does not deliver frame damage")
	patch._physics_process(float(patch.interval))
	check(p.vitals.hp==82 and patch.attack_action.hit_for_phase(1)!=first,"Next authored pulse receives a distinct M06 instance")
	patch.queue_free()
	p.vitals.refill();p.knockback=Vector2.ZERO;p.hindered=0
	var wolf := enemy_at(Vector2(0,12))
	wolf.attack_direction=wolf.global_position.direction_to(p.global_position)
	wolf.begin_attack();wolf._physics_process(float(wolf.definition.windup));wolf._physics_process(0)
	wolf._physics_process(float(wolf.definition.lunge_duration))
	check(wolf.state==WildEnemy.Mode.RECOVER and wolf.velocity==Vector2.ZERO,"Wolf ends lunge movement at Active end, not Recovery end")
func lifecycle() -> void:
	var p: MagePlayer=game.player
	var enemy := enemy_at()
	var action := action_for(p)
	var query := query_for(action,enemy)
	var old_target: WeakRef=weakref(enemy)
	var delivered: Array[CombatContact]=[]
	create_timer(0.03).timeout.connect(func(): delivered.append(CombatContact.resolve(action,query,AttackProfile.new(10))))
	game.combat._enemy_bolt(p.position,Vector2.RIGHT,10)
	var projectile: MagicProjectile=game.combat.get_child(game.combat.get_child_count()-1)
	game.travel_to("forest");game.travel_to("vault")
	game.player.vitals.refill()
	check(not action.is_current() and CombatContact.resolve(action,query,AttackProfile.new(10)).reason==&"stale_action","Rapid roundtrip invalidates the old generation")
	projectile.struck.emit(game.player,game.player.position,Vector2.RIGHT)
	check(game.player.vitals.hp==100,"Stale projectile callback cannot touch the replacement player")
	await create_timer(0.05).timeout
	check(delivered.size()==1 and delivered[0].reason==&"stale_action" and game.player.vitals.hp==100,"Actual delayed action is discarded after region change")
	for i in 2: await process_frame
	check(old_target.get_ref()==null and get_nodes_in_group("player").size()==1,"Weak context releases the old actor and leaves one player")
	game.player.try_parry()
	var before_load := action_for(game.player);game.player.track_action(before_load)
	check(game.save_game(),"Existing save works while defense and an action are active")
	var saved := SaveSystem.read(SAVE)
	check(saved.error.is_empty() and saved.data.save_version==3 and saved.data.player.size()==5 and not saved.data.run.has("active_combat"),"Schema 3 contains no transient combat state")
	check(game.load_game() and game.player.active_defense.mode==ActiveDefense.Mode.NORMAL and game.player.attack_actions.is_empty() and not game.player.reaction.locked(),"Load restores existing persistent data with fresh combat state")
	check(not before_load.is_current(),"Pre-load action cannot be reused after same-region reconstruction")
	var live := action_for(game.player)
	game.regions.unload()
	check(not live.is_current(),"Deactivation invalidates actions before deferred tree destruction")
