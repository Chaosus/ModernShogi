extends HBoxContainer

onready var icon = $Icon

var output_tex = preload("res://ui/buttons/output.png")
var input_tex = preload("res://ui/buttons/input.png")
var info_tex = preload("res://ui/buttons/info.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_text(string, icon_type):
	if icon_type == 0: # output
		icon.texture = output_tex
	elif icon_type == 1: # input
		icon.texture = input_tex
	elif icon_type == 2: # info
		icon.texture = info_tex
	if string != null:
		$Text.text = string
