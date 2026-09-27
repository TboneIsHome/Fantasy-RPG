class_name AttackInstance
extends RefCounted
## One locally owned action; an explicitly released payload can outlive its caster.
var timeline: ActionTimeline
var action_id: StringName
var source_id: String
var generation: int
var blockable: bool
var parryable: bool
var parent_action: AttackInstance
var _scope: WeakRef
var _actor: WeakRef
var _carrier: WeakRef
var _hit: HitInstance
var _hit_phase: int = -1

func _init(owner: Node, actor: Node2D, id: StringName, source: String, clock: ActionTimeline, rules: Dictionary) -> void:
	_scope = weakref(owner) if is_instance_valid(owner) else null
	_actor = weakref(actor) if is_instance_valid(actor) else null
	timeline = clock
	action_id = id
	source_id = source
	generation = int(owner.get_parent().generation) if is_instance_valid(owner) and owner.get_parent() != null else -1
	blockable = bool(rules.get("blockable", false))
	parryable = bool(rules.get("parryable", false))

func scope() -> Node:
	return _scope.get_ref() as Node if _scope != null else null

func actor() -> Node2D:
	return _actor.get_ref() as Node2D if _actor != null else null

func carrier() -> Node2D:
	return _carrier.get_ref() as Node2D if _carrier != null else null

func release_to(payload: Node2D) -> void:
	if is_instance_valid(payload): _carrier = weakref(payload)

func is_current() -> bool:
	var owner := scope()
	if not is_instance_valid(owner) or not owner._can_act() or owner.get_parent().generation != generation: return false
	var anchor: Node = _carrier.get_ref() if _carrier != null else actor()
	if not is_instance_valid(anchor) or anchor.is_queued_for_deletion() or not anchor.is_inside_tree() or not owner.get_parent().is_ancestor_of(anchor): return false
	return _carrier != null or (anchor.has_method("combat_alive") and anchor.combat_alive())

func tick(delta: float) -> void:
	if not is_current(): timeline.interrupt()
	else: timeline.tick(delta)

func hit_for_phase(expected_phase: int) -> HitInstance:
	if not is_current() or timeline.state() != ActionTimeline.State.ACTIVE or timeline.phase_index() != expected_phase: return null
	if _hit_phase != expected_phase:
		_hit = scope().new_hit(action_id, source_id)
		_hit_phase = expected_phase
	return _hit
