extends TextureRect

# WidgetIcon.gd

export(bool) var selection_enabled = false
export(bool) var tooltip_enabled = false

export(String) var tooltip

var color_mask_normal = Color(1, 1, 1)
var color_mask_hover = Color(0.5, 0.5, 0.5)
var color_mask_pressed = Color(0.5, 0.5, 0.5)

func _ready():
	UI.add_theme_element(self)
	if selection_enabled:
		connect("mouse_entered", self, "_on_mouse_entered")
		connect("mouse_exited", self, "_on_mouse_exited")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		UI.remove_theme_element(self)

func apply_theme(theme):
	color_mask_normal = theme.get_color("element_color", "Main")
	color_mask_hover = theme.get_color("element_hover_color", "Main")
	color_mask_pressed = theme.get_color("element_pressed_color", "Main")
	modulate = color_mask_normal
		
func _on_mouse_entered():
	if tooltip_enabled:
		UI.get_helper().show_tooltip_unaligned(tooltip, self)
	modulate = color_mask_hover

func _on_mouse_exited():
	if tooltip_enabled:
		UI.get_helper().hide_tooltip()
	modulate = color_mask_normal
