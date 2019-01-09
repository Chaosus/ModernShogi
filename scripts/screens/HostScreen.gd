extends "res://scripts/UIScreen.gd"
class_name HostScreen 

# HostScreen.gd

func _ready():
	self.title = "TITLE_HOST"

func _on_CreateButton_pressed():
	UI.get_root().start_host(int($SimpleLayout/HBoxPort/SpinBox.value))
