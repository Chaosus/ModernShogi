extends "res://scripts/ui/FadeElement.gd"

func _ready():
	UI.add_theme_element(self)
	
func apply_theme(theme):
	self.theme = theme

func add_piece_theme(name):
	pass
