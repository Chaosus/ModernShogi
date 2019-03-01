extends "res://scripts/UIScreen.gd"

onready var remote_box_prefab = preload("res://scenes/RemoteServerGameBox.tscn")
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

var join_dialog

func call_joining_dialog():
	join_dialog = UI.call_joining_dialog()
	join_dialog.connect("destroyed", self, "free_joining_dialog_ref")
	
func free_joining_dialog_ref():
	join_dialog = null
	
func destroy_joining_dialog():
	if join_dialog != null:
		join_dialog.destroy()
		
#--------------------------------------------------------------------------------#

func on_network_error(code):
	print("network error = " + str(code))

func show_account_info(name, country, rating, win_count, lose_count, draw_count, visit_count):
	UI.get_root().account_screen.setup_account(name, country, rating, win_count, lose_count, draw_count, visit_count)
	goto_screen(UI.SCREEN_ACCOUNT)

var saved_game_id
var saved_game_type
var saved_is_rated
var saved_game_name
var saved_handicap

# Начинаем игровую сессию
func start_session(is_obs):
	destroy_joining_dialog()
	game_session = Game.GameSession.new()
	game_session.id = saved_game_id
	game_session.game_name = saved_game_name
	game_session.game_template = Games.get_game_by_name(saved_game_type)
	game_session.is_rated = saved_is_rated
	game_session.setup = saved_handicap
	if is_obs:
		game_session.initial_side = -1
	game_session.obs_mode = is_obs
	game_session.user_name = Network.get_login_name()
	game_session.mp_mode = true
	game_session.global_game = true
	GameStarter.set_from_screen(self)
	GameStarter.join_game(game_session)
	
func join_fail(game_id, reason):
	if reason == 1: # game is full
		UI.call_dialog("DESC_GAME_IS_FULL")
	elif reason == 2: # creator decline join
		destroy_joining_dialog()
		UI.call_dialog("MP_PLAYER_DECLINE")
	elif reason == 10: # game is protected but password is incorrect
		destroy_joining_dialog()
		UI.call_dialog("MP_INCORRECT_PASSWORD")
	elif reason == 14: # other player already tries to connect to this game
		UI.call_dialog("MP_OTHER_CONNECTION_EXIST")

func join_obs_fail(id, reason):
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
	
func set_game(key, is_rated, is_protected, game_type, game_name, handicap, user_name, player_count, obs_count, turn_count):
	var children = game_list.get_children()
	for child in children:
		if child.key == key:
			child.change(user_name, player_count, obs_count, turn_count)
			return
	var box = remote_box_prefab.instance()
	game_list.add_child(box)
	var id = game_list.get_child_count()
	box.setup(id, key, is_rated, is_protected, game_type, game_name, handicap, null, user_name, player_count, obs_count, turn_count)

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

