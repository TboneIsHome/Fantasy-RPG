class_name ThornPatch
extends Node2D
## A stationary, short-lived control zone. The caster telegraphs its location first.
var player: MagePlayer
var remaining: float = float(Content.section("enemies").kobold.thorn_duration)
var last_phase: int = -1
var radius: float = float(Content.section("enemies").kobold.thorn_radius)
var damage: float = float(Content.section("enemies").kobold.damage)
var slow_seconds: float = float(Content.section("enemies").kobold.thorn_slow)
var interval: float = float(Content.section("enemies").kobold.thorn_interval)
var peaceful_area: Rect2
var attack_action: AttackInstance
var source_id: String

func _ready() -> void:
	z_index=5

func _physics_process(delta: float) -> void:
	if is_queued_for_deletion(): return
	if attack_action == null or not attack_action.is_current():
		queue_free()
		return
	attack_action.tick(delta)
	remaining=attack_action.timeline.active_end-attack_action.timeline.elapsed
	var phase := attack_action.timeline.phase_index()
	if remaining<=0:
		queue_free()
		return
	if phase>=0 and phase!=last_phase:
		last_phase=phase
		if is_instance_valid(player) and not peaceful_area.has_point(player.global_position):
			var query := ContactContext.new(attack_action,player,global_position,radius).follow(self)
			query.visibility=_clear_line
			var profile := CombatProfiles.hostile_attack(damage,Content.section("enemies").kobold.damage_type,{"slow_seconds":slow_seconds})
			var contact := CombatContact.resolve(attack_action,query,profile)
			if contact.confirmed(): player.hindered=maxf(player.hindered,float(contact.resolution.secondary.slow_seconds))
	queue_redraw()

func _clear_line(from: Vector2, to: Vector2) -> bool:
	return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from,to,1)).is_empty()

func _draw() -> void:
	var alpha := minf(1,remaining*2)
	draw_circle(Vector2.ZERO,radius,Color(0.47,0.22,0.23,0.20*alpha))
	draw_arc(Vector2.ZERO,radius,0,TAU,32,Color(0.85,0.53,0.39,0.85*alpha),1)
	for i in 11:
		var angle := i*TAU/11
		var p := Vector2.from_angle(angle)*(radius*(0.35 if i%2 else 0.77))
		var thorn := PackedVector2Array([p+Vector2(-4,2),p+Vector2(-2,-8),p+Vector2(2,-3),p+Vector2(5,-11),p+Vector2(4,3)])
		draw_colored_polygon(thorn,Color(0.57,0.62,0.33,alpha))
		draw_line(p+Vector2(-2,0),p+Vector2(-1,-6),Color(0.87,0.75,0.48,alpha),1)
