extends "res://scripts/ui/FadeElement.gd"

class_name TimerPanel

onready var name_label = $VBox/NameLabel

func _ready() -> void:
	pass
	
func set_name(name : String) -> void:
	name_label.text = name