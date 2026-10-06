class_name CombatSystem
extends Node2D

signal sound_requested(id: String)
signal enemy_defeated
var player: MagePlayer
var run: RunState
var effects: CombatFeedback
var peaceful_area: Rect2
var _active: bool = true

func deactivate() -> void:
	_active = false
	player = null
	run = null

func _can_act() -> bool:
	return _active and is_inside_tree() and not is_queued_for_deletion()

func _exit_tree() -> void:
	deactivate()

func _ready() -> void:
	player.hit_scope = weakref(self)
	effects = CombatFeedback.new()
	add_child(effects)

func new_hit(action: StringName, source_id: String = "player") -> HitInstance:
	if not _can_act(): return null
	return HitInstance.new(self, action, source_id, int(get_parent().generation))

func new_action(actor: Node2D, id: StringName, clock: ActionTimeline, rules: Dictionary, source_id: String = "player") -> AttackInstance:
	if not _can_act() or not clock.valid: return null
	var action := AttackInstance.new(self,actor,id,source_id,clock,rules)
	clock.start()
	return action

func released_action(carrier: Node2D, parent: AttackInstance, id: StringName, clock: ActionTimeline, geometry: String, source: String, rules: Dictionary = {}) -> AttackInstance:
	var actor := parent.actor() if parent != null else player
	var action := new_action(actor,id,clock,ActionProfiles.rules(geometry) if rules.is_empty() else rules,source)
	if action == null: return null
	action.parent_action=parent
	action.release_to(carrier)
	return action

func accepts_hit(instance: HitInstance, target: Node) -> bool:
	return _can_act() and instance.scope() == self and instance.generation == int(get_parent().generation) and is_instance_valid(target) and not target.is_queued_for_deletion() and target.is_inside_tree() and get_parent().is_ancestor_of(target)

func cast(id: String, origin: Vector2, target: Vector2) -> void:
	if not _can_act(): return
	var data: Dictionary = Content.section("spells")[id]
	var action := new_action(player,StringName(id+"_cast"),ActionProfiles.spell(data),ActionProfiles.rules("projectile" if id=="bolt" else "area"))
	if action == null or not action.is_current(): return
	player.track_action(action)
	sound_requested.emit(id)
	if id == "bolt":
		var projectile := MagicProjectile.new()
		projectile.position = origin
		projectile.direction = origin.direction_to(target) if origin.distance_to(target)>1 else player.aim
		projectile.speed = float(data.speed)
		projectile.remaining = float(data.range)
		projectile.attack_action = released_action(projectile,action,&"bolt",ActionProfiles.clock(0,float(data.range)/float(data.speed),0),"projectile","player")
		projectile.struck.connect(_resolve_bolt_contact.bind(projectile.attack_action))
		add_child(projectile)
		projectile.hit_instance = projectile.attack_action.hit_for_phase(0)
	else:
		var center := origin+(target-origin).limit_length(float(data.range))
		# A targeting ray prevents casting through solid trunks, rocks or water.
		var ray := PhysicsRayQueryParameters2D.create(origin,center,1)
		var obstacle := get_world_2d().direct_space_state.intersect_ray(ray)
		if not obstacle.is_empty():
			center = obstacle.position+(origin-center).normalized()*5
		effects.ring(center,float(data.radius),Color("91dfed"))
		effects.burst(center,Color("b3edeb"),25)
		var hit_any := false
		var profile := CombatProfiles.player_attack(float(data.damage), data.damage_type, {"slow_seconds":float(data.slow_duration)})
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var query := ContactContext.new(action,enemy,center,float(data.radius),center.direction_to(enemy.global_position))
			query.visibility=_clear_line
			var contact := CombatContact.resolve(action,query,profile)
			if contact.confirmed():
				enemy.slowed = float(contact.resolution.secondary.slow_seconds)
				hit_any = true
		if not _can_act(): return
		var refund := run.inventory.frost_refund()
		if hit_any and refund>0:
			player.vitals.restore_mana(refund)
			effects.number(player.global_position,"+%s MP" % Content.number_text(refund),Color("a7e9da"))
		if "bloom" in run.learned and player.global_position.distance_to(center)<=float(data.radius):
			var healing: float = float(Content.section("skills").bloom.healing)
			player.vitals.heal(healing)
			effects.number(player.global_position,"+" + Content.number_text(healing),Color("b6edb3"))
	action.timeline.finish_active()

func _clear_line(from: Vector2, to: Vector2) -> bool:
	return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from,to,1)).is_empty()

func _bolt_hit(body: Node, point: Vector2, direction: Vector2) -> void:
	# Diagnostic compatibility entry only; live callbacks retain their released action.
	var action := new_action(player,&"bolt_diagnostic",ActionProfiles.clock(0,ActionProfiles.instant(),0),ActionProfiles.rules("projectile"))
	if action == null: return
	_resolve_bolt_contact(body,point,direction,action)
	action.timeline.finish_active()

func projectile_context(action: AttackInstance, body: Node2D, point: Vector2, heading: Vector2) -> ContactContext:
	var reach := MagicProjectile.COLLISION_RADIUS
	var carrier := action.carrier()
	if carrier is MagicProjectile: reach += carrier.safe_margin
	for child in body.get_children():
		if child is CollisionShape2D and child.shape is CircleShape2D:
			reach += child.shape.radius
			break
	var query := ContactContext.new(action,body,point,reach,heading)
	query.visibility=_clear_line
	return query

func _resolve_bolt_contact(body: Node, point: Vector2, direction: Vector2, action: AttackInstance) -> void:
	if not _can_act(): return
	if action == null or not action.is_current(): return
	if body is WildEnemy:
		var chained: WildEnemy = null
		if body.slowed>0 and "echo" in run.learned:
			for other in get_tree().get_nodes_in_group("enemies"):
				if other != body and other.hp>0 and other.global_position.distance_to(body.global_position)<float(Content.section("skills").echo.chain_range) and _clear_line(body.global_position,other.global_position):
					if chained==null or other.global_position.distance_to(point)<chained.global_position.distance_to(point):
						chained = other
		var data: Dictionary = Content.section("spells").bolt
		var shatter: bool = body.slowed > 0
		var amount := float(data.damage) + (float(data.shatter_bonus) if shatter else 0.0)
		var contact := CombatContact.resolve(action,projectile_context(action,body,point,direction),CombatProfiles.player_attack(amount,data.damage_type,{"shatter":shatter}))
		if not contact.confirmed() or not _can_act(): return
		if chained:
			var echo: Dictionary = Content.section("skills").echo
			var echo_action := new_action(player,&"echo",ActionProfiles.clock(0,ActionProfiles.instant(),0),ActionProfiles.rules("area"))
			var query := ContactContext.new(echo_action,chained,body.global_position,float(echo.chain_range),direction)
			query.visibility=_clear_line
			var echoed := CombatContact.resolve(echo_action,query,CombatProfiles.player_attack(float(echo.chain_damage),echo.damage_type))
			echo_action.timeline.finish_active()
			if echoed.confirmed(): effects.ring(chained.global_position,15,Color("eae9b3"))
	effects.burst(point,Color("c2eecb"),6)

func connect_enemy(enemy: WildEnemy) -> void:
	enemy.defeated.connect(_defeated)
	enemy.hit.connect(func(target,amount,shatter):
		if not _can_act(): return
		effects.number(target.global_position,str(int(amount))+("!" if shatter else ""),Color("c4f1ee") if shatter else Color("f0d9ab"))
		effects.burst(target.global_position+Vector2(0,-9),Color("aed8c5"),8)
		sound_requested.emit("hit"))
	var caster_id: String=enemy.id
	var damage_type: StringName=enemy.definition.damage_type
	var action: StringName=enemy.kind + "_projectile"
	var actor: WeakRef=weakref(enemy)
	enemy.projectile_requested.connect(func(origin,direction,amount):
		var live := actor.get_ref() as WildEnemy
		if is_instance_valid(live): _enemy_bolt(origin,direction,amount,caster_id,damage_type,action,live.attack_action))
	enemy.thorns_requested.connect(func(point):
		var live := actor.get_ref() as WildEnemy
		if is_instance_valid(live): _thorns(point,caster_id,live.attack_action))
	if enemy is SourceGuardian:
		enemy.slam_requested.connect(func(point,radius,amount):
			var live := actor.get_ref() as WildEnemy
			if is_instance_valid(live): _source_slam(point,radius,amount,live.attack_action))

func _source_slam(point: Vector2, radius: float, amount: float, parent: AttackInstance = null) -> void:
	if not _can_act(): return
	if parent != null and (not parent.is_current() or parent.timeline.state()!=ActionTimeline.State.ACTIVE): return
	var impact := SourceImpact.new()
	impact.position=point
	impact.player=player
	impact.radius=radius
	impact.damage=amount
	impact.attack_action=released_action(impact,parent,&"guardian_slam",ActionProfiles.clock(0,ActionProfiles.instant(),0),"area",SourceQuest.GUARDIAN_ID)
	add_child(impact)
	impact.hit_instance=impact.attack_action.hit_for_phase(0)
	sound_requested.emit("nova")

func clear_guardian_effects() -> void:
	for child in get_children():
		if child is SourceImpact or (child is MagicProjectile and child.source_id==SourceQuest.GUARDIAN_ID):
			child.queue_free()

func _thorns(point: Vector2, source_id: String = "", parent: AttackInstance = null) -> void:
	if not _can_act(): return
	if parent != null and (not parent.is_current() or parent.timeline.state()!=ActionTimeline.State.ACTIVE): return
	var definition: Dictionary=Content.section("enemies").kobold
	var patch := ThornPatch.new()
	patch.position=point
	patch.player=player
	patch.radius=float(definition.thorn_radius)
	patch.remaining=float(definition.thorn_duration)
	patch.damage=float(definition.damage)
	patch.slow_seconds=float(definition.thorn_slow)
	patch.interval=float(definition.thorn_interval)
	patch.peaceful_area=peaceful_area
	patch.attack_action=released_action(patch,parent,&"thorn_pulse",ActionProfiles.pulses(patch.remaining,patch.interval),"ground",source_id)
	patch.source_id=source_id
	add_child(patch)
	sound_requested.emit("hit")

func _enemy_bolt(origin: Vector2, direction: Vector2, amount: float, source_id: String = "", damage_type: StringName = &"", action: StringName = &"enemy_projectile", parent: AttackInstance = null) -> void:
	if not _can_act(): return
	if parent != null and (not parent.is_current() or parent.timeline.state()!=ActionTimeline.State.ACTIVE): return
	var projectile := MagicProjectile.new()
	projectile.position = origin
	projectile.direction = direction
	projectile.speed = float(Content.section("combat").enemy_projectile_speed)
	projectile.remaining = float(Content.section("combat").enemy_projectile_range)
	projectile.hostile = true
	projectile.source_id=source_id
	var instance := released_action(projectile,parent,action,ActionProfiles.clock(0,projectile.remaining/projectile.speed,0),"projectile",source_id)
	var profile := CombatProfiles.hostile_attack(amount,damage_type)
	projectile.attack_action=instance
	projectile.struck.connect(func(body,point,heading):
		if not _can_act() or not instance.is_current(): return
		if body is MagePlayer and not peaceful_area.has_point(body.global_position):
			var contact := CombatContact.resolve(instance,projectile_context(instance,body,point,heading),profile)
			if not contact.confirmed(): return
		effects.burst(point,Color("e9b192"),7))
	add_child(projectile)
	projectile.hit_instance=instance.hit_for_phase(0)

func _defeated(enemy: WildEnemy) -> void:
	if not _can_act(): return
	if enemy is SourceGuardian:
		return
	if not run.defeat_enemy(enemy.id, enemy.kind):
		return
	effects.burst(enemy.global_position,Color("d3dcb0"),18)
	enemy_defeated.emit()
