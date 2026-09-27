class_name ActiveDefense
extends RefCounted
## Exactly one defensive action; recovery is exposed, never free block/parry.
enum Mode {NORMAL, DODGE, BLOCK, PARRY, RECOVERY}
var mode: Mode = Mode.NORMAL
var remaining: float = 0
var recovery: float = 0
var from_parry: bool = false
var facing := Vector2.RIGHT

func tick(delta: float) -> void:
	if not is_finite(delta) or delta < 0 or mode in [Mode.NORMAL, Mode.BLOCK]: return
	remaining -= delta
	if remaining <= 0:
		if mode in [Mode.DODGE, Mode.PARRY] and recovery > 0:
			mode = Mode.RECOVERY
			remaining += recovery
			recovery = 0
		if remaining <= 0: reset()

func reset() -> void:
	mode = Mode.NORMAL
	remaining = 0
	recovery = 0
	from_parry = false

func can_start() -> bool:
	return mode in [Mode.NORMAL, Mode.BLOCK]

func block(held: bool, heading: Vector2) -> bool:
	if not held:
		if mode == Mode.BLOCK: reset()
		return true
	if not can_start(): return false
	mode = Mode.BLOCK
	facing = heading.normalized()
	return true

func dodge(window: float, after: float) -> bool:
	if not can_start(): return false
	mode = Mode.DODGE
	remaining = window
	recovery = after
	from_parry = false
	return true

func parry(window: float, after: float, heading: Vector2) -> bool:
	if not can_start(): return false
	mode = Mode.PARRY
	remaining = window
	recovery = after
	facing = heading.normalized()
	from_parry = true
	return true

func parry_confirmed() -> void:
	if mode != Mode.PARRY: return
	mode = Mode.RECOVERY
	remaining = recovery
	recovery = 0
	if remaining <= 0: reset()

func blocks_offense() -> bool:
	return mode in [Mode.BLOCK, Mode.PARRY, Mode.DODGE] or (mode == Mode.RECOVERY and from_parry)

func outcome(incoming_from: Vector2, rules: Dictionary, damage_protected: bool, config: Dictionary) -> DefenseOutcome:
	if damage_protected or mode == Mode.DODGE: return DefenseOutcome.evade()
	var aligned := incoming_from.length_squared() < 0.000001 or (facing.length_squared() > 0 and facing.dot(incoming_from.normalized()) >= float(config.facing_dot))
	if aligned and mode == Mode.PARRY and bool(rules.parryable): return DefenseOutcome.parry()
	if aligned and mode == Mode.BLOCK and bool(rules.blockable): return DefenseOutcome.block(float(config.block_damage_scale), float(config.block_impact_scale))
	return DefenseOutcome.hit()
