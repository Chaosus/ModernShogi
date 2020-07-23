extends Control

# GameBox.gd

onready var index_label = $VBox/HBox/Index
onready var password_box = $VBox/HBox/Password
onready var places_label = $VBox/HBox/Places
onready var turn_count = $VBox/HBox/TurnCount
onready var players_label = $VBox/HBox/Players
onready var game_label = $VBox/HBox/GameType
onready var handicap_label = $VBox/HBox/Handicap
onready var desc_label = $VBox/HBox/Description
onready var server_ip_label = $VBox/HBox/ServerIP

export(bool) var is_header = false

var id
var key
var game
var game_name
var game_handicap
var is_rated
var is_protected

func expand(enabled):
	if enabled:
		desc_label.rect_min_size.x = 485
		rect_min_size.x = 1920
	else:
		desc_label.rect_min_size.x = 455
		rect_min_size.x = 1920 - 30
	
	desc_label.rect_size.x = desc_label.rect_min_size.x
	rect_size.x = rect_min_size.x

func change(player_names, player_count, obs_count, turn_count):
	players_label.text = player_names
	places_label.text = "2/" + str(player_count)
	if obs_count > 0:
		places_label.text += "(" + str(obs_count) + ")"
	self.turn_count.text = str(turn_count)
		
func _setup_std(id, key, is_rated, is_protected, game, game_name, player_names, player_count, obs_count, turn_count):
	self.id = id
	self.key = key
	index_label.text = str(id)
	self.is_rated = is_rated
	self.is_protected = is_protected
	if !is_protected:
		password_box.texture = null
	places_label.text = "2/" + str(player_count)
	if obs_count > 0:
		places_label.text += "(" + str(obs_count) + ")"
	game_label.text = "?"
	self.game = game
	match game:
		Games.GameType.SHOGI:
			game_label.text = "LABEL_GAME_NAME_SHOGI"
	players_label.text = player_names
	self.game_name = game_name
	desc_label.text = game_name
	$VBox/HBox/JoinButton.apply_current_theme()
	$VBox/HBox/ObserveButton.apply_current_theme()
	self.turn_count.text = str(turn_count)
	#if player_count > 1:
	#	$VBox/HBox/JoinButton.disabled = true

func setup_header():
	is_header = true
	$VBox/HBox/VSeparator10.hide()
	$VBox/HBox/JoinButton.hide()
	$VBox/HBox/ObserveButton.hide()
	index_label.text = "#"
	places_label.text = "HEADER_PLACES"
	turn_count.text = "HEADER_TURN_COUNT"
	game_label.text = "HEADER_GAMETYPE"
	handicap_label.text = "HEADER_HANDICAP"
	server_ip_label.text = "IP"
	players_label.text = "HEADER_PLAYERS"
	desc_label.text = "HEADER_SERVER_DESC"
	
func setup_save(id, key, is_rated, is_protected, game_type, game_name, handicap, sfen, username, player_count, obs_count, turn_count):
	_setup_std(id, key, is_rated, is_protected, game_type, game_name, username, player_count, obs_count, turn_count)
	handicap_label.text = "[SFEN]"

func setup(id, key, is_rated, is_protected, game_type, game_name, handicap, sfen, username, player_count, obs_count, turn_count):
	_setup_std(id, key, is_rated, is_protected, game_type, game_name, username, player_count, obs_count, turn_count)
	handicap_label.text = "?"
	self.game_handicap = handicap
	match handicap:
		Games.ShogiHandicaps.NONE:
			handicap_label.text = "None"
		Games.ShogiHandicaps.LEFT_LANCE:
			handicap_label.text = "LeftLance"
		Games.ShogiHandicaps.BISHOP:
			handicap_label.text = "Bishop"
		Games.ShogiHandicaps.ROOK:
			handicap_label.text = "Rook"
		Games.ShogiHandicaps.ROOK_LEFT_LANCE:
			handicap_label.text = "RookLeftLance"
		Games.ShogiHandicaps.PIECE2:
			handicap_label.text = "Piece2"
		Games.ShogiHandicaps.PIECE3:
			handicap_label.text = "Piece3"
		Games.ShogiHandicaps.PIECE4:
			handicap_label.text = "Piece4"
		Games.ShogiHandicaps.PIECE5:
			handicap_label.text = "Piece5"
		Games.ShogiHandicaps.PIECE6:
			handicap_label.text = "Piece6"
		Games.ShogiHandicaps.PIECE7:
			handicap_label.text = "Piece7"
		Games.ShogiHandicaps.PIECE8:
			handicap_label.text = "Piece8"
		Games.ShogiHandicaps.PIECE9:
			handicap_label.text = "Piece9"
		Games.ShogiHandicaps.PIECE10:
			handicap_label.text = "Piece10"
		Games.ShogiHandicaps.PAWNS3:
			handicap_label.text = "Pawns3"
		Games.ShogiHandicaps.NAKED_KING:
			handicap_label.text = "OnlyKing"
		Games.ShogiHandicaps.DRAGONFLY:
			handicap_label.text = "Dragonfly"
		Games.ShogiHandicaps.DRAGONFLY_LANCES:
			handicap_label.text = "DragonflyLances"
		Games.ShogiHandicaps.DRAGONFLY_LANCES_KNIGHTS:
			handicap_label.text = "DragonflyLancesKnights"

func _ready():
	if is_header:
		setup_header()

func _on_ObserveButton_pressed():
	var ss = UI.get_root().server_screen
	
	ss.saved_game_id = key
	ss.saved_game_type = game
	ss.saved_is_rated = is_rated
	ss.saved_game_name = game_name
	ss.saved_handicap = game_handicap
	
	if is_protected:
		var dialog = UI.call_password_dialog()
		yield(dialog, "destroyed")
		if dialog.has_result():
			Network.request_join_protected(key, true, dialog.get_password())
		return
	Network.request_join(key, true)
	
func _on_JoinButton_pressed():
	var ss = UI.get_root().server_screen
	
	ss.saved_game_id = key
	ss.saved_game_type = game
	ss.saved_is_rated = is_rated
	ss.saved_game_name = game_name
	ss.saved_handicap = game_handicap
	
	if is_protected:
		var dialog = UI.call_password_dialog()
		yield(dialog, "destroyed")
		if dialog.has_result():
			Network.request_join_protected(key, false, dialog.get_password())
		return
	Network.request_join(key, false)
