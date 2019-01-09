extends "res://scripts/UIScreen.gd"

onready var ai_box = $Box/SimpleLayout/QuickAIControl
onready var ai_error_box = $Box/SimpleLayout/QuickAIControl/AIBox/VBox/VBoxQuickAIError
onready var ai_box2 = $Box/SimpleLayout/QuickAIControl/AIBox/VBox/QuickAIControl
onready var ai_handicap = $Box/SimpleLayout/HandicapBox/VBox/VBox/HBoxAIHandicap

onready var minutes_list = $Box/SimpleLayout/TimeControl/HBoxTimeControl/TimeControlMinutes
onready var seconds_list = $Box/SimpleLayout/TimeControl/HBoxTimeControl/TimeControlSeconds

onready var handicap_box = $Box/SimpleLayout/HandicapBox
onready var handicap_header = $Box/SimpleLayout/SH_GAME_HANDICAP
onready var handicap_control = $Box/SimpleLayout/HandicapBox/VBox/VBox/HBoxHandicap/CB_GAME_ENABLE_HANDICAP

# NETWORK SETTINGS

onready var net_box = $Box/SimpleLayout/VBoxNetworkControl
onready var port_box = $Box/SimpleLayout/VBoxNetworkControl/NetBox/VBox/HBoxPort
onready var port = $Box/SimpleLayout/VBoxNetworkControl/NetBox/VBox/HBoxPort/SpinBox

# GAME SETTINGS

onready var game_type_box = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/GameType
onready var game_name_box = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/GameName
onready var game_name = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/GameName/GameName
onready var password_box = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/Password
onready var password_box2 = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/Password/PasswordBox

onready var host_side_box = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/HostSide/HBoxSide
onready var side_box = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/HostSide

onready var random_side_label = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/HostSide/RandomSide
onready var black_side_label = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/HostSide/BlackSide
onready var white_side_label = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/HostSide/WhiteSide
onready var local_side_label = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/HostSide/LocalSide
onready var ai_side_label = $Box/SimpleLayout/GameSettings/GameBox/VBox/HBox/VBox/HostSide/AISide

onready var create_button = $Box/SimpleLayout/CreateButton

var is_rated_game = true
var is_private_game = false
var password = null

var host_side = 0

var _handicap = -1
var _files = []

var is_ai_game
var mp_host = false
var player_config
var from_master

var handicap_toggled = false
var is_local_side = false

var give_ai_handicap = false

var create_click = false

enum {
	SIDE_DISABLE_ALL
	SIDE_LOCAL,
	SIDE_AI,
	SIDE_BLACK,
	SIDE_WHITE	
}

# Настройки сети

func _on_SetupScreen_visibility_changed():
	if visible:
		if is_ai_game:
			if Profiles.get_value(Settings.SV_AI_ENGINE_EXE) == "":
				ai_error_box.visible = true
				ai_box2.visible = false
				create_button.disabled = true
			else:
				ai_error_box.visible = false
				ai_box2.visible = true
				create_button.disabled = false

func setup_standart():
	from_master = false
	is_ai_game = false
	self.mp_host = false
	create_button.disabled = false
	ai_handicap.visible = false
	ai_box.visible = false
	if !ai_vs_ai_mode:
		if handicap_toggled:
			host_side_box.visible = false
			black_side_label.visible = true
		else:	
			host_side_box.visible = true
			black_side_label.visible = false
	ai_side_label.visible = false
	white_side_label.visible = false
	local_side_label.visible = false
	side_box.visible = true
	is_local_side = false
	game_type_box.visible = false
	password_box.visible = false
	game_name_box.visible = false
	port_box.visible = true
	random_side_label.visible = false
	handicap_box.visible = true
	handicap_header.visible = true
	get_tree().call_group("local_offset", "set_visible", false)

func setup_ai_game():
	is_ai_game = true
	ai_box.visible = true
	ai_handicap.visible = handicap_toggled
	if ai_vs_ai_mode:
		ai_side_label.visible = true
		host_side_box.visible = false
	else:
		if handicap_toggled:
			host_side_box.visible = false
			if give_ai_handicap:
				black_side_label.visible = false
				white_side_label.visible = true
			else:
				black_side_label.visible = true
				white_side_label.visible = false

func setup_local():
	is_local_side = true
	local_side_label.visible = true
	
	get_tree().call_group("local_offset", "set_visible", true)
	
	host_side_box.visible = false
	ai_side_label.visible = false
	black_side_label.visible = false
	white_side_label.visible = false

func setup_config(config, mp_host, master_server = false) -> void:
	player_config = config
	self.mp_host = mp_host
	if mp_host:
		net_box.visible = true
	else:
		net_box.visible = false
	from_master = master_server
	if from_master:
		game_type_box.visible = true
		if is_rated_game:
			host_side_box.visible = false
			random_side_label.visible = true
			handicap_box.visible = false
			handicap_header.visible = false
		elif is_private_game:
			password_box.visible = true
		game_name_box.visible = true
		port_box.visible = false
		net_box.visible = false
		get_tree().call_group("local_offset", "set_visible", true)
		
func _ready():
	self.title = "TITLE_GAME_CREATION"
	UI.register_named_element(UI.SR_AI_SKILL_LEVEL2, $Box/SimpleLayout/QuickAIControl/AIBox/VBox/QuickAIControl/HBoxAISkillLevel/AISkillLevelSlider)
	UI.register_named_element(UI.LABEL_AI_SKILL_LEVEL2, $Box/SimpleLayout/QuickAIControl/AIBox/VBox/QuickAIControl/HBoxAISkillLevel/AISkillLevelSV)

	var tm = minutes_list
	tm.add_item("0")
	tm.add_item("5")
	tm.add_item("10")
	tm.add_item("15")
	tm.add_item("20")
	tm.add_item("30")
	tm.add_item("45")
	tm.add_item("60")
	
	var tb = seconds_list
	tb.add_item("10")
	tb.add_item("20")
	tb.add_item("30")
	tb.add_item("60")

func update_side(v):
	match v:
		SIDE_DISABLE_ALL:
			black_side_label.visible = false
			white_side_label.visible = false
			local_side_label.visible = false
			ai_side_label.visible = false
			host_side_box.visible = true
		SIDE_AI:
			black_side_label.visible = false
			white_side_label.visible = false
			local_side_label.visible = false
			ai_side_label.visible = true
			host_side_box.visible = false
		SIDE_LOCAL:
			black_side_label.visible = false
			white_side_label.visible = false
			ai_side_label.visible = false
			local_side_label.visible = true
			host_side_box.visible = false
		SIDE_BLACK:
			white_side_label.visible = false
			ai_side_label.visible = false
			local_side_label.visible = false
			black_side_label.visible = true
			host_side_box.visible = false
		SIDE_WHITE:
			ai_side_label.visible = false
			local_side_label.visible = false
			black_side_label.visible = false
			white_side_label.visible = true
			host_side_box.visible = false

# Game settings

func _on_RatedGameRadioBox_pressed():
	is_rated_game = true
	is_private_game = false
	password = null
	host_side_box.visible = false
	random_side_label.visible = true
	handicap_box.visible = false
	handicap_header.visible = false
	password_box.visible = false
	
func _on_UnratedGameRadioBox_pressed():
	is_rated_game = false
	is_private_game = false
	password = null
	host_side_box.visible = true
	random_side_label.visible = false
	handicap_box.visible = true
	handicap_header.visible = true
	password_box.visible = false

func _on_PrivateGameRadioBox_pressed():
	is_rated_game = false
	is_private_game = true
	password = ""
	host_side_box.visible = true
	random_side_label.visible = false
	handicap_box.visible = true
	handicap_header.visible = true
	password_box.visible = true
			
func _on_CB_GAME_ENABLE_HANDICAP_toggled(toggled):
	handicap_toggled = toggled
	if is_ai_game:
		ai_handicap.visible = toggled
	get_tree().call_group("handicap_separator", "set_visible", toggled)
	#get_tree().call_group("handicap_separator", "set_visible", button_pressed)
	$Box/SimpleLayout/HandicapBox/VBox/VBox2.visible = toggled
	if !is_local_side:
		if toggled:
			if  ai_vs_ai_mode and is_ai_game:
				update_side(SIDE_AI)
			elif is_ai_game and give_ai_handicap:
				update_side(SIDE_WHITE)
			else:
				update_side(SIDE_BLACK)
		else:
			if is_ai_game:
				if ai_vs_ai_mode:
					update_side(SIDE_AI)
				else:
					update_side(SIDE_DISABLE_ALL)
			else:
				update_side(SIDE_DISABLE_ALL)
	if _handicap == -1:
		_handicap = Games.ShogiHandicaps.LEFT_LANCE



func _on_AIGiveHandicapCheckBox_toggled(toggled):
	give_ai_handicap = toggled
	if !ai_vs_ai_mode:
		if toggled:
			update_side(SIDE_WHITE)
		else:
			update_side(SIDE_BLACK)
		
# Быстрые настройки AI

var ai_vs_ai_mode = false

func _on_CPUBattleCheckBox_toggled(toggled):
	ai_vs_ai_mode = toggled
	if !handicap_toggled:
		if toggled:
			update_side(SIDE_AI)
		else:
			update_side(SIDE_DISABLE_ALL)
	else:
		if toggled:
			update_side(SIDE_AI)
		else:
			if give_ai_handicap:
				update_side(SIDE_WHITE)
			else:
				update_side(SIDE_BLACK)
	
func _on_AIAdvancedSettingsButton_pressed():
	UI.get_root().open_ai_settings()

# Настройки стороны хостера

func _on_RandomCheckBox_pressed():
	host_side = 0

func _on_BlackCheckBox_pressed():
	host_side = 1

func _on_WhiteCheckBox_pressed():
	host_side = 2

# Фора

func _on_HandicapLeftLance_pressed():
	_handicap = Games.ShogiHandicaps.LEFT_LANCE

func _on_HandicapBishop_pressed():
	_handicap = Games.ShogiHandicaps.BISHOP

func _on_HandicapRook_pressed():
	_handicap = Games.ShogiHandicaps.ROOK

func _on_HandicapRookLeftLance_pressed():
	_handicap = Games.ShogiHandicaps.ROOK_LEFT_LANCE

func _on_HandicapPiece2_pressed():
	_handicap = Games.ShogiHandicaps.PIECE2

func _on_HandicapPiece3_pressed():
	_handicap = Games.ShogiHandicaps.PIECE3

func _on_HandicapPiece4_pressed():
	_handicap = Games.ShogiHandicaps.PIECE4

func _on_HandicapPiece5_pressed():
	_handicap = Games.ShogiHandicaps.PIECE5

func _on_HandicapPiece6_pressed():
	_handicap = Games.ShogiHandicaps.PIECE6

func _on_HandicapPiece7_pressed():
	_handicap = Games.ShogiHandicaps.PIECE7

func _on_HandicapPiece8_pressed():
	_handicap = Games.ShogiHandicaps.PIECE8

func _on_HandicapPiece9_pressed():
	_handicap = Games.ShogiHandicaps.PIECE9

func _on_HandicapPiece10_pressed():
	_handicap = Games.ShogiHandicaps.PIECE10

func _on_Handicap3Pawns_pressed():
	_handicap = Games.ShogiHandicaps.PAWNS3

func _on_HandicapNakedKing_pressed():
	_handicap = Games.ShogiHandicaps.NAKED_KING

func _on_HandicapDragonfly_pressed():
	_handicap = Games.ShogiHandicaps.DRAGONFLY

func _on_HandicapDragonflyLances_pressed():
	_handicap = Games.ShogiHandicaps.DRAGONFLY_LANCES

func _on_HandicapDragonflyLancesKnights_pressed():
	_handicap = Games.ShogiHandicaps.DRAGONFLY_LANCES_KNIGHTS

func _on_AISkillLevelSlider_value_changed(value):
	UI.get_named_element(UI.SR_AI_SKILL_LEVEL).value = float(value)
	value = int(value)
	Profiles.set_current_settings(Settings.SV_AI_ENGINE_SKILL_LEVEL, value)
	UI.get_named_element(UI.LABEL_AI_SKILL_LEVEL2).text = str(value)
	if UI.get_game().has_active_session():
		UI.get_ai().SetSkillLevel(value)

func _on_CreateButton_pressed():
	if is_private_game:
		if password_box2.text.length() == 0:
			UI.call_dialog("LABEL_PASSWORD_EMPTY")
			return
	
	if create_click:
		return
		
	create_click = true
	
	var minutes = minutes_list.get_item_text(minutes_list.selected)
	var seconds = seconds_list.get_item_text(seconds_list.selected)
	var handicap = Games.ShogiHandicaps.NONE
	var side = host_side
	
	if !is_rated_game:
		if handicap_control.pressed:
			handicap = _handicap
	else:
		side = 0
			
	if is_ai_game:
		if ai_vs_ai_mode:
			side = -1
		elif handicap != Games.ShogiHandicaps.NONE:
			if !give_ai_handicap:
				side = 1
			else:
				side = 2
	else:
		if handicap != Games.ShogiHandicaps.NONE:
			side = 1
	
	GameStarter.set_from_screen(self)
	if from_master:
		
		if is_private_game:
			password = password_box2.text
		
		Network.request_create_game(Games.GameType.SHOGI, is_rated_game, game_name.text, handicap, side, password)
	if mp_host:
		GameStarter.start_host(port.value, is_rated_game, side, minutes, seconds, handicap, null, from_master)
	else:
		GameStarter.start_local(player_config, side, minutes, seconds, handicap)



