class_name InteractionTarget
extends RefCounted
## A small adapter owned by a real world object. No registry or process loop.
var _node: WeakRef

func _init(node: Node2D) -> void:
	if is_instance_valid(node): _node = weakref(node)

func node() -> Node2D:
	return _node.get_ref() as Node2D if _node != null else null

func discover(_context: InteractionContext) -> Dictionary:
	# Offers use consumer-local intent IDs and presentation text, not object types.
	return {"offers": [], "notice": ""}

func validate(_context: InteractionContext) -> StringName:
	return &""

func resolve(_context: InteractionContext) -> InteractionResult:
	return InteractionResult.rejected(&"not_implemented")

func present(_result: InteractionResult) -> void:
	pass
