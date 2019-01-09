extends "res://scripts/UIScreen.gd"

#################################################################
#													MPEnterScreen.gd
#################################################################

func _ready():
	self.title = "GAME_TITLE"
	
func go_back_if_possible():
	var mp = UI.get_root().mp
	if mp.IsWorking():
		return
	mp.Close()
	previous_screen = UI.get_named_element(UI.SCREEN_MAIN_MENU)
	.go_back_if_possible()

func goto_loading():
	goto_screen(UI.SCREEN_LOADING)

func _on_BTN_MP_ENTER_pressed():
	var nickname = $VBox/HBoxNickname/LE_MP_ENTER_NICKNAME.text
	var password = $VBox/HBoxPassword/LE_MP_ENTER_PASSWORD.text
	
	UI.get_root().login(nickname, password)
	
	Profiles.get_current_profile().nickname = nickname
	Profiles.get_current_profile().password = password

func _on_BTN_MP_REGISTER_pressed():
	 goto_screen(UI.SCREEN_MP_TERMS)

func enable():
	
	UI.set_current_screen(self)
	previous_screen = UI.get_screen(UI.SCREEN_MAIN_MENU)
	UI.show_back_btn()
	.enable()

func _on_MPEnterScreen_visibility_changed():
	if visible:
		$VBox/HBoxNickname/LE_MP_ENTER_NICKNAME.text = Profiles.get_current_profile().nickname
		$VBox/HBoxPassword/LE_MP_ENTER_PASSWORD.text = Profiles.get_current_profile().password
