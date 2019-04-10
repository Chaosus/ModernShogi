extends PanelContainer
class_name UserBox

# UserBox.gd

onready var index_label = $VBox/HBox/Index
onready var status_offset = $VBox/HBox/StatusOffset
onready var status_box = $VBox/HBox/StatusRect
onready var country_label = $VBox/HBox/Country
onready var country_box = $VBox/HBox/CountryRect
onready var name_label = $VBox/HBox/Name
onready var rank_label = $VBox/HBox/Rank
onready var wins_label = $VBox/HBox/Wins
onready var losses_label = $VBox/HBox/Losses
onready var draws_label = $VBox/HBox/Draws
onready var show_account_btn = $VBox/HBox/ShowAccount

export(bool) var is_header = false

func get_id() -> int:
	return _id

var _id := -1
var _is_online := false
var _country_id := 0

func _setup_header(value):
	if !value:
		status_offset.visible = false
		status_box.visible = true
		
		country_label.visible = false
		country_box.visible = true
		
		rank_label.text = "?(?)"
		wins_label.text = "0"
		losses_label.text = "0"
		draws_label.text = "0"
		
		show_account_btn.visible = true
		
	else:
		status_offset.visible = true
		status_box.visible = false
		
		country_label.visible = true
		country_box.visible = false
		
		rank_label.text = "HEADER_PLAYER_RANK"
		wins_label.text = "HEADER_PLAYER_WINS"
		losses_label.text = "HEADER_PLAYER_LOSSES"
		draws_label.text = "HEADER_PLAYER_DRAWS"
		
		show_account_btn.visible = false
		
func _ready():
	_setup_header(is_header)

func _set_status_box(is_online):
	_is_online = is_online
	if is_online:
		status_box.texture = preload("res://ui/other/is_online.png")
	else:
		status_box.texture = preload("res://ui/other/is_offline.png")

func _set_country_box(country_id):
	_country_id = country_id
	country_box.texture = UI.get_country_texture(country_id)

func get_info() -> String:
	return "UserName: " + name_label.text + " Country: " + UI.get_country_name(_country_id)

# Изменение
func change(is_online, account_type, user_name, country_id, points, wins, losses, draws):
	_set_status_box(is_online)
	name_label.text = user_name
	_set_country_box(country_id)
	
	rank_label.text = Games.get_rank_string_from_rating(points) + "(" + str(points) + ")"
	wins_label.text = str(wins)
	losses_label.text = str(losses)
	draws_label.text = str(draws)

# Начальная установка
func setup(id, is_online, account_type, user_name, country_id, points, wins, losses, draws):
	_id = id
	index_label.text = str(id)
	change(is_online, account_type, user_name, country_id, points, wins, losses, draws)