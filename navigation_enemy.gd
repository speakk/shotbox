extends RigidBody2D

@export var SPEED = 500
@export var target_points: Array[Node2D] = []
var current_target_point_index: int = 0

var ENEMY_HIT_PARTICLES = preload("res://particles/enemy_hit.tscn")

@onready var shooter = $Shooter as Shooter

var next_position_target
var final_target_position

var target_position_check_interval = randf_range(1.5, 2.5)
var target_position_check_timer = target_position_check_interval

var _player_noticed = false

func _ready():
	$Sprite2D.material = $Sprite2D.material.duplicate()
	$Health.zero_health.connect(_zero_health)
	$AnimationPlayer.play("RESET")
	$AnimationPlayer2.play("run")
	sleeping = true
	$FOVDetector.has_noticed_target.connect(func(): set_player_noticed(true))
	
	if target_points.size() > 0:
		final_target_position = target_points[0].global_position

func _process(delta):
	$Sprite2D.global_rotation = 0

func _physics_process(delta):
	target_position_check_timer -= delta
	
	var player = get_tree().get_first_node_in_group("player")
	if shooter._can_shoot and player and _player_noticed:
		shooter.shoot(global_position, global_position.direction_to(player.global_position))
		
	if target_position_check_timer < 0:
		if _player_noticed:
			if not player:
				return
			final_target_position = player.global_position
		
		if final_target_position:
			$NavigationAgent2D.target_position = final_target_position
			
		target_position_check_timer = target_position_check_interval
		
		#await get_tree().physics_frame
	
	apply_central_force(global_position.direction_to($NavigationAgent2D.get_next_path_position()) * SPEED)
	
	if final_target_position and global_position.distance_to(final_target_position) < 60:
		# TODO: Don't just use _player_noticed here, have proper state handling
		# for when we're following the player etc
		if not _player_noticed:
			if target_points.size() > 0:
				current_target_point_index += 1
				current_target_point_index = wrapi(current_target_point_index, 0, target_points.size())
				final_target_position = target_points[current_target_point_index].global_position
				print("Now index: ", current_target_point_index)

func get_hit(hit_position: Vector2, hit_velocity: Vector2, damage: int):
	set_player_noticed(true)
	var direction = hit_velocity.normalized()
	var particles = ENEMY_HIT_PARTICLES.instantiate() as GPUParticles2D
	particles.global_position = hit_position
	#get_tree().root.get_node("Main").get_node("GroundLayer").add_child(particles)
	get_parent().add_child(particles)
	particles.process_material.direction = Vector3(-direction.x, -direction.y, 0)
	particles.emitting = true
	$AnimationPlayer.play("got_hit")
	$Health.take_damage(damage)
	
func _zero_health():
	queue_free()

func set_player_noticed(noticed):
	if noticed:
		_player_noticed = true
		#$PlayerNoticeRing.visible = true
		$FOVDetector.visible = false
		sleeping = false
	
	else:
		_player_noticed = false
		$Sprite2D.modulate = Color.WHITE
		#$PlayerNoticeRing.visible = false
		$FOVDetector.visible = true
		sleeping = true
		

func _on_detection_area_2d_body_entered(_body):
	pass
	#_player_noticed = true
