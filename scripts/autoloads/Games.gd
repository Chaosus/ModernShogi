extends Node

# Глобальный класс - содержит все специфичные для каждого вида игр константы и методы

const PT_UNKNOWN = -1
const PT_DUMMY = -2

enum PlayerConfig {
	PVP,
	AI
}

enum GameSpeed {
	SLOW,
	MEDIUM,
	HIGH,
	IMMEDIATE
}

enum GameResult {
	# Game not finished or not played
	NONE,
	# Resign
	RESIGN,
	# Disconnect Resign
	DISCONNECT,
	# Illegal move
	ILLEGAL_MOVE
	# Draw by repetition
	REPETITION,
	# Perpetual check resign
	PERPETUAL_CHECK,
	# Win declaration using 28-point rule
	DECLARE_WIN,
	# Checkmate(only for ModernShogi online games)
	CHECKMATE,
	# Try-rule win(only for ModernShogi online games)
	TRYRULE_WIN
}

class PieceTheme:
	var tag
	var name_tag
	var limit # максимальное число фигур одного цвета
	var one_set # true - означает что тема не поддерживает два цвета
	var textures = {}
	
	func get_elements_count():
		if one_set:
			return limit
		return limit * 2
	
	func _init(tag, name, one_set):
		self.tag = tag
		name_tag = name
		self.one_set = one_set
	
	func add_theme_texture(piece_tag, texture_path):
		textures[piece_tag] = load(texture_path + ".png")

enum PieceTag {
	PROMOTABLE,
	ROYAL
}

enum PieceStates {
	NORMAL,
	PROMOTED
}

enum PieceImportance {
	MINOR,
	MEDIUM,
	MAJOR
}

enum GrammaType {
	MALE,
	FEMALE,
	NEUTRAL
}

class PieceTemplate:
	var game # принадлежность к игре
	var type # тип фигуры
	var name # переводимая строка имени фигуры
	var promoted_name
	var special = {}
	var importance
	var material
	var mesh
	var textures = {}
	var weight
	var promoted_weight
	var gramma
	var promoted_gramma
	
	func set_mesh(mesh):
		self.mesh = mesh
	
	func get_name():
		return name

	func get_gramma_type():
		return gramma
	
	func get_promoted_name():
	 	return promoted_name
		
	func get_texture():
		return game.current_piece_theme.textures[type]
	
	func add_special(tag):
		special[tag] = true
		return self
	
	func has_special(tag):
		if special.has(tag):
			return true
		return false
	
	func _init(game, type, name, gramma, weight, importance = PieceImportance.IMP_MEDIUM, promoted_name = "", promoted_gramma = GrammaType.NEUTRAL, promoted_weight = -1):
		self.game = game
		self.type = type
		self.name = name
		self.gramma = gramma
		self.weight = weight
		self.importance = importance
		self.promoted_name = promoted_name
		self.promoted_gramma = promoted_gramma
		self.promoted_weight = promoted_weight

# Возвращает трансфорированную позицию из реальной позиции
static func get_transformed_position(gameplay, x, y):
	if x < 0 or y < 0 or x > gameplay.width or y > gameplay.depth:
		return null
	if gameplay.inverted_tile_numeration:
		return Vector2( gameplay.width - x,  y + 1)
	else:
		return Vector2( x + 1,  y + 1)

enum TileNotation {
	SHOGI
}

class Gameplay:
	var tag # тэг игры в массиве игр
	var name_tag # тэг имени игры
	var respath # строка доступа к ресурсам игры
	var width # длина игрового поля
	var depth # ширина игрового поля
	var max_players # количество игроков
	var notation # нотация тайлов
	var use_tiles # true - фигуры будут использовать тайлы, false - пересечения тайлов
	var tiles_even # true - тайлы одинакового размера, false - глубина отличается
	var piece_type_count # количество типов фигур 
	var piece_themes = {} # массив PieceTheme
	var piece_templates = {} # массив PieceTemplate
	var droprule # игра поддерживает сбросы
	var current_piece_theme
	var editor_mode = false
	var setups = []
	
	func get_default_sfen():
		return ""
	func get_sfen(id):
		return setups[id]
	func add_piece_theme(tag, tag_str, one_set):
		var theme = PieceTheme.new(tag, tag_str, one_set)
		piece_themes[tag] = theme
		return theme
	func change_piece_theme(tag):
		if piece_themes.has(tag):
			current_piece_theme = piece_themes[tag]
	func get_piece_type(tag):
 		return piece_templates[tag]
	func get_piece_theme(tag):
		return piece_themes[tag]
	func add_piece_type(tag, importance, name, gramma, weight, promoted_name = "", promoted_gramma = GrammaType.NEUTRAL, promoted_weight = -1):
		var pt = PieceTemplate.new(self, tag, name, gramma, weight, importance, promoted_name, promoted_gramma, promoted_weight)
		piece_templates[tag] = pt
		return pt
	func make_moves(_piece, _checkmate):
		pass

# Все виды игр
enum GameType {
	SHOGI,
	MODERN_SHOGI
}

var game_list = {}

func get_game_by_name(game_name):
	return game_list[game_name]

#######################################################################
#		ОБЫЧНЫЕ  СЁГИ
#######################################################################

var shogi_piece_mesh = preload("res://models/shogi/shogi_piece.obj")

enum ShogiPieceTypes {
	PAWN,
	LANCE,
	KNIGHT,
	SILVER,
	GOLD,
	BISHOP,
	ROOK,
	KING,
	LIMITER
}

enum ShogiSetups {
	STANDART,
	FULL,
	TEST_PAWNS,
	TEST,
	TEST2,
	TEST3
}

enum ShogiHandicaps {
	NONE, # Без форы
	LEFT_LANCE, # Левое Копьё
	BISHOP, # Слон
	ROOK, # Ладья
	ROOK_LEFT_LANCE, # Ладья и левое Копьё
	PIECE2, # Ладья и Слон
	PIECE3, # Ладья, Слон, правое Копьё
	PIECE4, # Ладья, Слон, оба Копья
	PIECE5, # ЛАДЬЯ, СЛОН, ОБА КОПЬЯ, ПРАВЫЙ КОНЬ
	PIECE6, # ЛАДЬЯ, СЛОН, ОБА КОПЬЯ, ОБА КОНЯ,
	PIECE7, # ЛАДЬЯ, СЛОН, ОБА КОПЬЯ, ОБА КОНЯ, ЛЕВОЕ СЕРЕБРО
	PIECE8, # ЛАДЬЯ, СЛОН, ОБА КОПЬЯ, ОБА КОНЯ, ОБА СЕРЕБРА
	PIECE9, # ЛАДЬЯ, СЛОН, ОБА КОПЬЯ, ОБА КОНЯ, ОБА СЕРЕБРА, ЛЕВОЕ ЗОЛОТО
	PIECE10, # ЛАДЬЯ, СЛОН, ОБА КОПЬЯ, ОБА КОНЯ, ОБА СЕРЕБРА, ОБА ЗОЛОТА
	PAWNS3, # ВСЕ ФИГУРЫ ИСКЛЮЧАЯ КОРОЛЯ, ДАЁТ 3 ПЕШКИ В РУКУ
	NAKED_KING, # ВСЕ ФИГУРЫ ИСКЛЮЧАЯ КОРОЛЯ,
	DRAGONFLY, # ВСЕ КРОМЕ КОРОЛЯ, ПЕШЕК, ЛАДЬИ И СЛОНА
	DRAGONFLY_LANCES, # ВСЕ КРОМЕ КОРОЛЯ, ПЕШЕК, ЛАДЬИ, СЛОНА И ОБЕИХ КОПЬЯ
	DRAGONFLY_LANCES_KNIGHTS, # ВСЕ КРОМЕ КОРОЛЯ, ПЕШЕК, ЛАДЬИ, СЛОНА, ОБЕИХ КОПЬЯ И ОБЕИХ КОНЕЙ
	LIMITER
}

class ShogiGamePlay extends Gameplay:
	var sente_king
	var gote_king
	
	# Возвращает тип фигуры из символа или null если совпадений не обнаружено
	func get_piece_type_from_symbol(s):
		match s:
			"歩":
				return ShogiPieceTypes.PAWN
			"香":
				return ShogiPieceTypes.LANCE
			"桂":
				return ShogiPieceTypes.KNIGHT
			"銀":
				return ShogiPieceTypes.SILVER
			"金":
				return ShogiPieceTypes.GOLD
			"角":
				return ShogiPieceTypes.BISHOP
			"飛":
				return ShogiPieceTypes.ROOK
			"玉":
				return ShogiPieceTypes.KING
			"P":
				return ShogiPieceTypes.PAWN
			"L":
				return ShogiPieceTypes.LANCE
			"N":
				return ShogiPieceTypes.KNIGHT
			"S":
				return ShogiPieceTypes.SILVER
			"G":
				return ShogiPieceTypes.GOLD
			"B":
				return ShogiPieceTypes.BISHOP
			"R":
				return ShogiPieceTypes.ROOK
			"K":
				return ShogiPieceTypes.KING
		return null
	
	func _init():
		#setups.append("l1k2S2l/P2+S2g+P1/+Ppg1ppn2/2p3S2/1P5p1/L4Np1p/1S+b1PP+bG1/2+nP5/5K2L w 2RN2Pg2p")
		#setups.append("3k5/9/9/9/9/9/9/9/+R4K3 b") # test game
		#setups.append("4k4/9/9/9/9/9/9/9/+R3K3+B b") # test game 2
		
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b") # normal game
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/1NSGKGSNL b") # left lance
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/7R1/LNSGKGSNL b") # bishop
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B7/LNSGKGSNL b") # rook
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B7/1NSGKGSNL b") # rook and left lance
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/LNSGKGSNL b") # rook and bishop
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/LNSGKGSN1 b") # rook and bishop and right lance
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/1NSGKGSN1 b") # rook and bishop and both lances
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/1NSGKGS2 b") # rook and bishop, both lances, right knight
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/2SGKGS2 b") # rook and bishop, both lances and knights
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/3GKGS2 b") # rook and bishop, both lances, both knights, left silver
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/3GKG3 b") # rook and bishop, both lances, both knights, both silvers
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/4KG3 b") # rook and bishop, both lances, both knights, both silvers, left gold
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/9/4K4 b") # rook and bishop, both lances, both knights, both silvers, both golds
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/9/9/4K4 b 3P") # all, except king + 3 pawns in hand
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/9/9/4K4 b") # all, except king
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/4K4 b") # all, except king, pawns, rook and bishop
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/L3K3L b") # all, except king, pawns, rook, bishop and both lances
		setups.append("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LN2K2NL b") # all, except king, pawns, rook, bishop, both lances and knights

	func get_default_sfen():
		return "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b" # normal game
		
		#return "lns1k2nl/1rg6/p1pp+B3p/1p4pp1/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL w B2GS2P" # mate
		#return "4k4/9/9/9/9/9/9/9/4K4 b 12P"
		#return "lnsg2s1+B/3kr4/pppp1p1pb/4p3p/6pP1/2P3g2/PP1PPP2P/3S2GK1/LNS+r4g w 2NLPl"
		#return "lns1k1snl/7b1/pppp1pppp/9/9/9/PPPP1PPPP/1B6/LNS1K1SNL b GGgg"
				
	func make_moves(piece, checkmate):
		match piece.piece_template.type:
			ShogiPieceTypes.PAWN:
				if piece.in_storage:
					Moves.add_drop_moves_pawn(piece)
				else:
					if piece.is_promoted():
						Moves.add_gold_moves(piece, checkmate)
					else:
						Moves.add_move_up_line(piece, 1, checkmate)
			ShogiPieceTypes.KNIGHT:
				if piece.in_storage:
					Moves.add_drop_moves_limit(piece, 2)
				else:
					if piece.is_promoted():
						Moves.add_gold_moves(piece, checkmate)
					else:
						Moves.add_moves_knight_updown(piece, true, checkmate)
			ShogiPieceTypes.LANCE:
				if piece.in_storage:
					Moves.add_drop_moves_limit(piece, 1)
				else:
					if piece.is_promoted():
						Moves.add_gold_moves(piece, checkmate)
					else:
						Moves.add_move_up_line(piece, -1, checkmate)
			ShogiPieceTypes.SILVER:
				if piece.in_storage:
					Moves.add_drop_moves(piece)
				else:
					if piece.is_promoted():
						Moves.add_gold_moves(piece, checkmate)
					else:
						Moves.add_move_leftup_line(piece, 1, checkmate)
						Moves.add_move_up_line(piece, 1, checkmate)
						Moves.add_move_rightup_line(piece, 1, checkmate)
						Moves.add_move_leftdown_line(piece, 1, checkmate)
						Moves.add_move_rightdown_line(piece, 1, checkmate)
			ShogiPieceTypes.GOLD:
				if piece.in_storage:
					Moves.add_drop_moves(piece)
				else:
					Moves.add_gold_moves(piece, checkmate)
			ShogiPieceTypes.BISHOP:
				if piece.in_storage:
					Moves.add_drop_moves(piece)
				else:
					if piece.is_promoted():
						Moves.add_move_up_line(piece, 1, checkmate)
						Moves.add_move_down_line(piece, 1, checkmate)
						Moves.add_move_left_line(piece, 1, checkmate)
						Moves.add_move_right_line(piece, 1, checkmate)
					Moves.add_move_leftup_line(piece, -1, checkmate)
					Moves.add_move_leftdown_line(piece, -1, checkmate)
					Moves.add_move_rightup_line(piece, -1, checkmate)
					Moves.add_move_rightdown_line(piece, -1, checkmate)
			ShogiPieceTypes.ROOK:
				if piece.in_storage:
					Moves.add_drop_moves(piece)
				else:
					if piece.is_promoted():
						Moves.add_move_leftup_line(piece, 1, checkmate)
						Moves.add_move_rightup_line(piece, 1, checkmate)
						Moves.add_move_leftdown_line(piece, 1, checkmate)
						Moves.add_move_rightdown_line(piece, 1, checkmate)
					Moves.add_move_left_line(piece, -1,  checkmate)
					Moves.add_move_right_line(piece, -1,  checkmate)
					Moves.add_move_up_line(piece, -1,  checkmate)
					Moves.add_move_down_line(piece, -1, checkmate)
			ShogiPieceTypes.KING:
				if piece.in_storage:
					Moves.add_drop_moves(piece) # Невозможно
				else:
					Moves.add_king_moves(piece, 1, checkmate)
				
func load_piece_types_shogi(gameplay):
	
#	var pawn_textures = []
#	var lance_textures = []
#	var knight_textures = []
#	var silver_textures = []
#	var gold_textures = []
#	var bishop_textures = []
#	var rook_textures = []
#	var king_textures = []
#
#	pawn_textures.append(load("res://textures/pawn.png"))
#	lance_textures.append(load("res://textures/lance.png"))
#	knight_textures.append(load("res://textures/knight.png"))
#	silver_textures.append(load("res://textures/silver.png"))
#	gold_textures.append(load("res://textures/gold.png"))
#	bishop_textures.append(load("res://textures/bishop.png"))
#	rook_textures.append(load("res://textures/rook.png"))
#	king_textures.append(load("res://textures/king.png"))
	
	gameplay.add_piece_type(ShogiPieceTypes.PAWN, PieceImportance.MINOR, "PT_SHOGI_PAWN", GrammaType.FEMALE, 10, "PT_SHOGI_PROMOTED_PAWN", GrammaType.MALE, 70).add_special(PieceTag.PROMOTABLE).set_mesh(shogi_piece_mesh)
	gameplay.add_piece_type(ShogiPieceTypes.GOLD, PieceImportance.MEDIUM, "PT_SHOGI_GOLD", GrammaType.MALE, 60).set_mesh(shogi_piece_mesh)
	gameplay.add_piece_type(ShogiPieceTypes.SILVER, PieceImportance.MEDIUM, "PT_SHOGI_SILVER", GrammaType.MALE, 50, "PT_SHOGI_PROMOTED_SILVER", GrammaType.MALE, 60).add_special(PieceTag.PROMOTABLE).set_mesh(shogi_piece_mesh)
	gameplay.add_piece_type(ShogiPieceTypes.KNIGHT, PieceImportance.MEDIUM, "PT_SHOGI_KNIGHT", GrammaType.MALE, 30, "PT_SHOGI_PROMOTED_KNIGHT", GrammaType.MALE, 60).add_special(PieceTag.PROMOTABLE).set_mesh(shogi_piece_mesh)
	gameplay.add_piece_type(ShogiPieceTypes.LANCE, PieceImportance.MEDIUM, "PT_SHOGI_LANCE", GrammaType.NEUTRAL, 20, "PT_SHOGI_PROMOTED_LANCE", GrammaType.NEUTRAL, 60).add_special(PieceTag.PROMOTABLE).set_mesh(shogi_piece_mesh)
	gameplay.add_piece_type(ShogiPieceTypes.ROOK, PieceImportance.MAJOR, "PT_SHOGI_ROOK", GrammaType.FEMALE, 100, "PT_SHOGI_PROMOTED_ROOK", GrammaType.MALE, 130).add_special(PieceTag.PROMOTABLE).set_mesh(shogi_piece_mesh)
	gameplay.add_piece_type(ShogiPieceTypes.BISHOP, PieceImportance.MAJOR, "PT_SHOGI_BISHOP", GrammaType.MALE, 90, "PT_SHOGI_PROMOTED_BISHOP", GrammaType.MALE, 120).add_special(PieceTag.PROMOTABLE).set_mesh(shogi_piece_mesh)
	gameplay.add_piece_type(ShogiPieceTypes.KING, PieceImportance.MAJOR, "PT_SHOGI_KING", GrammaType.MALE, 30000).add_special(PieceTag.ROYAL).set_mesh(shogi_piece_mesh)

#enum ShogiSetups {
#	GS_SHOGI_STANDART,
#	GS_SHOGI_TEST_ONLY_KINGS,
#	GS_SHOGI_TEST_PAWNS,
#	GS_SHOGI_TEST_LANCES,
#	GS_SHOGI_TEST_KNIGHTS
#	GS_SHOGI_TEST_CANNONS,
#	GS_SHOGI_TEST_SILVERS,
#	GS_SHOGI_TEST_GOLDS,
#	GS_SHOGI_TEST_BISHOPS,
#	GS_SHOGI_TEST_ROOKS,
#	GS_SHOGI_TEST_QUEENS,
#	GS_SHOGI_TEST_THRONE_CAPTURE
#}

func load_piece_theme_shogi(piece_theme, respath, theme_index):
	var path = respath + "/theme%s/" % theme_index
	piece_theme.add_theme_texture(ShogiPieceTypes.PAWN, path + "pawn")
	piece_theme.add_theme_texture(ShogiPieceTypes.LANCE, path + "lance")
	piece_theme.add_theme_texture(ShogiPieceTypes.KNIGHT, path + "knight")
	piece_theme.add_theme_texture(ShogiPieceTypes.SILVER, path + "silver")
	piece_theme.add_theme_texture(ShogiPieceTypes.GOLD, path + "gold")
	piece_theme.add_theme_texture(ShogiPieceTypes.BISHOP, path + "bishop")
	piece_theme.add_theme_texture(ShogiPieceTypes.ROOK, path + "rook")
	piece_theme.add_theme_texture(ShogiPieceTypes.KING, path + "king")
	return piece_theme
	
	
var game_shogi

#######################################################################

var initialized = false

func is_initialized():
	return initialized


enum PieceThemeName {
	KANJI,
	SYMBOLIC,
	WESTERN,
	KANJI2
}

func init_games():
	
	game_shogi = ShogiGamePlay.new()
	game_shogi.tag = GameType.SHOGI
	game_shogi.name_tag = "GAME_SHOGI"
	game_shogi.respath = "res://games/shogi"
	game_shogi.width = 9
	game_shogi.depth = 9
	game_shogi.max_players = 2
	game_shogi.piece_type_count = ShogiPieceTypes.LIMITER
	game_shogi.notation = TileNotation.SHOGI
	game_shogi.use_tiles = true
	game_shogi.tiles_even = false
	game_shogi.droprule = true
	game_list[game_shogi.tag] = game_shogi
	
	var list = []
	
	list.append(load_piece_theme_shogi(game_shogi.add_piece_theme(PieceThemeName.KANJI, "PSTYLE_KANJI", true), game_shogi.respath, 0))
	list.append(load_piece_theme_shogi(game_shogi.add_piece_theme(PieceThemeName.SYMBOLIC, "PSTYLE_SYMBOLIC", true), game_shogi.respath, 1))
	list.append(load_piece_theme_shogi(game_shogi.add_piece_theme(PieceThemeName.WESTERN, "PSTYLE_WESTERN", true), game_shogi.respath, 2))
	list.append(load_piece_theme_shogi(game_shogi.add_piece_theme(PieceThemeName.KANJI2, "PSTYLE_KANJI", true), game_shogi.respath, 3))
	game_shogi.current_piece_theme = list[Profiles.get_current_settings().get_value(Settings.SV_STYLES_PIECE_THEME)]
	
	load_piece_types_shogi(game_shogi)
	
	initialized = true

enum PlayerSide {
	PLAYER_CHESS_RANDOM = -1,
	PLAYER_SHOGI_SENTE = 0,
	PLAYER_SHOGI_GOTE = 1
}

enum GameMode {
	LOCAL,
	MP,
	REPLAY
}

class InitialSetup:
	var gmode
	var game
	var setup
	var player_config
	var player_side
	var tc_minutes
	var tc_seconds
	var handicap
	func _init(gmode, game, setup, player_config, player_side, minutes, seconds):
		self.gmode = gmode
		self.game = game
		self.handicap = setup
		self.player_config = player_config
		self.player_side = player_side
		tc_minutes = minutes
		tc_seconds = seconds



enum NotationLetters {
	JAPANESE,
	ENGLISH
}

enum HistoryMode {
	SHOGI = 0, # сёги стиль
	CHESS = 1 # шахматный стиль
}


class Record:
	var id
	var is_replay
	var side
	var piece_type
	var piece
	var piece_was_promoted
	var piece_is_promoted
	var can_be_promoted
	var eaten
	var eaten_was_promoted
	var prev_nest
	var next_nest
	var same
	var data
	var drop
	var sfen
	var sfen_hash
	var think_time = "0:0"
	var box1 = null
	var box2 = null
	var mbox1 = null
	var mbox2 = null
	var ai_string = null
	var previous_record = null
	var string

	func init_string():
		string = get_full_string(2, true, Games.NotationLetters.ENGLISH)
	
	func get_full_string(notation_style, use_y_num, notation_language) -> String:
		var string = ""
		if notation_style == 0: # Japanese
			var same = false
			if previous_record != null:
				if previous_record.next_nest == next_nest:
					string = '同' + Checks.get_piece_symbol(piece_type, Games.NotationLetters.JAPANESE, piece_is_promoted)
					same = true
			if !same:
				string = get_move_string(notation_style, use_y_num) + Checks.get_piece_symbol(piece_type, Games.NotationLetters.JAPANESE, piece_is_promoted)  + ("成" if piece_was_promoted else ("不成" if can_be_promoted else "")) + ("打" if drop else "")
		else:
			string = Checks.get_piece_symbol(piece_type, notation_language, piece_is_promoted) + ("*" if drop else " ") + get_move_string(notation_style, use_y_num)
		return string
		
	func get_move_string(notation_style, use_y_num) -> String:
		var string = ""
		if notation_style == 0: # Japanese
			string += str(next_nest.x) + Checks.convert_number_to_japanese_char(next_nest.y) # ２六
		elif notation_style == 1: # Short
			string += str(next_nest.x) + "," + ( str(next_nest.y) if use_y_num else str(next_nest.letter) )
			if piece_was_promoted:
				string += "+"
		if notation_style == 2: # Full
			if drop:
				string += str(next_nest.x) + "," + ( str(next_nest.y) if use_y_num else str(next_nest.letter) ) 
			else:
				string += str(prev_nest.x) + "," + ( str(prev_nest.y) if use_y_num else str(prev_nest.letter) ) + " - " + str(next_nest.x) + "," + ( str(next_nest.y) if use_y_num else str(next_nest.letter) ) 
			if piece_was_promoted:
				string += "+"
		return string

class History:
	var moves = []
	var remove_list = []
	var current_index = 0
	
	# Возвращает историю в виде лога, используется при загрузке мультиплеерной игры
	func get_log() -> String:
		var s = ""
		for record in moves:
			s += record.string + '\n'
		return s
		
	func get_ai_log(max_index = -1) -> String:
		var s = ""
		var idx = 0
		for record in moves:
			if max_index != -1:
				if idx == max_index:
					break
			s += record.ai_string + ' '
			idx += 1
		return s
	
	func get_last_record():
		if get_count() > 0:
			return moves[moves.size()-1]
		return null
	
	func get_current_record():
		return get_record(current_index)
	
	func get_previous_record():
		return get_record(current_index - 1)
	
	func get_record_or_null(idx):
		if idx < 0:
			return null
		return moves[idx]
		
	func get_record(idx):
		if idx < 0:
			if get_count() == 1:
				return moves[0]
			return moves[1]
		return moves[idx]
	
	func get_current_index():
		return current_index
		
	func get_count():
		return moves.size()
		
	func clear():
		moves.clear()
		current_index = 0
		
	func is_min():
		if current_index == 0:
			return true
		return false
		
	func is_max():
		if current_index == get_count():
			return true
		return false
	
	func clear_until_selected():
		var counter = 0
		var start_count = get_count()
		
		for i in range(start_count - 1, current_index - 1, -1):
			var item = moves[i]
			if item.box1 != null:
				item.box1.queue_free()
			if item.box2 != null:
				item.box2.queue_free()
			if item.mbox1 != null:
				item.mbox1.queue_free()
			if item.mbox2 != null:
				item.mbox2.queue_free()
			moves.remove(i)
			counter += 1
		return counter

	func unmark_first():
		var box1 = moves[0].box1
		box1.pressed = false
		var box2 = moves[0].box2
		box2.pressed = false
	
	func mark_last():
		var box = moves[current_index - 1].box1
		box.pressed = true
		var box2 = moves[current_index - 1].box2
		box2.pressed = true
		return box
	
	func next():
		var move = moves[current_index]
		current_index = clamp(current_index + 1, 0, get_count())
		return move
	
	func previous():
		current_index = clamp(current_index - 1, 0, get_count())
		return moves[current_index]
	
	func get_previous():
		var index = get_count() - 1
		if index < 0:
			return null
		return moves[index]
	
	func current():
		return moves[current_index]
		
	func add_record(move, increase_index):
		moves.append(move)
		if increase_index:
			current_index += 1

enum Rank{
 	Kyu15,
	Kyu14,
	Kyu13,
	Kyu12,
	Kyu11,	
	Kyu10,
	Kyu9,
	Kyu8,
	Kyu7,
	Kyu6,
	Kyu5,
	Kyu4,
	Kyu3,
	Kyu2,
	Kyu1,
	Dan1,
	Dan2,
	Dan3,
	Dan4,
	Dan5,
	Dan6,
	Dan7
}

func get_rank_from_rating(rating):
	if rating < 500:
		return Rank.Kyu15
	elif rating < 600:
		return Rank.Kyu14
	elif rating < 700:
		return Rank.Kyu13
	elif rating < 800:
		return Rank.Kyu12
	elif rating < 900:
		return Rank.Kyu11
	elif rating < 1000:
		return Rank.Kyu10
	elif rating < 1050:
		return Rank.Kyu9
	elif rating < 1100:
		return Rank.Kyu8	
	elif rating < 1150:
		return Rank.Kyu7
	elif rating < 1200:
		return Rank.Kyu6
	elif rating < 1250:
		return Rank.Kyu5
	elif rating < 1300:
		return Rank.Kyu4
	elif rating < 1350:
		return Rank.Kyu3
	elif rating < 1425:
		return Rank.Kyu2
	elif rating < 1500:
		return Rank.Kyu1
	elif rating < 1625:
		return Rank.Dan1
	elif rating < 1750:
		return Rank.Dan2
	elif rating < 1875:
		return Rank.Dan3
	elif rating < 2000:
		return Rank.Dan4
	elif rating < 2150:
		return Rank.Dan5
	elif rating < 2300:
		return Rank.Dan6
	else:
		return Rank.Dan7
		
func get_rank_string_from_rating(rating):
	var rank = get_rank_from_rating(rating)
	match rank:
		Rank.Kyu15:
			return "15-Kyu"
		Rank.Kyu14:
			return "14-Kyu"
		Rank.Kyu13:
			return "13-Kyu"
		Rank.Kyu12:
			return "12-Kyu"
		Rank.Kyu11:
			return "11-Kyu"
		Rank.Kyu10:
			return "10-Kyu"
		Rank.Kyu9:
			return "9-Kyu"
		Rank.Kyu8:
			return "8-Kyu"
		Rank.Kyu7:
			return "7-Kyu"
		Rank.Kyu6:
			return "6-Kyu"
		Rank.Kyu5:
			return "5-Kyu"
		Rank.Kyu4:
			return "4-Kyu"
		Rank.Kyu3:
			return "3-Kyu"
		Rank.Kyu2:
			return "2-Kyu"
		Rank.Kyu1:
			return "1-Kyu"
		Rank.Dan1:
			return "1-Dan"
		Rank.Dan2:
			return "2-Dan"
		Rank.Dan3:
			return "3-Dan"
		Rank.Dan4:
			return "4-Dan"
		Rank.Dan5:
			return "5-Dan"
		Rank.Dan6:
			return "6-Dan"
		Rank.Dan7:
			return "7-Dan"
	return "?"