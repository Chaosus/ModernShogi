extends "res://scripts/ui/FadeElement.gd"

class_name PlayerPanel

# PlayerPanel.gd

onready var avatar = $VBox/AvatarImage
onready var name_label = $VBox/NameLabel
onready var timer_box = $VBox/TimerBox
onready var timer_label = $VBox/TimerBox/TimerLabel
onready var rank_box = $VBox/RankBox
onready var rating_box = $VBox/RatingBox
onready var country_box = $VBox/CountryBox
onready var hide_button = $VBox/HideButton
onready var show_button = $VBox/ShowButton

export(bool) var side = false

var country_tag = 0
var cpu_mode_enabled := false
var byomi_mode_enabled := false

var timer_enabled := false setget set_timer_enabled, get_timer_enabled
func set_timer_enabled(enabled : bool) -> void:
	if timer_enabled == enabled:
		return
	timer_enabled = enabled
	if enabled:
		timer_box.visible = true
	else:
		timer_box.visible = false
	self.rect_size.y = 0	
func get_timer_enabled() -> bool:
	return timer_enabled

var full_mode := true setget set_full_mode, get_full_mode
func set_full_mode(enabled : bool) -> void:
	if full_mode == enabled:
		return
	full_mode = enabled
	if enabled:
		hide_button.visible = true
		show_button.visible = false	
		avatar.visible = true
		rank_box.visible = true
		rating_box.visible = true
		country_box.visible = true
	else:
		hide_button.visible = false
		show_button.visible = true		
		avatar.visible = false
		rank_box.visible = false
		rating_box.visible = false
		country_box.visible = false
	self.rect_size.y = 0
func get_full_mode() -> bool:
	return full_mode

func _ready() -> void:
	UI.add_theme_element(self)

func apply_theme(theme : Theme) -> void:
	self.theme = theme
	add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))
	$VBox/CountryBox/CountryIcon.tooltip = UI.get_country_name(country_tag)
	if side:
		$VBox/CountryBox/CountryIcon.tooltip_align = 2
	
func _on_HideButton_pressed() -> void:
	set_full_mode(false)

func _on_ShowButton_pressed() -> void:
	set_full_mode(true)
	
func set_byomi_mode_enabled(enabled : bool) -> void:
	byomi_mode_enabled = enabled
	if enabled:
		timer_label.self_modulate = Color.yellow
	else:
		timer_label.self_modulate = Color.white

func set_timer(minutes : int, seconds : int, byomi : int) -> void:
	if byomi_mode_enabled:
		timer_label.text = str(byomi)
	else:
		timer_label.text = str(minutes) + " : " + str(seconds) + "(" + str(byomi) + ")"

func set_cpu_mode(enabled : bool) -> void:
	cpu_mode_enabled = enabled
	rank_box.visible = enabled
	rating_box.visible = enabled
	country_box.visible = enabled	

func set_name(name : String) -> void:
	name_label.text = name

func set_position(position : Vector2) -> void:
	self.rect_position = position

func get_position() -> Vector2:
	return rect_position