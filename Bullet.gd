extends RigidBody2D

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
		get_parent().add_child(particles)
		queue_free()
		break
