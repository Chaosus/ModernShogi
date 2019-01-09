extends "res://scripts/ui/FloatElement.gd"

signal done

var result = -1

func _ready():
	connect("done", self, "beautiful_hide")
	UI.add_theme_element(self)
	rect_scale = UI.scale
	rect_position.x = ((UI.get_real_resolution().x / 2.0) - (rect_size.x * UI.scale.x / 2.0))
	rect_position.y = -128
	setup()

func apply_theme(theme):
	self.theme = theme

func _on_UnpromotionBtn_pressed():
	if get_show_state() != ShowState.NONE:
		return
	result = 0
	emit_signal("done")
	
func _on_PromotionBtn_pressed():
	if get_show_state() != ShowState.NONE:
		return
	result = 1
	emit_signal("done")

func _on_PromotionPanel_visibility_changed():
	if visible:
		rect_position.x = ((UI.get_real_resolution().x / 2.0) - (rect_size.x * UI.scale.x / 2.0))
		rect_position.y = -128
		update_x()
		update_y()
		update_end()
