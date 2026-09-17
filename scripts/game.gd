extends Node2D

var run: RunState
var regions: RegionLifecycle
# Compatibility views, never separate mutable owners of regional references.
var world: RegionInstance:
	get: return regions.current if is_instance_valid(regions) else null
var terrain: WorldView:
	get: return world.terrain if is_instance_valid(world) else null
var player: MagePlayer:
	get: return world.player if is_instance_valid(world) else null
var combat: CombatSystem:
	get: return world.combat if is_instance_valid(world) else null
var ui: GameUI
var audio: AudioController
var source_story: SourceStory
var nearest: Landmark
var scan_time: float = 0
var last_level: int = 1
var save_path: String = SaveSystem.DEFAULT_PATH
var settings: Dictionary = {"volume":0.4,"shake":true}

func _ready() -> void:
	InputSetup.install()
	get_tree().auto_accept_quit=false
	get_window().min_size=Vector2i(640,360)
	audio=AudioController.new()
	add_child(audio)
	ui=GameUI.new()
	add_child(ui)
	ui.requested.connect(handle_action)
	ui.volume_changed.connect(func(value): settings.volume=value; audio.volume=value)
	ui.shake_changed.connect(func(value): settings.shake=value; player.shake_enabled=value)
	source_story=SourceStory.new()
	source_story.game=self
	add_child(source_story)
	regions=RegionLifecycle.new()
	add_child(regions)
	regions.deactivating.connect(_region_deactivating)
	regions.activated.connect(_region_activated)
	build_run("LICHTERHAIN")
	show_title()

func build_run(seed_text: String, saved: Dictionary = {}) -> bool:
	if regions.is_transitioning(): return false
	regions.unload()
	if run and run.changed.is_connected(_progress_changed):
		run.changed.disconnect(_progress_changed)
	run=RunState.new() if saved.is_empty() else RunState.restore(saved.run)
	run.world_seed=seed_text.strip_edges().substr(0,64)
	if run.world_seed.is_empty():
		run.world_seed="LICHTERHAIN"
	if not saved.is_empty():
		settings=saved.settings.duplicate()
	last_level=run.level
	run.changed.connect(_progress_changed)
	return regions.build(run, settings, saved.get("player",{}))

func _region_deactivating(region: RegionInstance) -> void:
	var origin := region.generation
	region.combat.sound_requested.disconnect(_region_sound.bind(origin))
	region.player.dash_performed.disconnect(_region_sound.bind("dash",origin))
	region.player.was_hit.disconnect(_region_sound.bind("hurt",origin))
	region.player.died.disconnect(_region_player_died.bind(origin))
	nearest=null
	scan_time=0
	source_story.clear_region()
	ui.clear()
	ui.hud.player=null
	ui.hud.run=null
	ui.hud.map_data={}
	ui.hud.prompt=""
	ui.hud.game_visible=false

func _region_activated(region: RegionInstance) -> void:
	get_tree().paused=false
	var origin := region.generation
	combat.sound_requested.connect(_region_sound.bind(origin))
	player.dash_performed.connect(_region_sound.bind("dash",origin))
	player.was_hit.connect(_region_sound.bind("hurt",origin))
	player.died.connect(_region_player_died.bind(origin))
	source_story.build_region()
	audio.volume=settings.volume
	ui.settings=settings.duplicate()
	ui.hud.player=player
	ui.hud.run=run
	ui.hud.map_data=terrain.data
	ui.hud.location_name="Quellengruft" if region.region_id=="vault" else "Laternenrast"
	ui.hud.prompt=""
	ui.hud.game_visible=true
	ui.clear()
	scan_time=0
	if region.region_id=="forest": run.discover("camp")

func _region_sound(id: String, origin_generation: int) -> void:
	if regions.is_current(origin_generation): audio.play(id)

func _region_player_died(origin_generation: int) -> void:
	if not regions.is_current(origin_generation): return
	get_tree().paused=true
	ui.death_menu()

func dungeon_object_active(id: String) -> bool:
	return world.dungeon_object_active(id) if is_instance_valid(world) else false

func travel_to(region: String) -> void:
	if not regions.travel(region, settings): return
	if save_game():
		ui.toast("Die Quellengruft · M zeichnet entdeckte Räume auf." if region=="vault" else "Zurück im Sternengarten.")

func show_title() -> void:
	player.input_enabled=false
	player.camera.position=WorldGenerator.center(terrain.data.points[3].tile)-player.position+Vector2(-100,35)
	player.camera.reset_smoothing()
	get_tree().paused=true
	ui.title_menu(FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path+".bak"))

func handle_action(action: String, argument: String = "") -> void:
	if is_instance_valid(source_story) and source_story.handle_action(action,argument): return
	match action:
		"new":
			if build_run(argument):
				ui.toast("Willkommen. Sprich mit Edda nördlich des Lagerfeuers.")
		"resume":
			ui.clear()
			get_tree().paused=false
			player.input_enabled=true
			player.cast_armed=false
		"pause":
			get_tree().paused=true
			ui.pause_menu()
		"map":
			get_tree().paused=true
			ui.map_menu()
		"discoveries":
			get_tree().paused=true
			ui.journal(run,true)
		"journal":
			get_tree().paused=true
			ui.journal(run)
		"equipment":
			get_tree().paused=true
			ui.journal(run,false,true)
		"equip_relic":
			if run.equip_relic(argument): save_game()
			ui.journal(run,false,true)
		"learn":
			if run.learn(argument):
				audio.play("light")
				ui.journal(run)
		"save":
			save_game()
		"load":
			load_game()
		"title":
			if save_game():
				show_title()
		"respawn":
			regions.return_to_camp(settings)
			player.position=terrain.data.spawn
			player.vitals.refill()
			player.reset_transient()
			for child in combat.get_children():
				if child is MagicProjectile:
					child.queue_free()
			handle_action("resume")
			ui.toast("Edda hat dich zurückgebracht. Deine Funde bleiben bei dir.")
		"accept":
			run.accept_quest()
			handle_action("resume")
			ui.toast("Folge den hellen Pfaden. M öffnet Eddas Karte.")
		"reward":
			if run.complete_quest():
				player.vitals.refill()
				audio.play("light")
				save_game()
				ui.dialogue("Die Quelle singt wieder","Du erhältst den Quellenfokus. Aktive Waldlichter sind jetzt Rastpunkte.\n\nDein Fokus öffnet nun die Quellengruft südöstlich des Waldlichts im alten Sternengarten.",[["Weiter erkunden","resume"],["Talente und Beutel ansehen","journal"]])

func _process(delta: float) -> void:
	if not is_instance_valid(player) or not ui.page.is_empty():
		return
	run.advance_time(delta)
	scan_time-=delta
	if scan_time<=0:
		scan_time=0.12
		_scan_landmarks()
		terrain.update_canopies(player.global_position)
	if Input.is_action_just_pressed("interact") and is_instance_valid(nearest):
		interact(nearest)

func _scan_landmarks() -> void:
	nearest=null
	var closest_distance: float=36
	var region := "Die Quellengruft" if run.region=="vault" else "Die Lichterhaine"
	if run.region=="vault":
		for room in terrain.data.rooms:
			if room.rect.has_point(Vector2i(player.position/16)):
				region=room.name
				if room.id=="sanctum" and not run.source.resolution.is_empty():
					region="Quellengarten" if run.source.resolution=="restored" else "Die offene Erzader"
				if run.visit_room(room.id):
					ui.toast("Entdeckt: "+room.name)
	for landmark in get_tree().get_nodes_in_group("landmarks"):
		var distance := player.global_position.distance_to(landmark.global_position)
		if distance<closest_distance:
			var hit := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(player.position,landmark.position,1))
			if hit.is_empty() or hit.collider.get_parent()==landmark:
				closest_distance=distance
				nearest=landmark
		if run.region=="forest" and landmark.kind in ["camp","shrine","entrance"] and distance<98:
			region=landmark.title
			if run.discover(landmark.id) and landmark.kind in ["shrine","entrance"]:
				ui.toast("Entdeckt: "+landmark.title)
	ui.hud.location_name=region
	ui.hud.prompt=""
	if is_instance_valid(source_story.guardian) and source_story.guardian.awake: return
	if nearest:
		if nearest is DungeonObject:
			ui.hud.prompt=dungeon_prompt(nearest)
		elif nearest.kind=="npc":
			ui.hud.prompt="E · Mit Edda sprechen"
		elif nearest.kind=="camp":
			ui.hud.prompt="E · Rasten und speichern"
		elif not nearest.active:
			ui.hud.prompt="E · Waldlicht entzünden"
		else:
			ui.hud.prompt="E · Am Waldlicht rasten" if run.quest_complete else "Dieses Waldlicht leuchtet wieder."

func dungeon_prompt(object: DungeonObject) -> String:
	if object is SourceSite: return source_story.prompt()
	match object.kind:
		"entrance": return "E · Quellengruft betreten" if run.quest_complete else "E · Die versiegelte Treppe untersuchen"
		"exit": return "E · In den Sternengarten zurückkehren"
		"font": return "E · Rasten für %d Lichtstaub" % DungeonGenerator.content().fountain_cost
		"memory": return "E · Erinnerung lesen"
		"chest": return "Der Fund liegt in deinem Journal." if object.active else "E · Behältnis öffnen"
		"lever": return "Die Abkürzung ist geöffnet." if object.active else "E · Wurzelwinde drehen"
		"gate": return "Das Gitter steht offen." if object.active else "E · Das Gitter untersuchen"
		"secret_gate": return "Der Stein hat den Weg freigegeben." if object.active else "E · Wasserspuren untersuchen"
	return ""

func interact_dungeon(object: DungeonObject) -> void:
	if not regions.owns(object): return
	match object.kind:
		"entrance":
			if run.quest_complete:
				travel_to("vault")
			else:
				get_tree().paused=true
				ui.dialogue("Die versiegelte Treppe","Drei erloschene Zeichen liegen im Stein. Wecke die drei Waldlichter und kehre zu Edda zurück. Ihr Quellenfokus könnte die Treppe öffnen.",[["Zurück","resume"]])
		"exit": travel_to("forest")
		"font":
			var cost: int=int(DungeonGenerator.content().fountain_cost)
			if run.motes<cost:
				ui.toast("Die Sickerquelle benötigt %d Lichtstaub." % cost)
			elif player.vitals.hp>=100 and player.vitals.mana>=100 and player.vitals.stamina>=100:
				ui.toast("Du bist bereits vollständig erholt.")
			elif run.spend_motes(cost):
				player.vitals.refill()
				combat.effects.ring(player.position,28,Color("b7e5d3"))
				save_game()
		"memory":
			if run.unlock_memory(object.id):
				object.activate()
				save_game()
			if object.id in run.vault.memories: show_discovery(object.id)
		"chest":
			if not run.collect_vault_relic(object.id):
				return
			object.activate()
			audio.play("light")
			save_game()
			show_discovery(object.id)
		"lever":
			if run.open_vault_shortcut():
				open_dungeon_gates()
				if save_game(): ui.toast("Ein Gitter hebt sich. Der kurze Weg zum Eingang ist frei.")
		"gate":
			if not object.active:
				ui.toast("Die Winde liegt auf der anderen Seite, im Garten ohne Sonne.")
		"secret_gate":
			if run.open_vault_secret():
				open_dungeon_gates()
				if save_game(): ui.toast("Der Stern im Stein antwortet. Ein verborgener Weg öffnet sich.")
			elif not run.vault.secret_open:
				ui.toast("Ein kaum erkennbares Zeichen. Vielleicht kennt das Wasser seine Bedeutung.")

func open_dungeon_gates() -> void:
	for object in get_tree().get_nodes_in_group("landmarks"):
		if object is DungeonObject and dungeon_object_active(object.id):
			object.activate()
	if terrain is DungeonView:
		terrain.refresh_gates()

func show_discovery(id: String) -> void:
	var entry: Dictionary=DiscoveryBook.entries()[id]
	get_tree().paused=true
	ui.dialogue(entry.title,entry.text,[["Im Journal nachlesen","discoveries"],["Weitergehen","resume"]])

func interact(landmark: Landmark) -> void:
	if not regions.owns(landmark): return
	if landmark is SourceSite:
		source_story.interact()
		return
	if landmark is DungeonObject:
		interact_dungeon(landmark)
		return
	if landmark.kind=="npc":
		get_tree().paused=true
		if not run.source.resolution.is_empty():
			source_story.speak_to_edda()
		elif "star_chart" in run.vault.relics:
			if run.report_vault_chart(): save_game()
			ui.dialogue("Edda · Eine Karte unter Wurzeln","Diese Linien gehören nicht an den Himmel. Meine Lehrerin suchte ihr Ende im Aschemoor.\n\nDie Karte erklärt auch die gebrochene Fassung in der Gruft. Lies die Erinnerungen im Wasser und zwischen den Wurzeln. Vielleicht musst du ihren Hüter gar nicht bekämpfen.",[["Entdeckungen lesen","discoveries"],["Weiter erkunden","resume"]])
		elif run.quest_complete:
			ui.dialogue("Edda","Hörst du das Wasser? Die Quelle erinnert sich wieder. Dein Quellenfokus lässt dich an jedem geweckten Waldlicht rasten. Im alten Sternengarten öffnet er außerdem die Treppe zur Quellengruft.",[["Talente ansehen","journal"],["Aufbrechen","resume"]])
		elif run.active_lights.size()==3:
			ui.dialogue("Edda","Drei Lichter. Ich hätte nicht gedacht, dass ich sie noch einmal sehen würde. Nimm diesen Fokus; die Quelle wird dich auf deinen Wegen begleiten.",[["Quellenfokus annehmen","reward"],["Noch einen Moment","resume"]])
		elif not run.quest_accepted:
			ui.dialogue("Edda · Hüterin der Quelle","Seit die Waldlichter verstummt sind, werden die Tiere unruhig. Drei alte Orte tragen noch einen Funken.\n\nFolge den Pfaden auf meiner Karte. Wecke die Lichter mit E und kehre zu mir zurück.",[["Ich suche die Waldlichter","accept"],["Ich sehe mich erst um","resume"]])
		else:
			ui.dialogue("Edda","Der Frostkreis hält die Gefahr auf Abstand. Trifft dein Lichtfunke ein verlangsamtes Wesen, zerbricht der Frost.\n\n%d von 3 Lichtern leuchten. M zeigt dir die Wege." % run.active_lights.size(),[["Danke für den Hinweis","resume"]])
	elif landmark.kind=="camp" or (landmark.active and run.quest_complete):
		player.vitals.refill()
		save_game()
		combat.effects.ring(player.position,25,Color("ead6a3"))
		audio.play("light")
	elif not landmark.active and run.activate_light(landmark.id):
		landmark.activate()
		audio.play("light")
		combat.effects.ring(landmark.position,45,Color("b4f0cf"))
		ui.toast("Alle drei Lichter sind erwacht. Kehre zu Edda zurück." if run.active_lights.size()==3 else "Waldlicht erwacht · +20 Erfahrung")

func _progress_changed() -> void:
	if run.level>last_level:
		last_level=run.level
		ui.toast("Stufe %d · Ein neues Talent wartet im Journal (TAB)." % run.level)
		audio.play("light")

func save_game() -> bool:
	var error := SaveSystem.write(SaveSystem.snapshot(run,player,settings),save_path)
	ui.toast("Lichtpfad gespeichert." if error.is_empty() else error)
	return error.is_empty()

func load_game() -> bool:
	var result := SaveSystem.read(save_path)
	if not result.error.is_empty():
		ui.toast(result.error)
		return false
	if not build_run(result.data.run.world_seed,result.data): return false
	ui.toast(result.get("notice","Lichtpfad geladen."))
	return true

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		if is_instance_valid(ui) and ui.page!="title" and player.vitals.hp>0:
			if not save_game():
				return
		get_tree().quit()
