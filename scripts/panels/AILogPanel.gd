extends "res://scripts/ui/FadeElement.gd"

onready var sbox = $ScrollContainer
onready var console = $ScrollContainer/VBox

func _ready():
	UI.register_widgetbar(self)
	UI.ai_log_panel = self
	
func clear():
	var childs = console.get_children()
	for c in childs:
		console.remove_child(c)

func apply_theme(theme):
	self.theme = theme
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))
	
func has_focus():
	if visible:
		return Rect2(rect_position, rect_size * rect_scale).has_point(get_viewport().get_mouse_position())
	return false