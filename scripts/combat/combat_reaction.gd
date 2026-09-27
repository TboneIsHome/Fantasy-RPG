class_name CombatReaction
extends RefCounted
## State only. Effective Impact already includes M06 Stability mitigation.
enum Kind {NORMAL, INTERRUPT, STAGGER}
var kind: Kind = Kind.NORMAL
var remaining: float = 0
var guard_remaining: float = 0
var displacement := Vector2.ZERO

func tick(delta: float) -> void:
	if not is_finite(delta) or delta < 0: return
	remaining = maxf(0, remaining - delta)
	guard_remaining = maxf(0, guard_remaining - delta)
	if remaining <= 0: kind = Kind.NORMAL

func apply(result: HitResolution, heading: Vector2, config: Dictionary) -> Kind:
	if result == null or not result.resolved or not result.contact or result.outcome == &"parry": return Kind.NORMAL
	displacement = heading.limit_length(1) * minf(result.impact, float(config.max_displacement))
	if result.impact <= 0 or guard_remaining > 0: return Kind.NORMAL
	var next := Kind.STAGGER if result.impact >= float(config.stagger_impact) else Kind.INTERRUPT if result.impact >= float(config.interrupt_impact) else Kind.NORMAL
	if next == Kind.NORMAL: return next
	kind = next
	remaining = float(config.stagger_seconds if kind == Kind.STAGGER else config.interrupt_seconds)
	guard_remaining = remaining + float(config.recovery_guard)
	return next

func counter(seconds: float, guard: float) -> void:
	if guard_remaining > 0: return
	kind = Kind.INTERRUPT
	remaining = seconds
	guard_remaining = seconds + guard

func locked() -> bool:
	return remaining > 0
