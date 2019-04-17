extends Node

# Game.gd - содержит различные методы и классы  игры(чтобы разгрузить GameScreen.gd)

class StorageSection:
	var side
	var importance
	var stacks = {}
	var storage_prefab
	
	func add_moves():
		var move_count = 0
		for stack in stacks.values():
			move_count += stack.add_moves()
		return move_count
	
	func update_top_pieces():
		for stack in stacks.values():
			stack.update_top_piece()
	
	func update_temp_moves():
		for stack in stacks.values():
			stack.update_temp_moves()
	
	func remove_checkmate_moves():
		for stack in stacks.values():
			stack.remove_checkmate_moves()
			
	func update_realmoves_top_pieces():
		for stack in stacks.values():
			stack.update_realmoves_top_piece()
	
	func _init(side, importance):
		self.side = side
		self.importance = importance
		storage_prefab = preload("res://scenes/StorageNest.tscn")
		
	func cleanup():
		stacks.clear()
		
	func clear():
		for stack in stacks.values():
			stack.clear()
			
	func add_piece_type(piece_template, board):
		var storage = storage_prefab.instance()
		stacks[piece_template.type] = storage
		storage.setup(piece_template, side, stacks.size(), importance, board)
		return stacks[piece_template.type]
		
	func add_piece(piece):
		stacks[piece.piece_template.type].push(piece)
	
	func get_childs():
		return stacks

class Storage:
	var side = -1
	var sections = {}
	var stacks = {}
	
	func get_piece_stack(type):
		return stacks[type]
	
	func clear():
		for section in sections.values():
			section.clear()
	
	func get_sfen():
		var s = ""
		var rook_section = sections[Games.PieceImportance.MAJOR].stacks[Games.ShogiPieceTypes.ROOK]
		var bishop_section = sections[Games.PieceImportance.MAJOR].stacks[Games.ShogiPieceTypes.BISHOP]
		var gold_section = sections[Games.PieceImportance.MEDIUM].stacks[Games.ShogiPieceTypes.GOLD]
		var silver_section = sections[Games.PieceImportance.MEDIUM].stacks[Games.ShogiPieceTypes.SILVER]
		var knight_section = sections[Games.PieceImportance.MEDIUM].stacks[Games.ShogiPieceTypes.KNIGHT]
		var lance_section = sections[Games.PieceImportance.MEDIUM].stacks[Games.ShogiPieceTypes.LANCE]
		var pawn_section = sections[Games.PieceImportance.MINOR].stacks[Games.ShogiPieceTypes.PAWN]
		
		s += rook_section.get_sfen()
		s += bishop_section.get_sfen()
		s += gold_section.get_sfen()
		s += silver_section.get_sfen()
		s += knight_section.get_sfen()
		s += lance_section.get_sfen()
		s += pawn_section.get_sfen()
		
		return s
	
	func get_pawn_section():
		return sections[Games.PieceImportance.MINOR].stacks[Games.ShogiPieceTypes.PAWN]
	
	func remove_checkmate_moves():
		for section in sections.values():
			section.remove_checkmate_moves()
	
	func update_temp_moves():
		for section in sections.values():
			section.update_temp_moves()
	
	func update_realmoves_top_pieces():
		for section in sections.values():
			section.update_realmoves_top_pieces()
	
	func update_top_pieces():
		for section in sections.values():
			section.update_top_pieces()
	
	func add_moves():
		var move_count = 0
		for section in sections.values():
			move_count += section.add_moves()
		return move_count
	
	func _init(side):
		self.side = side
	
	# Добавляет секцию
	func add_section(importance):
		sections[importance] = StorageSection.new(side, importance)
		
	# Добавляет тип фигуры
	func add_piece_type(piece_template, board):
		stacks[piece_template.type] = sections[piece_template.importance].add_piece_type(piece_template, board)
	
	# Добавляет фигуру
	func add_piece(piece):
		piece.in_storage = true
		
		if piece.is_promoted():
			piece.unpromote()
		
		piece.nest = null
		
		sections[piece.piece_template.importance].add_piece(piece)
		
	func cleanup():
		for section in sections.values():
			for stack in section.get_childs().values():
				stack.free()
		sections.clear()
	
	func add_to_scene(scene):
		for section in sections.values():
			for stack in section.get_childs().values():
				scene.add_child(stack)

class Player:
	var side = 0 # сентэ(0) или готэ(1), а также индекс игрока
	var name # строка имени игрока
	var key = -1
	var all_pieces = [] # все фигуры
	var moves = [] # массив возможных ходов(тайлы)
	var ai_moves = [] # массив возможных ходов вместе с превращениями(для AI)
	var move_count = 0
	var storage # массив съеденных фигур, если droprule включен оттуда их можно брать
	var peer # id в сети
	var current_minutes = 0
	var current_seconds = 0
	var current_byomi = 0
	var byomi_mode = false
	var panel = null
	
	func set_name(name):
		self.name = name
		panel.set_name(name)
	
	func _init(index):
		self.side = index
		storage = Storage.new(index)
		storage.add_section(Games.PieceImportance.MINOR)
		storage.add_section(Games.PieceImportance.MEDIUM)
		storage.add_section(Games.PieceImportance.MAJOR)
	
	func get_storage_stack(piece_type):
		if piece_type == Games.ShogiPieceTypes.KING:
			return null
		elif piece_type == Games.ShogiPieceTypes.PAWN:
			 return storage.get_pawn_section()
		elif piece_type == Games.ShogiPieceTypes.ROOK or piece_type == Games.ShogiPieceTypes.BISHOP:
			return storage.sections[Games.PieceImportance.MAJOR].stacks[piece_type]
		else:
			return storage.sections[Games.PieceImportance.MEDIUM].stacks[piece_type]
			
	func add_to_storage(piece):
		storage.add_piece(piece, side)
		
	func cleanup(scene):
		storage.cleanup()
		for piece in all_pieces:
			piece.queue_free()
		all_pieces.clear()

class GameSession:
	var id = -1
	var game_name = "?"
	var game_template = null
	var is_rated = false
	var setup = 0
	var user_name
	var host_name
	var sfen = null
	var initial_side = 0
	var turn_counter = 0
	var turn_side = 0
	var replay = null
	var gameover = false
	var gamestate = Games.GameResult.NONE
	var players = []
	var players_data = {}
	var observers_data = {}
	var winner = null
	var your_side = 0
	var global_game = false
	var mp_mode = false
	var obs_mode = false
	var replay_mode = false
	var ai_enabled = false
	var max_minutes = 0
	var max_byomi = 0
	var is_server = false	
	var has_other_player = false

	# Возращает Id мультиплеерной игры
	func get_id():
		return id
	func is_pvp():
		return !ai_enabled
	func is_ai():
		return ai_enabled
	func is_ai_turn():
		if is_pvp():
			return false
		if your_side == -1:
			return true
		if is_replay():
			return false
		return your_side != turn_side
	func is_multiplayer():
		return mp_mode
	func is_observer():
		return obs_mode
	func is_replay():
		return replay_mode
	func is_gameover():
		return gameover
	func get_black_player_name():
		if  players[0].key != -1:
			return players[0].name + "[" + str( players[0].key) + "]"
		return players[0].name
	func get_white_player_name():
		if  players[1].key != -1:
			return players[1].name + "[" + str( players[1].key) + "]"
		return players[1].name
	func get_turn_count():
		return turn_counter
	func get_current_player():
		return players[turn_side]
	func set_your_side(value):
		your_side = value
	func get_your_side():
		return your_side
	func get_your_player():
		return players[get_your_side()]
	func set_your_name(new_name):
		get_your_player().name = new_name
	func get_your_name():
		return get_your_player().name
	func get_opponent_side():
		return 1 if your_side == 0 else 0
	func get_opponent_player():
		return players[get_opponent_side()]
	func has_other_player():
		return has_other_player