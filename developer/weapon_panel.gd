extends VBoxContainer
const Trials = preload("res://developer/weapon_trials.gd")
var host: Control
var choices: OptionButton
var description: RichTextLabel

func build(owner_ui: Control) -> void:
	host=owner_ui
	add_theme_constant_override("separation",8)
	host.section(self,"M08 · WAFFENVERGLEICH")
	choices=host.select(self)
	host.button(self,"Auswahl laden / Arena zurücksetzen",load_choice)
	host.label(self,"Lokal und ungespeichert. Auswahl setzt den Versuch zurück; kein Equipment-Wechsel während eines Kampfes.",13)
	description=host.rich(self)
	host.section(self,"AKTIONEN")
	var row: HBoxContainer=host.row(self)
	host.button(row,"Primary · J",func(): request("primary"))
	host.button(row,"Heavy · K",func(): request("heavy"))
	row=host.row(self)
	host.button(row,"Alternative · L",func(): request("secondary"))
	host.button(row,"Follow-up · O",func(): request("follow_up"))
	row=host.row(self)
	host.button(row,"Off-Hand · U",func(): request("primary","off"))
	host.button(row,"Combined · I",func(): request("combined"))
	row=host.row(self)
	host.button(row,"Bogen loslassen",release_bow)
	host.button(row,"Abbruch · X",cancel_action)
	host.label(self,"Bogen: J/K halten, zielen, loslassen. LMB/1 bleibt Lichtfunke; RMB/2 bleibt Frostkreis. F/Q/Leertaste: Block/Parry/Dodge.",13)
	host.section(self,"KONTROLLIERTE VERSUCHE")
	host.button(self,"Pause + 50 ms Waffenzeit",step_action)
	row=host.row(self)
	host.button(row,"Ziel zurück",func(): motion("retreat"))
	host.button(row,"Seitwärts",func(): motion("side"))
	row=host.row(self)
	host.button(row,"Ziel nähert sich",func(): motion("approach"))
	host.button(row,"Ziel stoppen",func(): motion(""))
	host.label(self,"Tab Versuche: Abstand/Winkel, HP/Protection/Stability, mehrere Gegner. R: echter Gegnerangriff. F2: gewählter Startzustand inklusive Waffe.",13)
	host.button(self,"Alle M08 A01–A12 vergleichen",run_cases)
	host.label(self,"Gleicher Dummy bei Abstand 30: Dolch verfehlt, übrige Primäraktionen treffen. Ergebnisse und Kontakte im Diagnosebericht. Danach pausiert.",13)

func populate() -> void:
	host.option(choices,"","M07 / Magier ohne Waffenprofil")
	for id in Trials.CASES: host.option(choices,id,Trials.label_for(id))

func restore_choice() -> void:
	var id: String=host.selected(choices)
	if not id.is_empty(): Trials.attach(host.session,id)

func load_choice() -> void:
	if not host.available(): return
	var id: String=host.selected(choices)
	if id.is_empty(): host.reset_selected(); return
	if host.session.select_weapon_case(id):
		host.players.select(0);host.enemies.select(0);host.preset_fields()
		host.say(Trials.label_for(id)+" · J/K/L/U/I/O · Abstand 30 ist für Dolch zu weit.")

func request(slot: String, hand: String = "main") -> void:
	if host.available(): host.say("Waffenaktion angenommen" if host.session.weapon_request(slot,hand) else "Aktion fehlt oder Combat-State noch gebunden.")

func release_bow() -> void:
	if host.available() and host.session.fixture.player.weapons != null:
		host.say("Release angefragt" if host.session.fixture.player.weapons.request_release() else "Keine gehaltene Bogenaktion.")

func cancel_action() -> void:
	if host.available() and host.session.fixture.player.weapons != null:
		host.say("Vor Commit abgebrochen" if host.session.fixture.player.weapons.cancel() else "Kein freier Abbruch nach Commit.")

func step_action() -> void:
	if not host.available(): return
	host.session.set_paused(true)
	Trials.step(host.session,.05)
	host.say("50 ms Action/Defense/Reaction; kein Körper-/Projektilschritt.")

func motion(mode: String) -> void:
	if host.available():
		host.session.target_motion=mode
		host.say("Testbewegung: "+("gestoppt" if mode.is_empty() else mode)+" · Gegner-Grundtempo; Reset stellt Startposition wieder her.")

func run_cases() -> void:
	if not host.available(): return
	host.busy=true
	var results: Array=[]
	var passed := true
	for id in Trials.CASES:
		var result: Dictionary=await Trials.compare(host.session,id)
		results.append(result);passed=passed and result.passed
	host.session.last_scenario={"set":"M08","passed":passed,"results":results}
	host.busy=false
	host.say("PASS · M08 A01–A12; vollständiger Diagnosebericht verfügbar." if passed else "FAIL · M08: Diagnosebericht prüfen.")

func refresh() -> void:
	var w: WeaponActions=host.session.fixture.player.weapons
	if w==null:
		description.text="Kein Waffenprofil. Bestehender Magierpfad aktiv."
		return
	var data := Content.weapons()
	var main: Dictionary=data.weapons[w.main_id]
	var p: Dictionary=data.actions[main.portfolio.primary]
	var defense := w.defense_config()
	description.text="[b]%s[/b]\n%s\nMain: %s · Off: %s\nPrimary: %s · Reach %.0f\nStartup %.2f · Commit %.2f · Recovery %.2f\nDamage %.0f · Impact %.0f\nBlock %s · Parry %s\n[b]%s[/b]" % [host.session.weapon_case,main.identity,main.name,"–" if w.off_id.is_empty() else data.weapons[w.off_id].name,p.geometry.shape,p.geometry.reach,p.startup,p.commit,p.recovery,p.hit.damage,p.hit.impact,str(defense.block),str(defense.parry),"Zielen · J/K loslassen" if w.busy() and w.current.timeline.awaiting_release() else host.action_text(host.session.action_info(w.current))]
