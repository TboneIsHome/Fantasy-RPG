class_name CombatContact
extends RefCounted
## M07 result + synchronous handoff. Miss/Evade never call the M06 resolver.
var outcome: StringName = &"miss"
var reason: StringName
var resolution: HitResolution

func confirmed() -> bool:
	return resolution != null and resolution.resolved and resolution.contact

static func resolve(action: AttackInstance, context: ContactContext, profile: AttackProfile) -> CombatContact:
	var result := CombatContact.new()
	if action == null or context == null or not action.is_current():
		result.reason = &"stale_action"
		return result
	var target := context.target()
	if not is_instance_valid(target) or target.is_queued_for_deletion() or not target.is_inside_tree() or not action.scope().get_parent().is_ancestor_of(target) or not target.has_method("combat_alive") or not target.combat_alive():
		result.reason = &"invalid_target"
		return result
	if not target.has_method("combat_defense") or not target.has_method("receive_hit"):
		result.reason = &"invalid_target_contract"
		return result
	if action.timeline.state() != ActionTimeline.State.ACTIVE or action.timeline.phase_index() != context.phase:
		result.reason = &"inactive_phase"
		return result
	result.reason = context.spatial_error()
	if not result.reason.is_empty(): return result
	var instance := action.hit_for_phase(context.phase)
	if instance == null or not is_instance_valid(target) or not target.combat_alive():
		result.reason = &"stale_action"
		return result
	var defense: DefenseOutcome = target.combat_defense(context.incoming_from(), {"blockable":action.blockable,"parryable":action.parryable})
	result.outcome = defense.kind
	if defense.kind in [&"miss", &"evade"]: return result
	result.resolution = target.receive_hit(instance, profile, context.direction, defense)
	if not result.confirmed():
		result.reason = result.resolution.reason
		return result
	if not action.is_current(): return result
	if defense.kind == &"parry":
		target.confirm_parry()
		var origin := action.parent_action if action.parent_action != null else action
		var attacker := origin.actor()
		if origin.is_current() and is_instance_valid(attacker) and attacker.has_method("parried_action"):
			attacker.parried_action(origin)
		action.timeline.interrupt()
	elif defense.kind == &"block": target.defense_feedback(&"block")
	return result
