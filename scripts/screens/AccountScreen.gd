extends "res://scripts/UIScreen.gd"

# AccountScreen.gd

var state = 0
var country_tag = 0

onready var name_box = $AccountInfoPanel/VBox/HLayout/VLayout/GeneralInfo/VBox/PlayerName/PlayerNameBox
onready var country_box = $AccountInfoPanel/VBox/HLayout/VLayout/GeneralInfo/VBox/CountryName/CountryButton
onready var visit_box = $AccountInfoPanel/VBox/HLayout/VLayout/HBox/Info/PlayerVisits/PlayerVisitsBox

onready var old_password_box = $ChangePasswordPanel/VBox/Layout/VBox/OldPassword/OldPasswordBox
onready var new_password_box = $ChangePasswordPanel/VBox/Layout/VBox/NewPassword/NewPasswordBox

onready var delete_account_password_box = $DeleteAccountPanel/VBox/Layout/VBox/Password/PasswordBox

onready var change_country_box = $ChangePublicDataPanel/VBox/Layout/VBox/Country/CountryButton

func _ready():
	self.title = "MP_PLAYER_INFO"

func setup_account(name, country, rating, win_count, lose_count, draw_count, visit_count):
	name_box.text = name
	country_tag = country
	country_box.texture_normal = UI.get_country_texture(country)
	country_box.tooltip =  UI.get_country_raw_name(country)
	visit_box.text = str(visit_count)
	$AccountInfoPanel.get_node("VBox/HLayout/VLayout/HBox/Info/PlayerRating/PlayerRatingBox").text = str(rating)

func on_accept_change(what):
	match what:
		1: # public data
			show_account_panel_from_public_data()
		2: # password
			yield(UI.call_dialog("LABEL_PASSWORD_WAS_CHANGED"), "ok_pressed")
			Profiles.set_value(Settings.SV_MP_PASSWORD, new_password_box.text)
			UI.get_named_element(UI.LE_MP_PASSWORD).text = new_password_box.text
			show_account_panel_from_password()
		100: # delete account
			Profiles.set_value(Settings.SV_MP_PASSWORD, "")
			UI.get_named_element(UI.LE_MP_PASSWORD).text = ""
			Profiles.set_value(Settings.SV_MP_SIGNED, false)
			$DeleteAccountPanel.beautiful_hide()
			UI.call_dialog("LABEL_YOUR_ACCOUNT_WAS_DELETED")
			Network.disconnect_if_connected()
			return goto_screen(UI.SCREEN_MAIN_MENU)
	
func on_decline_change(what, reason):
	match reason:
		5: # DeclineArg.UserNotExist
			UI.call_dialog("LABEL_USER_NOT_FOUND")
		10: # DeclineArg.PasswordIsIncorrect
			UI.call_dialog("LABEL_OLD_PASSWORD_WAS_INCORRECT")
		12: # DeclineArg.MalformedPasswordData
			UI.call_dialog("MP_PASSWORD_MALFORMED")
			
func go_back_if_possible():
	if state == 0:
		$AccountInfoPanel.beautiful_hide()
		$ChangePasswordPanel.beautiful_hide()
		return .go_back_if_possible()
	elif state == 1:
		show_account_panel_from_public_data()
	elif state == 2:
		show_account_panel_from_password()
	elif state == 100:
		show_account_panel_from_delete_account()

func _on_BackButton_pressed():
	go_back_if_possible()

func _on_AccountScreen_show_completed():
	if state == 1:
		$ChangePublicDataPanel.beautiful_show()
	else:
		$AccountInfoPanel.beautiful_show()

func _on_ChangePublicDataButton_pressed():
	state = 1
	change_country_box.texture_normal = UI.get_country_texture(country_tag)
	change_country_box.tooltip = UI.get_country_raw_name(country_tag)
	$AccountInfoPanel.beautiful_hide()
	$ChangePublicDataPanel.beautiful_show()
	
func _on_ChangePasswordButton_pressed():
	state = 2
	old_password_box.text = ""
	new_password_box.text = ""
	$AccountInfoPanel.beautiful_hide()
	$ChangePasswordPanel.beautiful_show()

func _on_DeleteAccountButton_pressed():
	state = 100
	delete_account_password_box.text = ""
	$AccountInfoPanel.beautiful_hide()
	$DeleteAccountPanel.beautiful_show()

func _on_AcceptChangePasswordButton_pressed():
	Network.request_change_password(old_password_box.text, new_password_box.text)

func _on_CancelChangePasswordButton_pressed():
	show_account_panel_from_password()
	
func _on_ShowOldPassword_toggled(toggled):
	old_password_box.secret = !toggled
	
func _on_ShowNewPassword_toggled(toggled):
	new_password_box.secret = !toggled
	
func show_account_panel_from_password():
	state = 0
	$ChangePasswordPanel.beautiful_hide()
	$AccountInfoPanel.beautiful_show()

# Диалог удаления аккаунта

func _on_DeleteAccountShowPassword_toggled(toggled):
	delete_account_password_box.secret = !toggled

func _on_AcceptDeleteAccountButton_pressed():
	Network.delete_yourself(delete_account_password_box.text)

func _on_CancelDeleteAccountButton_pressed():
	show_account_panel_from_delete_account()
	
func show_account_panel_from_delete_account():
	state = 0
	$DeleteAccountPanel.beautiful_hide()
	$AccountInfoPanel.beautiful_show()

# Диалог изменения публичных сведений

func _on_CountryButton_pressed():
	$ChangePublicDataPanel.beautiful_hide()
	UI.register_country_button(change_country_box)
	goto_screen(UI.SCREEN_SELECT_COUNTRY)

func _on_ApplyPublicChangesButton_pressed():
	if country_tag != UI.country_tag:
		Network.request_change_country(UI.country_tag)
		country_tag = UI.country_tag
		country_box.texture_normal = UI.get_country_texture(country_tag)
		country_box.tooltip =  UI.get_country_raw_name(country_tag)
	show_account_panel_from_public_data()

#func _on_PublicChangeButton_pressed():
#	Network.request_change_name()

func _on_PublicChangesCancelButton_pressed():
	show_account_panel_from_public_data()

func show_account_panel_from_public_data():
	state = 0
	$ChangePublicDataPanel.beautiful_hide()
	$AccountInfoPanel.beautiful_show()

