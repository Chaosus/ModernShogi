extends "res://scripts/dialogs/PopupBase.gd"

# PasswordDialog.gd

var _result
var _has_result = false

onready var password_box = $VBoxContainer/PasswordHBox/PasswordBox

func has_result():
	return _has_result

func get_password():
	return password_box.text

func _on_OKButton_pressed():
	_has_result = true
	destroy()

func _on_CancelButton_pressed():
	_has_result = false
	destroy()
