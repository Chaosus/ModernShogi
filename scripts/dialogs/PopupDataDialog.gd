extends "res://scripts/dialogs/PopupBase.gd"

# PopupDataDialog.gd

signal ok_pressed

func _ready():
	UI.add_theme_element(self)
	rect_scale = UI.scale
	hide()

func set_caption(text):
	$VBox/Caption/Caption.text = text
	yield(get_tree(), "idle_frame")
	.update_position()

func set_data(text):
	$VBox/Data/Data.text = text
	yield(get_tree(), "idle_frame")
	.update_position()
	
func _on_ButtonOK_pressed():
	emit_signal("ok_pressed")
	destroy()