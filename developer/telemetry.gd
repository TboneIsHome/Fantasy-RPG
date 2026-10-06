extends RefCounted
const LIMIT := 96
var events: Array[Dictionary] = []
var generation: int
var scenario := "manual"
var player_preset := "mage"
var elapsed := 0.0

func record(event: String, details: Dictionary = {}) -> void:
	var item := details.duplicate(true)
	item.merge({"event":event,"scenario":scenario,"player_preset":player_preset,"generation":generation,"time":snappedf(elapsed,0.001)},true)
	events.append(item)
	if events.size() > LIMIT: events.pop_front()

func defense(actor: Node2D, result: DefenseOutcome, incoming: Vector2) -> void:
	record("live_defense", {"target":actor.get_instance_id(),"preset":actor.get_meta("sandbox_preset",""),"outcome":str(result.kind),"incoming":str(incoming),"position":str(actor.global_position)})

func resolution(actor: Node2D, instance: HitInstance, result: HitResolution) -> void:
	record("live_resolution", {"target":actor.get_instance_id(),"position":str(actor.global_position),"hit_id":result.hit_id,"action":str(instance.action_id) if instance != null else "","confirmed":result.resolved and result.contact,"reason":str(result.reason),"outcome":str(result.outcome),"damage":result.damage,"impact":result.impact,"reaction":CombatReaction.Kind.keys()[actor.reaction.kind]})

func contact(action: AttackInstance, query: ContactContext, result: CombatContact) -> void:
	var target := query.target()
	var detail := {"attack_instance":action.get_instance_id(),"action":str(action.action_id),"action_generation":action.generation,"phase":ActionTimeline.State.keys()[action.timeline.state()],"target":target.get_instance_id() if is_instance_valid(target) else 0,"origin":str(query.origin()),"target_position":str(target.global_position) if is_instance_valid(target) else "freed","range":query.reach,"direction":str(query.direction),"confirmed":result.confirmed(),"outcome":str(result.outcome),"reason":str(result.reason)}
	if result.resolution != null: detail.merge({"damage":result.resolution.damage,"impact":result.resolution.impact,"hit_id":result.resolution.hit_id,"secondary":result.resolution.secondary})
	record("contact_probe",detail)
