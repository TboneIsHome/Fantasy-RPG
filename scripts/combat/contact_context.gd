class_name ContactContext
extends RefCounted
## Small spatial adapter: current actor origin OR a fixed impact/area point.
## Consumers supply their range, facing and fresh visibility predicate.
var phase: int
var reach: float
var direction: Vector2
var minimum_dot: float
var point: Vector2
var visibility: Callable
var _origin: WeakRef
var _target: WeakRef

func _init(action: AttackInstance, target_node: Node2D, center: Vector2, radius: float, heading: Vector2 = Vector2.ZERO, facing_dot: float = -1) -> void:
	phase = action.timeline.phase_index()
	_target = weakref(target_node) if is_instance_valid(target_node) else null
	point = center
	reach = radius
	direction = heading
	minimum_dot = facing_dot

func follow(node: Node2D) -> ContactContext:
	_origin = weakref(node) if is_instance_valid(node) else null
	return self

func target() -> Node2D:
	return _target.get_ref() as Node2D if _target != null else null

func origin() -> Vector2:
	var node: Node2D = _origin.get_ref() as Node2D if _origin != null else null
	return node.global_position if is_instance_valid(node) else point

func incoming_from() -> Vector2:
	var offset := origin() - target().global_position
	return offset if offset.length_squared() > 0.000001 else -direction

func spatial_error() -> StringName:
	if not is_instance_valid(target()): return &"invalid_target"
	if _origin != null:
		var node: Node = _origin.get_ref()
		if not is_instance_valid(node) or not node.is_inside_tree() or node.is_queued_for_deletion(): return &"invalid_origin"
	var center := origin()
	if not center.is_finite() or not target().global_position.is_finite() or not direction.is_finite() or not is_finite(reach) or reach < 0 or not is_finite(minimum_dot) or minimum_dot < -1 or minimum_dot > 1: return &"invalid_geometry"
	var offset := target().global_position - center
	if offset.length() > reach and not is_equal_approx(offset.length(),reach): return &"out_of_range"
	if minimum_dot > -1 and offset.length_squared() > 0.000001:
		if direction.length_squared() < 0.000001 or direction.normalized().dot(offset.normalized()) < minimum_dot: return &"wrong_direction"
	if not visibility.is_null():
		if not visibility.is_valid() or not visibility.call(center, target().global_position): return &"obstructed"
	return &""
