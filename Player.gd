extends RigidBody2D

const SPEED = 600.0
const DAMP = 1.0
const HAND_DISTANCE = 50
#const BULLET_DELAY = 0.01

const BULLET = preload("res://bullet.tscn")

const BULLET_DELAY = 0.1
var _can_shoot = true
var _bullet_timer = 0

const DASH_DELAY = 1
const DASH_SPEED = 4000
var _can_dash = true
var _dash_timer = 0

func shoot():
	var bullet = BULLET.instantiate()
	#bullet.global_position = global_position
	get_parent().add_child(bullet)
	bullet.shoot_at($Hand.global_position, global_position.direction_to(get_global_mouse_position()))
	_bullet_timer = BULLET_DELAY
	_can_shoot = false

func dash():
	#apply_central_impulse(global_position.direction_to(get_global_mouse_position()) * DASH_SPEED)
	apply_central_impulse(linear_velocity.normalized() * DASH_SPEED)
	_dash_timer = DASH_DELAY
	_can_dash = false

func _physics_process(delta):
	var input_velocity = get_input()
	apply_central_force(input_velocity * SPEED * delta)
	#velocity = velocity.move_toward(Vector2(), 3000 * delta)
	#move_and_slide()
	
	$Hand.global_position = global_position + global_position.direction_to(get_global_mouse_position()) * HAND_DISTANCE
	if Input.is_action_pressed("shoot") and _can_shoot:
		shoot()
		
	if Input.is_action_pressed("dash") and _can_dash:
		dash()
	
	_bullet_timer -= delta
	if _bullet_timer <= 0:
		_bullet_timer = 0
		_can_shoot = true
	
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
