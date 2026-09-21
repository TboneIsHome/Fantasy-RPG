class_name InteractionRequest
extends RefCounted
## Captures origin at selection time, not when a delayed action is delivered.
var intent: StringName:
	get: return _intent
var generation: int:
	get: return _generation
var lifecycle_id: int:
	get: return _lifecycle_id
var _actor: WeakRef
var _target: WeakRef
var _intent: StringName
var _generation: int
var _lifecycle_id: int

func _init(actor: Node2D, target: InteractionTarget, action: StringName, origin: int, owner_id: int) -> void:
	if is_instance_valid(actor): _actor = weakref(actor)
	if is_instance_valid(target): _target = weakref(target)
	_intent = action
	_generation = origin
	_lifecycle_id = owner_id

func actor() -> Node2D:
	return _actor.get_ref() as Node2D if _actor != null else null

func target() -> InteractionTarget:
	return _target.get_ref() as InteractionTarget if _target != null else null
