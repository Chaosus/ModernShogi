extends "res://scripts/ui/FadeElement.gd"
class_name InfoPanel

onready var label = $VBox/HBoxInfo/LABEL_INFO

export(String) var text = ""

export(String) var prefix = ""

func _ready():
	UI.add_theme_element(self)
	
func apply_theme(theme):
	self.theme = theme
	
func start():
	label.text = TranslationServer.translate(prefix) + " " + TranslationServer.translate(text)
	margin_left = UI.get_resolution().x / 2 - rect_size.x / 2
	beautiful_show()
	
func stop():
	beautiful_hide()
