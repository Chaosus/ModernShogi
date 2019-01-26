extends "res://scripts/UIScreen.gd"

# LoginScreen.gd

onready var username_box = $LoginPanel/VBox/DataList/HBoxUsername/UsernameLE
onready var password_box = $LoginPanel/VBox/DataList/HBoxPassword/PasswordLE
onready var save_password_box = $LoginPanel/VBox/DataList/HBoxSavePassword/SavePasswordCheckBox

onready var username_reg_box = $RegPanel/VBox/Data/HBox/VBox/HBoxUsername/UsernameLE
onready var password_reg_box = $RegPanel/VBox/Data/HBox/VBox/HBoxPassword/PasswordLE
onready var agreement_box = $RegPanel/VBox/Data/HBoxAgreed/AgreedCheckBox

var agreed_toggled = false
var username_reg = ""
var password_reg = ""
var password_secret_reg = true

var connection = false
var was_connected = false

var state = 0
var prev_panel

func _ready():
	self.title = "GAME_TITLE"
	$LoginPanel.rect_scale = UI.scale
	UI.register_named_element(UI.LE_MP_USERNAME, username_box)
	UI.register_named_element(UI.LE_MP_PASSWORD, password_box)
	UI.register_named_element(UI.CB_MP_SAVE_PASSWORD, save_password_box)
	UI.register_named_element(UI.BTN_SIGNUP, $LoginPanel/VBox/SignUpButton)
	UI.register_named_element(UI.BTN_RESTORE_PASSWORD, $LoginPanel/VBox/RestorePasswordButton)
	
# Обработчики событий
	
# Возникает при установлении соединения с сервером
func on_connection_success():
	if connection:
		UI.hide_back_btn()
		was_connected = true
		yield($ConnectionPanel.beautiful_hide(), "fade_completed")
		Network.notify_connect_to_server()
		Profiles.set_value(Settings.SV_MP_SIGNED, true)
		goto_screen(UI.SCREEN_SERVER, false)

# Происходит при попытке залогиниться дважды
func on_already_connected():
	on_connection_fail(2)
	
# Возникает при закрытиии соединения с сервером
func on_connection_fail(reason):
	if connection:
		yield($ConnectionPanel.beautiful_hide(), "fade_completed")
		if reason == 0:
			if !was_connected:
				$ConnectionDonePanel/Box/Desc.text = "LABEL_SERVER_CONNECTION_FAIL"
			else:
				$ConnectionDonePanel/Box/Desc.text = "LABEL_SERVER_CLOSED"
		elif reason == 1: # invalid login
			$ConnectionDonePanel/Box/Desc.text = "MP_INVALID_LOGIN"
		elif reason == 2: # already been logged
			$ConnectionDonePanel/Box/Desc.text = "MP_ALREADY_LOGON"
		elif reason == 3: # banned
			$ConnectionDonePanel/Box/Desc.text = "MP_BANNED"
		else:
			$ConnectionDonePanel/Box/Desc.text = "LABEL_UNKNOWN_ERROR"
		yield($ConnectionDonePanel.beautiful_show(), "fade_completed")
		yield(get_tree().create_timer(1.5), "timeout")
		yield($ConnectionDonePanel.beautiful_hide(), "fade_completed")
		
		if connection:
			$LoginPanel.beautiful_show()
		was_connected = false

func on_signup_success():
	yield($ConnectionPanel.beautiful_hide(), "fade_completed")
	$ConnectionDonePanel/Box/Desc.text = "MP_SIGNUP_OK"
	yield($ConnectionDonePanel.beautiful_show(), "fade_completed")
	yield(get_tree().create_timer(1.0), "timeout")
	yield($ConnectionDonePanel.beautiful_hide(), "fade_completed")
	$LoginPanel.beautiful_show()

func on_signup_fail(reason):
	yield($ConnectionPanel.beautiful_hide(), "fade_completed")
	if reason == 4:
		yield(UI.call_dialog("MP_USER_ALREADY_EXISTED"), "ok_pressed")
	if reason == 11: # DeclineArg.MalformedNameData
		yield(UI.call_data_dialog("MP_NAME_MALFORMED", "MP_NAME_MALFORMED_DESC"), "ok_pressed")
	if reason == 12:# DeclineArg.MalformedPasswordData
		yield(UI.call_data_dialog("MP_PASSWORD_MALFORMED", "MP_PASSWORD_MALFORMED_DESC"), "ok_pressed")
	$RegPanel.beautiful_show()
	
# Экран входа

func _on_LoginScreen_show_completed():
	update_login_button()
	if state == 0:
		$LoginPanel.beautiful_show()
	elif state == 1:
		$RegPanel.beautiful_show()
	elif state == 2:
		$RestorePassword.beautiful_show()
	elif state == 3:
		$RegPanel.beautiful_show()
		
	if Profiles.get_value(Settings.SV_MP_SIGNED):
		UI.get_named_element(UI.BTN_SIGNUP).visible = false
		UI.get_named_element(UI.BTN_RESTORE_PASSWORD).visible = true
	else:
		UI.get_named_element(UI.BTN_SIGNUP).visible = true
		UI.get_named_element(UI.BTN_RESTORE_PASSWORD).visible = false
		
func _on_LoginScreen_hide_completed():
	hide_all()

func hide_all():
	$LoginPanel.beautiful_hide()
	$ConnectionPanel.beautiful_hide()
	$ConnectionDonePanel.beautiful_hide()
	$RestorePassword.beautiful_hide()
	$RegPanel.beautiful_hide()

func _on_UsernameLE_text_changed(new_text):
	update_login_button()

func _on_PasswordLE_text_changed(new_text):
	update_login_button()

func _on_SavePasswordCheckBox_toggled(toggled):
	Profiles.set_value(Settings.SV_MP_SAVE_PASSWORD, toggled)
	
func update_login_button():
	if username_box.text.length() > 0 and password_box.text.length() > 0:
		$LoginPanel/VBox/SignInButton.disabled = false
	else:
		$LoginPanel/VBox/SignInButton.disabled = true

func go_back_if_possible():
	connection = false
	was_connected = false
	if state == 0:
		hide_all()
		return .go_back_if_possible()
	else:
		if state == 1:
			yield($RegPanel.beautiful_hide(), "fade_completed")
			yield($LoginPanel.beautiful_show(), "fade_completed")
			state = 0
		elif state == 2:
			yield($RestorePassword.beautiful_hide(), "fade_completed")
			yield($LoginPanel.beautiful_show(), "fade_completed")
			state = 0
		elif state == 3:
			yield($RegPanel.beautiful_show(), "fade_completed")
		return true

func setup_connection_data():
	var ip = UI.get_master_ip()
	var port = UI.get_master_port()
	ip = "localhost"
	port = 9009
	Network.setup_connection_data(ip, port)
	
func _on_SignInButton_pressed():
	connection = true
	state = 0
	yield($LoginPanel.beautiful_hide(), "fade_completed")
	yield($ConnectionPanel.beautiful_show(), "fade_completed")
	setup_connection_data()
	
	print(username_box.text)
	
	Network.sign_in(username_box.text, password_box.text)
	if !save_password_box.pressed:
		password_box.text = ""
	else:
		Profiles.set_value(Settings.SV_MP_PASSWORD, password_box.text)
		
func _on_SignUpButton_pressed():
	state = 1
	username_reg = ""
	password_reg = ""
	username_reg_box.text = ""
	password_reg_box.text = ""
	agreed_toggled = false
	agreement_box.pressed = false
	$RegPanel/VBox/Data/HBox/VBox2/CountrySelectionButton.tooltip = TranslationServer.translate("LABEL_COUNTRY") + " " + UI.get_country_name(UI.country_tag)
	$RegPanel/VBox/CreateButton.disabled = true
	prev_panel = $LoginPanel
	yield(prev_panel.beautiful_hide(), "fade_completed")
	yield($RegPanel.beautiful_show(), "fade_completed")
	
func _on_RestorePassword_pressed():
	state = 2
	prev_panel = $LoginPanel
	yield(prev_panel.beautiful_hide(), "fade_completed")
	yield($RestorePassword.beautiful_show(), "fade_completed")
	
# Панель регистрации

func update_create_button():
	if agreed_toggled and username_reg.length() > 0 and password_reg.length() > 0:
		$RegPanel/VBox/CreateButton.disabled = false
	else:
		$RegPanel/VBox/CreateButton.disabled = true

func _on_UsernameLE2_text_changed(new_text):
	username_reg = new_text
	update_create_button()

func _on_PasswordLE2_text_changed(new_text):
	password_reg = new_text
	update_create_button()

func _on_ShowPassword_pressed():
	password_secret_reg = !password_secret_reg
	password_reg_box.secret = password_secret_reg

func _on_AgreedCheckBox_toggled(toggled):
	agreed_toggled = toggled
	update_create_button()

func _on_CountrySelectionButton_pressed():
	yield($RegPanel.beautiful_hide(), "fade_completed")
	UI.register_country_button($RegPanel/VBox/Data/HBox/VBox2/CountrySelectionButton)
	UI.register_country_label($RegPanel/VBox/Data/HBox/VBox2/CountrySelectionCurrent)
	goto_screen(UI.SCREEN_SELECT_COUNTRY)

func _on_CreateButton_pressed():
	username_box.text = username_reg
	yield($RegPanel.beautiful_hide(), "fade_completed")
	yield($ConnectionPanel.beautiful_show(), "fade_completed")
	setup_connection_data()
	Network.sign_up(username_reg_box.text, password_reg_box.text, UI.country_tag)

func _on_CancelButton_pressed():
	yield($RegPanel.beautiful_hide(), "fade_completed")
	yield($LoginPanel.beautiful_show(), "fade_completed")

# Диалог восстановления пароля

func _on_SignUpButton2_pressed():
	state = 1
	prev_panel = $RestorePassword
	$RegPanel/VBox/Data/HBox/VBox2/CountrySelectionButton.tooltip = UI.get_country_name(UI.country_tag)
	yield($RestorePassword.beautiful_hide(), "fade_completed")
	yield($RegPanel.beautiful_show(), "fade_completed")

func _on_CancelRestoreButton_pressed():
	prev_panel = $LoginPanel
	yield($RestorePassword.beautiful_hide(), "fade_completed")
	yield(prev_panel.beautiful_show(), "fade_completed")

