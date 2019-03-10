extends Spatial

# GameCamera.gd

export(float) var angle_y := 0.0

onready var camera = $Camera

onready var reset_tween = $ResetTween

onready var flip_tween = $FlipTween

onready var zoom_tween = $ZoomTween

const ROTATE_LIMIT_X = 1.5

const ROTATE_LIMIT_Y = PI/2

const FLIP_TIME = 0.5 # seconds

const RESET_TIME = 0.5 # seconds

const SMOOTH_SPEED = 15.0

var startup_translation

var startup_rotation

var startup_scale

func stop_tweens():
	reset_tween.stop_all()
	flip_tween.stop_all()
	zoom_tween.stop_all()

func pitch(angle : float, delta : float) -> void:
	rotation.x = clamp(rotation.x + angle * delta, 0.0, ROTATE_LIMIT_X)

func yaw(angle : float, lock : bool, delta : float) -> void:
	if lock:
		rotation.y = clamp(rotation.y + angle * delta, -ROTATE_LIMIT_Y - startup_rotation.y, ROTATE_LIMIT_Y - startup_rotation.y)
	else:
		rotation.y = wrapf(rotation.y + angle * delta, 0.0, TAU)

func zoom(s, lim_min, lim_max, delta):
	var new_scale = scale
	new_scale += Vector3(s, s, s)
	new_scale.x = clamp(new_scale.x, lim_min, lim_max)
	new_scale.y = clamp(new_scale.y, lim_min, lim_max)
	new_scale.z = clamp(new_scale.z, lim_min, lim_max)
	
#	if Profiles.get_value(Settings.SV_CAMERA_SMOOTH_ENABLED):
#		if zoom_tween.interpolate_property (
#			self, "scale", 
#			scale, 
#			new_scale,
#			300.0 * delta,
#			Tween.TRANS_EXPO,
#			Tween.EASE_OUT):
#			zoom_tween.start()
#	else:
	scale = new_scale

func flip(target : float) -> void:
	if Profiles.get_value(Settings.SV_CAMERA_SMOOTH_ENABLED):
		flip_tween.interpolate_property (
			self, "rotation:y",
			rotation.y, 
			target,
			FLIP_TIME,
			Tween.TRANS_QUART,
			Tween.EASE_OUT)
		flip_tween.start()
	else:
		rotation.y = target
	
func reset():
	zoom_tween.stop_all()
	
	if Profiles.get_value(Settings.SV_CAMERA_SMOOTH_ENABLED):
		reset_tween.interpolate_property (
			self, "translation", 
			translation, 
			startup_translation,
			RESET_TIME,
			Tween.TRANS_QUART,
			Tween.EASE_OUT)
		reset_tween.interpolate_property (
			self, "rotation", 
			rotation, 
			startup_rotation,
			RESET_TIME,
			Tween.TRANS_QUART,
			Tween.EASE_OUT)
		reset_tween.interpolate_property (
			self, "scale", 
			scale, 
			startup_scale,
			RESET_TIME,
			Tween.TRANS_QUART,
			Tween.EASE_OUT)
		reset_tween.start()
	else:
		translation = startup_translation
		rotation = startup_rotation
		scale = startup_scale

func make_current():
	camera.make_current()
	
func _ready():
	rotation.y = deg2rad(angle_y)
	
	startup_translation = translation
	startup_rotation = rotation
	startup_scale = scale

