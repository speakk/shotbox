extends Node

class_name Health

signal health_changed(new_value)
signal max_health_changed(new_value)
signal zero_health

@export var max_health = 10:
	set(value):
		max_health_changed.emit(value)
		max_health = value

var health = max_health:
	set(value):
		health_changed.emit(value)
		health = value
		if health <= 0:
			zero_health.emit()

func take_damage(damage):
	health -= damage

func heal(healing_value):
	health += healing_value

func _ready():
	health = max_health
