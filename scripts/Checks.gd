extends Node

# В этом глобальном файле я буду хранить функции проверки разных переменных

const MIN_NICKNAME_LENGTH = 3
const MIN_PASSWORD_LENGTH = 3

static func handicap_from_string(string):
	match string:
		"None":
			return Games.ShogiHandicaps.NONE
		"LeftLance":
			return Games.ShogiHandicaps.LEFT_LANCE
		"Bishop":
			return Games.ShogiHandicaps.BISHOP
		"Rook":
			return Games.ShogiHandicaps.ROOK
		"RookLeftLance":
			return Games.ShogiHandicaps.ROOK_LEFT_LANCE
		"Piece2":
			return Games.ShogiHandicaps.PIECE2
		"Piece3":
			return Games.ShogiHandicaps.PIECE3
		"Piece4":
			return Games.ShogiHandicaps.PIECE4
		"Piece5":
			return Games.ShogiHandicaps.PIECE5
		"Piece6":
			return Games.ShogiHandicaps.PIECE6
		"Piece7":
			return Games.ShogiHandicaps.PIECE7
		"Piece8":
			return Games.ShogiHandicaps.PIECE8
		"Piece9":
			return Games.ShogiHandicaps.PIECE9
		"Piece10":
			return Games.ShogiHandicaps.PIECE10
		"Pawns3":
			return Games.ShogiHandicaps.PAWNS3
		"NakedKing":
			return Games.ShogiHandicaps.NAKED_KING
		"Dragonfly":
			return Games.ShogiHandicaps.DRAGONFLY
		"DragonflyLances":
			return Games.ShogiHandicaps.DRAGONFLY_LANCES
		"DragonflyLancesKnights":
			return Games.ShogiHandicaps.DRAGONFLY_LANCES_KNIGHTS
			
	return Games.ShogiHandicaps.NONE

static func get_game_result_str(result):
	match result:
		Games.GameResult.NONE:
			return "?"
		Games.GameResult.RESIGN:
			return "GAME_RESULT_RESIGN"
		Games.GameResult.DISCONNECT:
			return "GAME_RESULT_DISCONNECT"
		Games.GameResult.ILLEGAL_MOVE:
			return "GAME_RESULT_ILLEGAL_MOVE"
		Games.GameResult.REPETITION:
			return "GAME_RESULT_REPETITION"
		Games.GameResult.PERPETUAL_CHECK:
			return "GAME_RESULT_PERPETUAL_CHECK"
		Games.GameResult.DECLARE_WIN:
			return "GAME_RESULT_DECLARE_WIN"
		Games.GameResult.CHECKMATE:
			return "GAME_RESULT_CHECKMATE"
		Games.GameResult.TRYRULE_WIN:
			return "GAME_RESULT_TRYRULE_WIN"

func convert_wide_number(number):
	match number:
		'１':
			return 1
		'２':
			return 2
		'３':
			return 3
		'４':
			return 4
		'５':
			return 5
		'６':
			return 6
		'７':
			return 7
		'８':
			return 8
		'９':
			return 9

func convert_japanese_number(number):
	match number:
		'一':
			return 1
		'二':
			return 2
		'三':
			return 3
		'四':
			return 4
		'五':
			return 5
		'六':
			return 6
		'七':
			return 7
		'八':
			return 8
		'九':
			return 9

func convert_number_to_japanese_char(number):
	match number:
		1:
			return '一'
		2:
			return '二'
		3: 
			return '三'
		4:
			return '四'
		5:
			return '五'
		6:
			return '六'
		7:
			return '七'
		8:
			return '八'
		9:
			return '九'
			
static func is_pow2(v):
	var r = v % 2
	if r == 0:
		return true
	return false

static func get_side(symbol) -> int: 
	match symbol:
		'P':
			return 0
		'L':
			return 0
		'N':
			return 0
		'S':
			return 0
		'G':
			return 0
		'B':
			return 0
		'R':
			return 0
		'K':
			return 0
		'p':
			return 1
		'l':
			return  1
		'n':
			return 1
		's':
			return 1
		'g':
			return 1
		'b':
			return 1
		'r':
			return 1
		'k':
			return 1
	return 0

static func get_sfen_piece_symbol(piece_type, side, promoted):
	var s = ""
	if promoted:
		s += "+"
	if side == 0:
		match piece_type:
			Games.ShogiPieceTypes.PAWN:
				s += "P"
			Games.ShogiPieceTypes.LANCE:
				s += "L"
			Games.ShogiPieceTypes.KNIGHT:
				s += "N"	
			Games.ShogiPieceTypes.SILVER:
				s += "S"	
			Games.ShogiPieceTypes.GOLD:
				s += "G"
			Games.ShogiPieceTypes.BISHOP:
				s += "B"
			Games.ShogiPieceTypes.ROOK:
				s += "R"
			Games.ShogiPieceTypes.KING:
				s += "K"
	elif side == 1:
		match piece_type:
			Games.ShogiPieceTypes.PAWN:
				s += "p"
			Games.ShogiPieceTypes.LANCE:
				s += "l"
			Games.ShogiPieceTypes.KNIGHT:
				s += "n"	
			Games.ShogiPieceTypes.SILVER:
				s += "s"	
			Games.ShogiPieceTypes.GOLD:
				s += "g"
			Games.ShogiPieceTypes.BISHOP:
				s += "b"
			Games.ShogiPieceTypes.ROOK:
				s += "r"
			Games.ShogiPieceTypes.KING:
				s += "k"
	return s



static func convert_japanese_symbol(piece_type):
	match piece_type:
		"と":
			return Games.ShogiPieceTypes.PAWN
		"歩":
			return Games.ShogiPieceTypes.PAWN
		"杏":
			return Games.ShogiPieceTypes.LANCE
		"香":
			return Games.ShogiPieceTypes.LANCE
		"圭":
			return Games.ShogiPieceTypes.KNIGHT
		"桂":
			return Games.ShogiPieceTypes.KNIGHT
		"全":
			return Games.ShogiPieceTypes.SILVER
		"銀":
			return Games.ShogiPieceTypes.SILVER
		"金":
			return Games.ShogiPieceTypes.GOLD
		"馬":
			return Games.ShogiPieceTypes.BISHOP
		"角":
			return Games.ShogiPieceTypes.BISHOP
		"龍":
			return Games.ShogiPieceTypes.ROOK
		"飛":
			return Games.ShogiPieceTypes.ROOK
		"玉":
			return Games.ShogiPieceTypes.KING


static func is_promoted_piece_symbol(piece_type):
	match piece_type:
		"と":
			return true
		"杏":
			return true
		"圭":
			return true
		"全":
			return true
		"馬":
			return true
		"龍":
			return true
	return false

static func get_ja_piece_type(symbol):
	match symbol:
		"と":
			return Games.ShogiPieceTypes.PAWN
		"歩":
			return Games.ShogiPieceTypes.PAWN
		"杏":
			return Games.ShogiPieceTypes.LANCE
		"香":
			return Games.ShogiPieceTypes.LANCE
		"圭":
			return Games.ShogiPieceTypes.KNIGHT
		"桂":
			return Games.ShogiPieceTypes.KNIGHT
		"全":
			return Games.ShogiPieceTypes.SILVER
		"銀":
			return Games.ShogiPieceTypes.SILVER
		"金":
			return Games.ShogiPieceTypes.GOLD
		"馬":
			return Games.ShogiPieceTypes.BISHOP
		"角":
			return Games.ShogiPieceTypes.BISHOP
		"龍":
			return Games.ShogiPieceTypes.ROOK
		"飛":
			return Games.ShogiPieceTypes.ROOK
		"玉":
			return Games.ShogiPieceTypes.KING

static func get_en_piece_type(symbol):
	symbol = symbol.to_upper()
	match symbol:
		'P':
			return Games.ShogiPieceTypes.PAWN
		'L':
			return Games.ShogiPieceTypes.LANCE
		"N":
			return Games.ShogiPieceTypes.KNIGHT
		"S":
			return Games.ShogiPieceTypes.SILVER
		"G":
			return Games.ShogiPieceTypes.GOLD
		"B":
			return Games.ShogiPieceTypes.BISHOP
		"R":
			return Games.ShogiPieceTypes.ROOK
		"K":
			return Games.ShogiPieceTypes.KING

static func get_piece_type_from_symbol(symbol):
	var p = symbol.to_lower()
	match p:
		"p":
			return Games.ShogiPieceTypes.PAWN
		"l":
			return Games.ShogiPieceTypes.LANCE
		"n":
			return Games.ShogiPieceTypes.KNIGHT
		"s":
			return Games.ShogiPieceTypes.SILVER
		"g":
			return Games.ShogiPieceTypes.GOLD
		"b":
			return Games.ShogiPieceTypes.BISHOP
		"r":
			return Games.ShogiPieceTypes.ROOK
		"k":
			return Games.ShogiPieceTypes.KING

static func get_piece_symbol(piece_type, symbol_type, is_promoted):
	var s = ""
	
	if is_promoted:
		s += "+" if symbol_type == Games.NotationLetters.ENGLISH else "成"
	
	match symbol_type:
		Games.NotationLetters.JAPANESE:
			match piece_type:
				Games.ShogiPieceTypes.PAWN:
					s += "歩"
				Games.ShogiPieceTypes.LANCE:
					s += "香"
				Games.ShogiPieceTypes.KNIGHT:
					s += "桂"	
				Games.ShogiPieceTypes.SILVER:
					s += "銀"	
				Games.ShogiPieceTypes.GOLD:
					s += "金"
				Games.ShogiPieceTypes.BISHOP:
					s += "角"
				Games.ShogiPieceTypes.ROOK:
					s += "飛"
				Games.ShogiPieceTypes.KING:
					s += "玉"
		Games.NotationLetters.ENGLISH:
			match piece_type:
				Games.ShogiPieceTypes.PAWN:
					s += "P"
				Games.ShogiPieceTypes.LANCE:
					s += "L"
				Games.ShogiPieceTypes.KNIGHT:
					s += "N"	
				Games.ShogiPieceTypes.SILVER:
					s += "S"	
				Games.ShogiPieceTypes.GOLD:
					s += "G"
				Games.ShogiPieceTypes.BISHOP:
					s += "B"
				Games.ShogiPieceTypes.ROOK:
					s += "R"
				Games.ShogiPieceTypes.KING:
					s += "K"
	return s

#				Games.ShogiPieceTypes.PROMOTED_PAWN:
#					return "と"
#				Games.ShogiPieceTypes.PROMOTED_LANCE:
#					return "杏"
#				Games.ShogiPieceTypes.PROMOTED_KNIGHT:
#					return "圭"
#				Games.ShogiPieceTypes.PROMOTED_SILVER:
#					return "全"
#				Games.ShogiPieceTypes.PROMOTED_BISHOP:
#					return "馬"
#				Games.ShogiPieceTypes.PROMOTED_ROOK:
#					return "龍"

static func is_number(symbol):
	var result = false
	match symbol:
		'0':
			result = true
		'1':
			result = true
		'2':
			result = true
		'3':
			result = true
		'4':
			result = true
		'5':
			result = true
		'6':
			result = true
		'7':
			result = true
		'8':
			result = true
		'9':
			result = true
	return result

static func is_symbol_is_latin_letter(symbol, ignore_case):
	var result = false
	match symbol:
		'a':
			result = true
		'b':
			result = true
		'c':
			result = true
		'd':
			result = true
		'e':
			result = true
		'f':
			result = true
		'g':
			result = true
		'h':
			result = true
		'i':
			result = true
		'j':
			result = true
		'k':
			result = true
		'l':
			result = true
		'm':
			result = true
		'n':
			result = true
		'o':
			result = true
		'p':
			result = true
		'q':
			result = true
		'r':
			result = true
		's':
			result = true
		't':
			result = true
		'u':
			result = true
		'v':
			result = true
		'w':
			result = true
		'x':
			result = true
		'y':
			result = true
		'z':
			result = true
	if ignore_case:
		match symbol:
			'A':
				result = true
			'B':
				result = true
			'C':
				result = true
			'D':
				result = true
			'E':
				result = true
			'F':
				result = true
			'G':
				result = true
			'H':
				result = true
			'I':
				result = true
			'J':
				result = true
			'K':
				result = true
			'L':
				result = true
			'M':
				result = true
			'N':
				result = true
			'O':
				result = true
			'P':
				result = true
			'Q':
				result = true
			'R':
				result = true
			'S':
				result = true
			'T':
				result = true
			'U':
				result = true
			'V':
				result = true
			'W':
				result = true
			'X':
				result = true
			'Y':
				result = true
			'Z':
				result = true
	return result

# Возвращает букву ряда
func get_index_letter(index):
	match int(index):
		1:
			return "a"
		2:
			return "b"
		3:
			return "c"
		4:
			return "d"
		5:
			return "e"
		6:
			return "f"
		7:
			return "g"
		8:
			return "h"
		9:
			return "i"
		10:
			return "j"
		11:
			return "k"
	return ""

# Возвращает букву ряда
func get_number_from_letter(index):
	match index:
		"a":
			return 1
		"b":
			return 2
		"c":
			return 3
		"d":
			return 4
		"e":
			return 5
		"f":
			return 6
		"g":
			return 7
		"h":
			return 8
		"i":
			return 9
		"j":
			return 10
		"k":
			return 11
	return -1

static func is_symbol_is_latin_letter_or_number(l):
	return is_symbol_is_latin_letter(l, true) or l.is_valid_integer()

static func is_valid_nickname_symbol(symbol):
	return is_symbol_is_latin_letter(symbol, true) or symbol.is_valid_integer()

static func check_nickname(s):
	if s.length() < MIN_NICKNAME_LENGTH:
		return false
	for letter in s:
		if is_symbol_is_latin_letter(letter, false) or letter.is_valid_integer():
			continue
		else:
			return false
	return true

func check_password(s):
	if s.length() < MIN_PASSWORD_LENGTH:
		return false
	for letter in s:
		if is_symbol_is_latin_letter(letter, true) or letter.is_valid_integer():
			continue
		else:
			return false
	return true
	
func is_orthogonal(a, b):
	return (a.x == b.x and a.y != b.y) or (a.y == b.y and a.x != b.x)