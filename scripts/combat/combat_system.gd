class_name CombatSystem
extends Node2D

signal sound_requested(id: String)
signal enemy_defeated
var player: MagePlayer
var run: RunState
var effects: CombatFeedback

func _ready() -> void:
	effects = CombatFeedback.new()
	add_child(effects)

func cast(id: String, origin: Vector2, target: Vector2) -> void:
	var data: Dictionary = Content.section("spells")[id]
	sound_requested.emit(id)
	if id == "bolt":
		var projectile := MagicProjectile.new()
		projectile.position = origin
		projectile.direction = origin.direction_to(target) if origin.distance_to(target)>1 else player.aim
		projectile.speed = float(data.speed)
		projectile.remaining = float(data.range)
		projectile.struck.connect(_bolt_hit)
		add_child(projectile)
	else:
		var center := origin+(target-origin).limit_length(float(data.range))
		# A targeting ray prevents casting through solid trunks, rocks or water.
		var query := PhysicsRayQueryParameters2D.create(origin,center,1)
		var obstacle := get_world_2d().direct_space_state.intersect_ray(query)
		if not obstacle.is_empty():
			center = obstacle.position+(origin-center).normalized()*5
		effects.ring(center,float(data.radius),Color("91dfed"))
		effects.burst(center,Color("b3edeb"),25)
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.global_position.distance_to(center)<=float(data.radius) and _clear_line(center,enemy.global_position):
				enemy.slowed = float(data.slow_duration)
				enemy.take_damage(float(data.damage),center.direction_to(enemy.global_position))
		if "bloom" in run.learned and player.global_position.distance_to(center)<=float(data.radius):
			player.vitals.hp = minf(100,player.vitals.hp+12)
			effects.number(player.global_position,"+12",Color("b6edb3"))

func _clear_line(from: Vector2, to: Vector2) -> bool:
	return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from,to,1)).is_empty()

func _bolt_hit(body: Node, point: Vector2, direction: Vector2) -> void:
	effects.burst(point,Color("c2eecb"),6)
	if body is WildEnemy:
		var chained: WildEnemy = null
		if body.slowed>0 and "echo" in run.learned:
			for other in get_tree().get_nodes_in_group("enemies"):
				if other != body and other.hp>0 and other.global_position.distance_to(body.global_position)<65 and _clear_line(body.global_position,other.global_position):
					if chained==null or other.global_position.distance_to(point)<chained.global_position.distance_to(point):
						chained = other
		body.take_damage(float(Content.section("spells").bolt.damage),direction,true)
		if chained:
			effects.ring(chained.global_position,15,Color("eae9b3"))
			chained.take_damage(12,direction)

func connect_enemy(enemy: WildEnemy) -> void:
	enemy.defeated.connect(_defeated)
	enemy.hit.connect(func(target,amount,shatter):
		effects.number(target.global_position,str(int(amount))+("!" if shatter else ""),Color("c4f1ee") if shatter else Color("f0d9ab"))
		effects.burst(target.global_position+Vector2(0,-9),Color("aed8c5"),8)
		sound_requested.emit("hit"))
	enemy.projectile_requested.connect(_enemy_bolt)
	enemy.thorns_requested.connect(_thorns)

func _thorns(point: Vector2) -> void:
	var definition: Dictionary=Content.section("enemies").kobold
	var patch := ThornPatch.new()
	patch.position=point
	patch.player=player
	patch.radius=float(definition.thorn_radius)
	patch.remaining=float(definition.thorn_duration)
	patch.damage=float(definition.damage)
	patch.slow_seconds=float(definition.thorn_slow)
	patch.interval=float(definition.thorn_interval)
	add_child(patch)
	sound_requested.emit("hit")

func _enemy_bolt(origin: Vector2, direction: Vector2, amount: float) -> void:
	var projectile := MagicProjectile.new()
	projectile.position = origin
	projectile.direction = direction
	projectile.speed = 115
	projectile.remaining = 210
	projectile.hostile = true
	projectile.struck.connect(func(body,point,heading):
		if body is MagePlayer:
			body.take_damage(amount,heading)
		effects.burst(point,Color("e9b192"),7))
	add_child(projectile)

func _defeated(enemy: WildEnemy) -> void:
	if enemy.id in run.defeated:
		return
	run.defeated.append(enemy.id)
	run.motes += 1
	run.add_xp(int(enemy.definition.xp))
	effects.burst(enemy.global_position,Color("d3dcb0"),18)
	enemy_defeated.emit()
