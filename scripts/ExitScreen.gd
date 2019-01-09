extends "res://scripts/UIScreen.gd"

onready var next_screen = get_node("..").get_node("GoodBayScreen")

func _ready():
	pass

func _on_ExitScreen_visibility_changed():
	return
	if !$VBox/HSplitContainer/NoBtn.has_focus():
		$VBox/HSplitContainer/NoBtn.grab_focus()

func _on_YesBtn_pressed():
	show_screen(next_screen)

func _on_NoBtn_pressed():
	go_back_if_possible()
