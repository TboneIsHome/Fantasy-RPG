class_name ThornPatch
extends Node2D
## A stationary, short-lived control zone. The caster telegraphs its location first.
var player: MagePlayer
var remaining: float = 2.8
var pulse: float = 0
var radius: float = 25
var damage: float = 9
var slow_seconds: float = 0.75
var interval: float = 0.9

func _ready() -> void:
	z_index=5

func _physics_process(delta: float) -> void:
	remaining-=delta
	pulse-=delta
	if remaining<=0:
		queue_free()
		return
	if pulse<=0:
		pulse=interval
		if is_instance_valid(player) and player.position.distance_to(global_position)<=radius:
			var wall := get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,player.position,1))
			if wall.is_empty() and player.take_damage(damage):
				player.hindered=maxf(player.hindered,slow_seconds)
	queue_redraw()

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
