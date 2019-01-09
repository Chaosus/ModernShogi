extends "res://scripts/ui/FadeElement.gd"

#	MainContainer.gd

func _ready():
	rect_min_size.x = ProjectSettings.get_setting("display/window/size/width")
	UI.set_main_container(self)
