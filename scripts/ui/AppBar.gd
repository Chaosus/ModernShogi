extends "res://scripts/ui/FadeElement.gd"
 
###################################################################
#														AppBar.gd
###################################################################

func _ready():
	UI.register_widgetbar(self)
	
func apply_theme(theme):
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))
