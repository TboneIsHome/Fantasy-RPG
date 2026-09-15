class_name SourceImpact
extends Node2D
var player: MagePlayer
var radius: float = 34
var damage: float = 21
var remaining: float = 0.45
var struck: bool = false

func _ready() -> void:
	z_index=6

func _physics_process(delta: float) -> void:
	if not struck:
		struck=true
		if is_instance_valid(player) and player.global_position.distance_to(global_position)<=radius:
			var wall := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,player.global_position,1))
			if wall.is_empty(): player.take_damage(damage,global_position.direction_to(player.global_position))
	remaining-=delta
	if remaining<=0: queue_free()
	queue_redraw()

func _draw() -> void:
	var fade := clampf(remaining/0.45,0,1)
	draw_circle(Vector2.ZERO,radius,Color(0.92,0.81,0.54,fade*0.3))
	draw_arc(Vector2.ZERO,radius*(1-fade*0.2),0,TAU,48,Color(0.97,0.88,0.63,fade),2)
	for i in 9:
		var at := Vector2.from_angle(i*TAU/9)*(radius*(1-fade*0.4))
		draw_line(at,at+Vector2(0,-14*fade),Color(0.96,0.85,0.57,fade),2)
