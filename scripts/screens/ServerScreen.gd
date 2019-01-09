extends "res://scripts/UIScreen.gd"

onready var remote_box_prefab = preload("res://prefabs/RemoteServerGameBox.tscn")
onready var game_list = $VBox/Box/ServerList/ServerList
onready var status_label = $VBox/Header/InfoContainer/StatusLabel

var save_state = 0

func _ready():
	self.title = "TITLE_JOIN_LIST"

class GameSessionInfo:
	var key
	var your_name
	var game_name
	var is_obs
	var players = []
	var observers = []

class GameUser:
	var name
	var is_obs

var game_session = null
	
func _on_ServerScreen_show_completed():
	UI.get_widget(UI.WIDGET_CREATE_SERVER).show()
	UI.get_widget(UI.WIDGET_ACCOUNT).show()
	
	previous_screen = UI.get_root().main_menu
	UI.show_back_btn()
	
func _on_ServerScreen_hide_completed():
	UI.get_widget(UI.WIDGET_CREATE_SERVER).hide()
	UI.get_widget(UI.WIDGET_ACCOUNT).hide()
	
func go_back_if_possible():
	save_state = 0
	Network.disconnect_if_connected()
	return .go_back_if_possible()

#--------------------------------------------------------------------------------#

func on_network_error(code):
	print("network error = " + str(code))

func show_account_info(name, country, rating, win_count, lose_count, draw_count, visit_count):
	UI.get_root().account_screen.setup_account(name, country, rating, win_count, lose_count, draw_count, visit_count)
	goto_screen(UI.SCREEN_ACCOUNT)
	
	
func create_game(game_type, is_rated, game_name, handicap, host_side, your_side):
	game_session = Game.GameSession.new()
	game_session.game_template = Games.get_game_by_name(game_type)
	game_session.is_rated = is_rated
	game_session.game_name = game_name
	game_session.setup = handicap
	game_session.mp_mode = true
	game_session.global_game = true
	game_session.initial_side = host_side
	game_session.your_side = your_side
	game_session.user_name = Network.get_login_name()
	UI.call_joining_dialog()

func join():
	GameStarter.set_from_screen(self)
	GameStarter.join_game(game_session)
	
func join_fail(reason):
	if reason == 1:
		UI.call_dialog("DESC_GAME_IS_FULL")
	elif reason == 10: # password is incorrect
		UI.call_dialog("MP_INCORRECT_PASSWORD")

func join_obs_fail(reason):
	if reason == 1:
		UI.call_dialog("DESC_GAME_IS_FULL2")

#--------------------------------------------------------------------------------#

func _on_AccountButton_pressed():
	Network.request_account_info(-1)
	
func _on_RefreshListButton_pressed():
	pass
	#request_game_list()

func _on_CreateGameButton_pressed():
	UI.get_root().goto_game_setup(self, Games.PlayerConfig.PVP, true, true)

	
# Очистка списка игр
func clear_game_list():
	var children = game_list.get_children()
	for child in children:
		child.free()	

var game_count = 0

func list_begin(count):
	game_count = count
	
func set_game(key, is_protected, game_type, game_name, handicap, user_name, player_count, obs_count, turn_count):
	var children = game_list.get_children()
	for child in children:
		if child.key == key:
			child.change(user_name, player_count, obs_count, turn_count)
			return
	var box = remote_box_prefab.instance()
	game_list.add_child(box)
	var id = game_list.get_child_count()
	box.setup(id, key, is_protected, game_type, game_name, handicap, null, user_name, player_count, obs_count, turn_count)

func remove_game(key):
	var children = game_list.get_children()
	for child in children:
		if child.key == key:
			child.free()
			
func list_end(count):
	var big_mode = false
	if count > 13:
		big_mode = true
	var children = game_list.get_children()
	$VBox/Header/VBoxContainer/Header.expand(!big_mode)
	for child in children:
		child.expand(!big_mode)
	status_label.text = TranslationServer.translate("LABEL_OPEN") + str(count)

func create_dummy_items(count):
	list_begin(count)
	for i in range(count):
		var box = remote_box_prefab.instance()
		game_list.add_child(box)
		var id = game_list.get_child_count()
		box.setup(id, id, Games.GameType.SHOGI, "MyTestGame" + str(i), Games.ShogiHandicaps.NONE, null, "Chaos, Chaos2", 0, 0, 0)
	list_end(count)
