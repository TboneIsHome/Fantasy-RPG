class_name SourceStory
extends Node
## Coordinates this quest without coupling persistent state to the live scene.
const SITE_CELL := Vector2i(78,43)
const GUARDIAN_CELL := Vector2i(78,51)
const REACH := 42.0
var game: Node2D
var guardian: SourceGuardian
var site: SourceSite
var grove: SourceGrove
var room_bounds: Rect2
var region_generation: int = -1

func clear_region() -> void:
	region_generation=-1
	if is_instance_valid(guardian):
		for event in [guardian.defeated, guardian.disengaged]:
			for connection in event.get_connections():
				if connection.callable.get_object()==self:
					event.disconnect(connection.callable)
	guardian=null
	site=null
	grove=null
	room_bounds=Rect2()
	game.ui.hud.guardian=null

func build_region() -> void:
	clear_region()
	region_generation=game.regions.generation
	if game.run.region!="vault": return
	for room in game.terrain.data.rooms:
		if room.id=="sanctum": room_bounds=Rect2(Vector2(room.rect.position)*16,Vector2(room.rect.size)*16)
	site=SourceSite.new()
	site.configure({"id":"source_binding","tile":SITE_CELL},false)
	game.terrain.actors.add_child(site)
	grove=SourceGrove.new()
	grove.bounds=room_bounds
	game.terrain.add_child(grove)
	if game.run.source.resolution.is_empty():
		guardian=SourceGuardian.new()
		guardian.configure({"id":SourceQuest.GUARDIAN_ID,"kind":"guardian","position":WorldGenerator.center(GUARDIAN_CELL)},game.player,Vector2(-1000,-1000))
		guardian.arena=room_bounds
		game.terrain.actors.add_child(guardian)
		game.combat.connect_enemy(guardian)
		guardian.defeated.connect(_guardian_fallen.bind(game.run,region_generation))
		guardian.disengaged.connect(_withdrawn.bind(region_generation))
		game.ui.hud.guardian=guardian
	apply_outcome()

func apply_outcome() -> void:
	if not game.regions.is_current(region_generation) or not is_instance_valid(site): return
	var resolution: String=game.run.source.resolution
	site.set_outcome(resolution,game.run.source.ore_taken)
	grove.set_outcome(resolution)
	game.terrain.source_resolution=resolution
	if not resolution.is_empty():
		if is_instance_valid(guardian):
			guardian.remove_from_group("enemies")
			guardian.hide()
			guardian.queue_free()
		guardian=null
		game.ui.hud.guardian=null
		game.combat.clear_guardian_effects()
	if resolution=="restored":
		game.combat.peaceful_area=room_bounds
		for effect in game.combat.get_children():
			if effect is ThornPatch: effect.peaceful_area=room_bounds
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.id in SourceQuest.QUIET_ENEMIES:
				enemy.remove_from_group("enemies")
				enemy.hide()
				enemy.queue_free()
			else:
				enemy.peaceful_area=room_bounds

func can_use() -> bool:
	return game.regions.is_current(region_generation) and is_instance_valid(site) and site.is_inside_tree() and game.run.region=="vault" and game.player.vitals.hp>0 and game.player.global_position.distance_to(site.global_position)<=REACH

func show_choices() -> void:
	get_tree().paused=true
	var ready: bool=game.run.source.has_evidence(game.run.vault)
	var detail := "Karte und beide Erinnerungen erklären die Zeichen." if ready else "Für eine neue Bindung fehlen noch Karte oder Erinnerungen."
	game.ui.dialogue("Die gebrochene Bindung","Eine neue Bindung nährt einen sicheren Garten. Besiegst du den Hüter, zerbricht sie und legt Sternenerz frei. Beide Wege geben das Quellenherz.\n\n"+detail,[["Die Zeichen stimmen" if ready else "Welche Spuren fehlen?","source_tune"],["Den Hüter herausfordern","source_challenge"],["Noch weiter erkunden","resume"]])

func show_tuning() -> void:
	get_tree().paused=true
	var count: int=game.run.source.alignment
	var text: String=["Welches Zeichen beginnt die Bindung?","Das Wasser fließt. Was folgt ihm?","Die Wurzeln trinken. Welches Zeichen schließt den Kreis?"][count]
	game.ui.dialogue("Die Bindung stimmen","%d / %d Zeichen · %s" % [count,SourceQuest.SIGNS.size(),text],[["Den Stern setzen","source_align","star"],["Das Wasser wecken","source_align","water"],["Die Wurzeln führen","source_align","roots"],["Später fortsetzen","resume"]])

func handle_action(action: String, argument: String) -> bool:
	if action not in ["source_tune","source_align","source_challenge","source_back"]: return false
	if not can_use() or not game.run.source.resolution.is_empty() or (is_instance_valid(guardian) and guardian.awake): return true
	if action=="source_back":
		show_choices()
	elif action=="source_challenge":
		if is_instance_valid(guardian) and game.run.prepare_source_challenge():
			var saved: bool=game.save_game()
			game.handle_action("resume")
			guardian.awaken()
			if saved: game.ui.toast("Quellenhüter · Kreis verlassen, zwischen den Geschossen ausweichen.")
	elif action=="source_tune":
		if game.run.source.has_evidence(game.run.vault):
			show_tuning()
		else:
			var missing: Array[String]=[]
			for pair in [["water_memory","Stimme im Wasser · Zisterne"],["root_memory","Brief zwischen Wurzeln · Garten"]]:
				if not pair[0] in game.run.vault.memories: missing.append(pair[1])
			if not "star_chart" in game.run.vault.relics: missing.append("Sternenkarte · schlafende Fassung")
			game.ui.dialogue("Spuren der Bindung","Noch zu finden:\n"+"\n".join(missing),[["Zurück zur Bindung","source_back"],["Erkunden","resume"]])
	elif action=="source_align":
		if not game.run.source.has_evidence(game.run.vault): return true
		var correct: bool=game.run.align_source(argument)
		if correct and game.run.source.resolution=="restored":
			present_completion()
		else:
			var saved: bool=game.save_game()
			show_tuning()
			if not correct and saved: game.ui.toast("Die Zeichen verlöschen. Die Erinnerungen nennen ihre Reihenfolge.")
	return true

func _guardian_fallen(_enemy: WildEnemy, original_run: RunState, origin_generation: int) -> void:
	if not game.regions.is_current(origin_generation): return
	call_deferred("finish_broken",original_run,origin_generation)

func finish_broken(original_run: RunState, origin_generation: int) -> void:
	if not game.regions.is_current(origin_generation) or game.run!=original_run or game.run.region!="vault" or not game.run.source.resolution.is_empty(): return
	if game.run.defeat_source_guardian(): present_completion()

func present_completion() -> void:
	var path: String=game.run.source.resolution
	apply_outcome()
	game.audio.play("light")
	if game.player.vitals.hp<=0: return
	game.save_game()
	get_tree().paused=true
	var title := "Die Quelle atmet" if path=="restored" else "Der Stern im gebrochenen Stein"
	var copy := "Wasser und Wurzeln finden zueinander. Hier kannst du nun kostenlos rasten." if path=="restored" else "Der Hüter sinkt nieder. In der offenen Fassung wartet einmalig bergbares Sternenerz."
	var reward := Content.section("source_quest")
	var relic: Dictionary = Content.section("relics")[reward.reward_item]
	game.ui.dialogue(title,copy+"\n\n%s erhalten und angelegt · +%d Erfahrung. Ein Frostkreis mit Treffer gibt dir nun %s Mana zurück. Erzähle Edda von deiner Entscheidung." % [relic.name, reward.reward_xp, Content.number_text(float(relic.frost_refund))],[["Relikt ansehen","equipment"],["Weitergehen","resume"]])

func _withdrawn(origin_generation: int) -> void:
	if not game.regions.is_current(origin_generation): return
	game.combat.clear_guardian_effects()
	if game.player.vitals.hp>0:
		game.ui.toast("Der Hüter ruht wieder. Du kannst einen neuen Versuch wagen.")

func speak_to_edda() -> void:
	var quest: SourceQuest=game.run.source
	if game.run.report_source(): game.save_game()
	var copy := "Du hast ihm seine Aufgabe zurückgegeben. Vielleicht schützt er dort unten bald Wurzeln, die wir noch gar nicht kennen. Bewahre das Quellenherz; sein Licht gehört nun auch zu deinem Weg." if quest.resolution=="restored" else "Du hast den Hüter bezwungen. Ohne die Bindung werden wir lernen müssen, was unter der Quelle geschlafen hat. Das Quellenherz ist kein Urteil über deinen Weg — es ist eine Erinnerung daran."
	game.ui.dialogue("Edda · Die Quelle erinnert sich",copy+"\n\nDie erste Geschichte des Lichterhains ist abgeschlossen. Seine Wege und Funde bleiben dir offen.",[["Mein Relikt ansehen","equipment"],["Weiter erkunden","resume"]])
