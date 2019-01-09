extends "res://scripts/ui/FadeElement.gd"

signal done

var result = -1

func _ready():
	connect("done", self, "beautiful_hide")
	UI.add_theme_element(self)
	rect_scale = UI.scale
	rect_position.x = ((UI.get_real_resolution().x / 2.0) - (rect_size.x * UI.scale.x / 2.0))
	rect_position.y = ((UI.get_real_resolution().y / 2.0) - (rect_size.y * UI.scale.y / 2.0))
	
func apply_theme(theme):
	self.theme = theme

func _on_BTN_OBSERVE_pressed():
	yield(beautiful_hide(), "fade_completed")
