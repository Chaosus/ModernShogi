extends "res://scripts/ui/FadeElement.gd"

func _ready():
	UI.register_widgetbar(self)
	UI.ai_panel = self

func apply_theme(theme):
	self.theme = theme
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))