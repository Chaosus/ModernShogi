extends "res://scripts/dialogs/PopupBase.gd"

# PlayerJoiningPanel.gd

var user_id = 0
var user_name = ""
var country_tag = 0

onready var name_box = $VBoxContainer/Name
onready var rank_box = $VBoxContainer/RankBox/Rank
onready var rating_box = $VBoxContainer/RankBox/RatingPoints
onready var wins_box = $VBoxContainer/StatsBox/WinCount
onready var draws_box = $VBoxContainer/StatsBox/DrawCount
onready var loses_box = $VBoxContainer/StatsBox/LoseCount

onready var country_box = $VBoxContainer/CountryBox/CountryIcon

func _ready():
	UI.add_theme_element(self)

func setup_params(id, name, avatar_tag, country, rating, wins, loses, draws):
	user_id = id
	user_name = name
	country_tag = country
	
	name_box.text = name
	country_box.texture_normal = UI.get_country_texture(country_tag)
	country_box.tooltip = UI.get_country_name(country_tag)
	
	rank_box.text = Games.get_rank_string_from_rating(rating)
	rating_box.text = str(rating)
	wins_box.text = str(wins)
	draws_box.text = str(draws)
	loses_box.text = str(loses)
	
func apply_theme(theme):
	self.theme = theme
	$VBoxContainer/CountryBox/CountryIcon.tooltip = UI.get_country_name(country_tag)
	$VBoxContainer/CountryBox/CountryIcon.tooltip_align = 1
	$VBoxContainer/ActionsBox/AcceptButton.apply_theme(theme)
	$VBoxContainer/ActionsBox/DeclineButton.apply_theme(theme)

func _on_AcceptButton_pressed():
	Network.accept_joining_request(user_id)
	destroy()

func _on_DeclineButton_pressed():
	Network.decline_joining_request(user_id)
	destroy()
	