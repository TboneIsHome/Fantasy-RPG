class_name DungeonInteraction
extends InteractionTarget
## Existing dungeon rules and presentation; the interaction core has none of them.
const REACH := 36.0 # Existing nearby selection radius; rechecked on execution.
var game: Node2D

func _init(object: DungeonObject, session: Node2D) -> void:
	super(object)
	game = session

func discover(context: InteractionContext) -> Dictionary:
	var object := context.target as DungeonObject
	var state := context.world_state as RunState
	if object == null or state == null: return {"offers": [], "notice": ""}
	if object.kind == "font":
		return {"offers": [{"intent": &"rest", "prompt": "E · Rasten für %d Lichtstaub" % DungeonGenerator.content().fountain_cost}], "notice": ""}
	if object.kind == "secret_gate":
		if state.vault.secret_open: return {"offers": [], "notice": "Der Stein hat den Weg freigegeben."}
		return {"offers": [{"intent": &"inspect", "prompt": "E · Wasserspuren untersuchen"}], "notice": ""}
	if object.kind != "chest": return {"offers": [], "notice": ""}
	if object.id in state.vault.relics:
		return {"offers": [], "notice": "Der Fund liegt in deinem Journal."}
	return {"offers": [{"intent": &"open", "prompt": "E · Behältnis öffnen"}], "notice": ""}

func validate(context: InteractionContext) -> StringName:
	var reason := validate_nearby(context, REACH)
	if not reason.is_empty(): return reason
	var object := context.target as DungeonObject
	var state := context.world_state as RunState
	if object.kind == "font":
		if state.motes < int(DungeonGenerator.content().fountain_cost): return &"insufficient_motes"
		if context.actor.vitals.is_full(): return &"already_full"
	return &""

static func validate_nearby(context: InteractionContext, reach: float) -> StringName:
	var actor := context.actor as MagePlayer
	if actor == null or context.world_state != actor.run or actor.vitals.hp <= 0: return &"actor_unavailable"
	if context.distance() > reach: return &"out_of_reach"
	var query := PhysicsRayQueryParameters2D.create(actor.global_position, context.target.global_position, 1)
	var hit := actor.get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider.get_parent() != context.target: return &"obstructed"
	return &""

func resolve(context: InteractionContext) -> InteractionResult:
	var object := context.target as DungeonObject
	var state := context.world_state as RunState
	if object.kind == "font":
		var cost: int = int(DungeonGenerator.content().fountain_cost)
		if not state.spend_motes(cost): return InteractionResult.rejected(&"insufficient_motes")
		context.actor.vitals.refill()
		return InteractionResult.confirmed(&"rested", {"motes_spent": cost, "resources_refilled": true})
	if object.kind == "secret_gate":
		if state.open_vault_secret(): return InteractionResult.confirmed(&"opened", {"gate": object.id})
		# A permitted investigation can have an unhelpful outcome. This is not a
		# generic missing-key condition and does not pre-explain the puzzle in UI.
		return InteractionResult.confirmed(&"unreadable")
	if not state.collect_vault_relic(object.id): return InteractionResult.rejected(&"unavailable")
	var data := DungeonGenerator.content()
	return InteractionResult.confirmed(&"collected", {"relic": object.id, "xp": int(data.chart_xp if object.id == "star_chart" else data.seed_xp)})

func present(result: InteractionResult) -> void:
	if not result.resolved:
		match result.code:
			&"insufficient_motes": game.ui.toast("Die Sickerquelle benötigt %d Lichtstaub." % DungeonGenerator.content().fountain_cost)
			&"already_full": game.ui.toast("Du bist bereits vollständig erholt.")
			&"out_of_reach": game.ui.toast("Das ist jetzt zu weit entfernt.")
			&"obstructed": game.ui.toast("Von hier aus ist das nicht erreichbar.")
		return
	if result.code == &"rested":
		game.combat.effects.ring(game.player.position,28,Color("b7e5d3"))
		game.save_game()
		return
	if result.code == &"opened":
		game.open_dungeon_gates()
		if game.save_game(): game.ui.toast("Der Stern im Stein antwortet. Ein verborgener Weg öffnet sich.")
		return
	if result.code == &"unreadable":
		game.ui.toast("Ein kaum erkennbares Zeichen. Vielleicht kennt das Wasser seine Bedeutung.")
		return
	var object := node() as DungeonObject
	object.activate()
	game.audio.play("light")
	game.save_game()
	game.show_discovery(object.id)
