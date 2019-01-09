extends "res://scripts/ui/FloatElement.gd"

export var mode = 0

func _ready():
	UI.register_widgetbar(self)
	if mode == 0:
		UI.game_left_bar_m0 = self
	elif mode == 1:
		UI.game_left_bar_m1 = self
	rect_scale = UI.scale
	$VBox/Offset.size_flags_vertical = VBoxContainer.SIZE_EXPAND
	rect_position.x = -142 * UI.scale.x
	rect_position.y = 128 * UI.scale.y
	setup()
	
func apply_theme(theme):
	self.theme = theme
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))

func _on_LeftHideButton_pressed():
	yield(beautiful_hide(), "fade_completed")
	get_parent().get_node("LeftGameHideBar").beautiful_show()
	UI.get_game().gui.ai_log_panel.rect_position.x = 0
	UI.get_game().gui.piece_style_panel.rect_position.x = 0
	UI.leftbar_was_visible = false

func _on_SwitchModeButton_pressed():
	if mode == 0:
		UI.ai_log_hidden = UI.get_game().gui.ai_log_panel.get_show_state() == BeautyElement.ShowState.NONE
		UI.get_game().gui.ai_log_panel.beautiful_hide()
	elif mode == 1:
		UI.piece_style_hidden = UI.get_game().gui.piece_style_panel.get_show_state() == BeautyElement.ShowState.NONE
		UI.get_game().gui.piece_style_panel.beautiful_hide()
	yield(beautiful_hide(), "fade_completed")
	if mode == 0:
		if UI.piece_style_hidden:
			UI.get_game().gui.piece_style_panel.beautiful_show()
		UI.game_left_bar_mode = 1
		yield(UI.game_left_bar_m1.beautiful_show(), "fade_completed")
	elif mode == 1:
		if UI.ai_log_hidden:
			UI.get_game().gui.ai_log_panel.beautiful_show()
		UI.game_left_bar_mode = 0
		yield(UI.game_left_bar_m0.beautiful_show(), "fade_completed")
