extends "res://scripts/UIScreen.gd"

onready var country_btn = $"VBox/Grid/VBox/GridOptional/VBox4/HBox/CountryBtn"
onready var country_label =  $"VBox/Grid/VBox/GridOptional/VBox4/HBox/CountryLabel"

onready var input_nickname = get_node("VBox/Grid/VBox/HBox/Grid/VBox2/NicknameInput")
onready var input_password = get_node("VBox/Grid/VBox/HBox/Grid/VBox2/PasswordInput")

func _ready():
	self.title = "TITLE_CREATE_NEW_PROFILE"
	UI.register_country_button(country_btn)
	UI.register_country_label(country_label)

func _on_CountryBtn_pressed():
	goto_screen(Globals.SCREEN_SELECT_COUNTRY)

func _on_AcceptBtn_pressed():
	var temp_profile = Profiles.get_temp_profile()
	temp_profile.nickname = input_nickname.text
	temp_profile.password = input_password.text
