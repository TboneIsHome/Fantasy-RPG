class_name ActionProfiles
extends RefCounted
## Adapters for current attacks. Existing durations/ranges remain authoritative.
static func clock(startup: float, active: float, recovery: float) -> ActionTimeline:
	return ActionTimeline.new(startup, startup * float(Content.section("active_combat").commit_fraction), [{"start":startup,"duration":active}], recovery)

static func instant() -> float:
	return float(Content.section("active_combat").instant_window)

static func enemy(data: Dictionary, kind: String) -> ActionTimeline:
	return clock(float(data.windup), float(data.lunge_duration) if kind == "wolf" else instant(), float(data.recovery))

static func guardian(data: Dictionary, fan: bool) -> ActionTimeline:
	return clock(float(data.fan_windup if fan else data.windup), instant(), float(data.recovery))

static func spell(data: Dictionary) -> ActionTimeline:
	return clock(0, instant(), float(data.cooldown))

static func pulses(duration: float, interval: float) -> ActionTimeline:
	var windows: Array = []
	if not is_finite(duration) or not is_finite(interval) or duration <= 0 or interval <= 0 or ceilf(duration / interval) > 512: return ActionTimeline.new(0,0,[],0)
	var at := 0.0
	while at < duration:
		windows.append({"start":at,"duration":minf(interval, duration - at)})
		at += interval
	return ActionTimeline.new(0, 0, windows, 0)

static func rules(kind: String) -> Dictionary:
	return Content.section("active_combat").contacts[kind]
