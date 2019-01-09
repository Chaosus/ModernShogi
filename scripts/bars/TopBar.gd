extends "res://scripts/ui/FloatElement.gd"

onready var title = $Title

func _ready():
	UI.topbar = self
	UI.register_widgetbar(self)

func apply_theme(theme):
	self.theme = theme
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))

func _on_HideTopPanelButton_pressed():
	yield(beautiful_hide(), "fade_completed")
	get_node("../TopHBar").beautiful_show()
	UI.topbar_was_visible = false
