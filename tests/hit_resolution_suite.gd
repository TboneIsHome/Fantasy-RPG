extends SceneTree
var checks := 0
var failures: Array[String] = []

func check(value: bool, title: String) -> void:
	checks += 1
	if value: print("PASS: ", title)
	else:
		failures.append(title)
		printerr("FAIL: ", title)

func solve(damage: float, impact: float, protection: float = 0, resistance: float = 0, stability: float = 0, defense: DefenseOutcome = null) -> HitResolution:
	return HitResolver.resolve(AttackProfile.new(damage, &"test", impact), CombatStats.new(protection, {"test":resistance}, stability), DefenseOutcome.hit() if defense == null else defense)

func _initialize() -> void:
	var r := solve(30, 20)
	check(r.resolved and r.contact and r.damage == 30 and r.impact == 20, "Approved example A: ordinary contact has independent 30 damage / 20 impact")
	r = solve(30, 20, 100)
	check(r.damage == 15 and r.impact == 20, "Approved example B: Protection 100 halves damage, never impact")
	check(solve(40, 0, 20, 75).damage == 8, "Approved example C: fire-style mitigation rounds 8.33 to 8")
	check(solve(40, 0, 0, -25).damage == 50, "Approved example D: minus 25 resistance means 50 damage")
	check(solve(0, 80, 0, 0, 200).impact == 27, "Approved example E: Stability 200 leaves 27 impact")
	for pair in [[0,30],[50,20],[100,15],[200,10]]:
		check(solve(30,20,pair[0]).damage == pair[1], "Protection diminishing returns at " + str(pair[0]))
	for pair in [[0,100],[25,75],[50,50],[90,10],[-25,125],[-50,150]]:
		check(solve(100,20,0,pair[0]).damage == pair[1], "Resistance percentage at " + str(pair[0]))
	check(solve(30,20,-1,0,-1).damage == 30 and solve(30,20,-1,0,-1).impact == 20, "Runtime formula normalizes negative protection/stability to zero")
	check(solve(40,0,0,-100).damage == 60 and solve(40,0,0,99).damage == 4, "Normal resistance formula clamps outliers to minus 50 / plus 90")
	r = solve(1,1,1e12,90,1e12)
	check(r.damage == 1 and r.impact == 0, "Normal extreme mitigation keeps minimum damage but has no minimum impact")
	check(solve(0.001,0,1e12,90).damage == 1, "Positive sub-unit raw damage still has minimum one")
	check(solve(0,20).damage == 0 and solve(0,20).impact == 20, "Zero raw damage is not raised to one and can carry impact")
	check(solve(20,0).damage == 20 and solve(20,0).impact == 0, "Damage-only profile has no invented impact")
	r = solve(40,20,0,100)
	check(r.immune and r.contact and r.damage == 0 and r.impact == 20, "Explicit 100 resistance negates damage without erasing contact or impact")
	r = solve(30,20,100,25,100,DefenseOutcome.block(0.5,0.25))
	check(r.contact and r.outcome == &"block" and r.damage == 6 and r.impact == 3, "Caller supplied block scales combine independently with mitigation")
	r = solve(30,20,0,0,0,DefenseOutcome.block(0,0.5))
	check(r.damage == 0 and r.impact == 10 and not r.immune, "Full damage negation can retain impact and is not an immunity stat")
	r = solve(30,20,0,0,0,DefenseOutcome.block(0.000001,0))
	check(r.damage == 1 and r.impact == 0, "Positive block scale obeys minimum damage; zero impact scale does not")
	r = solve(30,20,0,0,0,DefenseOutcome.parry())
	check(r.resolved and r.contact and r.outcome == &"parry" and r.damage == 0 and r.impact == 0, "Confirmed parry has contact but no normal effect on the defender")
	for defense in [DefenseOutcome.miss(),DefenseOutcome.evade()]:
		r = solve(100,100,0,0,0,defense)
		check(r.resolved and not r.contact and r.damage == 0 and r.impact == 0 and r.secondary.is_empty(), str(defense.kind) + " skips damage / impact / effect delivery")
	var stats := CombatStats.new(0,{"frost":50,"fire":-25})
	check(HitResolver.resolve(AttackProfile.new(40,&"frost"),stats,DefenseOutcome.hit()).damage == 20, "Damage type selects its matching resistance")
	check(HitResolver.resolve(AttackProfile.new(40,&"fire"),stats,DefenseOutcome.hit()).damage == 50, "Same target can resist one type and be vulnerable to another")
	check(HitResolver.resolve(AttackProfile.new(40,&"future_type"),stats,DefenseOutcome.hit()).damage == 40, "Unlisted damage type has neutral resistance without a global catalog")
	var information := {"future_effect":"illustration_only","duration":12}
	var attack := AttackProfile.new(0,&"utility",0,information)
	information.duration = 99
	r = HitResolver.resolve(attack,CombatStats.new(),DefenseOutcome.hit())
	check(r.resolved and r.contact and r.damage == 0 and r.impact == 0 and r.secondary.duration == 12 and r.secondary.is_read_only(), "Secondary information is copied and transported; no effects or fake damage executed")
	check(attack.damage == 0 and stats.resistances.frost == 50, "Pure calculation leaves attack and defense inputs unchanged")
	check(not HitResolver.resolve(null,stats,DefenseOutcome.hit()).resolved and not HitResolver.resolve(attack,null,DefenseOutcome.hit()).resolved and not HitResolver.resolve(attack,stats,null).resolved, "Missing required input fails closed")
	for invalid in [-1.0,NAN,INF,-INF]:
		check(not solve(invalid,1).resolved and not solve(1,invalid).resolved, "Invalid raw damage/impact rejected: " + str(invalid))
	for invalid in [NAN,INF,-INF]:
		check(not solve(1,1,invalid).resolved and not solve(1,1,0,0,invalid).resolved and not solve(1,1,0,invalid).resolved, "Non-finite defenses rejected: " + str(invalid))
	for invalid in [-1.0,NAN,INF]:
		check(not solve(1,1,0,0,0,DefenseOutcome.block(invalid,1)).resolved and not solve(1,1,0,0,0,DefenseOutcome.block(1,invalid)).resolved, "Invalid defense scales rejected: " + str(invalid))
	check(not solve(1,1,0,0,0,DefenseOutcome.new(&"invented")).resolved, "Unknown confirmed defense outcome rejected")
	check(not solve(1,1,0,0,0,DefenseOutcome.new(&"parry",1,1)).resolved, "Contradictory parry scales fail closed instead of applying normal damage")
	check(not HitResolver.resolve(AttackProfile.new(1,&""),stats,DefenseOutcome.hit()).resolved, "Missing damage type rejected")
	check(not HitResolver.resolve(AttackProfile.new(1,&"frost"),CombatStats.new(0,{"frost":"50"}),DefenseOutcome.hit()).resolved, "Invalid resistance data is not silently converted")
	check(not solve(1e308,1,0,-50,0,DefenseOutcome.block(2,1)).resolved, "Unrepresentable arithmetic result fails closed")
	content_tests()
	print("HIT RESOLUTION RESULT ", checks-failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)

func content_tests() -> void:
	var original := Content.all()
	check(Content.error_text().is_empty() and original.player.defense.is_read_only() and original.player.defense.resistances.is_read_only(), "Real defense definitions load once and are recursively read-only")
	var bundle := original.duplicate(true)
	bundle.player.defense.protection = 100
	bundle.player.defense.stability = 200
	bundle.player.defense.resistances = {"light":100,"frost":-50,"future_type":90}
	check(ContentValidator.validate_bundle(bundle,DungeonGenerator.content(),DiscoveryBook.entries()).is_empty(), "Valid authored defenses support vulnerability, immunity and extensible type keys")
	for data in [original.player,original.enemies.wolf,original.enemies.wisp,original.enemies.kobold,original.enemies.guardian]:
		check(data.defense.protection == 0 and data.defense.stability == 0 and data.defense.resistances.is_empty(), "Shipped actor defense is neutral, preserving existing damage / impact")
	var cases := [
		[["player","defense"],null,"Expected object"],
		[["player","defense"],{},"Missing required field"],
		[["player","defense","protection"],-1,"Expected number"],
		[["player","defense","protection"],NAN,"Expected number"],
		[["player","defense","stability"],INF,"Expected number"],
		[["player","defense","stability"],true,"Expected number"],
		[["player","defense","resistances"],[],"Expected object"],
		[["player","defense","resistances"],{"fire":91},"Expected finite resistance"],
		[["player","defense","resistances"],{"fire":99},"Expected finite resistance"],
		[["player","defense","resistances"],{"fire":101},"Expected finite resistance"],
		[["player","defense","resistances"],{"fire":-51},"Expected finite resistance"],
		[["player","defense","resistances"],{"fire":NAN},"Expected finite resistance"],
		[["player","defense","resistances"],{"fire":true},"Expected finite resistance"],
		[["player","defense","resistances"],{"fire":"50"},"Expected finite resistance"],
		[["player","defense","resistances"],{"Bad key":50},"Expected damage type ID"],
		[["player","defense","resistances"],{"":50},"Expected damage type ID"],
		[["enemies","guardian","defense","stability"],-1,"Expected number"],
		[["spells","bolt","damage_type"],"","Expected ID"],
		[["spells","nova","damage_type"],17,"Expected ID"],
		[["skills","echo","damage_type"],"bad-type","Expected ID"],
		[["enemies","wisp","damage_type"],false,"Expected ID"]
	]
	for sample in cases:
		bundle = original.duplicate(true)
		var cursor: Dictionary = bundle
		var path: Array = sample[0]
		for i in path.size()-1: cursor = cursor[path[i]]
		cursor[path[-1]] = sample[1]
		var diagnostics := ContentValidator.validate_bundle(bundle,DungeonGenerator.content(),DiscoveryBook.entries())
		var field := ".".join(path)
		check(not diagnostics.is_empty() and "data/content.json" in diagnostics[0] and field in diagnostics[0] and sample[2] in diagnostics[0], "Definition error identifies file, field and cause: " + field + " = " + str(sample[1]))
