extends "res://scripts/UIScreen.gd"

func _ready():
	self.title = "FIRST_INIT"

func _on_NewProfileBtn_pressed():
	goto_screen(Globals.SCREEN_CREATE_PROFILE)
	
func _on_GuestBtn_pressed():
	goto_screen(Globals.SCREEN_MAIN_MENU)
