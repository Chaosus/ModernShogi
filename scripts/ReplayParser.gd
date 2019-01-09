extends Node

var regex_move_from_x = RegEx.new()
var regex_move_from_y = RegEx.new()
var regex_move_to_x = RegEx.new()
var regex_move_to_y = RegEx.new()
var regex_move_what = RegEx.new()
var regex_move_same = RegEx.new()
var regex_move_drop = RegEx.new()
var regex_move_piece = RegEx.new()
var regex_move_after_promotion = RegEx.new()
var regex_move_before_promotion = RegEx.new()

var regex_game_pos = RegEx.new()
var regex_game_num = RegEx.new()
var regex_game_piece = RegEx.new()
var regex_game_promotion = RegEx.new()
var regex_game_promoted = RegEx.new()

var regex_resign = RegEx.new()
var regex_disconnect = RegEx.new()
var regex_illegalmove = RegEx.new()
var regex_repetition = RegEx.new()
var regex_impasse = RegEx.new()
var regex_perpetual_check = RegEx.new()
var regex_declare_win = RegEx.new()
var regex_tryrule_win = RegEx.new()

func precompile_regex():
	regex_resign.compile("(?<=\\s)(投了|Resign|Checkmate)")
	regex_disconnect.compile("(?<=\\s)(接続切れ|Disconnection)")
	regex_illegalmove.compile("(?<=\\s)(反則手|IllegalMove)")
	regex_repetition.compile("(?<=\\s)(千日手|Repetition)")
	regex_impasse.compile("(?<=\\s)(持将棋|Impasse)")
	regex_perpetual_check.compile("(?<=\\s)(連続王手の千日手|PerpetualCheck)")
	regex_declare_win.compile("(点宣言勝ち|DeclareWin)")
	regex_tryrule_win.compile("TryRule")
	
	regex_move_from_x.compile("[１|２|３|４|５|６|７|８|９]+")
	regex_move_from_y.compile("[一|二|三|四|五|六|七|八|九]+")
	regex_move_to_x.compile("(?<=\\()\\d{1}")
	regex_move_to_y.compile("\\d{1}(?=\\))")
	regex_move_same.compile("同")
	regex_move_piece.compile("[歩|香|桂|銀|金|角|飛|玉|馬|龍]+")
	regex_move_drop.compile("打")
	regex_move_after_promotion.compile("成(?=\\(+)")
	regex_move_before_promotion.compile("成(?=[歩|香|桂|銀|金|角|飛|玉|馬|龍]+)")
	
	regex_game_pos.compile("\\d+,\\d+")
	regex_game_num.compile("\\d+")
	regex_game_piece.compile("[歩|香|桂|銀|金|角|飛|玉|P|L|N|S|G|B|R|K]")
	regex_game_promotion.compile("(?<=\\d)\\+") # "\\+(?=\\s)")
	regex_game_promoted.compile("\\+(?=\\w)") #("\\+\\w") 
	
enum ReplayFormat {
	UNKNOWN,
	KIF_81DOJO,
	KIF_MODERNSHOGI
}

class TimeControl:
	var minutes = 0
	var byoyomi = 0

class Replay:
	var path
	var filename
	var format
	var date
	var place
	var time_control
	var handicap
	var handicap_value
	var black_name
	var white_name
	var move_count
	var result
	var winner
	var moves = []

class MoveRecord:
	var index
	var piece_type
	var from
	var to
	var is_drop
	var is_promoted
	var promotion
	var same
	var string

func transform_japanese_handicap(string):
	match string:
		"平手":
			return "LABEL_HANDICAP_NONE"
		"香落ち":
			return "LABEL_HANDICAP_LEFT_LANCE"
		"角落ち":
			return "LABEL_HANDICAP_BISHOP"
		"飛落ち":
			return "LABEL_HANDICAP_ROOK"
	return "?"

func transform_mkif_handicap(string):
	match string:
		"None":
			return "LABEL_HANDICAP_NONE"
		"LeftLance":
			return "LABEL_HANDICAP_LEFT_LANCE"
		"Bishop":
			return "LABEL_HANDICAP_BISHOP"
		"Rook":
			return "LABEL_HANDICAP_ROOK"
		"RookLeftLance":
			return "LABEL_HANDICAP_ROOK_LEFT_LANCE"
		"Piece2":
			return "LABEL_HANDICAP_PIECE2"
		"Piece3":
			return "LABEL_HANDICAP_PIECE3"
		"Piece4":
			return "LABEL_HANDICAP_PIECE4"
		"Piece5":
			return "LABEL_HANDICAP_PIECE5"
		"Piece6":
			return "LABEL_HANDICAP_PIECE6"
		"Piece7":
			return "LABEL_HANDICAP_PIECE7"
		"Piece8":
			return "LABEL_HANDICAP_PIECE8"
		"Piece9":
			return "LABEL_HANDICAP_PIECE9"
		"Piece10":
			return "LABEL_HANDICAP_PIECE10"
		"Pawns3":
			return "LABEL_HANDICAP_PAWNS3"
		"NakedKing":
			return "LABEL_HANDICAP_ONLY_KING"
		"Dragonfly":
			return "LABEL_HANDICAP_DRAGONFLY"
		"DragonflyLances":
			return "LABEL_HANDICAP_DRAGONFLY_LANCES"
		"DragonflyLancesKnights":
			return "LABEL_HANDICAP_DRAGONFLY_LANCES_KNIGHTS"
	return "?"

# Превращение строки в формате ModernShogi в ход
func parse_converted_move(game, string):
	var record = MoveRecord.new()
	var piece = regex_game_piece.search(string)
	var positions = regex_game_pos.search_all(string)
	var promotion = regex_game_promotion.search(string)
	var promoted = regex_game_promoted.search(string)
	
	record.promotion = promotion != null
	record.is_promoted = promoted != null
	
	if piece:
		record.piece_type = game.get_piece_type_from_symbol(piece.get_string())
	else:
		return null
	
	var sz = positions.size()
	
	if sz == 0:
		return null
		
	var nums = regex_game_num.search_all(positions[0].get_string())
		
	if sz == 1:
		record.is_drop = true
		record.to = Vector2(int(nums[0].get_string()), int(nums[1].get_string()))
	elif sz == 2:
		record.is_drop = false
		record.from = Vector2(int(nums[0].get_string()), int(nums[1].get_string()))
		nums = regex_game_num.search_all(positions[1].get_string())
		record.to = Vector2(int(nums[0].get_string()), int(nums[1].get_string()))

	return record

func parse_move(string):
	var record = MoveRecord.new()
	var result_from_x = regex_move_from_x.search(string)
	var result_from_y = regex_move_from_y.search(string)
	
	var result_to_x = regex_move_to_x.search(string)
	var result_to_y = regex_move_to_y.search(string)
	
	var same = regex_move_same.search(string)
	var piece = regex_move_piece.search(string)
	var drop = regex_move_drop.search(string)
	var promotion = regex_move_after_promotion.search(string)
	var promoted = regex_move_before_promotion.search(string)
	
	record.is_drop = drop != null
	record.promotion = promotion != null
	record.is_promoted = promoted != null
	
	if piece:
		record.piece_type = Checks.convert_japanese_symbol(piece.get_string())
		if Checks.is_promoted_piece_symbol(piece.get_string()):
			record.promotion = false
			record.is_promoted = true
		
	var to_x
	var to_y
	
	if same:
		record.same = true
	
	if result_to_x and result_to_y:
		to_x = result_to_x.get_string()
		to_y = result_to_y.get_string()
		record.from = Vector2(int(to_x), int(to_y))
	else: # parsing error
		if !drop:
			return null
		
	if result_from_x and result_from_y:
		var x = result_from_x.get_string()
		var y = result_from_y.get_string()
		 
		x = Checks.convert_wide_number(x)
		y = Checks.convert_japanese_number(y)
		
		#print("from( x: " + str(x) + " y: " + str(y) + ") -> to( x: " + str(to_x)  + " y: " + str(to_y) + ")")
		record.to = Vector2(x, y)
	else:
		if !same:
			#print("drop to( x: " + str(to_x)  + " y: " + str(to_y) + ")")
			record.is_drop = true
	
	return record

func parse_header_line(string):
	var regex = RegEx.new()
	regex.compile("(?<=：|:).+$")
	var result = regex.search(string)
	if result:
		return result.get_string()
	return null

func parse_time_line(string):
	var time_control = TimeControl.new()
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search_all(string)
	if result.size() == 2:
		time_control.minutes = result[0].get_string()
		time_control.byoyomi = result[1].get_string()
	return time_control


func _ready():
	precompile_regex()

func parse_result(string):
	var result1 = regex_resign.search(string)
	if result1:
		return Games.GameResult.RESIGN
	var result2 = regex_disconnect.search(string)
	if result2:
		return Games.GameResult.DISCONNECT
	var result3 = regex_illegalmove.search(string)
	if result3:
		return Games.GameResult.ILLEGAL_MOVE
	var result4 = regex_repetition.search(string)
	if result4:
		return Games.GameResult.REPETITION
	var result5 = regex_impasse.search(string)
	if result5:
		return Games.GameResult.DECLARE_WIN
	var result6 = regex_perpetual_check.search(string)
	if result6:
		return Games.GameResult.PERPETUAL_CHECK
	var result7 = regex_declare_win.search(string)
	if result7:
		return Games.GameResult.DECLARE_WIN
		
	return Games.GameResult.NONE

func parse_replay(path, filename):
	var replay = Replay.new()
	replay.path = path
	replay.filename = filename
	var ext = filename.get_extension()
	if ext == "mkif":
		replay.format = ReplayFormat.KIF_MODERNSHOGI
	else:
		replay.format = ReplayFormat.KIF_81DOJO
	var file = File.new()
	if file.open(path + "/" + filename, File.READ) == OK:
		var strings = []
		var move_count = 0
		var reset_move_count = true
		while(!file.eof_reached()):
			var line = file.get_line()
			if line.empty():
				break
			strings.append(line)
			move_count += 1
			if move_count == 9 and reset_move_count:
				move_count = 1
				reset_move_count = false
		file.close()
		var version = strings[0]
		replay.date = parse_header_line(strings[1])
		replay.place = parse_header_line(strings[2])
		replay.time_control = parse_time_line(strings[3])
		replay.handicap = parse_header_line(strings[4])
		replay.handicap_value = Checks.handicap_from_string(replay.handicap)
		if replay.format == ReplayFormat.KIF_81DOJO:
			replay.handicap = transform_japanese_handicap(replay.handicap)
		elif replay.format == ReplayFormat.KIF_MODERNSHOGI:
			replay.handicap = transform_mkif_handicap(replay.handicap)
		replay.black_name = parse_header_line(strings[5])
		replay.white_name = parse_header_line(strings[6])
		replay.move_count = move_count - 1
		for i in range(replay.move_count):
			replay.moves.append(strings[8 + i])
		var end = strings[7 + move_count]
		replay.result = parse_result(end)
		replay.winner = "-"
		if replay.result == Games.GameResult.RESIGN or replay.result == Games.GameResult.DISCONNECT:
			if move_count % 2 == 0:
				replay.winner = replay.black_name
			else:
				replay.winner = replay.white_name
		elif replay.result == Games.GameResult.PERPETUAL_CHECK or replay.result == Games.GameResult.ILLEGAL_MOVE:
			if move_count % 2 == 0:
				replay.winner = replay.white_name
			else:
				replay.winner = replay.black_name
	else:
		return null
	return replay