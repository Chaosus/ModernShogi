extends "res://scripts/UIScreen.gd"

# FirstScreen.gd

var language = Settings.Language.ENGLISH

func _ready():
	self.title = "GAME_TITLE"
	$FirstScreenBox.rect_scale = UI.scale
	$FirstScreenBox.rect_position.x = ((UI.get_real_resolution().x / 2.0) - ($FirstScreenBox.rect_size.x * UI.scale.x / 2.0))
	$FirstScreenBox.rect_position.y = ((UI.get_real_resolution().y / 2.0) - ($FirstScreenBox.rect_size.y * UI.scale.y / 2.0))
	
func show_itself(immediate = false):
	UI.get_widget(UI.WIDGET_BACKBTN).visible = false
	UI.get_widget(UI.WIDGET_SETTINGS).visible = false
	$FirstScreenBox.beautiful_show()
	return .show_itself(immediate)

func apply_and_continue():
	Profiles.get_current_settings().set_value(Settings.SV_UI_LANGUAGE, language)
	UI.get_named_element(UI.LE_PROFILE_NAME).text = $FirstScreenBox/VBox/DescriptionsList/HBoxUsername/UsernameLE.text
	$FirstScreenBox.beautiful_hide()
	goto_screen(UI.SCREEN_MAIN_MENU, false)
	
func _on_LanguageENRadioButton_pressed():
	UI.apply_language(Settings.Language.ENGLISH)
	language = Settings.Language.ENGLISH
	UI.get_named_element(UI.RB_UI_LANGUAGE_ENGLISH).pressed = true
	
func _on_LanguageRURadioButton_pressed():
	UI.apply_language(Settings.Language.RUSSIAN)
	language = Settings.Language.RUSSIAN
	UI.get_named_element(UI.RB_UI_LANGUAGE_RUSSIAN).pressed = true

func _on_UsernameLE_text_changed(new_text):
	Profiles.get_current_profile().nickname = new_text
	if new_text.length() > 0:
		$FirstScreenBox/VBox/ContinueButton.disabled = false
	else:
		$FirstScreenBox/VBox/ContinueButton.disabled = true
	
func _on_ContinueButton_pressed():
	apply_and_continue()


