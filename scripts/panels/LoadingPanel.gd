extends "res://scripts/ui/FadeElement.gd"

onready var symbol = $VBox/Symbol

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	self.theme = theme

func _physics_process(delta):
	if visible:
		symbol.rotation = wrapf(symbol.rotation + 5 * delta, 0.0, TAU)
