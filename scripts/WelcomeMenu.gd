extends "res://scripts/UIScreen.gd"

# Экран приветствия
# На нём будет располагаться информация о первоначальной настройке

onready var next_screen = get_node("..").get_node("ThemeScreen")

func _ready():
	pass

func _on_BackBtn_pressed():
	go_back_if_possible()

func _on_BeginBtn_pressed():
	show_screen(next_screen)
