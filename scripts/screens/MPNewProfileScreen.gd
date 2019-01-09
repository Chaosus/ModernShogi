extends "res://scripts/UIScreen.gd"

var temp_profile
var dont_use_age = true

onready var username_control = $ScrollBox/ProfileSettings/HBoxNickname/LE_PROFILE_USERNAME
onready var password_control = $ScrollBox/ProfileSettings/HBoxPassword/LE_PROFILE_PASSWORD
onready var email_control = $ScrollBox/ProfileSettings/HBoxEMail/LE_PROFILE_EMAIL
onready var age_control = $ScrollBox/ProfileSettings/HBoxAge/SB_PROFILE_AGE
onready var country_btn = $ScrollBox/ProfileSettings/HBoxCountry/BTN_COUNTRY
onready var country_label = $ScrollBox/ProfileSettings/HBoxCountry/LABEL_COUNTRY

func _ready():
	self.title = "TITLE_CREATE_NEW_PROFILE"
	UI.register_named_element(UI.SCREEN_MP_CREATE_PROFILE, self)
	country_label.text = "CY_UNKNOWN"
	temp_profile = Profiles.create_temp_profile()

func goto_loading():
	goto_screen(UI.SCREEN_LOADING)

func _on_LE_PROFILE_NICKNAME_text_changed(new_text):
	temp_profile.nickname = new_text

func _on_LE_PROFILE_PASSWORD_text_changed(new_text):
	temp_profile.password = new_text

func _on_LE_PROFILE_EMAIL_text_changed(new_text):
	temp_profile.email = new_text

func _on_SB_PROFILE_AGE_value_changed(new_value):
	temp_profile.age = int(new_value)

func _on_RB_PROFILE_GENDER_UNSPECIFIED_pressed():
	temp_profile.gender = Profiles.GENDER_UNKNOWN

func _on_RB_PROFILE_GENDER_MALE_pressed():
	temp_profile.gender = Profiles.GENDER_MALE

func _on_RB_PROFILE_GENDER_FEMALE_pressed():
	temp_profile.gender = Profiles.GENDER_FEMALE

func _on_LE_PROFILE_FIRST_NAME_text_changed(new_text):
	temp_profile.first_name = new_text

func _on_LE_PROFILE_LAST_NAME_text_changed(new_text):
	temp_profile.last_name = new_text

func _on_CB_PROFILE_SECURITY_NAME_USAGE_toggled(toggle):
	temp_profile.protection = 1 if toggle == true else 0

func _on_BTN_COUNTRY_pressed():
	goto_screen(UI.SCREEN_SELECT_COUNTRY)

func _on_LE_PROFILE_CITY_text_changed(new_text):
	temp_profile.city = new_text

func _on_MPNewProfileScreen_visibility_changed():
	if visible:
		previous_screen = UI.get_named_element(UI.SCREEN_MP_ENTER)
		UI.register_country_button(country_btn)
		UI.register_country_label(country_label)
		
func _on_BTN_SIGNUP_pressed():
	temp_profile.country = UI.get_country_tag()
	var c = temp_profile.country
	if dont_use_age:
		temp_profile.age = 0
	UI.get_root().signup(temp_profile)

# Username description processing

func _on_LE_PROFILE_NICKNAME_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_USERNAME"), username_control)
func _on_LE_PROFILE_NICKNAME_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_USERNAME"), username_control)
func _on_LE_PROFILE_NICKNAME_mouse_exited():
	UI.get_helper().hide_tooltip()
func _on_LE_PROFILE_NICKNAME_focus_exited():
	UI.get_helper().hide_tooltip()

# Password description processing

func _on_LE_PROFILE_PASSWORD_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_PASSWORD"), password_control)
func _on_LE_PROFILE_PASSWORD_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_PASSWORD"), password_control)
func _on_LE_PROFILE_PASSWORD_focus_exited():
	UI.get_helper().hide_tooltip()
func _on_LE_PROFILE_PASSWORD_mouse_exited():
	UI.get_helper().hide_tooltip()

# EMail description processing

func _on_LE_PROFILE_EMAIL_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_EMAIL"), email_control)
func _on_LE_PROFILE_EMAIL_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_EMAIL"), email_control)
func _on_LE_PROFILE_EMAIL_focus_exited():
	UI.get_helper().hide_tooltip()
func _on_LE_PROFILE_EMAIL_mouse_exited():
	UI.get_helper().hide_tooltip()

# Country description processing

func _on_BTN_COUNTRY_focus_entered():
	UI.get_helper().show_tooltip(TranslationServer.translate("DESC_INPUT_COUNTRY"), country_btn)
func _on_BTN_COUNTRY_mouse_entered():
	UI.get_helper().show_tooltip(TranslationServer.translate("DESC_INPUT_COUNTRY"), country_btn)
func _on_BTN_COUNTRY_focus_exited():
	UI.get_helper().hide_tooltip()
func _on_BTN_COUNTRY_mouse_exited():
	UI.get_helper().hide_tooltip()

# Other

func _on_CB_NOAGE_toggled(toggle):
	if !toggle:
		age_control.show()
		dont_use_age = false
	else:
		age_control.hide()
		dont_use_age = true
