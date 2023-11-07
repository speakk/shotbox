extends RigidBody2D

const SPEED = 20000

var ENEMY_HIT_PARTICLES = preload("res://particles/enemy_hit.tscn")

@onready var shooter = $Shooter as Shooter

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
	target_position_check_timer -= delta
	
	if not _player_noticed:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	if shooter._can_shoot:
		shooter.shoot(global_position, global_position.direction_to(player.global_position))
		
	if target_position_check_timer < 0:
		final_target_position = player.global_position
		
		$NavigationAgent2D.target_position = final_target_position
		target_position_check_timer = target_position_check_interval
		
		#await get_tree().physics_frame
	
	apply_central_force(global_position.direction_to($NavigationAgent2D.get_next_path_position()) * SPEED * delta)

func get_hit(hit_position: Vector2, hit_velocity: Vector2, damage: int):
	var direction = hit_velocity.normalized()
	var particles = ENEMY_HIT_PARTICLES.instantiate() as GPUParticles2D
	particles.global_position = hit_position
	get_tree().root.get_node("Main").get_node("GroundLayer").add_child(particles)
	particles.process_material.direction = Vector3(-direction.x, -direction.y, 0)
	particles.emitting = true
	$AnimationPlayer.play("got_hit")
	$Health.take_damage(damage)
	
func _zero_health():
	queue_free()

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
		

func _on_detection_area_2d_body_entered(_body):
	_player_noticed = true
