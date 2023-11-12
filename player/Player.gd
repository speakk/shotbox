extends RigidBody2D

@onready var shooter = $Shooter as Shooter

var ENEMY_HIT_PARTICLES = preload("res://particles/enemy_hit.tscn")

const SPEED = 80.0
const DAMP = 1.0
const HAND_DISTANCE = 50
#const BULLET_DELAY = 0.01

const DASH_DELAY = 1
const DASH_SPEED = 2000
var _can_dash = true
var _dash_timer = 0

func _ready():
	$Health.zero_health.connect(_zero_health)
	$AnimationPlayer.play("run")

func _zero_health():
	#queue_free()
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	Events.player_died.emit()

func dash():
	apply_central_impulse(linear_velocity.normalized() * DASH_SPEED)
	_dash_timer = DASH_DELAY
	_can_dash = false
	$TrailParticles.emitting = true
	await get_tree().create_timer(0.25).timeout
	$TrailParticles.emitting = false

func _physics_process(delta):
	var input_velocity = get_input()
	apply_central_force(input_velocity * SPEED)
	
	$Hand.global_position = global_position + global_position.direction_to(get_global_mouse_position()) * HAND_DISTANCE
	if Input.is_action_pressed("shoot") and shooter._can_shoot:
		shooter.shoot($Hand.global_position, global_position.direction_to(get_global_mouse_position()))
		
	if Input.is_action_pressed("dash") and _can_dash:
		dash()
	
	_dash_timer -= delta
	if _dash_timer <= 0:
		_dash_timer = 0
		_can_dash = true
	
func get_input():
	var input_velocity = Vector2()
	if Input.is_action_pressed("right"):
		input_velocity.x += 1
	if Input.is_action_pressed("left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("down"):
		input_velocity.y += 1
	if Input.is_action_pressed("up"):
		input_velocity.y -= 1
	
	if input_velocity.length_squared() > 0:
		input_velocity = input_velocity.normalized() * SPEED
		#velocity = input_velocity
	
	return input_velocity


func get_hit(hit_position: Vector2, hit_velocity: Vector2, damage: int):
	var direction = hit_velocity.normalized()
	var particles = ENEMY_HIT_PARTICLES.instantiate() as GPUParticles2D
	particles.global_position = hit_position
	#get_tree().root.get_node("Main").get_node("GroundLayer").add_child(particles)
	get_parent().add_child(particles)
	particles.process_material.direction = Vector3(-direction.x, -direction.y, 0)
	particles.emitting = true
	$Health.take_damage(damage)
