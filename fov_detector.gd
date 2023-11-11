extends Node2D

# Script adapted from https://github.com/godot-addons/godot-field-of-view/


@export var radius_warn: float = 500.0
@export var field_of_view: float = 60.0
@export var radius_danger: float = 200.0
@export var view_detail: float = 60.0

@export var show_circle: bool = false
@export var show_fov: bool = true
@export var show_target_line: bool = true

@export var circle_color: Color = Color("#9f185c0b")
@export var fov_color: Color = Color("#b23d7f0b")
@export var fov_warn_color: Color = Color("#b1eedf0b")
@export var fov_danger_color: Color = Color("#9dfb320b")

@export var enemy_groups: Array = ["player"]

var in_danger_area: Array = []
var in_warn_area: Array = []

# Buffer to target points
var points_arc: Array = []
var is_update: bool = false

signal has_noticed_target

func _process(delta: float) -> void:
	global_rotation = 0
	is_update = true
	check_view()
	queue_redraw()
	#update()

func _draw() -> void:
	if show_circle:
		draw_circle(get_position(), radius_warn, circle_color)

	if show_fov && is_update:
		draw_circle_arc()

func draw_circle_arc() -> void:
	var dir_deg = rad_to_deg(get_parent().linear_velocity.angle())
	#print("Angle: ", dir_deg)
	#var dir_deg = rad_to_deg(transform.get_rotation())
	var start_angle = dir_deg - (field_of_view * 0.5)
	var end_angle = start_angle + field_of_view
	
	for aux in points_arc:
		if aux.level == 1 && show_target_line:
				draw_line(get_position(), aux.pos, fov_warn_color, 10, true)
		elif aux.level == 2 && show_target_line:
			draw_line(get_position(), aux.pos, fov_danger_color, 20, true)
		else:
				draw_line(get_position(), aux.pos, fov_color, 4, true)

func deg_to_vector(deg: float) -> Vector2:
	return Vector2(cos(deg_to_rad(deg)), sin(deg_to_rad(deg)))

func check_view() -> void:
	var dir_deg = rad_to_deg(get_parent().linear_velocity.angle())
	#print("Angle: ", dir_deg)
	#var dir_deg = rad_to_deg(transform.get_rotation())
	var start_angle = dir_deg - (field_of_view * 0.5)
	var end_angle = start_angle + field_of_view

	points_arc = []
	in_danger_area = []
	in_warn_area = []

	var space_state = get_world_2d().direct_space_state

	for i in range(view_detail + 1):
		var cur_angle = start_angle + (i * (field_of_view / view_detail))
		var point = get_position() + deg_to_vector(cur_angle) * radius_warn

		# use global coordinates, not local to node
		var physics_ray_parameters = PhysicsRayQueryParameters2D.new()
		physics_ray_parameters.from = get_global_transform().origin
		physics_ray_parameters.to = to_global(point)
		physics_ray_parameters.exclude =  [get_parent()]
		var result = space_state.intersect_ray(physics_ray_parameters)
		#var result = space_state.intersect_ray(get_global_transform().origin, to_global(point), [get_parent()])

		if result.is_empty():
			points_arc.append({"pos": point, "level": 0})
			continue

		var local_pos = to_local(result.position)
		var dist = get_position().distance_to(local_pos)
		var level = 0
		var is_enemy = false

		if in_danger_area.has(result.collider) || in_warn_area.has(result.collider):
			points_arc.append({"pos": local_pos, "level": level})
			continue

		for g in enemy_groups :
			if result.collider.get_groups().has(g):
				is_enemy = true
				has_noticed_target.emit()

		if !is_enemy:
			points_arc.append({"pos": local_pos, "level": level})
			continue

		level = 1

		if dist < radius_danger :
			level = 2
			in_danger_area.append(result.collider)
		else :
			in_warn_area.append(result.collider)

		# check if directly to target, we can "shoot"
		var tgt_pos = result.collider.get_global_transform().origin
		var this_pos = get_global_transform().origin
		var tgt_dir = (tgt_pos - this_pos).normalized()
		#var dirr = get_global_transform().get_rotation())+90
		var dirr = dir_deg
		var view_angle = rad_to_deg(deg_to_vector(dirr).angle_to(tgt_dir))

		if !(view_angle > start_angle && view_angle < end_angle):
			points_arc.append({"pos": local_pos, "level": level})
			continue
		
		var physics_ray_parameters2 = PhysicsRayQueryParameters2D.new()
		physics_ray_parameters2.from = this_pos
		physics_ray_parameters2.to = tgt_pos
		physics_ray_parameters2.exclude = [get_parent()]
		var result2 = space_state.intersect_ray(physics_ray_parameters2)
		#var result2 = space_state.intersect_ray(this_pos, tgt_pos, [get_parent()])

		if !result2.is_empty() && result2.collider == result.collider :
			# we can, then use this as line
			points_arc.append({"pos": local_pos, "level": 0})
			if show_target_line:
				points_arc.append({"pos": to_local(tgt_pos), "level": level})
		else :
			points_arc.append({"pos": local_pos, "level": level})
