extends Control

# HelpElement.gd

export(bool) var tooltip_enabled = false

export(int, "LeftAlign", "CenterAlign", "RightAlign", "TopLeftAlign", "TopRightAlign") var tooltip_align = 0

export(String) var tooltip

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
		
func _on_mouse_entered():
	if tooltip_align == 0:
		UI.get_helper().show_tooltip_left(tooltip, self)
	elif tooltip_align == 1:
		UI.get_helper().show_tooltip_centered(tooltip, self)
	elif tooltip_align == 2:
		UI.get_helper().show_tooltip_right(tooltip, self)
	elif tooltip_align == 3:
		UI.get_helper().show_tooltip_left_top(tooltip, self)
	elif tooltip_align == 4:
		UI.get_helper().show_tooltip_right_top(tooltip, self)

func _on_mouse_exited():
	UI.get_helper().hide_tooltip()
