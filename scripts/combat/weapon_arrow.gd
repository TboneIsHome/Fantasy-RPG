class_name WeaponArrow
extends MagicProjectile
## Presentation only; flight, collision and regional lifetime are inherited.
func _draw() -> void:
	draw_line(-direction*7,direction*5,Color("dfcba1"),1.5)
	draw_colored_polygon(PackedVector2Array([direction*8,direction*3+direction.orthogonal()*2,direction*3-direction.orthogonal()*2]),Color("dfeded"))
	draw_line(-direction*6,-direction*9+direction.orthogonal()*3,Color("a6c3b0"),1)
