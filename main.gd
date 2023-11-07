extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	$CanvasLayer/Label.text = "%s" % Engine.get_frames_per_second()
