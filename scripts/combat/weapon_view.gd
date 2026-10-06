class_name WeaponView
extends Node2D
## Replaceable prototype presentation. No decisions, collision, or timing owner.
func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var p := get_parent() as MagePlayer
	if p == null or p.weapons == null: return
	var w := p.weapons
	if not w.busy():
		draw_line(p.aim*7,p.aim*17,Color("b5c9b9"),2)
		return
	var state := w.current.timeline.state()
	var color := Color("ffe2a0") if state == ActionTimeline.State.ACTIVE else Color("bb8465") if state == ActionTimeline.State.RECOVERY else Color("72b7ba")
	var g: Dictionary = w.definition.geometry
	var rotation_angle := w.heading.angle()
	var reach: float = g.reach
	if g.shape == "projectile":
		draw_arc(Vector2.ZERO,12,rotation_angle-1,rotation_angle+1,16,color,2)
		draw_line(w.heading*12,w.heading*30,color,1)
	elif g.shape in ["narrow","forward"]:
		var points := PackedVector2Array()
		for point in [Vector2(g.minimum_reach,-g.half_width),Vector2(reach,-g.half_width),Vector2(reach,g.half_width),Vector2(g.minimum_reach,g.half_width),Vector2(g.minimum_reach,-g.half_width)]: points.append(point.rotated(rotation_angle))
		draw_polyline(points,Color(color,.5),1)
		draw_line(w.heading*5,w.heading*reach,color,2)
	else:
		var start: float = -g.half_angle if g.shape == "wide" else minf(g.from_angle,g.to_angle)
		var end: float = g.half_angle if g.shape == "wide" else maxf(g.from_angle,g.to_angle)
		draw_arc(Vector2.ZERO,reach,rotation_angle+start,rotation_angle+end,32,Color(color,.4),1)
		var fraction := 0.0
		var phase := w.current.timeline.phase_index()
		if phase >= 0:
			var window: Dictionary = w.current.timeline.windows[phase]
			fraction = clampf((w.current.timeline.elapsed-window.start)/window.duration,0,1)
		var angle: float = 0 if g.shape=="wide" else lerpf(g.from_angle,g.to_angle,fraction)
		draw_line(Vector2.ZERO,Vector2.from_angle(rotation_angle+angle)*reach,color,2)
