extends "res://scripts/ui/FadeElement.gd"

func _ready():
	UI.game_right_hbar = self
	rect_scale = UI.scale
	rect_position.x = (1920 - 142) * UI.scale.x
	rect_position.y = 128 * UI.scale.y
	setup()
	
func _on_RightShowWidget_pressed():
	yield(beautiful_hide(), "fade_completed")
	get_parent().get_node("RightGameBar").beautiful_show()
	UI.rightbar_was_visible = true
	UI.get_game().update_history_panel_position(true)