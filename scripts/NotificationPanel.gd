extends "res://scripts/ui/FloatElement.gd"

onready var label = get_node("Label")

func beautiful_show(text):
	label.text = text
	return .beautiful_show()