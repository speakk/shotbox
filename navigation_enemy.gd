extends RigidBody2D

const SPEED = 20000

var ENEMY_HIT_PARTICLES = preload("res://particles/enemy_hit.tscn")

var next_position_target
var final_target_position

var target_position_check_interval = 2
var target_position_check_timer = target_position_check_interval

var _player_noticed = false

func _ready():
	$Sprite2D.material = $Sprite2D.material.duplicate()
	$Health.zero_health.connect(_zero_health)
	$AnimationPlayer.play("RESET")
	sleeping = true

func _physics_process(delta):
	if not _player_noticed:
		return
		
	target_position_check_timer -= delta
	if target_position_check_timer < 0:
		var player = get_tree().get_first_node_in_group("player")
		final_target_position = player.global_position
		
		$NavigationAgent2D.target_position = final_target_position
		target_position_check_timer = target_position_check_interval
		
		#await get_tree().physics_frame
	
	apply_central_force(global_position.direction_to($NavigationAgent2D.get_next_path_position()) * SPEED * delta)

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
	get_tree().root.get_node("Main").get_node("GroundLayer").add_child(particles)
	#get_parent().add_child(particles)
	#particles.process_material.di
	particles.process_material.direction = Vector3(-direction.x, -direction.y, 0)
	particles.emitting = true
	$AnimationPlayer.play("got_hit")
	$Health.take_damage(4)

func set_player_noticed(noticed):
	if noticed:
		_player_noticed = true
		$PlayerNoticeRing.visible = true
		sleeping = false
	
	else:
		_player_noticed = false
		$Sprite2D.modulate = Color.WHITE
		$PlayerNoticeRing.visible = false
		sleeping = true
		

func _on_detection_area_2d_body_entered(body):
	print("Noticed!")
	_player_noticed = true
