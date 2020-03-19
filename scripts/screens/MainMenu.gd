extends "res://scripts/UIScreen.gd"

onready var main_box = $GridContainer
onready var multiplayer_box = $MultiplayerContainer

# MainMenu.gd

func _ready():
	self.title = "GAME_TITLE_V"
	
# Функции кнопок / тайлов

var game_run = false

# Быстрый запуск игры(для теста)
func quick_game():
	# Запрещает двойную загрузку при двойном нажатии
	if !game_run:
		game_run = true
		yield(beautiful_hide(), "fade_completed")
		UI.get_root().start_quick_game()
		game_run = false
	
# Открывает меню настроек
func open_settings_menu():
	UI.get_root().open_settings()

func open_newgame_menu():
	goto_screen(UI.SCREEN_NEWGAME)

# Открывает дополнительное меню
func open_extras_menu():
	goto_screen(UI.SCREEN_EXTRA)	

func open_library_menu():
	goto_screen(UI.SCREEN_LIBRARY).tree.open_library()
	
func open_new_game_menu():
	goto_screen(UI.SCREEN_NEWGAME)

# Выход из игры
func open_quit_menu():
	goto_screen(UI.SCREEN_QUIT_CONFIRMATION)

############################################
# 			Обработчики кнопок
############################################

# Колонка 1 - Кнопки запуска игры

func _on_VersusAIButton_pressed():
	UI.server_list_enabled = false
	UI.get_root().goto_game_setup(self, Games.PlayerConfig.AI, false)

func _on_PlayerVsPlayerButton_pressed():
	UI.server_list_enabled = false
	UI.get_root().goto_game_setup(self, Games.PlayerConfig.PVP, false)

func _on_MultiplayerButton_pressed():
	main_box.beautiful_hide()
	multiplayer_box.beautiful_show()
	
func _on_ServerListButton_pressed():
	UI.server_list_enabled = true
	goto_screen(UI.SCREEN_LOGIN)
	
# Колонка 2 - Кнопки вспомогательных функций

# Кнопка вызова экрана помощи
func _on_HelpButton_pressed():
	pass # Replace with function body.

# Кнопка вызова экрана редактора
func _on_EditorButton_pressed():
	pass

# Кнопка вызова экрана загрузки
func _on_LoadButton_pressed():
	goto_screen(UI.SCREEN_LOADGAME)

# Кнопка вызова экрана библиотеки
func _on_LibraryButton_pressed():
	open_library_menu()

# Колонка 3 - Кнопки онлайн функций

# Кнопка вызова экрана просмотра онлайн повторо
func _on_WatchOnlineButton_pressed():
	pass

# Кнопка вызова настроек профиля
func _on_ProfileButton_pressed():
	pass

# Колонка 4 - Вспомогательные кнопки

# Кнопка открытия меню настроек
func _on_SettingsButton_pressed():
	open_settings_menu()

# Кнопка открытия окна репорта бага
func _on_BugsButton_pressed():
	pass

# Кнопка открытия окна доната
func _on_DonateButton_pressed():
	pass

# Кнопка вызова диалога закрытия игры
func _on_QuitButton_pressed():
	open_quit_menu()

func _on_QuickPlay_pressed():
	UI.get_root().quick_game()


############################################
# 			Обработчики кнопок (мультиплеер)
############################################

func _on_HostButton_pressed():
	UI.server_list_enabled = false
	UI.get_root().goto_game_setup(self, Games.PlayerConfig.PVP, true)
	
func _on_JoinButton_pressed():
	UI.server_list_enabled = false
	goto_screen(UI.SCREEN_JOIN_IP)

func _on_BackFromMultiplayerButton_pressed():
	multiplayer_box.beautiful_hide()
	main_box.beautiful_show()
