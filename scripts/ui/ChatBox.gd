extends VBoxContainer

func _ready():
	rect_min_size.x = ProjectSettings.get_setting("display/window/size/width") - 800