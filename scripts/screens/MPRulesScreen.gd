extends "res://scripts/UIScreen.gd"

func _ready():
	self.title = "TITLE_MP_RULES"

func _on_CB_MP_RULES_ACCEPT_toggled(toggle):
	$ScrollBox/HBoxContainer/VBox/BTN_CONTINUE.disabled = !toggle

func _on_BTN_CONTINUE_pressed():
	goto_screen(UI.SCREEN_MP_CREATE_PROFILE)

func _on_MPRulesScreen_visibility_changed():
	$ScrollBox/HBoxContainer/VBox/CB_MP_RULES_ACCEPT.pressed = false
	$ScrollBox/HBoxContainer/VBox/BTN_CONTINUE.disabled = true