extends "res://scripts/ui/FadeElement.gd"
class_name PlayerPanel

var country_tag = 0

export(bool) var side = false

onready var name_label = $VBox/NameLabel
onready var timer_label = $VBox/Timer/TimerLabel

onready var rank_box = $VBox/RankBox
onready var rating_box = $VBox/RatingBox
onready var country_box = $VBox/CountryBox

var cpu_mode_enabled := false
var byomi_mode_enabled := false

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	self.theme = theme
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))
	$VBox/CountryBox/CountryIcon.tooltip = UI.get_country_name(country_tag)
	if side:
		$VBox/CountryBox/CountryIcon.tooltip_align = 2
	
func _on_HideButton_pressed():
	get_tree().call_group("player_panel", "beautiful_hide")

func set_byomi_mode_enabled(enabled : bool) -> void:
	byomi_mode_enabled = enabled
	if enabled:
		timer_label.self_modulate = Color.yellow
	else:
		timer_label.self_modulate = Color.white

func set_timer(minutes : int, seconds : int, byomi : int) -> void:
	if byomi_mode_enabled:
		timer_label.text = "0 : " + str(byomi)
	else:
		timer_label.text = str(minutes) + " : " + str(seconds) + "(" + str(byomi) + ")"

func set_cpu_mode(enabled : bool) -> void:
	cpu_mode_enabled = enabled
	rank_box.visible = enabled
	rating_box.visible = enabled
	country_box.visible = enabled	

func set_name(name : String) -> void:
	name_label.text = name