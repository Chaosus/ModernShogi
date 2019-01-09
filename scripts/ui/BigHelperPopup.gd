extends "res://scripts/ui/FadeElement.gd"

onready var header = $CBox/VBoxContainer/Header
onready var description = $CBox/VBoxContainer/Description

func _ready():
	UI.add_theme_element(self)

func _input(event):
	if event.is_pressed():
		beautiful_hide()

func apply_theme(theme):
	self.theme = theme

func beautiful_hide():
	return .beautiful_hide()

func show_tooltip(header, text):
	if get_show_state() == ShowState.NONE:
		return
	self.header.text = header
	self.description.text = text
	beautiful_show()
	self.rect_size = $CBox/VBoxContainer.rect_size + Vector2(60, 60)
	self.rect_position = UI.get_resolution() / 2.0 - self.rect_size / 2.0
	$CBox.rect_size = self.rect_size
	beautiful_show()