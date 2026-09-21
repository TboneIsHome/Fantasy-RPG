class_name InteractionResult
extends RefCounted
## A confirmed outcome is not necessarily a changed world (e.g. a sealed door).
## Consequences describe already applied domain changes, never commands to replay.
var resolved: bool = false
var code: StringName
var consequences: Dictionary = {}

static func rejected(reason: StringName) -> InteractionResult:
	var result := InteractionResult.new()
	result.code = reason
	return result

static func confirmed(outcome: StringName, changes: Dictionary = {}) -> InteractionResult:
	var result := InteractionResult.new()
	result.resolved = true
	result.code = outcome
	result.consequences = changes.duplicate(true)
	result.consequences.make_read_only()
	return result
