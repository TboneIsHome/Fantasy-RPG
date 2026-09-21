extends SceneTree
## Real regional actors, current attacks and state owners; no runtime demo actors.
const SAVE := "user://m06_hits_only.json"
var checks := 0
var failures: Array[String] = []
var game
var original: Dictionary
var target_number := 0

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS HIT SCENE: " if ok else "FAIL HIT SCENE: ",title)

func fixture() -> void:
	Content._cache = original.duplicate(true)
	var saved := SaveSystem.read_one("res://tests/fixtures/v03_completed_save.json")
	game.build_run(saved.data.run.world_seed, saved.data)
	game.travel_to("vault")
	paused = true
	game.player.vitals.refill()
	game.player.knockback = Vector2.ZERO
	for enemy in get_nodes_in_group("enemies"):
		enemy.remove_from_group("enemies")
		enemy.set_physics_process(false)

func enemy_at(offset: Vector2 = Vector2(15,0)) -> WildEnemy:
	target_number += 1
	var enemy := WildEnemy.new()
	enemy.configure({"id":"m06_target_%d" % target_number,"kind":"wolf","position":game.player.position+offset},game.player,Vector2(-1000,-1000))
	game.terrain.actors.add_child(enemy)
	enemy.set_physics_process(false)
	enemy.hp = 100
	return enemy

func verify() -> void:
	original = Content.all().duplicate(true)
	game = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	game.save_path = SAVE
	fixture()
	await actor_contract()
	fixture()
	await actual_attacks()
	fixture()
	await regions_and_saves()
	Content._cache = original
	paused = false
	game.queue_free()
	for i in 5: await process_frame
	await create_timer(0.15).timeout
	for suffix in ["", ".bak", ".tmp", ".bak.tmp", ".pre-v03", ".pre-v04"]:
		if FileAccess.file_exists(SAVE+suffix): DirAccess.remove_absolute(SAVE+suffix)
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var file := FileAccess.open("res://test-output/hit_scene_results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures},"  ")); file.close()
	print("HIT SCENE RESULT ",checks-failures.size(),"/",checks)
	quit(0 if failures.is_empty() else 1)

func actor_contract() -> void:
	var p: MagePlayer = game.player
	var enemy := enemy_at()
	var profile := AttackProfile.new(30,&"example",20)
	var instance: HitInstance = game.combat.new_hit(&"approved_example","test_attacker")
	var a := p.receive_hit(instance,profile,Vector2.RIGHT)
	var b := enemy.receive_hit(instance,profile,Vector2.RIGHT)
	check(a.damage == b.damage and a.impact == b.impact and p.vitals.hp == 70 and enemy.hp == 70, "Player and NPC use exactly the same resolution inputs and health result")
	check(p.knockback == Vector2(20,0) and enemy.knockback == Vector2(20,0), "Existing actor response consumes effective impact independently of damage")
	check(a.hit_id == b.hit_id and a.hit_id == instance.get_instance_id() and a.action_id == &"approved_example" and a.source_id == "test_attacker" and a.target_id != b.target_id and a.generation == game.regions.generation, "Result retains action, attacker, target and regional hit identity without granting skill XP")
	p.vitals.invulnerable = 0
	var before: Dictionary = game.run.serialize()
	var duplicate := p.receive_hit(instance,profile)
	check(duplicate.reason == &"duplicate_hit" and p.vitals.hp == 70 and game.run.serialize() == before, "Repeated contact cannot apply again after the player's protection timer expires")
	check(enemy.receive_hit(instance,profile).reason == &"duplicate_hit" and enemy.hp == 70, "One AoE instance can affect multiple targets but each target only once")
	check(enemy.receive_hit(game.combat.new_hit(&"next_attack"),profile).damage == 30 and enemy.hp == 40, "A genuinely new attack instance can affect the same target")
	var reentrant: Array[HitResolution] = []
	var guarded: HitInstance = game.combat.new_hit(&"reentrancy")
	var callback := func(_enemy, _amount, _shatter): reentrant.append(enemy.receive_hit(guarded,AttackProfile.new(5)))
	enemy.hit.connect(callback)
	enemy.receive_hit(guarded,AttackProfile.new(5))
	enemy.hit.disconnect(callback)
	check(reentrant.size() == 1 and reentrant[0].reason == &"duplicate_hit" and enemy.hp == 35, "Receipt is claimed before enemy hit signals can reenter health mutation")
	guarded = game.combat.new_hit(&"player_reentrancy")
	callback = func(_amount):
		p.vitals.invulnerable = 0
		reentrant.append(p.receive_hit(guarded,AttackProfile.new(5)))
	p.vitals.damaged.connect(callback)
	p.receive_hit(guarded,AttackProfile.new(5))
	p.vitals.damaged.disconnect(callback)
	check(reentrant.size() == 2 and reentrant[1].reason == &"duplicate_hit" and p.vitals.hp == 65, "Player health signals cannot replay a claimed hit even when immunity is cleared")
	for defense in [DefenseOutcome.miss(),DefenseOutcome.evade(),DefenseOutcome.parry()]:
		p.vitals.refill(); p.knockback = Vector2.ZERO
		var result := p.receive_hit(game.combat.new_hit(&"defense_input"),profile,Vector2.RIGHT,defense)
		check(result.resolved and p.vitals.hp == 100 and p.knockback == Vector2.ZERO, "Confirmed " + str(defense.kind) + " causes no normal actor effect")
	var parried: HitInstance = game.combat.new_hit(&"parried_instance")
	p.receive_hit(parried,profile,Vector2.ZERO,DefenseOutcome.parry())
	check(p.receive_hit(parried,profile).reason == &"duplicate_hit" and p.vitals.hp == 100, "A parried contact cannot be replayed as a hit after its defense outcome changes")
	var blocked := p.receive_hit(game.combat.new_hit(&"block_input"),profile,Vector2.RIGHT,DefenseOutcome.block(0.5,0.25))
	check(blocked.contact and blocked.damage == 15 and blocked.impact == 5 and p.vitals.hp == 85 and p.knockback.x == 5, "Actor accepts caller-supplied block scales without a new active block system")
	p.vitals.refill(); p.knockback = Vector2.ZERO
	check(p.try_dash(Vector2.RIGHT), "Existing dash remains the owner of its activation and cost")
	var evaded := p.receive_hit(game.combat.new_hit(&"during_dash"),profile,Vector2.RIGHT)
	check(evaded.outcome == &"evade" and not evaded.contact and p.vitals.hp == 100 and p.knockback == Vector2.ZERO, "Existing dash protection supplies Evade to the resolver and preserves health")
	p.dash_remaining = 0; p.vitals.refill()
	var notifications: Array[float] = []
	callback = func(amount): notifications.append(amount)
	p.vitals.damaged.connect(callback)
	var impact_only := p.receive_hit(game.combat.new_hit(&"impact_only"),AttackProfile.new(0,&"example",17),Vector2.RIGHT)
	check(impact_only.contact and impact_only.damage == 0 and p.vitals.hp == 100 and p.knockback.x == 17 and notifications.is_empty(), "Impact-only contact moves through the existing response without inventing health damage")
	p.vitals.damaged.disconnect(callback)
	var data := original.duplicate(true)
	data.player.defense = {"protection":100,"resistances":{"example":25},"stability":100}
	data.enemies.wolf.defense = data.player.defense.duplicate(true)
	check(ContentValidator.validate_bundle(data,Content.vault(),Content.discoveries()).is_empty(), "Changed defense definitions are validated before real consumer use")
	Content._cache = data
	enemy = enemy_at(Vector2(30,0))
	p.vitals.refill()
	profile = AttackProfile.new(40,&"example",80)
	a = p.receive_hit(game.combat.new_hit(&"modified_stats"),profile,Vector2.RIGHT)
	b = enemy.receive_hit(game.combat.new_hit(&"modified_stats"),profile,Vector2.RIGHT)
	check(a.damage == 15 and b.damage == 15 and p.vitals.hp == 85 and enemy.hp == 85, "One authored protection/resistance profile changes real Player and NPC damage equally")
	check(a.impact == 40 and b.impact == 40 and p.knockback.x == 40 and enemy.knockback.x == 40, "Authored Stability changes transferred impact while retaining existing response code")
	data.player.defense.resistances.example = 100
	data.enemies.wolf.defense.resistances.example = 100
	p.vitals.refill()
	a = p.receive_hit(game.combat.new_hit(&"immune_contact"),profile,Vector2.RIGHT)
	b = enemy.receive_hit(game.combat.new_hit(&"immune_contact"),profile,Vector2.RIGHT)
	check(a.immune and b.immune and a.damage == 0 and b.damage == 0 and p.vitals.hp == 100 and enemy.hp == 85 and a.impact == 40, "Explicit typed damage immunity works on both actor roles and does not negate impact")
	data.player.defense.resistances.example = -25
	data.player.defense.protection = 0
	a = p.receive_hit(game.combat.new_hit(&"vulnerability"),AttackProfile.new(40,&"example"))
	check(a.damage == 50 and p.vitals.hp == 50, "Negative authored resistance increases damage in the real Player path")
	data.combat.default_damage_type = "typed_default"
	data.player.defense.resistances.typed_default = 50
	p.vitals.refill()
	var vitals := Vitals.new()
	check(p.take_damage(10) and vitals.damage(10) and p.vitals.hp == 95 and vitals.hp == 95, "Legacy Player and isolated Vitals entry points use the same defined default damage type and resolver")
	Content._cache = original.duplicate(true)
	var pure_info := enemy.receive_hit(game.combat.new_hit(&"information_only"),AttackProfile.new(0,&"utility",0,{"future_effect":"burn","seconds":99}))
	check(pure_info.contact and pure_info.secondary.seconds == 99 and enemy.hp == 85 and enemy.slowed == 0, "Secondary information creates no hidden damage or status executor")
	var discarded := enemy_at()
	discarded.queue_free()
	check(discarded.receive_hit(game.combat.new_hit(&"queued_target"),profile).reason == &"stale_contact", "Queued target is rejected before any mutation")
	var weak_target: WeakRef = weakref(discarded)
	await process_frame
	check(weak_target.get_ref() == null, "Hit receipts do not retain freed targets")
	var outside := Node2D.new()
	root.add_child(outside)
	check(game.combat.new_hit(&"wrong_tree").resolve(outside,profile,CombatStats.new(),DefenseOutcome.hit()).reason == &"stale_contact", "Contact cannot be applied to a target outside its originating region")
	outside.queue_free()
	var dormant: SourceGuardian = game.source_story.guardian
	check(dormant.receive_hit(game.combat.new_hit(&"dormant_boss"),profile).reason == &"dormant_target" and dormant.hp == 280, "Dormant guardian rule stays with the actor and is not a second damage formula")
	dormant.awaken()
	var boss_result := dormant.receive_hit(game.combat.new_hit(&"awake_boss"),AttackProfile.new(10,&"example",80),Vector2.RIGHT)
	check(boss_result.damage == 10 and boss_result.impact == 80 and dormant.hp == 270 and dormant.knockback == Vector2.ZERO, "Awake guardian shares resolution while its existing rooted response remains intact")

func actual_attacks() -> void:
	var p: MagePlayer = game.player
	var a := enemy_at(Vector2(10,0))
	var b := enemy_at(Vector2(28,0))
	game.run.learned.assign(["echo"])
	a.slowed = 3
	game.combat.cast("bolt",p.position,a.position)
	var bolt: MagicProjectile = game.combat.get_child(game.combat.get_child_count()-1)
	check(bolt.hit_instance != null and bolt.hit_instance.action_id == &"bolt", "Real projectile retains one cast-time hit identity")
	bolt.struck.emit(a,a.position,Vector2.RIGHT)
	check(a.hp == 71 and b.hp == 88, "Real bolt plus frost bonus and echo preserve 29 / 12 damage")
	var effect_counts := Vector3i(game.combat.effects.particles.size(),game.combat.effects.numbers.size(),game.combat.effects.rings.size())
	bolt.struck.emit(a,a.position,Vector2.RIGHT)
	check(a.hp == 71 and b.hp == 88 and Vector3i(game.combat.effects.particles.size(),game.combat.effects.numbers.size(),game.combat.effects.rings.size()) == effect_counts, "Repeated projectile signal grants neither primary/chained damage nor feedback twice")
	bolt.queue_free()
	a.slowed = 0; a.hp = 100; b.hp = 100
	game.run.inventory.grant("source_heart")
	p.vitals.refill()
	check(p.request_cast("nova",p.position), "Existing area cast still executes through MageAbilities")
	check(a.hp == 84 and b.hp == 84 and a.slowed == 3.5 and b.slowed == 3.5 and p.vitals.mana == 78, "Nova resolves both targets once, then existing slow and one relic refund")
	check(not p.request_cast("nova",p.position) and a.hp == 84 and p.vitals.mana == 78, "Existing cooldown remains authoritative; no duplicate hit or refund")
	a.definition = a.definition.duplicate(true)
	a.definition.defense.resistances.frost = 50
	a.definition.defense.stability = 100
	p.abilities.cooldowns.nova = 0
	p.request_cast("nova",p.position)
	check(a.hp == 76 and b.hp == 68 and a.knockback.length() == 40 and b.knockback.length() == 80, "Real Frostkreis selects frost resistance and resolves impact separately for each target")
	Content._cache.spells.nova.damage_type = "custom_type"
	a.definition.defense.resistances.custom_type = 100
	p.abilities.cooldowns.nova = 0
	p.vitals.refill()
	p.request_cast("nova",p.position)
	check(a.hp == 76 and b.hp == 52 and a.slowed == 3.5 and p.vitals.mana == 78, "Changed spell type reaches live resolution; damage immunity does not silently become status immunity or a missed contact")
	a.definition.defense.protection = 100
	a.definition.defense.resistances.light = 50
	var feedback: Array = []
	a.hit.connect(func(_target,amount,shatter): feedback.append([amount,shatter]))
	game.combat.connect_enemy(a)
	game.combat._bolt_hit(a,a.position,Vector2.RIGHT)
	check(a.hp == 69 and feedback == [[7.0,true]], "Frost bonus joins raw bolt damage before mitigation and hit feedback reports the effective rounded seven")
	check(game.combat.effects.numbers[-1].text == "7!", "Actual floating combat number displays effective damage, retaining the frost-combo mark")
	p.vitals.refill()
	game.combat._enemy_bolt(p.position-Vector2(20,0),Vector2.RIGHT,11,"test_wisp")
	var hostile: MagicProjectile = game.combat.get_child(game.combat.get_child_count()-1)
	hostile.struck.emit(p,p.position,Vector2.RIGHT)
	check(p.vitals.hp == 89 and p.knockback.x == 65, "Hostile projectile preserves 11 damage / existing 65 response")
	p.vitals.invulnerable = 0
	hostile.struck.emit(p,p.position,Vector2.RIGHT)
	check(p.vitals.hp == 89, "Hostile projectile cannot hit again even after damage immunity expires")
	hostile.queue_free()
	p.vitals.refill()
	game.combat._source_slam(p.position,34,21)
	var slam: SourceImpact = game.combat.get_child(game.combat.get_child_count()-1)
	slam._physics_process(0)
	check(p.vitals.hp == 79 and slam.hit_instance.action_id == &"guardian_slam", "Existing source impact uses a dedicated confirmed-hit instance")
	p.vitals.invulnerable = 0
	slam.struck = false
	slam._physics_process(0)
	check(p.vitals.hp == 79, "Source impact remains single hit even if its delivery is repeated")
	slam.queue_free()
	p.vitals.refill()
	game.combat._thorns(p.position,"test_kobold")
	var patch: ThornPatch = game.combat.get_child(game.combat.get_child_count()-1)
	patch._physics_process(0)
	check(p.vitals.hp == 91 and p.hindered == 0.75, "Existing thorn pulse resolves damage before applying its unchanged slow")
	p.vitals.invulnerable = 0
	patch._physics_process(0.1)
	check(p.vitals.hp == 91, "Remaining inside a thorn zone does not add an unrequested frame hit")
	patch._physics_process(0.9)
	check(p.vitals.hp == 82, "Next explicit thorn pulse owns a new instance and still deals damage")
	patch.queue_free()
	p.vitals.refill(); p.hindered = 0
	var wolf := enemy_at(Vector2(4,0))
	wolf.state = WildEnemy.Mode.ATTACK; wolf.timer = 0.2
	wolf._physics_process(0)
	check(p.vitals.hp == 87 and wolf.attack_hit != null and wolf.attack_hit.source_id == wolf.id, "Actual wolf lunge preserves damage and attack source identity")
	p.vitals.invulnerable = 0; wolf.attack_connected = false
	wolf._physics_process(0)
	check(p.vitals.hp == 87, "A repeated wolf contact within its same lunge cannot apply twice")
	wolf.state = WildEnemy.Mode.WINDUP; wolf.timer = 0
	wolf._physics_process(0)
	wolf._physics_process(0)
	check(p.vitals.hp == 74, "A new wolf attack phase creates a new instance under existing AI timing")
	# A fired projectile remains independent of its dead caster, within this region.
	p.vitals.refill()
	game.combat.connect_enemy(wolf)
	wolf.projectile_requested.emit(p.position-Vector2(20,0),Vector2.RIGHT,13)
	hostile = game.combat.get_child(game.combat.get_child_count()-1)
	wolf.queue_free()
	await process_frame
	hostile.struck.emit(p,p.position,Vector2.RIGHT)
	check(p.vitals.hp == 87, "Existing fired projectile can finish after its caster is freed; no strong actor ownership added")
	hostile.queue_free()

func regions_and_saves() -> void:
	var profile := AttackProfile.new(10,&"untyped",5)
	var stale: HitInstance = game.combat.new_hit(&"before_travel")
	var old_scope: WeakRef = weakref(game.combat)
	var results: Array[HitResolution] = []
	create_timer(0.03).timeout.connect(func(): results.append(game.player.receive_hit(stale,profile)))
	game.travel_to("forest")
	game.travel_to("vault")
	game.player.vitals.refill()
	check(game.player.receive_hit(stale,profile).reason == &"stale_contact" and game.player.vitals.hp == 100, "Immediate roundtrip cannot reuse the old hit in a replacement region")
	await create_timer(0.05).timeout
	check(results.size() == 1 and results[0].reason == &"stale_contact" and game.player.vitals.hp == 100, "Actual delayed hit delivery cannot affect the new region")
	# A wall-clock timer can expire during a costly synchronous build, before the
	# deferred deletion boundary. Check disposal only after actual frame boundaries.
	if old_scope.get_ref() != null:
		print("INFO HIT: previous scope inside tree = ",old_scope.get_ref().is_inside_tree(),"; parent queued = ",old_scope.get_ref().get_parent().is_queued_for_deletion())
	for i in 2: await process_frame
	check(old_scope.get_ref() == null and get_nodes_in_group("player").size() == 1, "Hit instance uses weak scope and leaves one current Player after region teardown")
	var fresh: HitInstance = game.combat.new_hit(&"current_region")
	check(game.player.receive_hit(fresh,profile).damage == 10 and game.player.vitals.hp == 90, "Fresh regional instance still resolves correctly")
	check(game.save_game(), "Existing checkpoint can save health after a resolved contact")
	var saved := SaveSystem.read(SAVE)
	check(saved.error.is_empty() and saved.data.save_version == 3 and saved.data.player.hp == 90 and saved.data.player.size() == 5, "Save format remains three with only original actor snapshot fields")
	check(game.load_game() and game.player.vitals.hp == 90, "Load restores health after combat without persisting hit receipts or defense snapshots")
	game.player.vitals.invulnerable = 0
	check(game.player.receive_hit(fresh,profile).reason == &"stale_contact" and game.player.vitals.hp == 90, "Pre-load hit cannot be reapplied after reloading the same region")
	var live: HitInstance = game.combat.new_hit(&"before_unload")
	var old_player: MagePlayer = game.player
	game.regions.unload()
	check(old_player.receive_hit(live,profile).reason == &"stale_contact", "Deactivated tree rejects even a still-referenced old target before frame-end free")
