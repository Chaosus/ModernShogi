extends AudioStreamPlayer

# Commentator.gd
onready var _sfx_pos_1 = preload("res://sounds/speech/1.wav")
onready var _sfx_pos_2 = preload("res://sounds/speech/2.wav")
onready var _sfx_pos_3 = preload("res://sounds/speech/3.wav")
onready var _sfx_pos_4 = preload("res://sounds/speech/4.wav")
onready var _sfx_pos_5 = preload("res://sounds/speech/5.wav")
onready var _sfx_pos_6 = preload("res://sounds/speech/6.wav")
onready var _sfx_pos_7 = preload("res://sounds/speech/7.wav")
onready var _sfx_pos_8 = preload("res://sounds/speech/8.wav")
onready var _sfx_pos_9 = preload("res://sounds/speech/9.wav")
onready var _sfx_side_black = preload("res://sounds/speech/black.wav")
onready var _sfx_side_white = preload("res://sounds/speech/white.wav")
onready var _sfx_check = preload("res://sounds/speech/check.wav")
onready var _sfx_drop = preload("res://sounds/speech/drop.wav")
onready var _sfx_promoted = preload("res://sounds/speech/promoted.wav")
onready var _sfx_promotion = preload("res://sounds/speech/promotion.wav")
onready var _sfx_on = preload("res://sounds/speech/on.wav")
onready var _sfx_checkmate = preload("res://sounds/speech/checkmate.wav")
onready var _sfx_shogi_pawn = preload("res://sounds/speech/pawn.wav")
onready var _sfx_shogi_lance = preload("res://sounds/speech/lance.wav")
onready var _sfx_shogi_knight = preload("res://sounds/speech/knight.wav")
onready var _sfx_shogi_silver = preload("res://sounds/speech/silver.wav")
onready var _sfx_shogi_gold = preload("res://sounds/speech/gold.wav")
onready var _sfx_shogi_rook = preload("res://sounds/speech/rook.wav")
onready var _sfx_shogi_bishop = preload("res://sounds/speech/bishop.wav")
onready var _sfx_shogi_king = preload("res://sounds/speech/king.wav")
onready var _sfx_shogi_horse = preload("res://sounds/speech/horse.wav")
onready var _sfx_shogi_dragon = preload("res://sounds/speech/dragon.wav")

var _say_check
var _say_checkmate

func say_side(side):
	stream = _sfx_side_black if side == 0 else _sfx_side_white
	return _say()

func say_piece(piece_type, promoted):
	match piece_type:
		Games.ShogiPieceTypes.PAWN:
			stream = _sfx_shogi_pawn
		Games.ShogiPieceTypes.LANCE:
			stream = _sfx_shogi_lance
		Games.ShogiPieceTypes.KNIGHT:
			stream = _sfx_shogi_knight
		Games.ShogiPieceTypes.SILVER:
			stream = _sfx_shogi_silver
		Games.ShogiPieceTypes.GOLD:
			stream = _sfx_shogi_gold
		Games.ShogiPieceTypes.ROOK:
			if promoted:
				stream = _sfx_shogi_dragon
			else:
				stream = _sfx_shogi_rook
		Games.ShogiPieceTypes.BISHOP:
			if promoted:
				stream = _sfx_shogi_horse
			else:
				stream = _sfx_shogi_bishop
		Games.ShogiPieceTypes.KING:
			stream = _sfx_shogi_king
	return _say()

func say_number(n):
	match int(n):
		1:
			stream = _sfx_pos_1
		2:
			stream = _sfx_pos_2
		3:
			stream = _sfx_pos_3
		4:
			stream = _sfx_pos_4
		5:
			stream = _sfx_pos_5
		6:
			stream = _sfx_pos_6
		7:
			stream = _sfx_pos_7
		8:
			stream = _sfx_pos_8
		9:
			stream = _sfx_pos_9
	return _say()

func say_drop():
	stream = _sfx_drop
	return _say()

func say_promoted():
	stream = _sfx_promoted
	return _say()

func say_promotion():
	stream = _sfx_promotion
	return _say()

func say_on():
	stream = _sfx_on
	return _say()
	
func say_check():
	if playing:
		_say_check = true
		return
		
	stream = _sfx_check
	_say_check = false
	_say()	
	
func say_checkmate():
	if playing:
		_say_checkmate = true
		return
	
	stream = _sfx_checkmate
	_say_checkmate = false
	_say()	
	
func say_record(record):
	UI.get_ai().SetSFXPause(true)
	yield(say_side(record.side), "finished")
	yield(get_tree().create_timer(0.1), "timeout")
	if record.drop:
		yield(say_drop(), "finished")
		yield(get_tree().create_timer(0.1), "timeout")	
	var p = !record.piece_was_promoted and record.piece.is_promoted()
	if p and record.piece_type != Games.ShogiPieceTypes.BISHOP and record.piece_type != Games.ShogiPieceTypes.ROOK:
		yield(say_promoted(), "finished")
	yield(say_piece(record.piece_type, p), "finished")
	yield(get_tree().create_timer(0.15), "timeout")	
	if record.drop:
		yield(say_on(), "finished")
		yield(get_tree().create_timer(0.15), "timeout")	

	yield(say_number(record.next_nest.x), "finished")
	yield(get_tree().create_timer(0.12), "timeout")	
	yield(say_number(record.next_nest.y), "finished")
	yield(get_tree().create_timer(0.12), "timeout")	
	
	if record.piece_was_promoted:
		yield(say_promotion(), "finished")
	
	if _say_check:
		say_check()
	elif _say_checkmate:
		say_checkmate()
		
	yield(get_tree().create_timer(0.12), "timeout")	
	UI.get_ai().SetSFXPause(false)
		
func _say():
	
	volume_db = linear2db(clamp(Profiles.get_current_settings().get_value(Settings.SV_SFX_SPEECH_VOLUME) / 100, 0.0, 1.0))
	play()
	return self

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here.
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
