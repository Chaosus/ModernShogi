extends "res://scripts/UIScreen.gd"

var nickname_error = false
var password_error = false

func _ready():
	self.title = "TITLE_PROFILE_CONFIRMATION"
	
func send_data(profile):
	Profiles.save_profile(profile)
	$SuccessBox.beautiful_show()

func _on_MainMenuButton_pressed():
	goto_screen(Globals.SCREEN_MAIN_MENU)