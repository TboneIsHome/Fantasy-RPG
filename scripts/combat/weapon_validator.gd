class_name WeaponValidator
extends ContentValidator
## Authoring validation only. No runtime weapon or combat registry.

static func validate(data: Variant) -> Array[String]:
	var check := WeaponValidator.new()
	check.file = "data/weapons.json"
	check.rules(data)
	return check.errors

func rules(data: Variant) -> void:
	if not fields(data,"",{"weapons":"object","actions":"object","defenses":"object","pairings":"object","dual_defense":"id"}): return
	for group in ["weapons","actions","defenses","pairings"]:
		for id in data[group]:
			if not id_valid(id): fail(group+"."+str(id),"Expected stable ID",id)
	for id in data.defenses:
		fields(data.defenses[id],"defenses."+id,{"block":"bool","parry":"bool","block_damage_scale":UNIT,"block_impact_scale":UNIT,"block_movement_scale":UNIT,"facing_dot":[-1,1],"parry_window":[0.02,1],"parry_recovery":[0.02,3],"dodge_speed_scale":[0.1,1]})
	if not data.defenses.has(data.dual_defense): fail("dual_defense","Unknown defense reference",data.dual_defense)
	for id in data.actions: action_rules(data.actions[id],"actions."+id,data.actions)
	for id in data.weapons:
		var p: String = "weapons."+str(id)
		var w: Variant = data.weapons[id]
		if not fields(w,p,{"name":"text","identity":"text","family":"id","handedness":"id","dual_compatible":"bool","delivery":"id","defense":"id","portfolio":"object"}): continue
		enum_value(w.family,p+".family",["one_handed_blade","two_handed_blade","one_handed_blunt","heavy_blunt","one_handed_axe","two_handed_axe","polearm","ranged"])
		enum_value(w.handedness,p+".handedness",["one","two"])
		enum_value(w.delivery,p+".delivery",["contact","projectile"])
		if w.dual_compatible and w.handedness != "one": fail(p+".dual_compatible","Only one-handed weapons may pair",true)
		if not data.defenses.has(w.defense): fail(p+".defense","Unknown defense reference",w.defense)
		if not w.portfolio.has("primary"): fail(p+".portfolio.primary","Missing primary action",null)
		for slot in w.portfolio:
			enum_value(slot,p+".portfolio",["primary","heavy","secondary","follow_up","ranged"])
			var ref: Variant = w.portfolio[slot]
			if not ref is String or not data.actions.has(ref): fail(p+".portfolio."+slot,"Unknown action reference",ref)
			elif data.actions[ref] is Dictionary and data.actions[ref].get("delivery") != w.delivery: fail(p+".portfolio."+slot,"Action delivery must match weapon",ref)
	for id in data.pairings:
		var p: String = "pairings."+str(id)
		var pair: Variant = data.pairings[id]
		if not fields(pair,p,{"main":"id","off":"id","combined":"id"}): continue
		for hand in ["main","off"]:
			if not data.weapons.has(pair[hand]): fail(p+"."+hand,"Unknown weapon reference",pair[hand])
			elif not data.weapons[pair[hand]].get("dual_compatible",false): fail(p+"."+hand,"Expected dual-compatible weapon",pair[hand])
		if not data.actions.has(pair.combined): fail(p+".combined","Unknown action reference",pair.combined)

func action_rules(a: Variant, p: String, actions: Dictionary) -> void:
	if not a is Dictionary: fail(p,"Expected action object",a); return
	var schema := {"purpose":"text","delivery":"id","startup":[0.02,5],"commit":[0,5],"recovery":[0.02,5],"phases":"array","geometry":"object","movement":"object","hit":"object","defense":"object","follow_ups":"array"}
	if a.get("delivery") == "projectile": schema.projectile_speed = [1,2000]
	if not fields(a,p,schema): return
	enum_value(a.delivery,p+".delivery",["contact","projectile"])
	if a.commit > a.startup: fail(p+".commit","Expected commit <= startup",a.commit)
	if a.phases.is_empty() or a.phases.size()>8: fail(p+".phases","Expected 1–8 explicit phases",a.phases.size())
	var end: float = a.startup
	for i in a.phases.size():
		var phase: Variant = a.phases[i]
		var at := p+".phases[%d]" % i
		if not fields(phase,at,{"start":[0,10],"duration":[0.05,3],"hand":"id"}): continue
		enum_value(phase.hand,at+".hand",["action","main","off","both"])
		if phase.start < end: fail(at+".start","Expected ordered non-overlapping phase >= previous end",phase.start)
		end = phase.start + phase.duration
	if a.delivery == "projectile" and (a.phases.size()!=1 or (a.phases[0] is Dictionary and a.phases[0].get("start")!=a.startup)):
		fail(p+".phases","Projectile release requires one phase starting at startup",a.phases)
	geometry_rules(a.geometry,p+".geometry",a.delivery)
	fields(a.movement,p+".movement",{"startup":UNIT,"active":UNIT,"recovery":UNIT,"forward_speed":[0,200],"turn_rate":[0,30]})
	fields(a.hit,p+".hit",{"damage":NONNEG,"damage_type":"id","impact":NONNEG})
	fields(a.defense,p+".defense",{"blockable":"bool","parryable":"bool"})
	var seen: Array = []
	for ref in a.follow_ups:
		if not ref is String or not actions.has(ref) or ref in seen: fail(p+".follow_ups","Expected unique existing action reference",ref)
		seen.append(ref)

func geometry_rules(g: Dictionary, p: String, delivery: String) -> void:
	var schema := {"shape":"id","reach":[1,1000]}
	var shape: Variant = g.get("shape")
	enum_value(shape,p+".shape",["narrow","wide","forward","sweep","projectile"])
	match shape:
		"narrow","forward": schema.merge({"minimum_reach":[0,1000],"half_width":[1,100]})
		"wide": schema.half_angle = [0.01,PI]
		"sweep": schema.merge({"from_angle":[-PI,PI],"to_angle":[-PI,PI],"half_angle":[0.01,PI/2]})
	if not fields(g,p,schema): return
	enum_value(shape,p+".shape",["narrow","wide","forward","sweep","projectile"])
	if (shape == "projectile") != (delivery == "projectile"): fail(p+".shape","Geometry must match delivery",shape)
	if g.get("minimum_reach",0) >= g.reach: fail(p+".minimum_reach","Expected minimum_reach < reach",g.minimum_reach)
	if shape == "sweep" and g.from_angle == g.to_angle: fail(p,"Sweep must span different angles",g)
