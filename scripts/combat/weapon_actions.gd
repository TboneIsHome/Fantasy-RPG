class_name WeaponActions
extends RefCounted
## Actor-local adapter. M07 owns time/contact/defense; M06 owns all arithmetic.
signal contact_resolved(action: AttackInstance, context: ContactContext, result: CombatContact)
signal action_started(action: AttackInstance)
var main_id: String = ""
var off_id: String = ""
var current: AttackInstance
var definition: Dictionary = {}
var heading := Vector2.RIGHT
var hand: String = "main"
var last_completed: String = ""
var _actor: WeakRef
var _previous_time: float = 0
var _release_requested: bool = false
var _released: bool = false
var _reported: Dictionary = {}

func _init(owner: MagePlayer) -> void:
	_actor = weakref(owner)

func actor() -> MagePlayer:
	return _actor.get_ref() as MagePlayer

func configure(main: String, off: String = "") -> bool:
	var data := Content.weapons()
	if busy() or not data.weapons.has(main) or (not off.is_empty() and not data.weapons.has(off)): return false
	if not off.is_empty() and (not data.weapons[main].dual_compatible or not data.weapons[off].dual_compatible): return false
	main_id = main
	off_id = off
	last_completed = ""
	return true

func defense_config() -> Dictionary:
	var data := Content.weapons()
	return data.defenses[data.dual_defense if not off_id.is_empty() else data.weapons[main_id].defense]

func busy() -> bool:
	return current != null and current.is_current() and current.timeline.state() not in [ActionTimeline.State.COMPLETED,ActionTimeline.State.INTERRUPTED]

func allows_defense() -> bool:
	return not busy() or not current.timeline.committed()

func cancel() -> bool:
	if not busy(): return false
	return current.timeline.cancel()

func _settle() -> void:
	if current == null: return
	if not current.is_current(): current.timeline.interrupt()
	if current.timeline.state() == ActionTimeline.State.COMPLETED:
		last_completed = str(current.action_id)
	elif current.timeline.state() == ActionTimeline.State.INTERRUPTED: last_completed = ""

func action_for(slot: String, from_hand: String) -> String:
	var data := Content.weapons()
	if slot == "combined":
		for pair in data.pairings.values():
			if pair.main == main_id and pair.off == off_id: return pair.combined
		return ""
	if not from_hand in ["main","off"]: return ""
	var id := off_id if from_hand == "off" else main_id
	return str(data.weapons[id].portfolio.get(slot,"")) if not id.is_empty() else ""

func request(slot: String = "primary", from_hand: String = "main") -> bool:
	_settle()
	var p := actor()
	if not is_instance_valid(p) or not p.combat_alive() or p.is_queued_for_deletion() or busy() or p.reaction.locked() or p.active_defense.blocks_offense() or p.dash_remaining>0: return false
	for other in p.attack_actions:
		if other.is_current() and other.timeline.state() not in [ActionTimeline.State.COMPLETED,ActionTimeline.State.INTERRUPTED]: return false
	var id := action_for(slot,from_hand)
	if id.is_empty(): return false
	var data := Content.weapons()
	if slot == "follow_up" and (last_completed.is_empty() or not id in data.actions[last_completed].follow_ups): return false
	var scope: CombatSystem = p.hit_scope.get_ref() as CombatSystem if p.hit_scope != null else null
	if not is_instance_valid(scope) or not scope._can_act(): return false
	definition = data.actions[id]
	var clock := ActionTimeline.new(definition.startup,definition.commit,definition.phases,definition.recovery)
	clock.hold_before_active = definition.delivery == "projectile"
	current = scope.new_action(p,StringName(id),clock,definition.defense)
	if current == null or not current.is_current(): return false
	hand = "both" if slot == "combined" else from_hand
	heading = p.aim.normalized()
	_previous_time = 0
	_release_requested = false
	_released = false
	_reported.clear()
	last_completed = ""
	p.track_action(current)
	action_started.emit(current)
	return true

func request_release() -> bool:
	if not busy() or definition.delivery != "projectile" or _released: return false
	_release_requested = true
	return true

func movement(input: Vector2) -> Vector2:
	if not busy(): return input
	var state := current.timeline.state()
	var scale: float = definition.movement.recovery if state == ActionTimeline.State.RECOVERY else definition.movement.active if state == ActionTimeline.State.ACTIVE else definition.movement.startup
	return input*scale + (heading*float(definition.movement.forward_speed) if state == ActionTimeline.State.ACTIVE else Vector2.ZERO)

func update(delta: float) -> void:
	# The actor has already ticked the AttackInstance exactly once.
	_settle()
	if not busy(): return
	var p := actor()
	if not is_instance_valid(p): return
	if not current.timeline.committed() or current.timeline.hold_before_active:
		heading = p.aim.normalized()
	else:
		heading = Vector2.from_angle(rotate_toward(heading.angle(),p.aim.angle(),float(definition.movement.turn_rate)*delta))
	if _release_requested and current.timeline.awaiting_release(): current.timeline.release_hold()
	if current.timeline.state() == ActionTimeline.State.ACTIVE:
		if definition.delivery == "projectile":
			if not _released: _release_projectile()
		else:
			# Only the current actor container, not a global search/registry.
			for target in p.get_parent().get_children():
				if target is WildEnemy and target.combat_alive(): contact(target)
	_previous_time = current.timeline.elapsed

func context(target: Node2D) -> ContactContext:
	if current == null: return null
	var p := actor()
	var query := ContactContext.new(current,target,p.global_position,definition.geometry.reach,heading).follow(p)
	query.shaped(definition.geometry,current,_previous_time)
	query.visibility = current.scope()._clear_line
	return query

func profile() -> AttackProfile:
	var phase := current.timeline.phase_index()
	var used_hand: String = definition.phases[phase].hand if phase >= 0 else hand
	if used_hand == "action": used_hand = hand
	var metadata := {"weapon_main":main_id,"weapon_off":off_id,"hand":used_hand,"delivery":definition.delivery}
	return AttackProfile.new(definition.hit.damage,definition.hit.damage_type,definition.hit.impact,metadata)

func contact(target: Node2D) -> CombatContact:
	if current == null or not current.is_current():
		var stale := CombatContact.new()
		stale.reason = &"stale_action"
		return stale
	if definition.delivery != "contact":
		var wrong_delivery := CombatContact.new()
		wrong_delivery.reason = &"projectile_delivery_required"
		return wrong_delivery
	var query := context(target)
	var result := CombatContact.resolve(current,query,profile())
	_report(current,query,result)
	return result

func _report(action: AttackInstance, query: ContactContext, result: CombatContact) -> void:
	# Bounded by current region candidates. Repeated overlap never floods UI.
	var target := query.target()
	var key := "%s/%s/%s/%s" % [target.get_instance_id() if is_instance_valid(target) else 0,query.phase,result.outcome,result.reason]
	if _reported.has(key): return
	_reported[key] = true
	contact_resolved.emit(action,query,result)

func _release_projectile() -> void:
	var scope := current.scope() as CombatSystem
	var p := actor()
	if not is_instance_valid(scope) or not current.is_current(): return
	_released = true
	var arrow := WeaponArrow.new()
	arrow.position = p.global_position
	arrow.direction = heading
	arrow.speed = definition.projectile_speed
	arrow.remaining = definition.geometry.reach
	# Snapshot numeric + semantic data at release; later loadouts cannot change it.
	var hit := profile()
	var payload := scope.released_action(arrow,current,current.action_id,ActionProfiles.clock(0,arrow.remaining/arrow.speed,0),"projectile",current.source_id,definition.defense)
	arrow.attack_action = payload
	arrow.struck.connect(scope.resolve_projectile_profile.bind(payload,hit))
	scope.add_child(arrow)
	arrow.hit_instance = payload.hit_for_phase(0)
	current.timeline.finish_active()
