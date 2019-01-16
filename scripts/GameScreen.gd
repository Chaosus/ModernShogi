extends "res://scripts/UIScreen.gd"

# GameScreen.gd

onready var gui = $GUI
onready var ai = $AI
onready var board = $Board
onready var fixedcamera1 = $FixedCamera1
onready var fixedcamera2 = $FixedCamera2
onready var commentator = $Commentator
onready var stopwatch = $SecondTimer

onready var arrow_prefab = preload("res://prefabs/Arrow.tscn")
onready var nest_prefab = preload("res://prefabs/Tile.tscn")
onready var piece_prefab = preload("res://prefabs/Piece.tscn")

var session

enum HistoryPlayProc {
	NONE,
	BACKWARD,
	FORWARD
}

func has_active_session():
	return session != null

var history_move_proc = HistoryPlayProc.NONE
var desired_idx
var playback_boost
var play_first_move_done = false

class PeerData:
	var name
	var state # 0 - Unknown yet, 1 - Player, 2 - Observer
	func _init():
		self.name = ""
		self.state = 0

var peers = {}

var game_speed = Games.GameSpeed.HIGH

func is_skip_anim():
	return game_speed == Games.GameSpeed.IMMEDIATE

var _opponent_name
var _started = false

var _checkmate_move = false

var sfen_hash_array = []
var _check = false

var obsmode = false
var username

var current_view = null

signal turn_changed

####################################################################################

var joining_dialog = null

func ms_show_joining_dialog(name, id, avatar, country, rating, wins, loses, draws):
	var dialog = preload("res://scenes/PlayerJoiningPanel.tscn").instance()
	dialog.self_destruct = true
	add_child(dialog)
	dialog.connect("destroyed", self, "free_joining_dialog_ref")
	dialog.setup_params(id, name, avatar, country, rating, wins, loses, draws)
	dialog.beautiful_show()
	joining_dialog = dialog
	return dialog

func free_joining_dialog_ref():
	joining_dialog = null

func ms_destroy_joining_dialog():
	if joining_dialog != null:
		joining_dialog.destroy()
		joining_dialog = null

# Происходит при отсоединении другого игрока
func ms_suspend(reason):
	show_await_label()
	if session != null:
		session.has_other_player = false
		set_player_name(session.get_opponent_side(), "?")

func ms_accept(what):
	if what == 0: # AcceptArg.Takeback - Получение положительного ответа на возврат хода
		gui.show_await_label(false, "DESC_AWAITING", true)
		gui.takeback_yes_popup.start()
		gui.infopanel.start()
		gui.history_panel.history_back(false, true)
		gui.history_panel.erase_next_moves()

func ms_decline(what):
	if what == -2 || what == 9: # DeclineArg.InvalidCommand или DeclineArg.GameNotExist
		UI.call_dialog("MP_DECLINE")
	elif what == 5: # DeclineArg.UserNotExist - Другой игрок не присоединён !
		gui.await_answer_disconnected.start()
		gui.infopanel.start()
	elif what == 6: # DeclineArg.UserCancelTakeback - Получение отрицательного ответа на возврат хода
		gui.takeback_no_popup.start()
		gui.infopanel.start()
	elif what == 7: # DeclineArg.GameNotStarted
		UI.call_dialog("MP_DECLINE_GAME_NOT_STARTED")
	elif what == 8: # DeclineArg.GameIsDone
		UI.call_dialog("MP_DECLINE_GAME_IS_DONE")
	elif what == 15: # DeclineArg.WrongTurn
		UI.call_dialog("MP_DECLINE_WRONG_TURN")
	else:
		UI.call_dialog("MP_DECLINE")
	
func ms_activate():
	hide_await_label()
	Network.request_player_data()

func hlog_from_arr(history):
	var result = ""
	for s in history:
		result += s + "\n"
	return result

func ms_game_data(index, sfen, history):
	history = hlog_from_arr(history)
	#print(str(sfen) + " [ " + str(history) + " ]")
	build_position(sfen)
	build_history(history)
	Network.request_ready() # Объявить готовым
	set_camera_side(index)
	session.set_your_side(index)
	if session.is_server and session.initial_side == 0: # не показывать сторону игроку создателю(иначе будет нечестно и неинтересно)
		return
	if session.is_server:
		session.get_your_player().name = session.user_name
		set_player_name(session.your_side, session.user_name)

func send_move(piece, from_x, from_y, to_x, to_y, promotion):
	assert(session.is_multiplayer())
	if !session.global_game:
		rpc("mp_move", from_x, from_y, to_x, to_y, promotion)
	else:
		Network.send_move(piece.get_type(), piece.is_promoted(), from_x, from_y, to_x, to_y, promotion)

func send_drop_move(piece, to_x, to_y):
	assert(session.is_multiplayer())
	if !session.global_game:
		rpc("mp_drop", piece.side, piece.get_type(), to_x, to_y)
	else:
		Network.send_drop(piece.side, piece.get_type(), to_x, to_y)

func ms_player_data(name, index, is_obs):
	if !is_obs:
		session.players[index].name = name
		session.players[index].side = index

func ms_player_data_end():
	
	if session.players[0].name == session.players[1].name:
		set_player_name(session.players[0].side, session.players[0].name + "[" + str(session.players[0].key) +"]")
		set_player_name(session.players[1].side, session.players[1].name + "[" + str(session.players[1].key) +"]")
	else:
		set_player_name(session.players[0].side, session.players[0].name)
		set_player_name(session.players[1].side, session.players[1].name)
	
	session.has_other_player = true
	set_camera_side(session.your_side)

func ms_player_joined(index, is_obs, name):
	if !is_obs:
		gui.connected_popup.prefix = name
		gui.connected_popup.start()
	else:
		gui.connected_obs_popup.prefix = TranslationServer.translate("DESC_OBSERVER") + " " + name
		gui.connected_obs_popup.start()
	
	gui.infopanel.start()

####################################################################################

var camera_side = -2 setget set_camera_side, get_camera_side

func set_camera_side(side):
	if side == -2:
		camera_side = side
		return
	if side == -1:
		set_camera_side(0)
	else:
		if camera_side != side:
			var cx = 0.0
			var cy = 0.0
			var cz = Vector3(1.0, 1.0, 1.0)
			var ct = Vector3(0.0, 0.0, 0.0)
			var was_resetted = camera_side == -2
			
			camera_side = side
			get_tree().call_group("storage_nest", "invert", side)
			
			if current_view != null and !was_resetted:
				cx = -current_view.rotation.x
				cy = current_view.rotation.y
				cz = current_view.scale
				ct = current_view.translation
			current_view = fixedcamera2 if side == 1 else fixedcamera1
			current_view.rotation.x = cx
			current_view.rotation.y = cy
			current_view.scale = cz
			current_view.translation = Vector3(-ct.x, ct.y, -ct.z)
			current_view.get_node("Camera").make_current()
		
func get_camera_side():
	return camera_side

# Опции геймплея

var lift_lock = false

var nest_select_lock = false

var piece_lock = false

# Текущий тайл
var current_nest = null

var current_tooltip_nest = null

# Текущая выбранная фигура(может быть только одна).
var current_piece = null

var nests = {}

func init_game(session):
	
	self.session = session
	
	reset_names()
	
	_checkmate_move = false
	
	hint_needed = false
	
	# не сбрасывать камеру при переподключении
	if !was_reconnect:
		set_camera_side(-2)
	
	history_move_proc = HistoryPlayProc.NONE
	desired_idx = 0
	playback_boost = false
	
	if !session.is_multiplayer():
		self.title = "GAME_TITLE"
	
	UI.get_widget(UI.WIDGET_TOGGLE_HINT_MODE).visible = !session.is_multiplayer()
	
	gui.setup(self)
	
	board.setup(self, Profiles.get_current_settings())
	
	# Создание игроков и тайлов хранилища
	
	for i in range(session.game_template.max_players):
		var player = Game.Player.new(i)
		player.name = "?"
		for piece_template in session.game_template.piece_templates.values():
			player.storage.add_piece_type(piece_template, board)
		player.storage.add_to_scene(self)
		session.players.append(player)
	
	# Создание тайлов
	
	for x in range(1, session.game_template.width + 1):
		for y in range(1, session.game_template.depth + 1):
			var nest = nest_prefab.instance()
			nest.setup(self, x, y)
			nests[Vector2(10 - x, y)] = nest
			add_child(nest)
	for x in range(1, session.game_template.width + 1):
		for y in range(1, session.game_template.depth + 1):
			var nest =  get_nest(x, y)
			nest.nest_left = get_nest(x - 1, y)
			nest.nest_right = get_nest(x + 1, y)
			nest.nest_up = get_nest(x, y - 1)
			nest.nest_down = get_nest(x, y + 1)
			nest.nest_left_up = get_nest(x - 1, y - 1)
			nest.nest_left_down = get_nest(x - 1, y + 1)
			nest.nest_right_up = get_nest(x + 1, y - 1)
			nest.nest_right_down = get_nest(x + 1, y + 1)
			
	update_style_settings()
	
	if session.global_game:
		pass
	elif session.is_pvp(): # Неважно какая сторона (?)
		set_camera_side(0)
		set_player_names("Black", "White")
	else: # Выбираем случайную сторону
		var what = session.initial_side
		var player_side
		if what == -1: # CPU vs CPU
			player_side = -1
		elif what == 0: # Random
			randomize()
			player_side = randi() % 2
		elif what == 1: # Black
			player_side = 0
		elif what == 2: # White
			player_side = 1
		
		var cpu_side = -1 if player_side == -1 else 0 if player_side == 1 else 1 
		
		var player_name
		var cpu_name
		
		if cpu_side == -1:
			player_name = "CPU1"
			cpu_name = "CPU2"
		else:
			player_name = Profiles.get_current_profile().nickname
			cpu_name = "CPU"
		
		var bname = ""
		var wname = ""
		
		if player_side == 0:
			bname = player_name
			wname = cpu_name
		else:
			bname = cpu_name
			wname = player_name
		
		session.set_your_side(player_side)
		set_camera_side(player_side)
		set_player_names(bname, wname)
	
	gui.update_history_panel()
	if !session.is_multiplayer() or (session.is_server and !session.global_game):
		if session.sfen != null:
			build_position(session.sfen)
		else:
			build_position(session.game_template.get_sfen(session.setup))
		if session.replay != null:
			setup_replay(session.replay)
	if !session.is_server: # показать метку ожидания хода
		hide_await_label()
	else:
		show_await_label()
	Network.request_game_data()
	
func common_cleanup():
	nest_select_lock = false
	piece_lock = false
	lift_lock = false
	current_nest = null
	current_piece = null
	current_tooltip_nest = null
	last_selected_piece = null
	$GUI.cleanup()
	UI.dialog_visible = false
	
# Полная очистка игры
func full_cleanup(cleanup_nests = true):
	if session == null:
		return
	common_cleanup()
	sfen_hash_array.clear()
	# Удаление игроков
	for player in session.players:
		player.cleanup(self)
	session.players.clear()
	if cleanup_nests:
		# Удаление гнёзд
		for nest in nests.values():
			nest.free()
		nests.clear()
	session = null
	peers.clear()

func clear_board():
	for player in session.players:
		for piece in player.all_pieces:
			piece.free()
		player.all_pieces.clear()
	for nest in nests.values():
		nest.piece = null
		nest.hide_all_masks()

func clear_storages():
	for player in session.players:
		player.storage.clear()
		
func clear():
	current_piece = null
	clear_board()
	clear_storages()
	
# Размещает фигуру на доске.
func create_piece(template, x, y, side, special = Games.PieceStates.NORMAL):
	var piece = piece_prefab.instance()
	add_child(piece)
	var nest = get_nest(x, y)
	piece.setup(template, self, nest, side, special)
	session.players[side].all_pieces.append(piece)
	return piece

# Размещает фигуру в резерве.
func create_storage_piece(template, side):
	var piece = piece_prefab.instance()
	add_child(piece)
	
	var storage = session.players[side].storage
	piece.setup(template, self, null, side, Games.PieceStates.NORMAL)
	
	session.players[side].all_pieces.append(piece)
	session.players[side].storage.add_piece(piece)
	
	return piece
	
func eat(piece, killer):
	if piece.nest != null:
		piece.nest.hide_masks()
	
	session.players[piece.side].all_pieces.erase(piece)
	session.players[killer.side].all_pieces.append(piece)
	
	session.players[killer.side].storage.add_piece(piece) # добавить фигуру игроку, который берёт
	piece._change_side(killer.side) # поменять принадлежность фигуры
	
func clear_attacks_side(side):
	for nest in nests.values():
		nest.clear_attacks(side)

func clear_attacks():
	for nest in nests.values():
		nest.clear_all_attacks()

func get_moves(side):
	var player = session.players[side]
	
	for piece in player.all_pieces:
		if piece.in_storage && !piece.on_top:
			continue
		piece.update_moves()
	
	for piece in player.all_pieces:
		piece.remove_checkmate_moves()
	
	var pawn_section = player.storage.get_pawn_section()
	if !pawn_section.empty(): # если пешки вообще есть в резерве
		var pawn = pawn_section.pieces.back()
		var king = get_opponent_king(player.side)
		var king_nest = king.nest
		var upper_nest = king_nest.nest_up if king.side == 0 else king_nest.nest_down
		if upper_nest != null and upper_nest.piece == null: # не имеет смысла делать эту проверку если король в верхнем ряду или место занято
			if king.current_moves.empty():
				var defend_count = 0
				if king.side == 0:
					defend_count += upper_nest.sente_attacks.size()
				elif king.side == 1:
					defend_count += upper_nest.gote_attacks.size()
				if defend_count == 0:
					pawn.current_moves.erase(upper_nest)
	
	var moves = []
	for piece in player.all_pieces:
		if piece.in_storage && !piece.on_top:
			continue
		moves += piece.get_moves()
	return moves

var prev_nest = null
var next_nest = null
var thread = null

signal moves_updated

# Обновляет данные всех ходов
func update_all_moves(prev_nest, next_nest):
	self.prev_nest = prev_nest
	self.next_nest = next_nest
	
	clear_attacks()
	
	var calc_amount = 0
	var black_pieces = []
	var white_pieces = []
	var pieces = []
	
	for player in session.players:
		player.moves.clear()
		player.ai_moves.clear()
		for piece in player.all_pieces:
			if piece.in_storage && !piece.on_top:
				continue
			if player.side == 0:
				black_pieces.append(piece)
			else:
				white_pieces.append(piece)
			pieces.append(piece)
			piece.update_moves()

	for piece in pieces:
		piece.update_real_moves()
		piece.need_update = false
	
	var show_check_dlg = false
	var show_checkmate_dlg = false
	
	_check = false
	
	var illegal_pawn_drop = false
	
	if !was_reconnect and king_in_check(session.turn_side) and !session.is_replay():
		show_checkmate_dlg = true
		session.gameover = true
		_checkmate_move = true
		session.gamestate = Games.GameResult.ILLEGAL_MOVE
		session.winner = session.players[0 if session.turn_side == 1 else 1]
	else:
		var checkside = 0
		if !session.game_template.sente_king.nest.gote_attacks.empty():
			show_check_dlg = true
			_check = true
			checkside = 0
		if !session.game_template.gote_king.nest.sente_attacks.empty():
			show_check_dlg = true
			_check = true
			checkside = 1
		if show_check_dlg and !session.is_replay():
		
			var player
			if checkside == 0:
				player = session.players[0]
			else:
				player = session.players[1]
			
			player.moves.clear()
			player.ai_moves.clear()
			
			if checkside == 0:
				for piece in black_pieces:
					piece.update_moves()
				for piece in black_pieces:
					piece.remove_checkmate_moves()
				for piece in black_pieces:
					piece.update_real_moves()
					piece.need_update = false
				player.move_count = 0
				for piece in black_pieces:
					if piece.in_storage && !piece.on_top:
						continue
					player.move_count += piece.add_moves()
			else:
				for piece in white_pieces:
					piece.update_moves()
				for piece in white_pieces:
					piece.remove_checkmate_moves()
				for piece in white_pieces:
					piece.update_real_moves()
					piece.need_update = false
				player.move_count = 0
				for piece in white_pieces:
					if piece.in_storage && !piece.on_top:
						continue
					player.move_count += piece.add_moves()
			
			if player.move_count == 0:
				var record = get_history().get_last_record()
				if record.piece_type == Games.ShogiPieceTypes.PAWN and record.drop:
					session.gamestate = Games.GameResult.ILLEGAL_MOVE
					session.winner = session.players[1 if session.turn_side == 0 else 0]
				else:
					session.gamestate = Games.GameResult.CHECKMATE
					session.winner = session.players[session.turn_side]
				
				show_check_dlg = false
				show_checkmate_dlg = true
				
			elif Profiles.get_current_settings().get_value(Settings.SV_SFX_CHECK_ENABLED):
				commentator.say_check()
				
#	else:
#		if !session.game_template.sente_king.nest.gote_attacks.empty():
#			show_check_dlg = true
#		if !session.game_template.gote_king.nest.sente_attacks.empty():
#			show_check_dlg = true
	
	if show_check_dlg and !session.is_replay():
		if Profiles.get_current_settings().get_value(Settings.SV_SFX_CHECK_ENABLED):
			commentator.say_check()
		gui.check_popup.start()
		gui.infopanel.start()
	elif show_checkmate_dlg:
#		if black_move_count == 0:
#			if Profiles.get_current_settings().get_value(Settings.SV_SFX_CHECK_ENABLED):
#				commentator.say_checkmate()
#			session.winner = session.players[1]
#		elif white_move_count == 0:
#			if Profiles.get_current_settings().get_value(Settings.SV_SFX_CHECK_ENABLED):
#				commentator.say_checkmate()
#			session.winner = session.players[0]
		if !session.is_replay():
			if Profiles.get_current_settings().get_value(Settings.SV_SFX_CHECK_ENABLED):
				commentator.say_checkmate()	
			show_checkmate_dlg(session.winner.side, session.gamestate == Games.GameResult.ILLEGAL_MOVE)
			
	#emit_signal("moves_updated")

func get_move_count(side):
	return session.players[side].move_count

func king_in_check(side):
	if side == 0:
		if !session.game_template.sente_king.nest.gote_attacks.empty():
			return true
	elif side == 1:
		if !session.game_template.gote_king.nest.sente_attacks.empty():
			return true
	return false

func opponent_king_in_check(side):
	if side == 1:
		if !session.game_template.sente_king.nest.gote_attacks.empty():
			return true
	elif side == 0:
		if !session.game_template.gote_king.nest.sente_attacks.empty():
			return true
	return false

func get_king(side):
	if side == 0:
		return session.game_template.sente_king
	elif side == 1:
		return session.game_template.gote_king
	return null

func get_opponent_king(side):
	if side == 1:
		return session.game_template.sente_king
	elif side == 0:
		return session.game_template.gote_king
	return null

func update_test_moves(side):
	var player = session.players[side]
	player.storage.update_temp_moves()
	for piece in player.all_pieces:
		piece.update_temp_moves()

func apply_game_settings():
	board.update_board()

###################################################################

var _current_replay

func setup_replay(replay):
	_current_replay = replay
	set_player_names(replay.black_name, replay.white_name)
	set_camera_side(0)
	
	var is_modern = replay.format == ReplayParser.ReplayFormat.KIF_MODERNSHOGI
	var counter = 0
	for move in replay.moves:
		var parsed_move
		if is_modern:
			parsed_move = ReplayParser.parse_converted_move(session.game_template, move)
		else:
			parsed_move = ReplayParser.parse_move(move)
		parsed_move.index = counter
		parsed_move.string = move
		add_record_to_history(parsed_move, false)
		counter += 1

func is_obsmode():
	return obsmode

func show_await_label():
	gui.show_await_label(true, "DESC_AWAITING", true)

func hide_await_label():
	gui.show_await_label(false, "DESC_AWAITING", true)


var cut_word_regex = null



func make_ai_move(move, hint):
	
	if cut_word_regex == null:
		cut_word_regex = RegEx.new()
		cut_word_regex.compile("\\S+")
	move = cut_word_regex.search(move).strings[0]
	
	if move == "resign":
		if !hint:
			game_resign(1 if session.turn_side == 0 else 0)
		return
	
	if move == "win":
		if !hint:
			game_win(1 if session.turn_side == 0 else 0)
		return
	
	if move == "draw":
		if !hint:
			game_draw()
		return
	
	var s = move
	var drop = move[1] == '*'
	#print("AI: " + s)
	
	var to_x = int(s[2])
	var to_y = Checks.get_number_from_letter(s[3])
	
	if drop:
		var piece_type = Checks.get_piece_type_from_symbol(s[0])
		if hint:
			var stack = session.players[session.turn_side].get_storage_stack(piece_type)
			spawn_arrow(stack, get_nest(to_x, to_y))
		else:
			var piece = session.players[session.turn_side].get_storage_stack(piece_type).peek_top_piece()
			if piece == null:
				print("ERROR: piece is null !")
				return
			piece._lift_up(0)
			yield(piece, "anim_completed")
			piece.move_or_eat(get_nest(to_x, to_y), false, 0)
		return
	
	var from_x = int(s[0])
	var from_y = Checks.get_number_from_letter(s[1])
	
	if hint:
		var promotion = false
		if s.length() > 4:
			promotion = s[4] == '+'
		
		spawn_arrow(get_nest(from_x, from_y), get_nest(to_x, to_y), promotion)
	else:
		var promotion = false
		if s.length() > 4:
			promotion = s[4] == '+'
		
		var piece = get_nest(from_x, from_y).piece
		if piece == null:
			print("AI_ERROR: Piece is null ! (" + str(from_x) + "," + str(from_y) + ")")
			return
		piece.select(true)
		yield(piece, "select_completed")
		piece.move_or_eat(get_nest(to_x, to_y), false, 1 if promotion else 0)
	
var startpos
	
func new_game(setup = true):
	send_to_ai_log("Newgame started", 0)
	
	if setup:
		# расстановка фигур
		session.game_template.setup(self, session.setup)
	
	# обновить ходы
	update_all_moves(null, null)
	
	clear_ai_log()
	
	startpos = get_current_sfen(false)
	var pos =  get_current_sfen(true)
	sfen_hash_array.append(pos.hash())
	reinit_ai()

func mp_smove(s):
	var move = ReplayParser.parse_converted_move(session.game_template, s)
	if move.is_drop:
		mp_drop(session.get_opponent_side(), move.piece_type, move.to.x, move.to.y)
	else:
		mp_move(move.from.x, move.from.y, move.to.x, move.to.y, move.promotion)
	
remotesync func mp_move(from_x, from_y, end_x, end_y, promote):
	var start_nest = get_nest(from_x, from_y)
	var end_nest = get_nest(end_x, end_y)
	if start_nest != null and end_nest != null:
		var piece = start_nest.piece
		if piece != null:
			if piece.side != session.your_side:
				piece._lift_up(0)
				yield(piece, "anim_completed")
			piece.move_or_eat(end_nest, false, 1 if promote else 0)

remotesync func mp_drop(side, piece_type, end_x, end_y):
	var end_nest = get_nest(end_x, end_y)
	if end_nest != null:
		var piece = null
		if side != session.your_side:
			piece = session.players[side].storage.get_piece_stack(piece_type).peek_top_piece()
			piece._lift_up(0)
			yield(piece, "anim_completed")
		else:
			piece = current_piece
		piece.move_or_eat(end_nest, false, 0)

func update_style_settings():
	update_board_style()
	update_grid_color()
	update_grid_thickness()
	update_background_color()
	for nest in nests.values():
		nest.update_scale()
		
func update_board_style():
	board.update_board_style()

func update_grid_color():
	board.update_grid_color()

func update_grid_thickness():
	board.update_grid_thickness()

func update_background_color():
	board.update_background_color(0)

puppet func build_history(hlog):
	if hlog is PoolByteArray:
		hlog = str(bytes2var(hlog))
	var strings = hlog.split('\n')
	var counter = 0
	for s in strings:
		if s=="":
			continue
		var parsed_move = ReplayParser.parse_converted_move(session.game_template, s)
		parsed_move.index = counter
		add_record_to_history(parsed_move, false)
		counter += 1
	# перемотка на последний ход
	gui.history_panel.history_to_end_forced()

puppet func build_position(sfen):
	if sfen is PoolByteArray:
		sfen = str(bytes2var(sfen))
	
	$GUI/Box/SFENLabel.text = sfen
	
	var promoted = false
	var col = 0
	var row = 0
	var turn_zone = false
	var drop_zone = false
	
	var isnum = false
	var num1
	var num = 1
	for s in sfen:
		if drop_zone:
			if s == ' ':
				continue
			if isnum:
				isnum = false
				if Checks.is_number(s):
					num = int(num1 + s)
					num1 = ""
					continue
				else:
					num = int(num1)
					num1 = ""
			isnum = Checks.is_number(s)
			if isnum:
				num1 = s
				continue
			for i in range(num):
				var type = Checks.get_en_piece_type(s)
				var side = Checks.get_side(s)
				create_storage_piece(session.game_template.get_piece_type(type), side)
			num = 1
		elif turn_zone:
			if s == 'w':
				session.turn_side = 1
				drop_zone = true
			elif s == 'b':
				session.turn_side = 0
				drop_zone = true
		else:
			if s == ' ':
				turn_zone = true
				continue
			if s == '/':
				col = 0
				row += 1
			elif Checks.is_number(s):
				col += int(s)
				continue
			else:
				if s == '+':
					promoted = true
					continue
				var type = Checks.get_en_piece_type(s)
				var side = Checks.get_side(s)
				var x = session.game_template.width - col
				var piece = create_piece(session.game_template.get_piece_type(type), x, row+1, side, Games.PieceStates.PROMOTED if promoted else  Games.PieceStates.NORMAL)		
				promoted = false
				
				if type == Games.ShogiPieceTypes.KING:
					if side == 0:
						session.game_template.sente_king = piece
					elif side == 1:
						session.game_template.gote_king = piece
				col += 1
	new_game(false)
	return self

func reinit_ai(reset = false):
	clear_ai_log()
	if session.is_multiplayer():
		return
	var engine_folder = OS.get_executable_path().get_base_dir() + "\\engines\\" + Profiles.get_value(Settings.SV_AI_ENGINE_FOLDER)
	var engine_exe = Profiles.get_value(Settings.SV_AI_ENGINE_EXE)
	ai.Init(engine_folder, engine_exe, reset)
	if ai.IsReady:
		if session.is_ai(): # для анализа игры использовать полную силу AI(по умолчанию), а при игре с AI установить сложность
			ai.SetSkillLevel(Profiles.get_value(Settings.SV_AI_ENGINE_SKILL_LEVEL))
		ai.NewGame(startpos)
		ai.SendMoves(get_history().get_ai_log(), session.is_ai_turn())

var hint_needed = false
	
func get_current_sfen(without_side = false):
	var s = ""
	var ecounter = 0
	# lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b
	for y in range(1, session.game_template.depth + 1):
		for x in range(1, session.game_template.width + 1):
			var nest = get_nest((session.game_template.width + 1) - x, y)
			var piece = nest.piece
			if piece != null:
				if ecounter > 0:
					s += str(ecounter)
					ecounter = 0
				s += Checks.get_sfen_piece_symbol(piece.get_type(), piece.side, piece.is_promoted())
			else:
				ecounter += 1
		if ecounter > 0:
			s += str(ecounter)
			ecounter = 0
		if y != session.game_template.depth:
			s += '/'
	
	s += ' '
	
	if !without_side:
		if session.turn_side == 0:
			s += 'b'
		elif session.turn_side == 1:
			s += 'w'
	
	var storage_sfen = ""
	for player in session.players:
		storage_sfen += player.storage.get_sfen()
	if storage_sfen != "":
		s += ' '
		s += storage_sfen
	
	s = s.strip_edges()
	$GUI/Box/SFENLabel.text = s
	return s

var _prev_record = null

func add_record_to_history(move, increase_selection):
	var record = Games.Record.new()
	if !move.same:
		_prev_record = record
	record.id = move.index
	record.is_replay = true
	record.side = 0 if (move.index % 2 == 0) else 1
	record.piece = null
	record.piece_type = move.piece_type
	record.drop = move.is_drop
	record.piece_was_promoted = move.promotion
	record.piece_is_promoted = move.is_promoted
	
	var move_from_x
	var move_from_y
	
	if !record.drop:
		move_from_x = move.from.x
		move_from_y = move.from.y
		
	var move_to_x
	var move_to_y
	
	if !move.same:
		move_to_x = move.to.x
		move_to_y = move.to.y
	else:
		move_to_x = _prev_record.next_nest.x
		move_to_y = _prev_record.next_nest.y
	if !record.drop:
		record.prev_nest = get_nest(move_from_x, move_from_y)
	else:
		record.prev_nest = null
	record.next_nest = get_nest(move_to_x, move_to_y)
	record.can_be_promoted = !record.drop and is_promotable_pos(record.next_nest.y, record.side)

	gui.add_history_record(record, increase_selection)
	record.init_string()

func is_promotable_pos(y, side):
	if side == 0:
		if y <= 3:
			return true
	elif side == 1:
		if y >= 7:
			return true
	return false

# Добавление хода в активной игре
func add_to_history(piece, piece_was_promoted, prev_nest, next_nest):
	var record = Games.Record.new()
	record.id = gui.get_history_record_count()
	record.is_replay = false
	record.side = piece.side
	record.piece = piece
	record.piece_type = piece.piece_template.type
	record.piece_was_promoted = piece_was_promoted
	record.piece_is_promoted = piece.is_promoted() and !piece_was_promoted
	record.prev_nest = prev_nest
	record.next_nest = next_nest
	record.eaten = next_nest.piece
	if next_nest.piece != null:
		record.eaten_was_promoted = next_nest.piece.was_promoted
	record.drop = prev_nest == null
	record.think_time = get_think_time()
	record.can_be_promoted = !record.drop and is_promotable_pos(record.next_nest.y, record.side)
	gui.add_history_record(record, true)
	record.init_string()
	if Profiles.get_current_settings().get_value(Settings.SV_SFX_SPEECH_ENABLED):
		commentator.say_record(record)

func extract_piece_from_storage(side, type):
	if type == Games.ShogiPieceTypes.PAWN:
		return session.players[side].storage.get_pawn_section().peek_top_piece()
	elif type == Games.ShogiPieceTypes.ROOK or type == Games.ShogiPieceTypes.BISHOP:
		return session.players[side].storage.sections[Games.PieceImportance.MAJOR].stacks[type].peek_top_piece()
	else:
		return session.players[side].storage.sections[Games.PieceImportance.MEDIUM].stacks[type].peek_top_piece()


# Начинает воспроизведение.
# idx - индекс на котором нужно остановиться
# boost - включить пропуск анимаций
func play(idx, boost):
	playback_boost = boost
	if session.turn_counter < idx:
		history_move_proc = HistoryPlayProc.FORWARD
	elif session.turn_counter > idx:
		history_move_proc = HistoryPlayProc.BACKWARD
	desired_idx = idx
	play_first_move_done = false

# Останавливает воспроизведение.
func stop():
	history_move_proc = HistoryPlayProc.NONE

# Делает ход назад.
func backward_move(record, boost):
	if !boost:
		if history_move_proc != HistoryPlayProc.NONE:
			if Profiles.get_value(Settings.SV_HISTORY_PLAYBACK_IS_FIXED):
				if play_first_move_done:
					yield(get_tree().create_timer(Profiles.get_value(Settings.SV_HISTORY_PLAYBACK_FIXED_DURATION)), "timeout")
			play_first_move_done = true
			
	if current_piece != null and current_piece.selected:
		var piece = current_piece
		current_piece.select()
		yield(piece, "select_completed")
	if boost:
		yield(get_tree().create_timer(0.01), "timeout")
	if !record.is_replay:
		record.piece.move_backward(record, boost)
	else:
		var piece = record.next_nest.piece
		piece.move_backward(record, boost)
		
# Делает ход вперёд.
func forward_move(record, boost):
	if boost:
		yield(get_tree().create_timer(0.01), "timeout")
	else:
		if history_move_proc != HistoryPlayProc.NONE:
			if Profiles.get_value(Settings.SV_HISTORY_PLAYBACK_IS_FIXED):
				if play_first_move_done:
					yield(get_tree().create_timer(Profiles.get_value(Settings.SV_HISTORY_PLAYBACK_FIXED_DURATION)), "timeout")
			play_first_move_done = true
			
	if !record.is_replay:
		record.piece.move_forward(record, boost)
	else:
		if record.drop:
			var piece = extract_piece_from_storage(record.side, record.piece_type)
			piece.move_forward(record, boost)
		else:
			var piece = record.prev_nest.piece
			piece.move_forward(record, boost)

# Очистка масок
func clear_nest_masks():
	for n in nests.values():
		n.hide_all_masks()

var last_selected_piece

func get_build_string(next_nest, prev_nest, promotion, piece):
	var move
	if prev_nest != null: 
		move = str(prev_nest.x) + prev_nest.letter + str(next_nest.x) + next_nest.letter + ('+' if promotion else '')
	else: # drops
		move = piece.get_en_symbol() + '*' + str(next_nest.x) + next_nest.letter
	return move


func get_history():
	return gui.history_panel.history

var draw_on_next_turn = false

func check_draw():
	for h in sfen_hash_array:
		if sfen_hash_array.count(h) == 4:
			if _check:
				game_perpetual_check(1 if session.turn_side == 0 else 0) # вечный шах ведет к проигрышу
			else:
				game_draw() # ничья
			break

func get_storage_nest(player_id, piece_type):
	return session.players[player_id].get_storage_stack(piece_type)

func spawn_arrow(from_nest, to_nest, promotion = false):
	if best_move_arrow != null:
		best_move_arrow.begin_hide()
		yield(best_move_arrow, "show_done")
		best_move_arrow.queue_free()
	
	best_move_arrow = arrow_prefab.instance()
	add_child(best_move_arrow)
	if from_nest == null:
		best_move_arrow.setup(get_storage_nest(to_nest.piece.side, to_nest.piece.get_type()), to_nest, false)
	else:
		best_move_arrow.setup(from_nest, to_nest, promotion)



func hint():
	if session.is_multiplayer():
		return
	if !hint_needed:
		if !session.is_ai_turn():
			UI.get_widget(UI.WIDGET_TOGGLE_HINT_MODE)._on_pressed()
			ai.Hint(get_history().get_ai_log(session.turn_counter))
		else:
			return
	if hint_needed:
		if best_move_arrow != null:
			UI.get_widget(UI.WIDGET_TOGGLE_HINT_MODE)._on_pressed()
			best_move_arrow.begin_hide()
	hint_needed = !hint_needed
	
# Следующий ход в игре.
func next_turn(prev_nest, next_nest, promotion):
	
	nest_select_lock = false
	_started = true
	
	session.turn_counter += 1
	
	current_piece = null
	
	update_all_moves(prev_nest, next_nest)
	
	var pos = get_current_sfen(true)
	sfen_hash_array.append(pos.hash())
	check_draw()
	
	session.turn_side = wrapi(session.turn_side + 1, 0, session.game_template.max_players)
	
	if Profiles.get_current_settings().get_value(Settings.SV_CAMERA_SWITCH_ENABLED):
		self.camera_side = session.turn_side
	
	lift_lock = false
	emit_signal("turn_changed")
	
	clear_nest_masks()
	stopwatch.start()
	
	get_history().get_previous_record().ai_string = get_build_string(next_nest, prev_nest, promotion, next_nest.piece)
	
	if best_move_arrow != null:
		if hint_needed and !session.is_ai_turn():
			if best_move_arrow != null:
				best_move_arrow.begin_hide()
			ai.Hint(get_history().get_ai_log())
			yield(best_move_arrow, "show_done")
			
	if !session.is_multiplayer():
		if !session.gameover:			
			ai.SendMoves(get_history().get_ai_log(), session.is_ai_turn())

	
# Предыдущий ход в истории.
func backward_turn(boost):

	if session.gameover:
		gui.gameover_dialog.beautiful_hide()
		UI.dialog_visible = false
		if !session.is_multiplayer():
			gui.await_label.visible = false
			
	session.gameover = false
	session.gamestate = Games.GameResult.NONE
	
	_checkmate_move = false
	
	nest_select_lock = false
	
	sfen_hash_array.pop_back()
	
	if !boost:
		update_all_moves(null, null)
	session.turn_side = wrapi(session.turn_side - 1, 0, session.game_template.max_players)
	
	session.turn_counter -= 1
	
	#if UI.enable_master_server_connection:
	#	UI.connection.NotifyTurnChanged(session.turn_counter)
	
	emit_signal("turn_changed")
	
	if history_move_proc == HistoryPlayProc.BACKWARD:
		if gui.history_panel.history.is_min():
			gui.history_panel.is_play_back_proc = false
			gui.history_panel.update_play_back_btn()

		if gui.history_panel.history.get_current_index() == desired_idx:
			history_move_proc = HistoryPlayProc.NONE
			update_all_moves(null, null)
			gui.history_panel.temp_autoscroll_disabled = false
			gui.history_panel._bproc = false
			if best_move_arrow != null:
				if hint_needed and !session.is_ai_turn():
					if best_move_arrow != null:
						best_move_arrow.begin_hide()
					ai.Hint(get_history().get_ai_log(session.turn_counter))
					yield(best_move_arrow, "show_done")
	else:
		if best_move_arrow != null:
			if hint_needed and !session.is_ai_turn():
				if best_move_arrow != null:
					best_move_arrow.begin_hide()
				ai.Hint(get_history().get_ai_log(session.turn_counter))
				yield(best_move_arrow, "show_done")			
	clear_nest_masks()
	
	var t = get_history().current_index - 1
	if t < 0:
		t = 0
	if t <= 0:
		t = 1
		if get_history().get_count() >= 1:
			t = 0
	var pm = get_history().moves[t]
	var piece = pm.next_nest.piece
	last_selected_piece = piece
	if piece != null:
		piece.set_mark(true)
		#if piece.prev_nest != null:
		#	piece.prev_nest.mark_last_move(true)
	
# Следующий ход в истории.
func forward_turn(boost, next_nest, prev_nest, promotion):
	
#	if best_move_arrow != null:
#		best_move_arrow.begin_hide()
	if session.is_replay():
		if get_history().get_previous_record().ai_string == null:
			get_history().get_previous_record().ai_string = get_build_string(next_nest, prev_nest, promotion, next_nest.piece)
			
	nest_select_lock = false
	
	var pos = get_current_sfen(true)
	sfen_hash_array.append(pos.hash())
	
	if !boost:
		update_all_moves(null, null)
		check_draw()
	
	session.turn_side = wrapi(session.turn_side + 1, 0, session.game_template.max_players)
	emit_signal("turn_changed")
	
	session.turn_counter += 1
	
	if history_move_proc == HistoryPlayProc.FORWARD:
		if gui.history_panel.history.get_current_index() == desired_idx:
			gui.history_panel.force_mode = false
			history_move_proc = HistoryPlayProc.NONE
			update_all_moves(null, null)
			check_draw()
			gui.history_panel.history.mark_last()
			gui.history_panel.temp_autoscroll_disabled = false
			gui.history_panel._bproc = false
			if best_move_arrow != null:
				if hint_needed and !session.is_ai_turn():
					if best_move_arrow != null:
						best_move_arrow.begin_hide()
					ai.Hint(get_history().get_ai_log(session.get_turn_count()))
					yield(best_move_arrow, "show_done")
	else:
		if best_move_arrow != null:
			if hint_needed and !session.is_ai_turn():
				best_move_arrow.begin_hide()
				if !gui.history_panel.history.is_max():
					ai.Hint(get_history().get_ai_log(session.get_turn_count()))
					yield(best_move_arrow, "show_done")
	if !boost:
		if gui.history_panel.history.is_max():
			gui.history_panel.is_play_proc = false
			gui.history_panel.update_play_btn()
			if session.is_replay():
				match _current_replay.result:
					Games.GameResult.NONE:
						gui.replaydone_popup.prefix = "LABEL_REPLAY_DONE"
						gui.replaydone_popup.text = ""
					Games.GameResult.REPETITION:
						gui.replaydone_popup.prefix = "LABEL_REPLAY_DONE2"
						gui.replaydone_popup.text = "DESC_DRAW"
					Games.GameResult.PERPETUAL_CHECK:
						gui.replaydone_popup.prefix = "LABEL_REPLAY_DONE2"
						gui.replaydone_popup.text = session.players[1 if session.turn_side == 0 else 0].name + " " + TranslationServer.translate("LABEL_PERPETUAL_CHECK")
					Games.GameResult.ILLEGAL_MOVE:
						gui.replaydone_popup.prefix = "LABEL_REPLAY_DONE2"
						gui.replaydone_popup.text = session.players[1 if session.turn_side == 0 else 0].name + " " + TranslationServer.translate("LABEL_ILLEGAL_MOVE")
					Games.GameResult.DISCONNECT:
						gui.replaydone_popup.prefix = "LABEL_REPLAY_DONE2"
						gui.replaydone_popup.text = session.players[session.turn_side].name + " " + TranslationServer.translate("LABEL_DISCONNECTED2")
					Games.GameResult.RESIGN:
						gui.replaydone_popup.prefix = "LABEL_REPLAY_DONE2"
						gui.replaydone_popup.text = session.players[session.turn_side].name + " " + TranslationServer.translate("LABEL_RESIGN2")
				gui.replaydone_popup.start()
				gui.infopanel.start()
	
	clear_nest_masks()

func go_back_if_possible():
	if get_show_state() == ShowState.NONE:
		if !session.is_replay():
			gui.show_dialog(UI.GUI_DLG_LEAVE)
		else:
			full_cleanup()
			gui.history_panel.clear()
			set_previous_screen(UI.get_named_element(UI.SCREEN_LIBRARY))
			UI.get_widget(UI.WIDGET_HIDEBAR_TOP).hide()
			open_screen(UI.SCREEN_LIBRARY, true)
			yield(gui.history_panel.beautiful_hide(), "fade_completed")

onready var ai_log_item_preset = preload("res://prefabs/AILogItem.tscn")
	
var need_max_ai_log_scroll = false

func send_to_ai_log(string, type):
	if !Profiles.get_value(Settings.SV_AI_ENGINE_ENABLE_LOG):
		return
	var log_item = ai_log_item_preset.instance()
	UI.ai_log_panel.console.add_child(log_item)
	log_item.set_text(string, type)
	need_max_ai_log_scroll = true

func clear_ai_log():
	UI.ai_log_panel.clear()

func hide_top_widgets():
	UI.get_widget(UI.WIDGET_TOGGLE_HINT_MODE).hide()
	UI.get_widget(UI.WIDGET_FLIP).hide()
	UI.get_widget(UI.WIDGET_RESIGN).hide()
	UI.get_widget(UI.WIDGET_TAKEBACK).hide()
	
func open_screen(screen, set_previous = true):
	
	hide_top_widgets()
	
	ai.Pause() # сделать паузу во время скрытия экрана игры
	
	if UI.htopbar.visible:
		UI.htopbar.hide()
		yield(UI.topbar.beautiful_show(), "fade_completed")
	gui.beautiful_hide()
	
	yield(UI.get_main_layout().beautiful_show(), "fade_completed")
	return goto_screen(screen, set_previous)

func exitgame():
	open_screen(UI.SCREEN_MAIN_MENU, false)

var _input_happens = false

func show_checkmate_dlg(winner, invalid_move):
	var text
	if !session.is_replay():
		session.gameover = true
	if session.is_multiplayer() or session.is_ai():
		gui.show_await_label(true, "DESC_GAMEOVER", false)
		if invalid_move:
			if session.is_observer():
				text = TranslationServer.translate("GAME_RESULT_ILLEGAL_MOVE") + " : " + session.players[winner].name + TranslationServer.translate("LABEL_IS_WINNER")
			else:
				if winner == session.your_side:
					text = TranslationServer.translate("GAME_RESULT_ILLEGAL_MOVE") + " : " + TranslationServer.translate("LABEL_VICTORY")
				else:
					text = TranslationServer.translate("GAME_RESULT_ILLEGAL_MOVE") + " : " + session.players[winner].name + TranslationServer.translate("LABEL_IS_WINNER")
		else:
			if session.is_observer():
				text = TranslationServer.translate("LABEL_CHECKMATE") + " : " + session.players[winner].name + TranslationServer.translate("LABEL_IS_WINNER")
			else:
				if winner == session.your_side:
					text = TranslationServer.translate("LABEL_CHECKMATE") + " : " + TranslationServer.translate("LABEL_VICTORY")
				else:
					text = TranslationServer.translate("LABEL_CHECKMATE") + " : " + session.players[winner].name + TranslationServer.translate("LABEL_IS_WINNER")
	else:
		if invalid_move:
			if winner == 0:
				text = "LABEL_GOTE_ILLEGAL_MOVE"
			elif winner == 1:
				text = "LABEL_SENTE_ILLEGAL_MOVE"
		else:
			if winner == 0:
				text = "LABEL_GOTE_CHECKMATE"
			elif winner == 1:
				text = "LABEL_SENTE_CHECKMATE"
	
	gui.gameover_dialog.get_node("VBox/LABEL_RESULT").text = text
	
	var prefix = "mp_" if session.is_multiplayer() else "sp_"
	var counter = Utility.get_file_count("user://Library/Replays/MKIF", prefix)
	gui.save_edit2.text = prefix + str(counter)
	gui.show_dialog(gui.gameover_dialog)

var s_move = ""

func save_ai_move(ai_move):
	s_move = ai_move

var best_move_arrow

func spawn_test_arrow(from_nest, to_nest, ptype, side):
	if best_move_arrow != null:
		best_move_arrow.begin_hide()
		yield(best_move_arrow, "show_done")
		best_move_arrow.queue_free()
	
	best_move_arrow = arrow_prefab.instance()
	add_child(best_move_arrow)
	
	best_move_arrow.setup_n(get_storage_nest(side, ptype), to_nest)
	yield(best_move_arrow, "show_done")
	
func _input(event):
	# Игра неактивна
	if !visible:
		return
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_T:
					ms_show_joining_dialog(0, "Chaosus", 0, 22, 1200, 0, 0, 0)
					#gui.show_promotion_dialog(null)
					#spawn_test_arrow(null, get_nest(1, 1), Games.ShogiPieceTypes.BISHOP, session.turn_side)
					pass
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				BUTTON_LEFT:
					_main_action()
				BUTTON_RIGHT:
					_secondary_action()
				BUTTON_WHEEL_UP:
					if Profiles.get_current_settings().get_value(Settings.SV_CAMERA_ZOOM_ENABLED):
						zoom(-ZOOMSPEED * get_process_delta_time())
				BUTTON_WHEEL_DOWN:
					if Profiles.get_current_settings().get_value(Settings.SV_CAMERA_ZOOM_ENABLED):
						zoom(ZOOMSPEED * get_process_delta_time())

func get_movelock():
	return nest_select_lock
								
func _main_action():
	if current_nest != null:
		if !session.is_replay():
			current_nest.main_action()

func _secondary_action():
	if current_nest != null:
		current_nest.secondary_action()

func is_your_turn():
	return session.get_your_side() == session.turn_side

func get_nestv(v):
	if v.x < 1 or v.y < 1 or v.x > session.game_template.width or v.y > session.game_template.depth:
		return null
	return nests[v]
	
func get_nest(x, y):
	return get_nestv(Vector2(x, y))

func has_panel_focus():
	return gui.history_has_focus() or UI.ai_log_panel.has_focus()

func zoom(s):
	if has_panel_focus():
		return
	_input_happens = true
	current_view.scale += Vector3(s, s, s)
	current_view.scale.x = clamp(current_view.scale.x, 0.2, board.board_scale / 1.8)
	current_view.scale.y = clamp(current_view.scale.y, 0.2, board.board_scale / 1.8)
	current_view.scale.z = clamp(current_view.scale.z, 0.2, board.board_scale / 1.8)

func reset_yaw():
	if current_view != null:
		current_view.rotation.y = 0

func reset_pitch():
	if current_view != null:
		current_view.rotation.x = 0

func reset_zoom():
	if current_view != null:
		current_view.scale = Vector3(1, 1 ,1)
		
func reset_pan():
	if current_view != null:
		current_view.translation.x = 0
		current_view.translation.z = 0

func reset_camera():
	if current_view != null:
		current_view.rotation.x = 0.0
		current_view.rotation.y = 0.0
		current_view.rotation.z = 0.0
		current_view.translation.x = 0.0
		current_view.translation.y = 0.0
		current_view.translation.z = 0.0
		current_view.scale = Vector3(1, 1, 1)
	
const ROTATELIMIT = 1.5
const ROTSPEED = 5.0
const ZOOMSPEED = 100.0

var _previous_mouse_pos = Vector2(0, 0)

func _process_input(delta):
	
	if Input.is_action_just_pressed("toggle_hint_mode"):
		hint()
	
	if Input.is_action_just_pressed("history_to_start"):
		gui.history_panel.history_to_start()
	elif Input.is_action_just_pressed("history_back"):
		gui.history_panel.history_back(false)
	elif Input.is_action_just_pressed("history_play"):
		gui.history_panel.play()
	elif Input.is_action_just_pressed("history_play_reversed"):
		gui.history_panel.play_back()
	elif Input.is_action_just_pressed("history_forward"):
		gui.history_panel.history_forward(false)
	elif Input.is_action_just_pressed("history_to_end"):
		gui.history_panel.history_to_end()
		
	if Input.is_action_just_pressed("show_history"):
		gui.history_panel.show_or_hide()
	
	# вращать влево/вправо
	if Profiles.get_current_settings().get_value(Settings.SV_CAMERA_YAW_ENABLED):
		var e = Profiles.get_value(Settings.SV_CAMERA_RESTRICT_YAW)
		if Input.is_action_pressed("rotate_camera_left"):
			_input_happens = true
			if e and !session.is_observer():
				current_view.rotation.y = clamp(current_view.rotation.y - (ROTSPEED * delta), -PI/2, PI/2)
			else:
				current_view.rotation.y = wrapf(current_view.rotation.y - (ROTSPEED * delta), 0.0, TAU)
		elif Input.is_action_pressed("rotate_camera_right"):
			_input_happens = true
			if e and !session.is_observer():
				current_view.rotation.y = clamp(current_view.rotation.y + (ROTSPEED * delta), -PI/2, PI/2)
			else:
				current_view.rotation.y = wrapf(current_view.rotation.y + (ROTSPEED * delta), 0.0, TAU)
			
	# вращать вверх/вниз
	if Profiles.get_current_settings().get_value(Settings.SV_CAMERA_PITCH_ENABLED):
		if camera_side == 0:
			if Input.is_action_pressed("rotate_camera_up"):
				_input_happens = true
				current_view.rotation.x = clamp(current_view.rotation.x - (ROTSPEED * delta), 0.0, ROTATELIMIT)
			elif Input.is_action_pressed("rotate_camera_down"):
				_input_happens = true
				current_view.rotation.x = clamp(current_view.rotation.x + (ROTSPEED * delta), 0.0, ROTATELIMIT)
		elif camera_side == 1:
			if Input.is_action_pressed("rotate_camera_down"):
				_input_happens = true
				current_view.rotation.x = clamp(current_view.rotation.x - (ROTSPEED * delta), -ROTATELIMIT, 0.0)
			elif Input.is_action_pressed("rotate_camera_up"):
				_input_happens = true
				current_view.rotation.x = clamp(current_view.rotation.x + (ROTSPEED * delta), -ROTATELIMIT, 0.0)
	
	var v = get_viewport().get_mouse_position()
	if Profiles.get_current_settings().get_value(Settings.SV_CAMERA_PAN_ENABLED):
		if Input.is_mouse_button_pressed(3):
			current_view.translate(Vector3((v.x - _previous_mouse_pos.x) * 0.01, 0.0, (v.y - _previous_mouse_pos.y) * 0.01))
	_previous_mouse_pos = v
			
	# сбросить камеру в первоначальное состояние
	if Input.is_action_just_pressed("reset_camera"):
		_input_happens = true
		reset_camera()
	
	# переключить вид сенте/готэ
	if Input.is_action_just_pressed("flip_board"):
		_input_happens = true
		flip_board()

	if UI.topbar_was_visible:
		$GUI/Box/HBoxReplay.rect_position.y = 142
	else:
		$GUI/Box/HBoxReplay.rect_position.y = 0

func flip_board():
	self.camera_side = wrapi(self.camera_side + 1, 0, session.game_template.max_players)

func _on_SecondTimer_timeout():
	pass
	#current_think_seconds += 1
	#if current_think_seconds == 2:
	#	if session.is_ai_turn() and !session.gameover:
	#		pass
			#send_to_ai_log("ProcessHasExited = " + str(ai.ProcessHasExited()), 2)
	# var player = session.get_current_player()
	#if player.remained_seconds >= 60:
	#	player.remained_minutes += 1
	#	current_think_seconds = 0

func get_think_time():
	pass
	#return str(current_think_minutes) + ":" + str(current_think_seconds)

func _process(delta):
	
	if !visible:
		return
	
	if session == null:
		return
	
	if need_max_ai_log_scroll:
		var bar = UI.ai_log_panel.sbox.get_v_scrollbar()
		bar.value = bar.max_value
		need_max_ai_log_scroll = false
	
	#$GUI/Box/ThinkTimeLabel.text = get_think_time()
	
	_process_input(delta)
	
	if _input_happens:
		_input_happens = false
		if UI.get_helper().visible:
			UI.get_helper().hide_tooltip()
	
	if history_move_proc != HistoryPlayProc.NONE:
		match history_move_proc:
			HistoryPlayProc.BACKWARD:
				gui.history_panel.history_back(playback_boost)
			HistoryPlayProc.FORWARD:
				gui.history_panel.history_forward(playback_boost)

func _ready():
	self.title = "GAME_TITLE"
	UI.set_game(self)
	tag = UI.SCREEN_GAME
	_register_multiplayer_events()
	hidden_by_default = true
	hide_layout = true

func goto_screen(screen, set_previous = true):
	
	UI.get_widget(UI.WIDGET_HIDEBAR_TOP).hide()
	UI.get_widget(UI.WIDGET_STYLE_PIECE).hide()
	
	#yield(UI.ai_panel.beautiful_hide(), "fade_completed")
	
	return .goto_screen(screen, set_previous)



func set_piece_theme(tag):
	Profiles.get_current_settings().set_value(Settings.SV_STYLES_PIECE_THEME, tag)
	session.game_template.change_piece_theme(tag)
	get_tree().call_group("piece", "update_piece_theme")
	apply_game_settings()
	
func update_history_panel_position(show):
	gui.history_panel.update_panel_position(show)

func beautiful_hide():
	on_hide()
	return .beautiful_hide()

func on_hide():
	board.visible = false
	gui.set_visible(false)
	gui.save_btn.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	current_view.disable()
	ai.Pause()
	
	gui.get_node("WhitePlayerPanel").beautiful_hide()
	gui.get_node("BlackPlayerPanel").beautiful_hide()

func beautiful_show():
	on_show()
	return .beautiful_show()

func on_show():
	board.visible = true
	gui.set_visible(true)
	gui.save_btn.visible = !session.is_replay()
	UI.get_widget(UI.WIDGET_TOGGLE_HINT_MODE).visible = !session.is_multiplayer()
	UI.get_widget(UI.WIDGET_SETTINGS).show()
	UI.get_widget(UI.WIDGET_STYLE_PIECE).show()
	UI.get_widget(UI.WIDGET_FLIP).show()
	
	#gui.get_node("WhitePlayerPanel").beautiful_show()
	#gui.get_node("BlackPlayerPanel").beautiful_show()
	
	if session.is_multiplayer() and !is_obsmode():
		UI.get_widget(UI.WIDGET_RESIGN).show()
		if !session.is_rated:
			UI.get_widget(UI.WIDGET_TAKEBACK).show()
		else:
			UI.get_widget(UI.WIDGET_TAKEBACK).hide()
	else:
		stopwatch.pause_mode = false
		UI.get_widget(UI.WIDGET_RESIGN).hide()
		UI.get_widget(UI.WIDGET_TAKEBACK).hide()
	# Показать окно истории вновь, если оно было открыто
	if UI.history_was_visible:
			gui.history_panel.beautiful_show()
	apply_game_settings()
	if !UI.topbar_was_visible:
		yield(UI.topbar.beautiful_hide(), "fade_completed")
		UI.htopbar.show()
	else:
		UI.htopbar.hide()
		UI.get_widget(UI.WIDGET_HIDEBAR_TOP).show()		
	if UI.leftbar_was_visible:
		if UI.game_left_bar_mode == 0:
			UI.game_left_bar_m0.beautiful_show()
		elif UI.game_left_bar_mode == 1:
			UI.game_left_bar_m1.beautiful_show()
		UI.game_left_hbar.beautiful_hide()
	else:
		UI.game_left_hbar.beautiful_show()
		if UI.rightbar_was_visible:
			UI.game_right_bar.beautiful_show()
			UI.game_right_hbar.beautiful_hide()
		else:
			UI.game_right_hbar.beautiful_show()
		gui.history_panel.update_panel_position(UI.rightbar_was_visible)
	ai.Resume()
	
func leave():
	if session.global_game:
		Network.request_close_game()
	
	if best_move_arrow != null:
		best_move_arrow.begin_hide()
		yield(best_move_arrow, "show_done")
	
	was_reconnect = false
	
	#if UI.enable_master_server_connection:
	#	UI.connection.Disconnect()
	#	UI.get_root().server_screen.save_state = 0
	
	gui.history_panel.clear()
	ai.Shutdown()
	UI.get_root().setup_screen.create_click = false

	if session.is_multiplayer():
		if !session.global_game:
			terminate_network()
	
	full_cleanup()
	
	stopwatch.stop()
	
	if UI.server_list_enabled:
		open_screen(UI.SCREEN_SERVER, false)
	else:
		open_screen(UI.SCREEN_MAIN_MENU, false)
	

func save_current_game(filename, format):
	var s = ""
	match session.gamestate:
		Games.GameResult.DISCONNECT:
			s = "Disconnection"
		Games.GameResult.RESIGN:
			s = "Resign"
		Games.GameResult.REPETITION:
			s = "Repetition"
		Games.GameResult.PERPETUAL_CHECK:
			s = "PerpetualCheck"
		Games.GameResult.ILLEGAL_MOVE:
			s = "IllegalMove"
		Games.GameResult.DECLARE_WIN:
			s = "DeclareWin"
		Games.GameResult.CHECKMATE:
			s = "Checkmate"
	save_game(filename, format, s)

func save_game(filename, format, result):
	
	# Получение времени
	var ut = OS.get_datetime_from_unix_time(OS.get_unix_time())
	var date = str(ut["year"]) + "/" + str(ut["month"]) + "/" + str(ut["day"])
	
	var place = "ModernShogi v" + UI.get_version() + " " + ("(Multiplayer)" if session.is_multiplayer() else "(Singleplayer)")
	
	var minutes = str(session.max_minutes)
	var seconds = str(session.max_seconds)
	
	var handicap = session.setup
	
	var bname = session.get_black_player_name()
	var wname = session.get_white_player_name()
	
	var tc_result = get_think_time()
	
	save_kif(filename, format, date, place, minutes, seconds, handicap, bname, wname, gui.history_panel.history.moves, result, tc_result)

func convert_move(format, step, move, at):
	var indent = ""
	if step < 10:
		indent += "   "
	elif step < 100:
		indent += "  "
	elif step < 999:
		indent += " "
	
	return indent + str(step) + " " + move + "   ( " +  at + "/)"	


func save_kif(filename, format, date, place, tc_min, tc_byo, handicap, black, white, hlog, result, tc_result):
	var ext = ""
	var folder = ""
	var file_header = ""
	var date_name = ""
	var div = ""
	var place_name = ""
	var time_name = ""
	var minutes = ""
	var seconds = ""
	var handicap_name = ""
	var black_name = ""
	var white_name = ""
	var moves_header = ""
	var thandicap = ""
	
	match format:
		ReplayParser.ReplayFormat.KIF_81DOJO:
			ext = "kif"
			folder = "KIF"
			file_header = "#KIF version=2.0 encoding=UTF-8"
			date_name = "開始日時"
			div = "："
			place_name = "場所"
			time_name = "持ち時間"
			minutes = "分"
			seconds = "秒"
			handicap_name = "手合割"
			black_name = "先手"
			white_name = "後手"
			moves_header = "手数----指手---------消費時間--"
			match handicap:
				Games.ShogiHandicaps.NONE:
					thandicap = "平手"
		ReplayParser.ReplayFormat.KIF_MODERNSHOGI:
			ext = "mkif"
			folder = "MKIF"
			file_header = "#MKIF version=1.0 encoding=UTF-8"
			date_name = "Date"
			div = ":"
			place_name = "Place"
			time_name = "TimeControl"
			minutes = "m"
			seconds = "s"
			handicap_name = "Handicap"
			black_name = "Black"
			white_name = "White"
			moves_header = "#----Move---------ThinkTime--"
			match handicap:
				Games.ShogiHandicaps.NONE:
					thandicap = "None"
				Games.ShogiHandicaps.LEFT_LANCE:
					thandicap = "LeftLance"
				Games.ShogiHandicaps.BISHOP:
					thandicap = "Bishop"
				Games.ShogiHandicaps.ROOK:
					thandicap = "Rook"
				Games.ShogiHandicaps.ROOK_LEFT_LANCE:
					thandicap = "RookLeftLance"
				Games.ShogiHandicaps.PIECE2:
					thandicap = "Piece2"
				Games.ShogiHandicaps.PIECE3:
					thandicap = "Piece3"
				Games.ShogiHandicaps.PIECE4:
					thandicap = "Piece4"
				Games.ShogiHandicaps.PIECE5:
					thandicap = "Piece5"
				Games.ShogiHandicaps.PIECE6:
					thandicap = "Piece6"
				Games.ShogiHandicaps.PIECE7:
					thandicap = "Piece7"
				Games.ShogiHandicaps.PIECE8:
					thandicap = "Piece8"
				Games.ShogiHandicaps.PIECE9:
					thandicap = "Piece9"
				Games.ShogiHandicaps.PIECE10:
					thandicap = "Piece10"
				Games.ShogiHandicaps.PAWNS3:
					thandicap = "Pawns3"
				Games.ShogiHandicaps.NAKED_KING:
					thandicap = "NakedKing"
				Games.ShogiHandicaps.DRAGONFLY:
					thandicap = "Dragonfly"
				Games.ShogiHandicaps.DRAGONFLY_LANCES:
					thandicap = "DragonflyLances"
				Games.ShogiHandicaps.DRAGONFLY_LANCES_KNIGHTS:
					thandicap = "DragonflyLancesKnights"
							
	var file = File.new()
	if file.open("user://Library/Replays/%s/%s" % [folder, filename] + "." + ext, File.WRITE) != OK:
		return false
	file.store_line(file_header)
	file.store_line(date_name + div + date)
	file.store_line(place_name + div + place)
	file.store_line(time_name + div + tc_min + minutes + "+" + tc_byo + seconds)
	file.store_line(handicap_name + div + thandicap)
	file.store_line(black_name + div + black)
	file.store_line(white_name + div + white)
	file.store_line(moves_header)
	var counter = 1
	for move in hlog:
		file.store_line(convert_move(format, counter, move.string, move.think_time))
		counter += 1
	file.store_line(convert_move(format, counter, result, tc_result))
	file.close()
	return true



# Команда сдачи партии для хоста и другого игрока
remotesync func resign_remote(side):
	show_resign(side)

func _show_gameover(result, side = -1):
	session.gameover = true
	session.gamestate = result
	var text = ""
	match result:
		Games.GameResult.PERPETUAL_CHECK:
			text = TranslationServer.translate("DESC_GAMEOVER") + "! (" + TranslationServer.translate("DESC_PCHECK") + ") " + session.players[side].name + " " + TranslationServer.translate("LABEL_WON") + "."
		Games.GameResult.DECLARE_WIN:
			continue
		Games.GameResult.ILLEGAL_MOVE:
			continue
		Games.GameResult.RESIGN:
			text = TranslationServer.translate("DESC_GAMEOVER") + "! " + session.players[side].name + " " + TranslationServer.translate("LABEL_WON") + "."
		Games.GameResult.REPETITION:
			text = TranslationServer.translate("DESC_DRAW") + "!"
	
	if !session.is_replay():
		var prefix = "mp_" if session.is_multiplayer() else "sp_"
		var counter = Utility.get_file_count("user://Library/Replays/MKIF", prefix)
		gui.save_edit2.text = prefix + str(counter)
		
		gui.gameover_dialog.get_node("VBox/LABEL_RESULT").text = text
		gui.show_dialog(UI.GUI_DLG_GAMEOVER)
		gui.show_await_label(true, text, false)

func game_resign(side):
	_show_gameover(Games.GameResult.RESIGN, side)
	if session.global_game:
		if side == session.get_your_side(): # отправить ваш проигрыш на сервер
			Network.send_result(session.gamestate)

func game_perpetual_check(side):
	_show_gameover(Games.GameResult.PERPETUAL_CHECK, side)
	if session.global_game:
		if side == session.get_your_side():
			Network.send_result(session.gamestate)
		
func game_win(side):
	_show_gameover(Games.GameResult.DECLARE_WIN, side)

func game_draw():
	_show_gameover(Games.GameResult.REPETITION)
	if session.global_game:
		Network.send_result(session.gamestate)

func show_resign(index):
	session.gameover = true
	session.gamestate = Games.GameResult.RESIGN
	
	var text = ""
	if index == session.your_side:
		text = "LABEL_RESIGN" 
	else:
		text = "LABEL_OPP_RESIGN"
		
	var prefix = "mp_" if session.is_multiplayer() else "sp_"
	var counter = Utility.get_file_count("user://Library/Replays/MKIF", prefix)
	gui.save_edit2.text = prefix + str(counter)
		
	gui.gameover_dialog.get_node("VBox/LABEL_RESULT").text = text
	gui.show_dialog(UI.GUI_DLG_GAMEOVER)
	gui.show_await_label(true, "DESC_GAMEOVER", false)
	

func mp_draw(index):
	pass

func mp_gamedone(result, caller_index):
	match result:
		Games.GameResult.RESIGN:
			show_resign(caller_index)
		
# Команда сдачи партии на хосте
func resign_host():
	if session.global_game:
		Network.send_result(Games.GameResult.RESIGN)
	else:
		if !session.has_other_player:
			return
		session.gameover = true
		session.gamestate = Games.GameResult.RESIGN
		rpc("resign_remote", session.your_side)
		gui.show_await_label(true, "DESC_GAMEOVER", false)

# Обработка возврата хода

# Получение запроса на возврат хода
func ms_takeback():
	gui.show_dialog(UI.GUI_DLG_TAKEBACK)

# Получение запроса на возврат хода
remote func request_takeback():
	gui.show_dialog(UI.GUI_DLG_TAKEBACK)

# Получение положительного ответа на возврат хода
remote func request_takeback_yes():
	gui.show_await_label(false, "DESC_AWAITING", true)
	gui.takeback_yes_popup.start()
	gui.infopanel.start()
	gui.history_panel.history_back(false, true)
	gui.history_panel.erase_next_moves()
	
# Получение отрицательного ответа на возврат хода	
remote func request_takeback_no():
	gui.takeback_no_popup.start()
	gui.infopanel.start()

# Запрос на возврат хода
func takeback_request():
	if session.global_game:
		gui.await_answer_popup.start()
		gui.infopanel.start()
		Network.request_takeback()
	else:
		gui.infopanel.start()
		if !session.has_other_player:
			gui.await_answer_disconnected.start()
			return
		else:
			gui.await_answer_popup.start()
		rpc_id(1, "request_takeback")
#	history_panel.history_back(false, true)
#	history_panel.erase_next_moves()
#	rpc("request_takeback_yes")

# Положительный ответ на запрос возрата хода
func takeback_accept():
	if session.global_game:
		Network.send_accept_takeback()
	else:
		session.gameover = false
		rpc("request_takeback_yes")
	
# Отрицательный ответ на запрос возрата хода
func takeback_cancel():
	if session.global_game:
		Network.send_decline_takeback()
	else:
		rpc("request_takeback_no")

# ENET NETWORKING STUFF

# Закрыть соединение
func terminate_network():
	UI.get_root().close_current_connection()

# Инициализация событий мультиплеера
func _register_multiplayer_events():
	multiplayer.connect("connected_to_server", self, "_connected_to_server")
	multiplayer.connect("server_disconnected", self, "_server_disconnected")
	multiplayer.connect("connection_failed", self, "_connected_fail")
	multiplayer.connect("network_peer_connected", self, "_network_peer_connected")
	multiplayer.connect("network_peer_disconnected", self, "_network_peer_disconnected")

# Emitted whenever this MultiplayerAPI's network_peer fails to establish a connection to a server. Only emitted on clients.
func _connected_fail():
	UI.get_root().on_connection_failed()
	
# Emitted whenever this MultiplayerAPI's network_peer successfully connected to a server. Only emitted on clients.
func _connected_to_server():
	var id = multiplayer.get_network_unique_id()
	peers[id] = PeerData.new()
	peers[id].name = username
	
# Emitted whenever this MultiplayerAPI's network_peer disconnects from server. Only emitted on clients.
func _server_disconnected():
	if session.has_other_player:
		session.has_other_player = false
		session.gameover = true
		session.gamestate = Games.GameResult.DISCONNECT
		gui.show_await_label(true, "DESC_GAMEOVER", false)

# Emitted whenever this MultiplayerAPI's network_peer connects with a new peer. ID is the peer ID of the new peer. 
# Clients get notified when other clients connect to the same server. 
# Upon connecting to a server, a client also receives this signal for the server (with ID being 1).
func _network_peer_connected(id):
	peers[id] = PeerData.new()
	if id == 1: # соединение с сервером
		self.set_network_master(id)
		GameStarter.start_join_session()
		rpc("client_ready", multiplayer.get_network_unique_id(), username, obsmode)

remote func force_leave():
	gui.get_node("Box/LeavePopup2").show()

remotesync func player_lost(name, is_obs):
	if is_obs:
		gui.disconnected_obs_popup.prefix = TranslationServer.translate("DESC_OBSERVER") + " " +  name
		gui.disconnected_obs_popup.start()
	else:
		gui.disconnected_popup.prefix = name
		gui.disconnected_popup.start()
	gui.infopanel.start()
	
# Emitted whenever this MultiplayerAPI's network_peer disconnects from a peer. 
# Clients get notified when other clients disconnect from the same server.
func _network_peer_disconnected(id):
	var state = peers[id].state
	var name = peers[id].name
	peers.erase(id)
	if state == 0:
		return
	if state == 1: # если отсоединился игрок
		session.gamestate = Games.GameResult.DISCONNECT
		session.has_other_player = false
		if !session.is_gameover():
			gui.show_await_label(true, "DESC_AWAITING", true)
	if multiplayer.is_network_server():
		rpc("player_lost", name, state == 2)
	if id == 1: # если соединение с сервером разорвано
		# пытаемся подсоединиться снова если игра не закончена
		if session != null:
			if !session.is_gameover():
				reconnect()

var was_reconnect = false
		
func reconnect():
	terminate_network()
	gui.show_await_label(true, "DESC_RECONNECT", true)
	full_cleanup()
	Network.reconnect_from_game()

# Клиентская функция получения информации о сервере
puppet func player_getinfo(host_name, host_side, move_count, gameresult, handicap):
	if !multiplayer.is_network_server():
		
		session.setup = handicap
		
		session.has_other_player = true
		session.your_side = 1 if host_side == 0 else 0
		
		_started = move_count > 0
		
		var your_name = username

		if  host_name == your_name:
			your_name += "2"
		
		var bname
		var wname
		
		if session.your_side == 0:
			bname = your_name
			wname = host_name
			_opponent_name = wname
		elif session.your_side == 1:
			bname = host_name
			wname = your_name
			_opponent_name = bname
		
		set_camera_side(session.your_side)
		
		set_player_names(bname, wname)
		
		if gameresult == Games.GameResult.DISCONNECT:
			session.gamestate = Games.GameResult.NONE
			was_reconnect = true
		else:
			session.gamestate = gameresult
			
			if gameresult != Games.GameResult.ILLEGAL_MOVE and gameresult != Games.GameResult.NONE:
				session.gameover = true
				gui.show_await_label(true, "DESC_GAMEOVER", false)
			else:
				gui.show_await_label(false, "DESC_AWAITING", true)
				
		var id = multiplayer.get_network_unique_id()
		rpc_id(1, "request_sfen", id)
		rpc_id(1, "request_history", id)

puppet func obs_getinfo(black_name, white_name, move_count, gameresult, handicap):
	if !multiplayer.is_network_server():
		_started = move_count > 0
		
		session.obs_mode = true
		
		set_camera_side(-1)
		set_player_names(black_name, white_name)
		
		if gameresult == Games.GameResult.DISCONNECT:
			session.gamestate = Games.GameResult.NONE
		else:
			session.gamestate = gameresult
			if gameresult != Games.GameResult.NONE:
				session.gameover = true
				gui.show_await_label(true, "DESC_GAMEOVER", false)
		
		var id = multiplayer.get_network_unique_id()
		rpc_id(1, "request_sfen", id)
		rpc_id(1, "request_history", id)

puppetsync func player_joined(id, name):
	peers[id].name = name
	if multiplayer.get_network_unique_id() != id:
		if was_reconnect:
			gui.reconnected_popup.prefix = name
			gui.reconnected_popup.start()
		else:
			gui.connected_popup.prefix = name
			gui.connected_popup.start()
		gui.infopanel.start()

puppetsync func obs_joined(id, name):
	peers[id].name = name
	if multiplayer.get_network_unique_id() != id:
		gui.connected_obs_popup.prefix = TranslationServer.translate("DESC_OBSERVER") + " " + name
		gui.connected_obs_popup.start()
		gui.infopanel.start()
	
master func request_sfen(id):
	rpc_id(id, "build_position", var2bytes(get_current_sfen()))

master func request_history(id):
	rpc_id(id, "build_history", var2bytes(gui.get_history_log()))
		
# Серверная функция принятия нового игрока
master func client_ready(id, client_name, obsmode):
	if multiplayer.is_network_server():
		peers[id] = PeerData.new()
		if obsmode: # наблюдатель присоединился
			#if UI.enable_master_server_connection:
			#	UI.connection.NotifyJoin(true)
		
			peers[id].state = 2
			# передать ему данные о сервере
			rpc_id(id, "obs_getinfo",  session.get_black_player_name(), session.get_white_player_name(), session.turn_counter, session.gamestate, session.setup)
			# оповестить других игроков
			rpc("obs_joined", id, client_name)
		else:
			if session.has_other_player:
				peers[id].state = 0
				rpc_id(id, "force_leave")
				return
			peers[id].state = 1
			
			#if UI.enable_master_server_connection:
			#	UI.connection.NotifyJoin(false)
			
			session.has_other_player = true
			
			var your_name = session.get_your_name()
			
			if client_name == your_name:
				client_name += "2"
			
			var bname
			var wname
			
			if session.your_side == 0:
				bname = your_name
				wname = client_name
				_opponent_name = wname
			elif session.your_side == 1:
				bname = client_name
				wname = your_name
				_opponent_name = bname
			
			set_player_names(bname, wname)
			if !session.is_gameover():
				gui.show_await_label(false, "DESC_AWAITING", true)
				
			gui.connected_popup.prefix = _opponent_name
			gui.connected_popup.start()
			gui.infopanel.start()
			
			rpc_id(id,"player_getinfo", session.get_your_name(), session.your_side, session.turn_counter, session.gamestate, session.setup)
			rpc("player_joined", id, client_name)
			
			gui.show_await_label(false, "DESC_AWAITING", true)

func set_player_name(idx, name):
	if idx == 0:
		$GUI/Box/HistoryPanel/VBox/VBoxShogi/HBoxTableHeader/HBoxPlayers/LABEL_BLACK_INPUT.text = name
		$GUI/Box/HistoryPanel/VBox/VBoxChess/HBoxTableHeader/LABEL_BLACK_INPUT.text = name
	elif idx == 1:
		$GUI/Box/HistoryPanel/VBox/VBoxShogi/HBoxTableHeader/HBoxPlayers/LABEL_WHITE_INPUT.text = name
		$GUI/Box/HistoryPanel/VBox/VBoxChess/HBoxTableHeader/LABEL_WHITE_INPUT.text = name
		
func set_player_names(black, white):
	session.players[0].name = black
	session.players[1].name = white
	$GUI/Box/HistoryPanel/VBox/VBoxShogi/HBoxTableHeader/HBoxPlayers/LABEL_BLACK_INPUT.text = black
	$GUI/Box/HistoryPanel/VBox/VBoxShogi/HBoxTableHeader/HBoxPlayers/LABEL_WHITE_INPUT.text = white
	$GUI/Box/HistoryPanel/VBox/VBoxChess/HBoxTableHeader/LABEL_BLACK_INPUT.text = black
	$GUI/Box/HistoryPanel/VBox/VBoxChess/HBoxTableHeader/LABEL_WHITE_INPUT.text = white

func reset_names():
	$GUI/Box/HistoryPanel/VBox/VBoxShogi/HBoxTableHeader/HBoxPlayers/LABEL_BLACK_INPUT.text = "?"
	$GUI/Box/HistoryPanel/VBox/VBoxShogi/HBoxTableHeader/HBoxPlayers/LABEL_WHITE_INPUT.text = "?"
	$GUI/Box/HistoryPanel/VBox/VBoxChess/HBoxTableHeader/LABEL_BLACK_INPUT.text = "?"
	$GUI/Box/HistoryPanel/VBox/VBoxChess/HBoxTableHeader/LABEL_WHITE_INPUT.text = "?"
