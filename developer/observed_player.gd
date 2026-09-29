extends MagePlayer
var telemetry: RefCounted

func combat_defense(incoming: Vector2, rules: Dictionary) -> DefenseOutcome:
	var result := super.combat_defense(incoming,rules)
	if telemetry != null: telemetry.defense(self,result,incoming)
	return result

func receive_hit(instance: HitInstance, attack: AttackProfile, direction: Vector2 = Vector2.ZERO, defense: DefenseOutcome = null) -> HitResolution:
	var result := super.receive_hit(instance,attack,direction,defense)
	if telemetry != null: telemetry.resolution(self,instance,result)
	return result
