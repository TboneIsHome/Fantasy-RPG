class_name HitInstance
extends RefCounted
## Transient identity/receipt set owned by one existing attack or explicit pulse.
## The region's CombatSystem supplies accepts_hit(); no global hit registry.
var action_id: StringName
var source_id: String
var generation: int
var _scope: WeakRef
var _targets: Dictionary = {}

func _init(scope: Node, action: StringName, source: String, origin: int) -> void:
	if is_instance_valid(scope): _scope = weakref(scope)
	action_id = action
	source_id = source
	generation = origin

func scope() -> Node:
	return _scope.get_ref() as Node if _scope != null else null

func resolve(target: Node, attack: AttackProfile, stats: CombatStats, defense: DefenseOutcome) -> HitResolution:
	var owner := scope()
	if not is_instance_valid(owner) or not owner.accepts_hit(self, target):
		return HitResolution.rejected(&"stale_contact")
	var target_key := target.get_instance_id()
	if _targets.has(target_key): return HitResolution.rejected(&"duplicate_hit")
	var result := HitResolver.resolve(attack, stats, defense)
	result.hit_id = get_instance_id()
	result.action_id = action_id
	result.source_id = source_id
	result.target_id = target_key
	result.generation = generation
	# Claim before an actor changes health or emits any signals. Negated contacts
	# (including parry/immunity) cannot be replayed after defenses change either.
	if result.resolved and result.contact: _targets[target_key] = true
	return result
