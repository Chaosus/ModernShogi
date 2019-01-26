extends "res://scripts/ui/FadeElement.gd"

# PopupCentered.gd

signal yes_pressed
signal no_pressed
signal ok_pressed

var mode = 0
var self_destruct = false

var _update_position

func _ready():
	UI.add_theme_element(self)
	rect_scale = UI.scale
	hide()
	update_position()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		UI.remove_theme_element(self) 

func update_mode(mode):
	self.mode = mode
	if mode == 0:
		$VBoxContainer/HBoxYesNo.show()
		$VBoxContainer/HBoxNoYes.hide()
		$VBoxContainer/HBoxOK.hide()
	elif mode == 1:
		$VBoxContainer/HBoxYesNo.hide()
		$VBoxContainer/HBoxNoYes.show()
		$VBoxContainer/HBoxOK.hide()
	else:
		$VBoxContainer/HBoxYesNo.hide()
		$VBoxContainer/HBoxNoYes.hide()
		$VBoxContainer/HBoxOK.show()

func beautiful_show():
	return .beautiful_show()

func _physics_process(delta):
	if _update_position:
		update_position()
		_update_position = false

func update_position():
	rect_position.x = ((UI.get_real_resolution().x / 2.0) - (rect_size.x * UI.scale.x / 2.0))
	rect_position.y = (((UI.get_real_resolution().y + 128) / 2.0) - (rect_size.y * UI.scale.y / 2.0))

func set_title(text):
	$VBoxContainer/HBoxContainer/Desc.text = text
	yield(get_tree(), "idle_frame")
	update_position()

func apply_theme(theme):
	self.theme = theme

func destroy():
	if self_destruct:
		yield(beautiful_hide(), "hide_completed")
		queue_free()
	else:	
		beautiful_hide()

func _on_ButtonYes_pressed():
	emit_signal("yes_pressed")
	destroy()
	
func _on_ButtonNo_pressed():
	emit_signal("no_pressed")
	destroy()

func _on_ButtonOK_pressed():
	emit_signal("ok_pressed")
	destroy()