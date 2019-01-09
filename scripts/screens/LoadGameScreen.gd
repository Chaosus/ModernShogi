extends "res://scripts/UIScreen.gd"

# LoadGameScreen.gd

onready var sfen_textbox = $Box/VBox/SFENTextBox
onready var net_box = $Box/VBox/VBoxNetwork
onready var port_box = $Box/VBox/VBoxNetwork/NetBox/VBox/HBoxPort/SpinBox
onready var game_name = $Box/VBox/VBoxNetwork/NetBox/VBox/HBoxGameName/GameName

var target = 0

func _ready():
	self.title = "TITLE_LOADGAME"

func _on_TargetLocalRadioButton_pressed():
	target = 0
	net_box.hide()

func _on_TargetHostRadioButton_pressed():
	target = 1
	net_box.show()

func _on_ResetSFENButton_pressed():
	sfen_textbox.text = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b"

func _on_LoadButton_pressed():
	GameStarter.set_from_screen(self)
	if target == 0: # Локальная игра
		GameStarter.start_local(Games.PlayerConfig.PVP, 0, 0, 0, Games.ShogiHandicaps.NONE, sfen_textbox.text)
	elif target == 1: # Сетевая игра
		GameStarter.start_host(port_box.value, 0, 0, 0, Games.ShogiHandicaps.NONE, sfen_textbox.text)
		
func parse_sfen():
	return true




