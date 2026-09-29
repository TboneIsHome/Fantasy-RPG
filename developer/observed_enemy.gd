extends WildEnemy
var telemetry: RefCounted
var passive := true
var single_attack := false

func target_is_safe() -> bool:
	return (passive and not single_attack) or super.target_is_safe()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if single_attack and attack_action != null and attack_action.timeline.state() in [ActionTimeline.State.COMPLETED,ActionTimeline.State.INTERRUPTED]:
		single_attack = false
		passive = true

func combat_defense(incoming: Vector2, rules: Dictionary) -> DefenseOutcome:
	var result := super.combat_defense(incoming,rules)
	if telemetry != null: telemetry.defense(self,result,incoming)
	return result

func receive_hit(instance: HitInstance, attack: AttackProfile, direction: Vector2 = Vector2.ZERO, defense: DefenseOutcome = null) -> HitResolution:
	var result := super.receive_hit(instance,attack,direction,defense)
	if telemetry != null: telemetry.resolution(self,instance,result)
	return result
