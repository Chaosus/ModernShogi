extends "res://scripts/UIScreen.gd"

const MASTER = 3

var loading = false

var last_username
var last_password
var last_email
var last_age
var last_firstname
var last_lastname
var last_country
var last_city
var last_desc

onready var save_popup = $SaveProfileMenuPopup
onready var avatar_control = $HBox/VBox/HBox/Avatar
onready var username_control = $HBox/VBox/HBox/VBox/HBoxUsername/LE_USERNAME
onready var password_control = $HBox/VBox/HBox/VBox/HBoxPassword/LE_PASSWORD
onready var email_control = $HBox/VBox/HBox/VBox/HBoxEMail/LE_EMAIL
onready var age_cb = $HBox/VBox/GridContainer/VBox/HBoxAge/CB_PROFILE_AGE
onready var age_control = $HBox/VBox/GridContainer/VBox/HBoxAge/SB_PROFILE_AGE
onready var firstname_control = $HBox/VBox/GridContainer/VBox/HBoxFirstName/LE_FIRST_NAME
onready var lastname_control = $HBox/VBox/GridContainer/VBox/HBoxLastName/LE_LAST_NAME
onready var country_control = $HBox/VBox/HBox/VBox2/HBoxCountry/VBox/BTN_COUNTRY
onready var country_label = $HBox/VBox/HBox/VBox2/HBoxCountry/VBox/LABEL_COUNTRY_INPUT
onready var city_control = $HBox/VBox/GridContainer/VBox/HBoxCity/LE_CITY
onready var desc_control = $HBox/VBox/GridContainer/VBox/HBoxProfileDescription/LE_PROFILE_DESCRIPTION

onready var avatar_changed_control = $SaveProfileMenuPopup/VBox/LABEL_AVATAR_CHANGED
onready var username_changed_control = $SaveProfileMenuPopup/VBox/LABEL_USERNAME_CHANGED
onready var password_changed_control = $SaveProfileMenuPopup/VBox/LABEL_PASSWORD_CHANGED
onready var email_changed_control = $SaveProfileMenuPopup/VBox/LABEL_EMAIL_CHANGED
onready var country_changed_control = $SaveProfileMenuPopup/VBox/LABEL_COUNTRY_CHANGED
onready var city_changed_control = $SaveProfileMenuPopup/VBox/LABEL_CITY_CHANGED
onready var age_changed_control = $SaveProfileMenuPopup/VBox/LABEL_AGE_CHANGED
onready var gender_changed_control = $SaveProfileMenuPopup/VBox/LABEL_GENDER_CHANGED
onready var firstname_changed_control = $SaveProfileMenuPopup/VBox/LABEL_FIRSTNAME_CHANGED
onready var lastname_changed_control = $SaveProfileMenuPopup/VBox/LABEL_LASTNAME_CHANGED
onready var desc_changed_control = $SaveProfileMenuPopup/VBox/LABEL_DESCRIPTION_CHANGED

func _ready():
	self.title = "TITLE_PROFILE_VIEW"
	
func send_data(privilegy, username, password, email, age, gender, firstname, lastname, country, city, description, status):
	
	var is_master =  privilegy == MASTER
		
	username_control.text = username
	username_control.editable = is_master
	
	if is_master:
		if password != null:
			password_control.visible = true
			password_control.text = password
			password_control.editable = true
		else:
			password_control.visible = false
		if email != null:
			email_control.visible = true
			email_control.text = email
			email_control.editable = true
		else:
			email_control.visible = false
		if gender == 0:
			$HBox/VBox/GridContainer/VBox/HBoxGender/RB_PROFILE_GENDER_UNSPECIFIED.pressed = true
		elif gender == 1:
			$HBox/VBox/GridContainer/VBox/HBoxGender/RB_PROFILE_GENDER_MALE.pressed = true
		elif gender == 2:
			$HBox/VBox/GridContainer/VBox/HBoxGender/RB_PROFILE_GENDER_FEMALE.pressed = true
	else:
		password_control.visible = false
		email_control.visible = false
	
	if age > 0:
		age_control.visible = true
		age_control.value = age
		age_cb.pressed = false
	else:
		age_control.visible = false
		age_cb.pressed = true
	
	age_control.editable = is_master
	
	firstname_control.visible = true
	lastname_control.visible = true
	firstname_control.text = firstname
	lastname_control.text = lastname
	firstname_control.editable = is_master
	lastname_control.editable = is_master
	
	UI.country_tag = country
	country_control.texture_normal = UI.country_list[country].texture
	country_label.text = UI.country_list[country].tag
	
	city_control.text = city
	city_control.editable = is_master
	
	#desc_control.text = description
	#desc_control.readonly = !is_master
	
	
	last_username = username
	last_password = password
	last_email = email
	last_age = age
	last_firstname = firstname
	last_lastname = lastname
	last_country = country
	last_city = city
	
	UI.register_country_button(country_control)
	UI.register_country_label(country_label)

func beautiful_show():
	.beautiful_show()

func _clear_labels():
	avatar_changed_control.hide()
	username_changed_control.hide()
	password_changed_control.hide()
	email_changed_control.hide()
	country_changed_control.hide()
	city_changed_control.hide()
	age_changed_control.hide()
	gender_changed_control.hide()
	firstname_changed_control.hide()
	lastname_changed_control.hide()
	desc_changed_control.hide()

func _restore():
	username_control.text = last_username
	password_control.text = last_password
	email_control.text = last_email
	firstname_control.text = last_firstname
	lastname_control.text = last_lastname
	city_control.text = last_city

func _on_BTN_QUIT_YES_pressed():	
	save_popup.hide()
	_clear_labels()
	.go_back_if_possible()
	
func _on_BTN_QUIT_NO_pressed():
	save_popup.hide()
	_clear_labels()
	_restore()
	.go_back_if_possible()

func _on_BTN_CANCEL_pressed():
	save_popup.hide()

func go_back_if_possible():
	var changed = false
	if last_username != username_control.text:
		username_changed_control.show()
		changed = true
	if last_password != password_control.text:
		password_changed_control.show()
		changed = true
	if last_email != email_control.text:
		email_changed_control.show()
		changed = true
	var age = age_control.value
	if age_cb.pressed:
		age = 0
	if last_age != age:
		age_changed_control.show()
		changed = true
	if last_firstname != firstname_control.text:
		firstname_changed_control.show()
		changed = true
	if last_lastname != lastname_control.text:
		lastname_changed_control.show()
		changed = true
	if last_country != UI.get_country_tag():
		country_changed_control.show()
		changed = true
	if last_city != city_control.text:
		city_changed_control.show()
		changed = true
			
	if changed:
		save_popup.show()
	else:
		.go_back_if_possible()

# Avatar

func _on_Avatar_pressed():
	goto_screen(UI.SCREEN_SELECT_AVATAR)
	
func _on_Avatar_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_AVATAR"), avatar_control)
	
func _on_Avatar_focus_exited():
	UI.get_helper().hide_tooltip()
	
func _on_Avatar_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_AVATAR"), avatar_control)

func _on_Avatar_mouse_exited():
	UI.get_helper().hide_tooltip()

# Nickname

func _on_LE_PROFILE_NICKNAME_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_USERNAME"), username_control)

func _on_LE_PROFILE_NICKNAME_focus_exited():
	UI.get_helper().hide_tooltip()

func _on_LE_PROFILE_NICKNAME_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_USERNAME"), username_control)

func _on_LE_PROFILE_NICKNAME_mouse_exited():
	UI.get_helper().hide_tooltip()

# Age

func _on_CB_PROFILE_AGE_toggled(toggled):
	if toggled:
		age_control.hide()
	else:
		age_control.show()

# First Name

func _on_LE_PROFILE_FIRST_NAME_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_FIRSTNAME"), firstname_control)

func _on_LE_PROFILE_FIRST_NAME_focus_exited():
	UI.get_helper().hide_tooltip()

func _on_LE_PROFILE_FIRST_NAME_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_FIRSTNAME"), firstname_control)

func _on_LE_PROFILE_FIRST_NAME_mouse_exited():
	UI.get_helper().hide_tooltip()

# Last Name

func _on_LE_PROFILE_LAST_NAME_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_LASTNAME"), lastname_control)

func _on_LE_PROFILE_LAST_NAME_focus_exited():
	UI.get_helper().hide_tooltip()

func _on_LE_PROFILE_LAST_NAME_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_LASTNAME"), lastname_control)

func _on_LE_PROFILE_LAST_NAME_mouse_exited():
	UI.get_helper().hide_tooltip()

# Country

func _on_BTN_COUNTRY_focus_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_COUNTRY"), country_control)

func _on_BTN_COUNTRY_focus_exited():
	UI.get_helper().hide_tooltip()

func _on_BTN_COUNTRY_mouse_entered():
	UI.get_helper().show_tooltip_unaligned(TranslationServer.translate("DESC_INPUT_MP_COUNTRY"), country_control)

func _on_BTN_COUNTRY_mouse_exited():
	UI.get_helper().hide_tooltip()

func _on_BTN_COUNTRY_pressed():
	goto_screen(UI.SCREEN_SELECT_COUNTRY)