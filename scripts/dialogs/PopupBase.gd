extends "res://scripts/ui/FadeElement.gd"

# PopupBase.gd

var self_destruct = false

signal destroyed

func _ready():
	UI.add_theme_element(self)
	rect_scale = UI.scale
	self_modulate.a = 0.88
	hide()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		UI.remove_theme_element(self) 
	
func apply_theme(theme):
	self.theme = theme

func destroy():
	emit_signal("destroyed")
	if self_destruct:
		yield(beautiful_hide(), "hide_completed")
		queue_free()
	else:	
		beautiful_hide()

func update_position():
	rect_position.x = ((UI.get_real_resolution().x / 2.0) - (rect_size.x * UI.scale.x / 2.0))
	rect_position.y = (((UI.get_real_resolution().y + 128) / 2.0) - (rect_size.y * UI.scale.y / 2.0))
	
func _physics_process(_delta):
	if visible:
		update_position()