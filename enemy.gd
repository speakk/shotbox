extends RigidBody2D

const SPEED = 20000

var ENEMY_HIT_PARTICLES = preload("res://particles/enemy_hit.tscn")

func _ready():
	$Sprite2D.material = $Sprite2D.material.duplicate()
	$Health.zero_health.connect(_zero_health)
	$AnimationPlayer.play("RESET")

func _physics_process(delta):
	var player = get_tree().get_first_node_in_group("player")
	apply_central_force(global_position.direction_to(player.global_position) * SPEED * delta)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	for i in state.get_contact_count():
		var object = state.get_contact_collider_object(i)
		if object.is_in_group("bullets"):
			var global_collision_point = state.get_contact_collider_position(i)
			var direction = state.get_contact_collider_velocity_at_position(i).normalized()
			_got_hit(global_collision_point, direction)

func _zero_health():
	queue_free()

func _got_hit(collision_point, direction):
	var particles = ENEMY_HIT_PARTICLES.instantiate() as GPUParticles2D
	particles.global_position = collision_point
	get_parent().add_child(particles)
	particles.process_material.direction = Vector3(-direction.x, -direction.y, 0)
	particles.emitting = true
	$AnimationPlayer.play("got_hit")
	$Health.take_damage(4)
