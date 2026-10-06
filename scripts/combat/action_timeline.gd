class_name ActionTimeline
extends RefCounted
## Local gameplay time, independent of animation. Windows are half-open.
enum State {INTENT, STARTUP, COMMIT, ACTIVE, RECOVERY, COMPLETED, INTERRUPTED}
var elapsed: float = 0
var started: bool = false
var interrupted: bool = false
var valid: bool = false
var startup: float
var commit_at: float
var recovery: float
var windows: Array = []
var active_end: float = 0
var hold_before_active: bool = false

func _init(preparation: float, commitment: float, phases: Array, after: float) -> void:
	startup = preparation
	commit_at = commitment
	recovery = after
	if not is_finite(startup) or startup < 0 or not is_finite(commit_at) or commit_at < 0 or commit_at > startup or not is_finite(recovery) or recovery < 0 or phases.is_empty(): return
	var end := startup
	for entry in phases:
		if not entry is Dictionary or not entry.has("start") or not entry.has("duration"): return
		if not (entry.start is float or entry.start is int) or not (entry.duration is float or entry.duration is int): return
		if not is_finite(float(entry.start)) or not is_finite(float(entry.duration)) or entry.start < end or entry.duration <= 0: return
		end = float(entry.start) + float(entry.duration)
		if not is_finite(end): return
		windows.append(entry.duplicate(true))
	active_end = end
	valid = is_finite(active_end + recovery)

func start() -> bool:
	if not valid or started or interrupted: return false
	started = true
	return true

func tick(delta: float) -> void:
	if not started or interrupted or not is_finite(delta) or delta < 0: return
	elapsed = minf(active_end + recovery, elapsed + delta)
	if hold_before_active: elapsed = minf(startup, elapsed)

func awaiting_release() -> bool:
	return hold_before_active and started and not interrupted and elapsed >= startup

func release_hold() -> bool:
	if not awaiting_release(): return false
	hold_before_active = false
	return true

func phase_index() -> int:
	if not valid or not started or interrupted or hold_before_active: return -1
	for index in windows.size():
		var window: Dictionary = windows[index]
		if elapsed >= float(window.start) and elapsed < float(window.start) + float(window.duration): return index
	return -1

func state() -> State:
	if not valid or interrupted: return State.INTERRUPTED
	if not started: return State.INTENT
	if elapsed >= active_end + recovery: return State.COMPLETED
	if elapsed >= active_end: return State.RECOVERY
	if phase_index() >= 0: return State.ACTIVE
	return State.COMMIT if elapsed >= commit_at else State.STARTUP

func committed() -> bool:
	return started and elapsed >= commit_at

func cancel() -> bool:
	if committed() or state() in [State.COMPLETED, State.INTERRUPTED]: return false
	interrupted = true
	return true

func interrupt() -> bool:
	if state() in [State.COMPLETED, State.INTERRUPTED]: return false
	interrupted = true
	return true

func finish_active() -> void:
	if state() == State.ACTIVE: elapsed = active_end

func remaining() -> float:
	match state():
		State.STARTUP, State.COMMIT: return maxf(0, startup - elapsed)
		State.ACTIVE: return maxf(0, float(windows[phase_index()].start) + float(windows[phase_index()].duration) - elapsed)
		State.RECOVERY: return maxf(0, active_end + recovery - elapsed)
	return 0
