extends AudioStreamPlayer

func is_enabled():
	return Profiles.get_current_settings().get_value(Settings.SV_SFX_UI_ENABLED)

func set_volume(value):
	volume_db = linear2db(clamp(value / 100, 0.0, 1.0))

func play_cb(toggled):
	if is_enabled():
		if !toggled:
			stream = preload("res://sounds/ui/cb0.wav")
		else:
			stream = preload("res://sounds/ui/cb1.wav")
		play()

func play_rb():
	if is_enabled():
		stream = preload("res://sounds/ui/rb.wav")
		play()
	
func play_big_btn():
	if is_enabled():
		stream = preload("res://sounds/ui/click.wav")
		play()

func play_widget(widget_type):
	return
	if is_enabled():
		stream = preload("res://sounds/ui/widget_click.wav")
		play()

func play_alert():
	if is_enabled():
		stream = preload("res://sounds/ui/alert.wav")
		play()
		
func play_server_connection_established():
	if is_enabled():
		stream = preload("res://sounds/ui/server_connection_established.wav")
		play()

func play_server_connection_failed():
	if is_enabled():
		stream = preload("res://sounds/ui/server_connection_failed.wav")
		play()
		
func _ready():
	pass
