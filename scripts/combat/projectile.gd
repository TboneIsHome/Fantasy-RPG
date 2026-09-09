class_name MagicProjectile
extends CharacterBody2D

signal struck(body: Node, point: Vector2, direction: Vector2)
var direction := Vector2.RIGHT
var speed: float = 265
var remaining: float = 235
var hostile: bool = false
var elapsed: float = 0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | (2 if hostile else 4)
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 3
	collision.shape = shape
	add_child(collision)
	z_index = 10

func _physics_process(delta: float) -> void:
	elapsed += delta
	var distance := speed*delta
	remaining -= distance
	var collision := move_and_collide(direction*distance)
	if collision:
		struck.emit(collision.get_collider(),global_position,direction)
		queue_free()
	elif remaining<=0:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var color := Color("edb396") if hostile else Color("baf8dd")
	for i in 5:
		var p := -direction*(i*3)
		var tint := color
		tint.a = 0.7-i*0.12
		draw_rect(Rect2(p-Vector2.ONE*2,Vector2.ONE*4),tint)
	draw_circle(Vector2.ZERO,3,color)
	draw_rect(Rect2(-1,-1,2,2),Color("fff9d4"))
