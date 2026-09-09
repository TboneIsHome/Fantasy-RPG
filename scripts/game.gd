extends Node2D

var run: RunState
var world: Node2D
var terrain: WorldView
var player: MagePlayer
var combat: CombatSystem
var ui: GameUI
var audio: AudioController
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
	build_run("LICHTERHAIN")
	show_title()

func build_run(seed_text: String, saved: Dictionary = {}) -> void:
	get_tree().paused=false
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	nearest=null
	run=RunState.new() if saved.is_empty() else RunState.restore(saved.run)
	run.world_seed=seed_text.strip_edges().substr(0,64)
	if run.world_seed.is_empty():
		run.world_seed="LICHTERHAIN"
	world=Node2D.new()
	world.name="CurrentRun"
	add_child(world)
	var generated := WorldGenerator.generate(run.world_seed)
	terrain=WorldView.new()
	world.add_child(terrain)
	terrain.build(generated)
	player=MagePlayer.new()
	player.run=run
	player.position=generated.spawn
	player.shake_enabled=settings.shake
	terrain.actors.add_child(player)
	combat=CombatSystem.new()
	combat.run=run
	combat.player=player
	world.add_child(combat)
	combat.sound_requested.connect(audio.play)
	player.cast_requested.connect(combat.cast)
	player.dash_performed.connect(func(): audio.play("dash"))
	player.was_hit.connect(func(): audio.play("hurt"))
	player.died.connect(func(): get_tree().paused=true; ui.death_menu())
	var camp: Vector2=WorldGenerator.center(generated.points[0].tile)
	for definition in generated.enemies:
		if definition.id in run.defeated:
			continue
		var enemy := WildEnemy.new()
		enemy.configure(definition,player,camp)
		terrain.actors.add_child(enemy)
		combat.connect_enemy(enemy)
	for point in generated.points:
		var landmark := Landmark.new()
		landmark.configure(point,point.id in run.active_lights)
		terrain.actors.add_child(landmark)
	var npc := Landmark.new()
	npc.configure({"id":"edda","kind":"npc","name":"Edda, Hüterin der Quelle","tile":generated.points[0].tile+Vector2i(0,-3)},false)
	terrain.actors.add_child(npc)
	var atmosphere := ForestAtmosphere.new()
	atmosphere.player=player
	atmosphere.run=run
	world.add_child(atmosphere)
	if not saved.is_empty():
		player.position=Vector2(saved.player.x,saved.player.y)
		player.vitals.hp=float(saved.player.hp)
		player.vitals.mana=float(saved.player.mana)
		player.vitals.stamina=float(saved.player.stamina)
		settings=saved.settings.duplicate()
		player.shake_enabled=settings.shake
		audio.volume=settings.volume
	ui.settings=settings.duplicate()
	ui.hud.player=player
	ui.hud.run=run
	ui.hud.map_data=generated
	ui.hud.location_name="Laternenrast"
	ui.hud.prompt=""
	ui.hud.game_visible=true
	ui.clear()
	player.input_enabled=true
	run.discover("camp")
	last_level=run.level
	run.changed.connect(_progress_changed)
	scan_time=0
	player.camera.reset_smoothing()

func show_title() -> void:
	player.input_enabled=false
	get_tree().paused=true
	ui.title_menu(FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path+".bak"))

func handle_action(action: String, argument: String = "") -> void:
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
		"journal":
			get_tree().paused=true
			ui.journal(run)
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
				ui.dialogue("Die Quelle singt wieder","Du erhältst den Quellenfokus. Aktive Waldlichter sind jetzt Rastpunkte.\n\nDie erste Erkundungsrunde ist abgeschlossen. Verbliebene Gegner und deine Talente kannst du weiter ausprobieren.",[["Weiter erkunden","resume"],["Talente und Beutel ansehen","journal"]])

func _process(delta: float) -> void:
	if not is_instance_valid(player) or not ui.page.is_empty():
		return
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
	var region := "Die Lichterhaine"
	for landmark in get_tree().get_nodes_in_group("landmarks"):
		var distance := player.global_position.distance_to(landmark.global_position)
		if distance<closest_distance:
			closest_distance=distance
			nearest=landmark
		if landmark.kind!="npc" and distance<98:
			region=landmark.title
			if run.discover(landmark.id) and landmark.kind=="shrine":
				ui.toast("Entdeckt: "+landmark.title)
	ui.hud.location_name=region
	ui.hud.prompt=""
	if nearest:
		if nearest.kind=="npc":
			ui.hud.prompt="E · Mit Edda sprechen"
		elif nearest.kind=="camp":
			ui.hud.prompt="E · Rasten und speichern"
		elif not nearest.active:
			ui.hud.prompt="E · Waldlicht entzünden"
		else:
			ui.hud.prompt="E · Am Waldlicht rasten" if run.quest_complete else "Dieses Waldlicht leuchtet wieder."

func interact(landmark: Landmark) -> void:
	if landmark.kind=="npc":
		get_tree().paused=true
		if run.quest_complete:
			ui.dialogue("Edda","Hörst du das Wasser? Die Quelle erinnert sich wieder. Dein Quellenfokus lässt dich an jedem geweckten Waldlicht rasten.",[["Talente ansehen","journal"],["Aufbrechen","resume"]])
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
