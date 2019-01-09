# Licensed under the MIT License.
# Copyright (c) 2018 Jaccomo Lorenz (Maujoe)
# Modified by Yuri Roubinski

extends Camera

export(int, "Visible", "Hidden", "Captured", "Confined") var mouse_mode = 0
var enabled setget set_enabled, get_enabled
export (float, 0.0, 0.999, 0.001) var smoothness = 0.1 setget set_smoothness
export(NodePath) var privot setget set_privot
export var distance = 5.0 setget set_distance
export var rotate_privot = false
export var collisions = true setget set_collisions

var yaw_limit = 360
var pitch_limit = 90

# Movement settings
var speed = 15
var forward_action = "rotate_camera_forward"
var backward_action = "rotate_camera_backward"
var left_action = "rotate_camera_left"
var right_action = "rotate_camera_right"

# Intern variables.
var _direction = Vector3(0.0, 0.0, 0.0)
var _mouse_position = Vector2(0.0, 0.0)
var _yaw = 0.0
var _pitch = 0.0
var _total_yaw = 0.0
var _total_pitch = 0.0

var _start_position
var _start_rotation

func _ready():
	
	_start_position = translation
	_start_rotation = rotation
	
	_check_actions([forward_action, backward_action, left_action, right_action])

	if privot:
		privot = get_node(privot)
	else:
		privot = null
		
	set_enabled(false)

# Сбрасывает позицию и вращение камеры
func reset():
	_yaw = 0
	_pitch = 0
	_total_yaw = 0
	_total_pitch = 0
	translation = _start_position
	rotation = _start_rotation

func _input(event):
	if event is InputEventMouseMotion:
		_mouse_position = get_viewport().get_mouse_position()
		
	if event.is_action_pressed(forward_action):
		_direction.z = -1
	elif event.is_action_pressed(backward_action):
		_direction.z = 1
	elif not Input.is_action_pressed(forward_action) and not Input.is_action_pressed(backward_action):
		_direction.z = 0

	if event.is_action_pressed(left_action):
		_direction.x = -1
	elif event.is_action_pressed(right_action):
		_direction.x = 1
	elif not Input.is_action_pressed(left_action) and not Input.is_action_pressed(right_action):
		_direction.x = 0

func _physics_process(delta):
	
	if privot:
		_update_distance()
	_update_mouselook()
	
	translate(_direction * speed * delta)

func _update_mouselook():
	
	var center = UI.screen_center
	
	_yaw = (_mouse_position.x - center.x) * 0.25
	_pitch = (_mouse_position.y - center.y) * 0.25
	_mouse_position = center
	get_viewport().warp_mouse(center)
	
	
	if yaw_limit < 360:
		_yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
	if pitch_limit < 360:
		_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)

	_total_yaw += _yaw
	_total_pitch += _pitch

	if privot:
		var target = privot.get_translation()
		var offset = get_translation().distance_to(target)

		set_translation(target)
		rotate_y(deg2rad(-_yaw))
		rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))
		translate(Vector3(0.0, 0.0, offset))

		if rotate_privot:
			privot.rotate_y(deg2rad(-_yaw))
	else:
		rotate_y(deg2rad(-_yaw))
		rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))

func _update_distance():
	var t = privot.get_translation()
	t.z -= distance
	set_translation(t)



func _check_actions(actions=[]):
	if OS.is_debug_build():
		for action in actions:
			if not InputMap.has_action(action):
				print('WARNING: No action "' + action + '"')

func set_privot(value):
	privot = value
	# TODO: fix parenting.
#	if privot:
#		if get_parent():
#			get_parent().remove_child(self)
#		privot.add_child(self)

func set_collisions(value):
	collisions = value

func set_enabled(enabled):
	if !enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		set_process_input(false)
		set_process(false)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		set_process_input(true)
		set_process(true)

func get_enabled():
	return enabled

func set_smoothness(value):
	smoothness = clamp(value, 0.001, 0.999)

func set_distance(value):
	distance = max(0, value)
