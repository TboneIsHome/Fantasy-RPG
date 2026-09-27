class_name SourceImpact
extends Node2D
var player: MagePlayer
var radius: float = float(Content.section("enemies").guardian.slam_radius)
var damage: float = float(Content.section("enemies").guardian.damage)
var remaining: float = 0.45
var struck: bool = false
var hit_instance: HitInstance
var attack_action: AttackInstance

func _ready() -> void:
	z_index=6

func _physics_process(delta: float) -> void:
	if is_queued_for_deletion(): return
	if attack_action == null or not attack_action.is_current():
		queue_free()
		return
	if not struck:
		struck=true
		if is_instance_valid(player):
			var query := ContactContext.new(attack_action,player,global_position,radius,global_position.direction_to(player.global_position)).follow(self)
			query.visibility=_clear_line
			CombatContact.resolve(attack_action,query,CombatProfiles.hostile_attack(damage,Content.section("enemies").guardian.damage_type))
		attack_action.timeline.finish_active()
	remaining-=delta
	if remaining<=0: queue_free()
	queue_redraw()

func _clear_line(from: Vector2, to: Vector2) -> bool:
	return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from,to,1)).is_empty()

func _draw() -> void:
	var fade := clampf(remaining/0.45,0,1)
	draw_circle(Vector2.ZERO,radius,Color(0.92,0.81,0.54,fade*0.3))
	draw_arc(Vector2.ZERO,radius*(1-fade*0.2),0,TAU,48,Color(0.97,0.88,0.63,fade),2)
	for i in 9:
		var at := Vector2.from_angle(i*TAU/9)*(radius*(1-fade*0.4))
		draw_line(at,at+Vector2(0,-14*fade),Color(0.96,0.85,0.57,fade),2)
