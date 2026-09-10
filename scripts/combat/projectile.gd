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
	var color := Color("f4aa8c") if hostile else Color("a9f2d8")
	for i in range(7,0,-1):
		var at := -direction*(i*3)
		var tint := Color(color,0.65-i*0.07)
		draw_line(at-direction*4,at,tint,3 if i<3 else 1)
		var spark := at+direction.orthogonal()*sin(elapsed*25-i)*i*0.3
		draw_rect(Rect2(spark.floor(),Vector2.ONE),Color(color,0.8-i*0.08))
	draw_circle(Vector2.ZERO,7,Color(color,0.12))
	draw_colored_polygon(PackedVector2Array([direction*6,direction.orthogonal()*3,-direction*6,-direction.orthogonal()*3]),color)
	draw_line(-direction*3,direction*3,Color("fff7d7"),2)
	draw_line(-direction.orthogonal()*5,direction.orthogonal()*5,Color(color,0.45),1)
