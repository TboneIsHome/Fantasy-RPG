class_name SourceInteraction
extends DungeonInteraction
## The existing source site offers different actions as its persistent state changes.
## Dialogue branches and the guardian still belong to SourceStory.

func discover(context: InteractionContext) -> Dictionary:
	var state := context.world_state as RunState
	if state == null: return {"offers": [], "notice": ""}
	if state.source.resolution == "restored":
		return {"offers": [{"intent": &"rest", "prompt": "E · Im Quellengarten rasten"}], "notice": ""}
	if state.source.resolution == "broken":
		if state.source.ore_taken: return {"offers": [], "notice": "Die Erzader ist abgeerntet."}
		return {"offers": [{"intent": &"gather", "prompt": "E · Sternenerz bergen"}], "notice": ""}
	var guardian: SourceGuardian = game.source_story.guardian
	var prompt := "Die Bindung steht unter Spannung." if is_instance_valid(guardian) and guardian.awake else "E · Die Bindung untersuchen"
	return {"offers": [{"intent": &"inspect", "prompt": prompt}], "notice": ""}

func validate(context: InteractionContext) -> StringName:
	var reason := validate_nearby(context, SourceStory.REACH)
	if not reason.is_empty(): return reason
	if context.target != game.source_story.site: return &"unavailable"
	var guardian: SourceGuardian = game.source_story.guardian
	if is_instance_valid(guardian) and guardian.awake: return &"source_busy"
	return &""

func resolve(context: InteractionContext) -> InteractionResult:
	var state := context.world_state as RunState
	match context.intent:
		&"rest":
			context.actor.vitals.refill()
			return InteractionResult.confirmed(&"source_rested", {"resources_refilled": true})
		&"gather":
			if not state.harvest_source_ore(): return InteractionResult.rejected(&"unavailable")
			return InteractionResult.confirmed(&"ore_taken", {"ore_taken": true, "motes_granted": int(Content.section("source_quest").ore_motes)})
		&"inspect":
			return InteractionResult.confirmed(&"source_inspected", {"inspection_changed": state.inspect_source()})
	return InteractionResult.rejected(&"not_offered")

func present(result: InteractionResult) -> void:
	if not result.resolved:
		if result.code == &"source_busy":
			game.ui.toast("Weiche aus oder verlasse den Raum, um dich zurückzuziehen.")
		else:
			super.present(result)
		return
	match result.code:
		&"source_rested":
			game.combat.effects.ring(node().position,35,Color("c4e8ad"))
			if game.save_game(): game.ui.toast("Der Quellengarten schenkt dir Ruhe und neue Kraft.")
		&"ore_taken":
			game.source_story.apply_outcome()
			if game.save_game(): game.ui.toast("Sternenerz geborgen · +%d Lichtstaub" % result.consequences.motes_granted)
		&"source_inspected":
			if result.consequences.inspection_changed: game.save_game()
			game.source_story.show_choices()
