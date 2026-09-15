class_name SourceQuest
extends RefCounted
## Persistent decisions; the live guardian's health and attacks are deliberately transient.
const GUARDIAN_ID := "source_guardian"
const SIGNS := ["water","roots","star"]
const QUIET_ENEMIES := ["vault_guard_5","vault_guard_6"]
var seen: bool = false
var alignment: int = 0
var resolution: String = ""
var guardian_defeated: bool = false
var reported: bool = false
var ore_taken: bool = false

func has_evidence(vault: DungeonProgress) -> bool:
	return "water_memory" in vault.memories and "root_memory" in vault.memories and "star_chart" in vault.relics

func align(sign_id: String, vault: DungeonProgress) -> bool:
	if not resolution.is_empty() or not has_evidence(vault) or sign_id not in SIGNS or alignment>=SIGNS.size():
		return false
	if sign_id!=SIGNS[alignment]:
		alignment=0
		return false
	alignment+=1
	return true

func resolve(path: String, vault: DungeonProgress) -> bool:
	if not resolution.is_empty() or path not in ["restored","broken"]:
		return false
	if path=="restored" and (alignment!=3 or not has_evidence(vault) or guardian_defeated):
		return false
	if path=="broken" and not guardian_defeated:
		return false
	seen=true
	alignment=0
	resolution=path
	return true

func objective(vault: DungeonProgress) -> String:
	if not resolution.is_empty():
		return "Edda von der Quelle erzählen" if not reported else "Der Quellengarten erwacht" if resolution=="restored" else "Die Erzader liegt frei"
	if not seen:
		return "Die Fassung der Gruft untersuchen"
	return "Bindung stimmen oder Hüter besiegen" if has_evidence(vault) else "Karte und zwei Erinnerungen finden"

func serialize() -> Dictionary:
	return {"seen":seen,"alignment":alignment,"resolution":resolution,"guardian_defeated":guardian_defeated,"reported":reported,"ore_taken":ore_taken}

static func restore(data: Dictionary) -> SourceQuest:
	var state := SourceQuest.new()
	state.seen=data.seen
	state.alignment=int(data.alignment)
	state.resolution=data.resolution
	state.guardian_defeated=data.guardian_defeated
	state.reported=data.reported
	state.ore_taken=data.ore_taken
	return state
