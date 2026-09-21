class_name InteractionCore
extends RefCounted
## Session-local synchronous contract. No gameplay verbs, rewards or broadcasts.
var _regions: RegionLifecycle
var _executing: bool = false

func _init(regions: RegionLifecycle) -> void:
	_regions = regions

func request(actor: Node2D, target: InteractionTarget, intent: StringName) -> InteractionRequest:
	var origin := _regions.generation if is_instance_valid(_regions) else -1
	var owner_id := _regions.get_instance_id() if is_instance_valid(_regions) else 0
	return InteractionRequest.new(actor, target, intent, origin, owner_id)

func discover(actor: Node2D, target: InteractionTarget, state: RefCounted) -> Dictionary:
	var selection := request(actor, target, &"")
	if not is_current(selection) or state == null: return {"offers": [], "notice": ""}
	return target.discover(_context(selection, state))

func is_current(selection: InteractionRequest) -> bool:
	return _invalid_reason(selection).is_empty()

func execute(selection: InteractionRequest, state: RefCounted) -> InteractionResult:
	if _executing: return InteractionResult.rejected(&"busy")
	var reason := _invalid_reason(selection)
	if not reason.is_empty(): return InteractionResult.rejected(reason)
	if state == null: return InteractionResult.rejected(&"invalid_state")
	_executing = true
	var result := _execute_current(selection, state)
	_executing = false
	return result

func _execute_current(selection: InteractionRequest, state: RefCounted) -> InteractionResult:
	var target := selection.target()
	var context := _context(selection, state)
	var offered := false
	for offer in target.discover(context).get("offers", []):
		if not selection.intent.is_empty() and offer.intent == selection.intent:
			offered = true
			break
	if not offered: return InteractionResult.rejected(&"not_offered")
	var reason := target.validate(context)
	if not reason.is_empty(): return InteractionResult.rejected(reason)
	# Consumers must not await or mutate in discovery/validation. Still fail closed
	# if a callback removed an object or replaced the region before resolution.
	reason = _invalid_reason(selection)
	if not reason.is_empty(): return InteractionResult.rejected(reason)
	var result := target.resolve(context)
	return result if result != null else InteractionResult.rejected(&"invalid_result")

func _invalid_reason(selection: InteractionRequest) -> StringName:
	if selection == null: return &"invalid_request"
	if not is_instance_valid(_regions) or selection.lifecycle_id != _regions.get_instance_id() or not _regions.is_current(selection.generation):
		return &"stale_region"
	var actor := selection.actor()
	if not is_instance_valid(actor) or not actor.is_inside_tree() or not _regions.owns(actor): return &"invalid_actor"
	var target := selection.target()
	if target == null: return &"invalid_target"
	var object := target.node()
	if not is_instance_valid(object) or not object.is_inside_tree() or not _regions.owns(object): return &"invalid_target"
	return &""

func _context(selection: InteractionRequest, state: RefCounted) -> InteractionContext:
	var context := InteractionContext.new()
	context.actor = selection.actor()
	context.target = selection.target().node()
	context.intent = selection.intent
	context.world_state = state
	context.generation = selection.generation
	return context
