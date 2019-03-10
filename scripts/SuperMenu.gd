extends Control

# SuperMenu.gd

var test_mode = false

# Экраны

var first_screen
var main_menu
var settings_screen
var library_screen
var loading_screen
var loadgame_screen
var setup_screen
var join_ip_screen
var login_screen
var server_screen
var account_screen
var quit_confirmation_screen
var goodbay_screen
var extras_screen
var select_country_screen
var select_avatar_screen
var select_color_screen
var game_screen

# Инициализация экранов
func _init_screens():
	var path = "MainContainer/MainLayout/Screens/"
	first_screen = UI.register_named_element(UI.SCREEN_FIRST, get_node(path + "FirstScreen"))
	main_menu = UI.register_named_element(UI.SCREEN_MAIN_MENU, get_node(path + "MainMenuScreen"))
	settings_screen = UI.register_named_element(UI.SCREEN_SETTINGS, get_node(path + "SettingsScreen"))
	library_screen = UI.register_named_element(UI.SCREEN_LIBRARY, get_node(path + "LibraryScreen"))
	loading_screen = UI.register_named_element(UI.SCREEN_LOADING, get_node(path + "LoadingScreen"))
	loadgame_screen = UI.register_named_element(UI.SCREEN_LOADGAME, get_node(path + "LoadGameScreen"))
	setup_screen = UI.register_named_element(UI.SCREEN_SETUP, get_node(path + "SetupScreen"))
	join_ip_screen = UI.register_named_element(UI.SCREEN_JOIN_IP, get_node(path + "JoinIPScreen"))
	login_screen = UI.register_named_element(UI.SCREEN_LOGIN, get_node(path + "LoginScreen"))
	server_screen = UI.register_named_element(UI.SCREEN_SERVER, get_node(path + "ServerScreen"))
	account_screen = UI.register_named_element(UI.SCREEN_ACCOUNT, get_node(path + "AccountScreen"))
	quit_confirmation_screen = UI.register_named_element(UI.SCREEN_QUIT_CONFIRMATION, get_node(path + "QuitConfirmationScreen"))
	goodbay_screen = UI.register_named_element(UI.SCREEN_GOODBAY, get_node(path + "GoodbayScreen"))
	extras_screen = UI.register_named_element(UI.SCREEN_EXTRAS, get_node(path + "ExtrasScreen"))
	select_country_screen = UI.register_named_element(UI.SCREEN_SELECT_COUNTRY, get_node(path + "CountrySelectionScreen"))
	select_avatar_screen = UI.register_named_element(UI.SCREEN_SELECT_AVATAR, get_node(path + "AvatarSelectionScreen"))
	select_color_screen = UI.register_named_element(UI.SCREEN_SELECT_COLOR, get_node(path + "ColorSelectionScreen"))
	game_screen = UI.register_named_element(UI.SCREEN_GAME, get_node("MainContainer/Game"))
	
	GameStarter.loading_screen = loading_screen
	GameStarter.game_screen = game_screen
	
	select_country_screen.create_countries()

func init_network():
	$MainContainer/MainLayout/Screens/JoinIPScreen/Panel/VBox/VBoxIP/HBoxIPV4/NumBox1.value = Profiles.get_current_settings().get_value(Settings.SV_IPV4_1)
	$MainContainer/MainLayout/Screens/JoinIPScreen/Panel/VBox/VBoxIP/HBoxIPV4/NumBox2.value = Profiles.get_current_settings().get_value(Settings.SV_IPV4_2)
	$MainContainer/MainLayout/Screens/JoinIPScreen/Panel/VBox/VBoxIP/HBoxIPV4/NumBox3.value = Profiles.get_current_settings().get_value(Settings.SV_IPV4_3)
	$MainContainer/MainLayout/Screens/JoinIPScreen/Panel/VBox/VBoxIP/HBoxIPV4/NumBox4.value = Profiles.get_current_settings().get_value(Settings.SV_IPV4_4)
	$MainContainer/MainLayout/Screens/JoinIPScreen/Panel/VBox/VBoxIP/HBoxIPV6/IPV6Box.text = Profiles.get_value(Settings.SV_IPV6)
	$MainContainer/MainLayout/Screens/JoinIPScreen/Panel/VBox/VBoxIP/HBoxPort/SpinBox.value = Profiles.get_current_settings().get_value(Settings.SV_JOIN_PORT)
	Network.setup($Connection, login_screen, server_screen, account_screen, game_screen)

func goto_game_setup(from_screen, config, mp_host = false, master_server = false):
	setup_screen.setup_standart()
	setup_screen.setup_config(config, mp_host, master_server)
	if config == Games.PlayerConfig.AI:
		setup_screen.setup_ai_game()
		setup_screen.title = "TITLE_AI_GAME"
	else:
		if mp_host:
			setup_screen.title = "TITLE_HOST_GAME"
		else:
			setup_screen.title = "TITLE_LOCAL_GAME"
			setup_screen.setup_local()
	from_screen.goto_screen(UI.SCREEN_SETUP)

func on_connection_failed():
	loading_screen.show_message("DESC_JOIN_ERROR", 0)
	loading_screen.show_message("DESC_JOIN_ERROR_SERVER_NOT_ANSWER", 1)
	loading_screen.stop_rotating()
	loading_screen.show_tryagain_btn()

func close_current_connection():
	if multiplayer.get_network_peer() != null:
		multiplayer.get_network_peer().close_connection()
	
func print_session(session):
	print("key = " + str(session.key))
	print("your_name = " + session.your_name)
	print("game_name = " + session.game_name)
	print("is_obs = " + str(session.is_obs))
	print("players = " + str(session.players))
	print("observers = " + str(session.observers))

func join_remote(session):
	print_session(session)
	loading_screen.clear_messages()
	loading_screen.show_message(TranslationServer.translate("DESC_JOINING_TO"), 0)
	loading_screen.show_message(session.game_name, 1)
	yield(server_screen.goto_screen(UI.SCREEN_LOADING, false), "fade_completed")
	
	game_screen.obsmode = session.is_obs
	game_screen.username = Profiles.get_current_profile().nickname

	game_screen.init_game(session)
	loading_screen.goto_screen(UI.SCREEN_GAME)
	
func _on_BTN_RETURN_TO_GAME_pressed():
	if UI.topbar.get_show_state() == 0:
		UI.get_current_screen().go_back_if_possible()

func _init():
	UI.scale = Vector2(UI.get_real_resolution().x / 1920.0, UI.get_real_resolution().y / 1080.0)
	rect_scale = UI.scale
	#UI.scale = Vector2(OS.get_screen_size().x / 1920.0, OS.get_screen_size().y / 1080.0)
	
func _ready():
	UI.set_root(self)
	
	# Расширить разрешение экрана до текущего
	var r = OS.get_screen_size()
	var r2 = UI.get_current_resolution()
	if r2 != r:
		UI.set_resolution(r)
		var t = PoolStringArray()
		OS.execute(OS.get_executable_path(), t, false)
		get_tree().quit()
		return
	
	UI.sfx_player = $UISFX
	UI.init_themes()
	UI.screen_center = get_viewport().size / 2
	_init_screens()
	#select_country_screen.create_countries()
	#select_avatar_screen.create_avatars()
	
	# Главный запуск
	var list = Profiles.get_profile_list()
	if list.empty():
		Profiles.set_current_profile(Profiles.create_temp_profile())
		UI.apply_profile(Profiles.get_current_profile())
		yield(first_screen.show_itself(), "fade_completed")
	else:
		var profile = Profiles.read_profile(list[0])
		if profile == null:
			Profiles.set_current_profile(Profiles.create_temp_profile())
			UI.apply_profile(Profiles.get_current_profile())
			yield(first_screen.show_itself(), "fade_completed")
		else:
			UI.apply_profile(Profiles.set_current_profile(profile))
			if !test_mode:
				main_menu.show_itself()
			
	init_network()
	Games.init_games()

func _on_ReconnectButton_pressed():
	game_screen.reconnect()

func _on_BackBtnWidget_pressed():
	if UI.get_current_screen() != null:
		UI.get_current_screen().go_back_if_possible()

func _on_SettingsWidget_pressed():
	open_settings()

func open_settings():
	if UI.get_current_screen() != null:
		if UI.get_current_screen().get_show_state() == BeautyElement.ShowState.NONE:
			if UI.get_current_screen() != UI.get_named_element(UI.SCREEN_SETTINGS):
				UI.get_widget(UI.WIDGET_SETTINGS).hide()
				var s = UI.get_current_screen()
				if s == UI._game_scene:
					s.open_screen(UI.SCREEN_SETTINGS)
				else:
					s.goto_screen(UI.SCREEN_SETTINGS)
				return true
	return false

func open_history_settings():
	if open_settings():
		settings_screen.open_history_subsection()

func open_ai_settings():
	if open_settings():
		settings_screen.open_ai_subsection()

func open_styles_settings():
	if open_settings():
		settings_screen.open_styles_subsection()

func hide_loader():
	return $MainContainer/LoadingPanel.beautiful_hide()

func _on_SansaraWidget_on_left_button_pressed():
	sansara_pressed(false)

func _on_SansaraWidget_on_right_button_pressed():
	sansara_pressed(true)

func sansara_pressed(reversed):
	var new_theme
	var current_theme = Profiles.get_current_settings().get_value(Settings.SV_UI_THEME)
	
	match Profiles.get_current_settings().get_value(Settings.SV_WIDGET_SANSARA_ORDER):
		0:
			if reversed:
				new_theme = wrapi(current_theme - 1, 0, UI.UITheme.LIMITER)
			else:
				new_theme = wrapi(current_theme + 1, 0, UI.UITheme.LIMITER)
		1:
			if reversed:
				new_theme = wrapi(current_theme + 1, 0, UI.UITheme.LIMITER)
			else:
				new_theme = wrapi(current_theme - 1, 0, UI.UITheme.LIMITER)					
	UI.current_aspect = UI.themes[new_theme].current_aspect
	Profiles.get_current_settings().set_value(Settings.SV_UI_THEME, new_theme)
	UI.apply_theme_to_ui(new_theme, UI.current_aspect)
	UI.set_theme(new_theme, UI.current_aspect)
	

func quit(save = true):
	if save:
		Profiles.save_current_profile()
	Network.disconnect_if_connected()
	UI.get_ai().Shutdown()
	get_tree().quit()

func _on_QuitButton_pressed():
	quit(false)
	
func _on_QQWidget_pressed():
	if Profiles.get_current_settings().get_value(Settings.SV_WIDGET_QQ_DIALOG_ENABLED):
		UI.get_current_screen().goto_screen(UI.SCREEN_QUIT_CONFIRMATION)
	else:
		quit()

# Кнопка возврата в игру
func _on_BackToGameWidget_pressed():
	UI.get_widget(UI.WIDGET_MP_BACK_TO_GAME).hide()
	UI.get_current_screen().goto_screen(UI.SCREEN_GAME)

func _on_ResignButton_pressed():
	if !game_screen.session.has_other_player():
		game_screen.gui.infopanel.start()
		game_screen.gui.await_answer_disconnected.start()
		return
	game_screen.gui.show_dialog(UI.GUI_DLG_RESIGN)

func _on_TakebackButton_pressed():
	game_screen.takeback_request()

func _on_AIButton_pressed():
	UI.ai_panel.show_or_hide()

func _on_FlipBoardButton_pressed():
	UI.get_game().flip_board()

func _on_DeleteProfileButton_pressed():
	var dlg = $DeleteFileDialog
	dlg.update_mode(0)
	dlg.set_title("DESC_DELETE_PROFILE")
	if !dlg.is_connected("yes_pressed", self, "delete_profile"):
		dlg.connect("yes_pressed", self, "delete_profile")
	dlg.beautiful_show()

func delete_profile():
	Utility.delete_file("user://current.profile")
	quit(false)
	
func _on_HintModeButton_pressed():
	UI.get_game().hint()

func _on_LoopbackCheckBox_toggled(toggled):
	Profiles.set_value(Settings.SV_LOOPBACK_MODE, toggled)

func _physics_process(_delta):
	$MainContainer/Game/FPS.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("ui_back"):
		if UI.get_current_screen() != null:
			UI.get_current_screen().go_back_if_possible()
