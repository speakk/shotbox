extends Node2D

class_name Shooter

const BULLET = preload("res://bullet.tscn")

@export var BULLET_DELAY := 0.1
var _can_shoot = true
var _bullet_timer = 0

func shoot(from: Vector2, direction: Vector2):
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	bullet.shoot_at(from, direction)
	_bullet_timer = BULLET_DELAY
	_can_shoot = false

func _physics_process(delta):
	_bullet_timer -= delta
	if _bullet_timer <= 0:
		_bullet_timer = 0
		_can_shoot = true
