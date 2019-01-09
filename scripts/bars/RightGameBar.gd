extends "res://scripts/ui/FloatElement.gd"

func _ready():
	UI.register_widgetbar(self)
	UI.game_right_bar = self
	rect_scale = UI.scale
	rect_position.x = (1920 * UI.scale.x)
	rect_position.y = 128 * UI.scale.y
	setup()

func apply_theme(theme):
	self.theme = theme
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))

func _on_RightHideWidget_pressed():
	yield(beautiful_hide(), "fade_completed")
	get_parent().get_node("RightGameHideBar").beautiful_show()
	UI.rightbar_was_visible = false
	UI.get_game().update_history_panel_position(false)