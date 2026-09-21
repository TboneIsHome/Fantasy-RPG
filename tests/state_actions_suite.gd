extends SceneTree
## Requests are checked against persistent state; observers see complete results.
var checks := 0
var failures: Array[String] = []
var watched: RunState
var observations: Array[Dictionary] = []
var invalid_notifications: Array[String] = []
var reenter: Callable
var reentry_accepted := false
var mage: MagePlayer
const SETTINGS := {"volume":0.4,"shake":true}

func _initialize() -> void:
	call_deferred("verify")

func check(ok: bool, title: String) -> void:
	checks += 1
	if not ok: failures.append(title)
	print("PASS STATE: " if ok else "FAIL STATE: ", title)

func watch(state: RunState) -> void:
	if watched != null: watched.changed.disconnect(observed)
	watched = state
	observations.clear()
	state.changed.connect(observed)

func observed() -> void:
	observations.append(watched.serialize())
	var error := SaveSystem.validate(SaveSystem.snapshot(watched, mage, SETTINGS))
	if not error.is_empty(): invalid_notifications.append(error)
	if reenter.is_valid():
		var action := reenter
		reenter = Callable()
		reentry_accepted = action.call()

func accept(action: Callable, title: String) -> void:
	var count := observations.size()
	var ok: bool = action.call()
	check(ok and observations.size() == count + 1 and observations.back() == watched.serialize(), title + ": one complete notification")

func reject(action: Callable, title: String) -> void:
	var before := watched.serialize()
	var count := observations.size()
	check(not action.call() and watched.serialize() == before and observations.size() == count, title + ": no mutation or notification")

func total_xp(state: RunState) -> int:
	return state.xp + 30 * state.level * (state.level - 1)

func unlocked_source() -> RunState:
	var state := RunState.new()
	for id in RunState.LIGHT_IDS: state.activate_light(id)
	state.complete_quest()
	state.inspect_source()
	return state

func verify() -> void:
	mage = MagePlayer.new()
	mage.position = Vector2(248,726)
	var state := RunState.new()
	watch(state)
	reject(state.activate_light.bind("unknown"), "Unknown light")
	reject(state.discover.bind("water_memory"), "Wrong owner for a dungeon memory")
	reject(state.discover.bind("unknown"), "Unknown discovery")
	reject(state.learn.bind("flow"), "Talent without a point")
	reject(state.complete_quest, "Incomplete light quest")
	reject(state.inspect_source, "Source before the forest quest")
	reject(state.defeat_source_guardian, "Guardian before source discovery")
	reject(state.equip_relic.bind("source_heart"), "Unowned equipment")
	accept(state.accept_quest, "Accept forest quest")
	reject(state.accept_quest, "Repeated quest acceptance")
	for id in RunState.LIGHT_IDS:
		var xp := total_xp(state)
		accept(state.activate_light.bind(id), "Activate " + id)
		check(total_xp(state) == xp + 20, "Existing light XP retained: " + id)
		reject(state.activate_light.bind(id), "Repeated " + id)
	var xp := total_xp(state)
	reenter = state.complete_quest
	accept(state.complete_quest, "Complete forest quest")
	check(state.quest_complete and state.quest_accepted and total_xp(state) == xp + 45 and not reentry_accepted, "Quest reward is complete before a reentrant observer can request it again")
	reject(state.complete_quest, "Repeated forest reward")
	accept(state.learn.bind("flow"), "Learn known talent")
	reject(state.learn.bind("flow"), "Repeated learned talent")
	reject(state.learn.bind("unknown"), "Unknown talent")
	accept(state.discover.bind("camp"), "Discover camp")
	reject(state.discover.bind("camp"), "Repeated discovery")
	reject(state.defeat_enemy.bind("unknown", "wolf"), "Unknown persistent enemy")
	reject(state.defeat_enemy.bind("guard_1_0", "wisp"), "Mismatched enemy kind")
	reject(state.defeat_enemy.bind(SourceQuest.GUARDIAN_ID, "guardian"), "Guardian cannot use ordinary kill rewards")
	xp = total_xp(state)
	accept(state.defeat_enemy.bind("guard_1_0", "wolf"), "Confirmed enemy defeat")
	check(state.motes == 1 and total_xp(state) == xp + 18 and state.defeated == ["guard_1_0"], "Enemy ID, dust and configured XP are granted together")
	reject(state.defeat_enemy.bind("guard_1_0", "wolf"), "Repeated death notification")
	reject(state.spend_motes.bind(-1), "Negative payment")
	reject(state.spend_motes.bind(0), "Zero payment")
	reject(state.spend_motes.bind(2), "Unaffordable payment")
	accept(state.spend_motes.bind(1), "Affordable payment")
	reject(state.spend_motes.bind(1), "Insufficient balance after payment")
	reject(state.visit_room.bind("unknown"), "Unknown room")
	accept(state.visit_room.bind("threshold"), "Visit room")
	reject(state.visit_room.bind("threshold"), "Repeated room visit")
	reject(state.unlock_memory.bind("unknown"), "Unknown memory")
	reject(state.collect_vault_relic.bind("unknown"), "Unknown find")
	reject(state.collect_vault_relic.bind("amber_seed"), "Hidden find before its gate opens")
	reject(state.open_vault_secret, "Secret gate without clue")
	reject(state.report_vault_chart, "Chart report without chart")
	xp = total_xp(state)
	accept(state.unlock_memory.bind("water_memory"), "Read water memory")
	check(total_xp(state) == xp + 10, "Memory keeps its existing XP")
	reject(state.unlock_memory.bind("water_memory"), "Repeated memory")
	accept(state.open_vault_secret, "Open secret using known clue")
	reject(state.open_vault_secret, "Repeated secret opening")
	accept(state.open_vault_shortcut, "Open shortcut")
	reject(state.open_vault_shortcut, "Repeated shortcut opening")
	xp = total_xp(state)
	accept(state.collect_vault_relic.bind("star_chart"), "Collect chart")
	accept(state.collect_vault_relic.bind("amber_seed"), "Collect accessible hidden find")
	check(total_xp(state) == xp + 40 + 25, "Both finds retain their existing XP")
	reject(state.collect_vault_relic.bind("star_chart"), "Repeated chart request")
	reject(state.collect_vault_relic.bind("amber_seed"), "Repeated hidden find request")
	accept(state.report_vault_chart, "Report chart")
	reject(state.report_vault_chart, "Repeated chart report")
	accept(state.inspect_source, "Inspect source")
	reject(state.inspect_source, "Repeated source inspection")
	reject(state.align_source.bind("water"), "Alignment before all clues")
	accept(state.unlock_memory.bind("root_memory"), "Read final clue")
	reject(state.align_source.bind("unknown"), "Unknown source sign")
	accept(state.align_source.bind("water"), "First correct source sign")
	var count := observations.size()
	check(not state.align_source("star") and state.source.alignment == 0 and observations.size() == count + 1, "Wrong known sign resets progress and publishes that change once")
	accept(state.align_source.bind("water"), "Restart alignment")
	accept(state.prepare_source_challenge, "Challenge resets an existing alignment")
	count = observations.size()
	check(state.prepare_source_challenge() and observations.size() == count, "Challenge with no alignment accepts the encounter without inventing a persistent change")
	accept(state.align_source.bind("water"), "Resume first sign")
	accept(state.align_source.bind("roots"), "Second sign")
	# M04 publishes immutable definitions. Inject the same fault into a test-only copy.
	var original_content := Content.all()
	Content._cache = original_content.duplicate(true)
	var reward: Dictionary = Content.section("source_quest")
	reward.reward_item = "missing_relic"
	reject(state.align_source.bind("star"), "Unavailable reward prevents partial quest completion")
	Content._cache = original_content
	xp = total_xp(state)
	reenter = state.align_source.bind("star")
	accept(state.align_source.bind("star"), "Final sign resolves and rewards source")
	check(state.source.resolution == "restored" and state.source.alignment == 0 and state.inventory.owned == ["source_heart"] and state.inventory.equipped == "source_heart" and total_xp(state) == xp + 90 and not reentry_accepted, "Observer receives a complete investigation outcome with its single reward")
	reject(state.align_source.bind("star"), "Repeated final sign")
	reject(state.defeat_source_guardian, "Cannot change an established source outcome")
	reject(state.harvest_source_ore, "Restored garden has no harvestable ore")
	accept(state.report_source, "Report complete source outcome")
	reject(state.report_source, "Repeated source report")
	accept(state.equip_relic.bind(""), "Unequip owned relic")
	reject(state.equip_relic.bind(""), "Already empty slot")
	reject(state.equip_relic.bind("unknown"), "Unknown equipment")
	accept(state.equip_relic.bind("source_heart"), "Equip owned relic")
	var restored := RunState.restore(state.serialize())
	watch(restored)
	reject(restored.collect_vault_relic.bind("star_chart"), "Reloaded chart remains claimed")
	reject(restored.align_source.bind("star"), "Reloaded source cannot reward again")
	var detached := restored.serialize()
	detached.vault.relics.clear(); detached.inventory.owned.clear(); detached.defeated.clear()
	check(restored.serialize() == state.serialize(), "Snapshots and restored arrays do not alias external mutations")
	state = unlocked_source()
	watch(state)
	check(not state.source.has_evidence(state.vault), "Combat route starts without investigation clues")
	xp = total_xp(state)
	accept(state.defeat_source_guardian, "Confirmed guardian defeat resolves combat route")
	check(state.source.guardian_defeated and state.source.resolution == "broken" and state.inventory.owned == ["source_heart"] and total_xp(state) == xp + 90, "Combat route publishes the same complete reward")
	reject(state.defeat_source_guardian, "Repeated guardian defeat")
	accept(state.harvest_source_ore, "Harvest exposed ore")
	check(state.motes == 4, "Ore grants exactly the configured dust")
	reject(state.harvest_source_ore, "Repeated ore harvest")
	accept(state.report_source, "Report combat route without chart")
	check(not state.vault.reported, "Source report does not invent a missing chart")
	accept(state.collect_vault_relic.bind("star_chart"), "Later chart remains obtainable")
	accept(state.report_source, "Later chart report updates the remaining state")
	reject(state.report_source, "All reports are now complete")
	check(invalid_notifications.is_empty(), "Every emitted state is immediately save-valid; no partial reward or alignment=3 escapes")
	watched.changed.disconnect(observed)
	mage.free()
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var report := FileAccess.open("res://test-output/state_actions_results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures,"invalid_notifications":invalid_notifications}, "  ")); report.close()
	print("STATE ACTIONS RESULT ", checks - failures.size(), "/", checks)
	quit(0 if failures.is_empty() else 1)
