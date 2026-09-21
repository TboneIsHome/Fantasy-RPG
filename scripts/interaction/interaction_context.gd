class_name InteractionContext
extends RefCounted
## Fresh, synchronous execution context. Never keep this across an await.
## The core treats world_state as opaque; consumers read their actual state owner.
var actor: Node2D
var target: Node2D
var intent: StringName
var world_state: RefCounted
var generation: int

func distance() -> float:
	return actor.global_position.distance_to(target.global_position)
