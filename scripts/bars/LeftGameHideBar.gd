extends "res://scripts/ui/FadeElement.gd"

func _ready():
	UI.game_left_hbar = self
	rect_scale = UI.scale
	rect_position.y = 128 * UI.scale.y
	
func _on_LeftShowWidget_pressed():
	yield(beautiful_hide(), "fade_completed")
	
	var bar
	if UI.game_left_bar_mode == 0:
		bar = UI.game_left_bar_m0
	elif UI.game_left_bar_mode == 1:
		bar = UI.game_left_bar_m1
	bar.rect_min_size.y *= UI.scale.y
	bar.rect_size.y = rect_min_size.y
	bar.beautiful_show()
	UI.leftbar_was_visible = true
	UI.get_game().gui.ai_log_panel.rect_position.x = 142
	UI.get_game().gui.piece_style_panel.rect_position.x = 142
