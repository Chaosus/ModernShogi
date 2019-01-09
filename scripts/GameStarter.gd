extends Node

# GameStarter.gd

# Содержит методы старта игры

var loading_screen
var game_screen
var from_screen

signal preload_completed
signal load_completed

func set_from_screen(screen):
	from_screen = screen
	
func _pre_load():
	
	loading_screen.clear_messages()
	loading_screen.show_message(TranslationServer.translate("DESC_LOADING"), 0)
	yield(from_screen.goto_screen(UI.SCREEN_LOADING, false), "fade_completed")	
	
	emit_signal("preload_completed")
	return self
		
func _post_load():
	loading_screen.goto_screen(UI.SCREEN_GAME)

# Старт новой одиночной игры
func start_local(player_config, player_side, minutes, seconds, handicap, sfen = null):
	_pre_load()
	yield(self, "preload_completed")
	
	var session = Game.GameSession.new()
	session.game_template = Games.get_game_by_name(Games.GameType.SHOGI)
	session.setup = handicap
	session.sfen = sfen
	session.ai_enabled = player_config == Games.PlayerConfig.AI
	session.initial_side = player_side
	game_screen.init_game(session)
	
	_post_load()

# Старт повтора из библиотеки
func start_replay(replay):
	_pre_load()
	yield(self, "preload_completed")
	
	var session = Game.GameSession.new()
	session.game_template = Games.get_game_by_name(Games.GameType.SHOGI)
	session.setup = replay.handicap_value
	session.initial_side = -1
	session.replay_mode = true
	session.replay = replay
	game_screen.init_game(session)
	
	_post_load()
	
func start_join_session():
	
	var session = Game.GameSession.new()
	session.mp_mode = true
	session.game_template = Games.get_game_by_name(Games.GameType.SHOGI)
	session.initial_side = -1
	game_screen.init_game(session)
	game_screen.set_player_names("?", "?")
	_post_load()

func join_game(session):
	_pre_load()
	yield(self, "preload_completed")
	game_screen.init_game(session)
	_post_load()
	
func join(ip, port, obsmode):
	loading_screen.clear_messages()
	loading_screen.show_message(TranslationServer.translate("DESC_JOINING_TO"), 0)
	loading_screen.show_message(ip + " : " + str(port), 1)
	yield(from_screen.goto_screen(UI.SCREEN_LOADING, false), "fade_completed")
	UI.show_back_btn()
	
	if !Network.create_client(ip, port):
		return
	
	game_screen.obsmode = obsmode
	game_screen.username = Profiles.get_current_profile().nickname
	
func start_host(port, is_rated, _host_side, minutes, seconds, handicap, sfen = null, global_game = false) -> void :
	_pre_load()
	yield(self, "preload_completed")
	
	var host_name = Profiles.get_current_profile().nickname
	if !global_game:
		if !Network.create_server(port):
			return
	
	var host_side = -1
	var bname = ""
	var wname = ""
	
	if !global_game:
		
		if sfen != null:
			if sfen.ends_with("w"):
				_host_side = 2
			else:
				_host_side = 1
		else:
			if handicap != Games.ShogiHandicaps.NONE:
				_host_side = 1
			
		if _host_side == 0:
			randomize()
			host_side = randi() % 2 # Выбираем случайную сторону
		elif _host_side == 1:
			host_side = 0
		elif _host_side == 2:
			host_side = 1
		
		if host_side == 0:
			bname = host_name
			wname = "?"
		else:
			bname = "?"
			wname = host_name
	else:
		if _host_side == 1:
			host_side = 0
		elif _host_side == 2:
			host_side = 1
		
		
	var session = Game.GameSession.new()
	session.mp_mode = true
	session.is_rated = is_rated
	
	if _host_side == 1:
		session.players_data[0] = [0, Network.get_login_name()]
		session.players_data[1] = [1, "?"]
	elif _host_side == 2:
		session.players_data[0] = [0, "?"]
		session.players_data[1] = [1, Network.get_login_name()]
	else:
		session.players_data[0] = [0, "?"]
		session.players_data[1] = [1, "?"]
	
	session.global_game = global_game
	session.game_template = Games.get_game_by_name(Games.GameType.SHOGI)
	session.setup = handicap
	session.sfen = sfen
	session.initial_side = _host_side
	session.your_side = host_side
	session.max_minutes = minutes
	session.max_seconds = seconds
	session.is_server = true
	session.user_name = Network.get_login_name()
	
	game_screen.init_game(session)
	if !global_game:
		session.set_your_name(host_name)
		session.set_your_side(host_side)
		game_screen.set_camera_side(host_side)
		game_screen.set_player_names(bname, wname)
	_post_load()