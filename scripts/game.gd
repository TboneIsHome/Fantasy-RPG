extends Node2D

var run: RunState
var world: Node2D
var terrain: WorldView
var player: MagePlayer
var combat: CombatSystem
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
	build_run("LICHTERHAIN")
	show_title()

func build_run(seed_text: String, saved: Dictionary = {}) -> void:
	run=RunState.new() if saved.is_empty() else RunState.restore(saved.run)
	run.world_seed=seed_text.strip_edges().substr(0,64)
	if run.world_seed.is_empty():
		run.world_seed="LICHTERHAIN"
	if not saved.is_empty():
		settings=saved.settings.duplicate()
	last_level=run.level
	run.changed.connect(_progress_changed)
	_build_region(saved.get("player",{}))

func _build_region(saved_player: Dictionary = {}, spawn_override: Vector2 = Vector2(INF,INF)) -> void:
	get_tree().paused=false
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	nearest=null
	world=Node2D.new()
	world.name="CurrentRun"
	add_child(world)
	var generated: Dictionary=DungeonGenerator.generate(run.world_seed) if run.region=="vault" else WorldGenerator.generate(run.world_seed)
	if run.region=="vault":
		var vault_view := DungeonView.new()
		vault_view.progress=run.vault
		terrain=vault_view
	else:
		terrain=WorldView.new()
	world.add_child(terrain)
	terrain.build(generated)
	player=MagePlayer.new()
	player.run=run
	player.position=generated.spawn if not is_finite(spawn_override.x) else spawn_override
	player.position=Vector2(saved_player.get("x",player.position.x),saved_player.get("y",player.position.y))
	player.shake_enabled=settings.shake
	terrain.actors.add_child(player)
	player.camera.limit_right=int(generated.get("width",WorldGenerator.WIDTH))*16
	player.camera.limit_bottom=int(generated.get("height",WorldGenerator.HEIGHT))*16
	player.vitals.hp=float(saved_player.get("hp",100))
	player.vitals.mana=float(saved_player.get("mana",100))
	player.vitals.stamina=float(saved_player.get("stamina",100))
	combat=CombatSystem.new()
	combat.run=run
	combat.player=player
	world.add_child(combat)
	combat.sound_requested.connect(audio.play)
	player.cast_requested.connect(combat.cast)
	player.dash_performed.connect(func(): audio.play("dash"))
	player.was_hit.connect(func(): audio.play("hurt"))
	player.died.connect(func(): get_tree().paused=true; ui.death_menu())
	var camp: Vector2=generated.spawn if run.region=="vault" else WorldGenerator.center(generated.points[0].tile)
	for definition in generated.enemies:
		if definition.id in run.defeated:
			continue
		if run.region=="vault" and run.source.resolution=="restored" and definition.id in SourceQuest.QUIET_ENEMIES:
			continue
		var enemy := WildEnemy.new()
		enemy.configure(definition,player,camp)
		if terrain is DungeonView:
			enemy.pathfinder=terrain.navigation
		terrain.actors.add_child(enemy)
		combat.connect_enemy(enemy)
	for point in generated.points:
		var landmark: Landmark
		if run.region=="vault":
			landmark=DungeonObject.new()
			landmark.configure(point,dungeon_object_active(point.id))
		else:
			landmark=Landmark.new()
			landmark.configure(point,point.id in run.active_lights)
		terrain.actors.add_child(landmark)
	if run.region=="forest":
		var npc := Landmark.new()
		npc.configure({"id":"edda","kind":"npc","name":"Edda, Hüterin der Quelle","tile":generated.points[0].tile+Vector2i(0,-3)},false)
		terrain.actors.add_child(npc)
		var entrance := DungeonObject.new()
		entrance.configure({"id":"vault_entrance","kind":"entrance","name":"Eingang zur Quellengruft","tile":generated.points[3].tile+Vector2i(2,2)},run.quest_complete)
		terrain.actors.add_child(entrance)
		var atmosphere := ForestAtmosphere.new()
		atmosphere.player=player
		atmosphere.run=run
		world.add_child(atmosphere)
		run.discover("camp")
	source_story.build_region()
	audio.volume=settings.volume
	ui.settings=settings.duplicate()
	ui.hud.player=player
	ui.hud.run=run
	ui.hud.map_data=generated
	ui.hud.location_name="Quellengruft" if run.region=="vault" else "Laternenrast"
	ui.hud.prompt=""
	ui.hud.game_visible=true
	ui.clear()
	player.input_enabled=true
	player.cast_armed=false
	scan_time=0
	player.camera.reset_smoothing()

func dungeon_object_active(id: String) -> bool:
	if id in ["shortcut_gate","shortcut_lever"]:
		return run.vault.shortcut_open
	if id=="secret_gate":
		return run.vault.secret_open
	return id in run.vault.memories or id in run.vault.relics

func travel_to(region: String) -> void:
	if region not in ["forest","vault"] or region==run.region or player.vitals.hp<=0:
		return
	if region=="vault" and not run.quest_complete:
		return
	var stats := {"hp":player.vitals.hp,"mana":player.vitals.mana,"stamina":player.vitals.stamina}
	run.region=region
	var spawn := Vector2(INF,INF)
	if region=="forest":
		var forest := WorldGenerator.generate(run.world_seed)
		spawn=WorldGenerator.center(forest.points[3].tile+Vector2i(2,3))
	_build_region(stats,spawn)
	player.vitals.invulnerable=0.8
	save_game()
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
			build_run(argument)
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
			if run.inventory.equip(argument): save_game()
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
			if run.region=="vault":
				run.region="forest"
				_build_region()
			player.position=terrain.data.spawn
			player.vitals.refill()
			player.reset_transient()
			for child in combat.get_children():
				if child is MagicProjectile:
					child.queue_free()
			handle_action("resume")
			ui.toast("Edda hat dich zurückgebracht. Deine Funde bleiben bei dir.")
		"accept":
			run.quest_accepted=true
			handle_action("resume")
			ui.toast("Folge den hellen Pfaden. M öffnet Eddas Karte.")
		"reward":
			if run.active_lights.size()==3 and not run.quest_complete:
				run.quest_complete=true
				run.quest_accepted=true
				run.add_xp(45)
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
				if not room.id in run.vault.visited:
					run.vault.visited.append(room.id)
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
			else:
				run.motes-=cost
				player.vitals.refill()
				combat.effects.ring(player.position,28,Color("b7e5d3"))
				save_game()
		"memory":
			if not object.id in run.vault.memories:
				run.vault.memories.append(object.id)
				run.add_xp(int(DungeonGenerator.content().memory_xp))
				object.activate()
				save_game()
			show_discovery(object.id)
		"chest":
			if object.active or (object.id=="amber_seed" and not run.vault.secret_open):
				return
			run.vault.relics.append(object.id)
			run.add_xp(int(DungeonGenerator.content().chart_xp if object.id=="star_chart" else DungeonGenerator.content().seed_xp))
			object.activate()
			audio.play("light")
			save_game()
			show_discovery(object.id)
		"lever":
			run.vault.shortcut_open=true
			open_dungeon_gates()
			save_game()
			ui.toast("Ein Gitter hebt sich. Der kurze Weg zum Eingang ist frei.")
		"gate":
			if not object.active:
				ui.toast("Die Winde liegt auf der anderen Seite, im Garten ohne Sonne.")
		"secret_gate":
			if "water_memory" in run.vault.memories:
				run.vault.secret_open=true
				open_dungeon_gates()
				save_game()
				ui.toast("Der Stern im Stein antwortet. Ein verborgener Weg öffnet sich.")
			else:
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
			run.vault.reported=true
			save_game()
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
	build_run(result.data.run.world_seed,result.data)
	ui.toast(result.get("notice","Lichtpfad geladen."))
	return true

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_CLOSE_REQUEST:
		if is_instance_valid(ui) and ui.page!="title" and player.vitals.hp>0:
			if not save_game():
				return
		get_tree().quit()
