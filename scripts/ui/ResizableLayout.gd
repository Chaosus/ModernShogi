extends VBoxContainer

func _ready():
	var rx = ProjectSettings.get_setting("display/window/size/width") 
	rect_min_size.x = rx - 10
