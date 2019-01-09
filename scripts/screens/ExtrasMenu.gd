extends "res://scripts/UIScreen.gd"

func _ready():
	pass
	#set_previous_screen(get_node("..").get_node("MainMenuScreen"))

func _on_BackBtn_pressed():
	go_back_if_possible()
