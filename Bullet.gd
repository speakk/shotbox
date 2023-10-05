extends RigidBody2D

const SPEED = 300.0

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
		queue_free()
		break
