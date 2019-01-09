extends Node

onready var background = $TextureRect

func _ready():
	background.beautiful_show()

func _on_Timer_timeout():
	get_tree().change_scene("res://scenes/SuperMenu.tscn")
