extends RigidBody2D

class_name Bullet

@export_flags_2d_physics var target_mask_layers:
	set(mask):
		print("Setting mask: ", mask)
		collision_mask = mask
		target_mask_layers = mask

@export var damage: int = 10

const SPEED = 1000.0


const PARTICLES = preload("res://particles/bullet_collision.tscn")

func _ready():
	add_to_group("bullets")

func shoot_at(from: Vector2, direction: Vector2):
	global_position = from
	#velocity = direction.normalized() * SPEED
	apply_central_impulse(direction.normalized() * SPEED)
	$AnimationPlayer.play("shoot")

func _delete():
	queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	for i in state.get_contact_count():
		var particles = PARTICLES.instantiate()
		particles.global_position = state.get_contact_collider_position(i)
		particles.emitting = true
		particles.top_level = true
		get_parent().add_child(particles)
		queue_free()
		
		var target = state.get_contact_collider_object(i)
		if target.has_method("get_hit"):
			print("WE HAVE A HIT")
			print("mask: ", collision_mask)
			target.get_hit(state.get_contact_collider_position(i), state.get_contact_collider_velocity_at_position(i), damage)
		
		break
