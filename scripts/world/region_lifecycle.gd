class_name RegionLifecycle
extends Node
## Session-owned, synchronous lifecycle for exactly one active 2D region.
## The generation is transient and never serialized or reset on load/new run.
signal deactivating(region: RegionInstance)
signal activated(region: RegionInstance)

var current: RegionInstance:
	get: return _current
var generation: int:
	get: return _generation
var current_id: String:
	get: return _current.region_id if is_instance_valid(_current) else ""
var _current: RegionInstance
var _generation: int = 0
var _active: bool = false
var _transitioning: bool = false

func is_transitioning() -> bool:
	return _transitioning

func is_current(origin_generation: int) -> bool:
	return _active and origin_generation == _generation and is_instance_valid(_current) and _current.is_inside_tree() and not _current.is_queued_for_deletion()

func owns(node: Node) -> bool:
	return is_current(_generation) and is_instance_valid(node) and not node.is_queued_for_deletion() and _current.is_ancestor_of(node)

func build(run: RunState, settings: Dictionary, saved_player: Dictionary = {}, returning_to_forest: bool = false) -> bool:
	if _transitioning or run.region not in ["forest", "vault"]: return false
	_transitioning = true
	_unload()
	_generation += 1
	_current = RegionInstance.new()
	_current.name = "ActiveRegion"
	_current.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_current)
	_current.build(run, _generation, settings, saved_player, returning_to_forest)
	_activate()
	_transitioning = false
	return true

func _activate() -> void:
	_active = true
	_current.activate()
	activated.emit(_current)

func _deactivate() -> void:
	if not _active: return
	_active = false # Reject old callbacks before any observer clears its references.
	_current.deactivate()
	deactivating.emit(_current)

func unload() -> void:
	if _transitioning: return
	_transitioning = true
	_unload()
	_transitioning = false

func _unload() -> void:
	_deactivate()
	if not is_instance_valid(_current): return
	var previous := _current
	_current = null
	remove_child(previous) # Removes actors/groups/physics before another region enters.
	previous.queue_free()

func travel(region_id: String, settings: Dictionary) -> bool:
	if _transitioning or not is_current(_generation) or region_id not in ["forest", "vault"] or region_id == current_id:
		return false
	if _current.player.vitals.hp <= 0: return false
	var run := _current.run
	if region_id == "vault" and not run.quest_complete: return false
	var vitals := _current.player.vitals
	var stats := {"hp": vitals.hp, "mana": vitals.mana, "stamina": vitals.stamina}
	run.region = region_id
	build(run, settings, stats, region_id == "forest")
	_current.player.vitals.invulnerable = 0.8
	return true

func return_to_camp(settings: Dictionary) -> void:
	if _transitioning or not is_current(_generation) or current_id != "vault": return
	var run := _current.run
	run.region = "forest"
	build(run, settings)

func _exit_tree() -> void:
	_active = false
