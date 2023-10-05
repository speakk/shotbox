extends RigidBody2D

#@onready var collision_shape = get_node("CollisionShape2D").shape as RectangleShape2D

func _integrate_forces(state: PhysicsDirectBodyState2D):
	for i in state.get_contact_count():
		var object = state.get_contact_collider_object(i)
		if object.is_in_group("bullets"):
			print("Coll", i)
			var global_collision_point = state.get_contact_collider_position(i)
			var collision_point = to_local(global_collision_point)
			print("Collision point: ", collision_point)
			
			var y_diff = $ColorRect.size.y - collision_point.y
			if y_diff < 3 or collision_point.y < 3:
				continue
				
			set_y_size(collision_point.y)
			var duplicated_wall = duplicate_unique()
			duplicated_wall.global_position = global_collision_point
			duplicated_wall.set_y_size(y_diff)
			get_parent().add_child(duplicated_wall)

func duplicate_unique():
	var duplicated = duplicate()
	duplicated.get_node("CollisionPolygon2D").polygon = get_node("CollisionPolygon2D").polygon.duplicate()
	duplicated.angular_velocity = -angular_velocity
	return duplicated

func set_y_size(y_size):
	$ColorRect.size.y = y_size
	$CollisionPolygon2D.polygon[2].y = y_size
	$CollisionPolygon2D.polygon[3].y = y_size
