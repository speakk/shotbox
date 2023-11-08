extends Node

const IN_GAME_PATH = "res://main_scenes/in_game.tscn"
const MAIN_MENU = "res://main_scenes/main_menu.tscn"
const LEVEL_SELECTOR_PATH = "res://main_scenes/level_selector.tscn"
const PROFILE_MANAGER_PATH = "res://main_scenes/profile_manager_ui.tscn"

func _process(_delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _ready():
	Events.new_game_pressed.connect(_new_game_pressed)
	Events.try_again_pressed.connect(_try_again_pressed)
	Events.level_change_pressed.connect(_level_change_pressed)
	Events.next_level_pressed.connect(_next_level_pressed)
	Events.profile_manager_pressed.connect(_profile_manager_pressed)
	Events.main_menu_pressed.connect(_main_menu_pressed)
	Events.first_time_player_added.connect(_first_time_player_added)

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func _switch_scene(scene_path, level_id):
	var previous_scene = $Scenes.get_child(0) if $Scenes.get_child_count() > 0 else null
	var new_scene = load(scene_path).instantiate()
	if previous_scene:
		#if "disable_main_camera" in previous_scene:
		#	previous_scene.disable_main_camera()

		previous_scene.queue_free()
	$Scenes.add_child(new_scene)
	
	# TODO: Just add special handling in general for in_game?
	# As in don't just use "enable_main_camera" to detect it
	if "load_level" in new_scene:
		new_scene.load_level(level_id)
	
	# Reset "camera" as in viewport location just in case
	# the scene we just switched to doesn't have a camera
	var viewport = get_viewport()
	viewport.canvas_transform = Transform2D.IDENTITY

func _new_game_pressed():
	_switch_scene(LEVEL_SELECTOR_PATH, null)
	
func _try_again_pressed():
	_switch_scene(IN_GAME_PATH, $Scenes.get_child(0).get_current_level_id())

func _level_change_pressed(level_id):
	_switch_scene(IN_GAME_PATH, level_id)

func _profile_manager_pressed():
	_switch_scene(PROFILE_MANAGER_PATH, null)

func _main_menu_pressed():
	_switch_scene(MAIN_MENU, null)

func _next_level_pressed():
	var next_level = Levels.get_next_level($Scenes.get_child(0).get_current_level_id())
	if next_level != null:
		_switch_scene(IN_GAME_PATH, next_level.get("id"))

func _first_time_player_added(_player_id):
	_switch_scene(MAIN_MENU, null)
