extends RigidBody2D

#@onready var collision_shape = get_node("CollisionShape2D").shape as RectangleShape2D

var PARTICLES = preload("res://particles/wall_break.tscn")

func _integrate_forces(state: PhysicsDirectBodyState2D):
	for i in state.get_contact_count():
		var object = state.get_contact_collider_object(i)
		if object.is_in_group("bullets"):
			print("Coll", i)
			var global_collision_point = state.get_contact_collider_position(i)
			var collision_point = to_local(global_collision_point)
			print("Collision point: ", collision_point)
			
			var y_diff = $ColorRect.size.y - collision_point.y
			
			if $ColorRect.size.y < 30:
				queue_free()
			
			if collision_point.y < 10:
				continue
				
			var particles = PARTICLES.instantiate()
			particles.global_position = global_collision_point
			get_parent().add_child(particles)
			particles.emitting = true
				
			call_deferred("set_y_size", collision_point.y)
			var duplicated_wall = duplicate_unique()
			duplicated_wall.global_position = global_collision_point
			duplicated_wall.call_deferred("set_y_size", y_diff)
			get_parent().call_deferred("add_child", duplicated_wall)

func duplicate_unique():
	var duplicated = duplicate()
	duplicated.get_node("CollisionPolygon2D").polygon = get_node("CollisionPolygon2D").polygon.duplicate()
	duplicated.angular_velocity = -angular_velocity
	return duplicated

func set_y_size(y_size):
	$ColorRect.size.y = y_size
	$CollisionPolygon2D.polygon[2].y = y_size
	$CollisionPolygon2D.polygon[3].y = y_size
	center_of_mass.y = y_size / 2
	
	if y_size < 3:
		queue_free()
