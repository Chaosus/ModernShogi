extends "res://scripts/UIScreen.gd"

func _ready():
	self.title = "GAME_TITLE"
	
func _on_BTN_YES_pressed():
	yield(UI.topbar.beautiful_hide(), "fade_completed")
	goto_screen(UI.SCREEN_GOODBAY)

func _on_BTN_NO_pressed():
	go_back_if_possible()
