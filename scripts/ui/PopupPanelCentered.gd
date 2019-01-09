extends "res://scripts/ui/FadeElement.gd"

# PopupPanelCentered.gd

var mode = 0
var self_destruct = false

var _update_position

func _ready():
	UI.add_theme_element(self)
	rect_scale = UI.scale
	hide()

func beautiful_show():
	_update_position = true
	return .beautiful_show()

func _physics_process(delta):
	if _update_position:
		update_position()
		_update_position = false

func update_position():
	rect_position.x = ((UI.get_real_resolution().x / 2.0) - (rect_size.x * UI.scale.x / 2.0))
	rect_position.y = (((UI.get_real_resolution().y + 128) / 2.0) - (rect_size.y * UI.scale.y / 2.0))

func apply_theme(theme):
	self.theme = theme

func destroy():
	if self_destruct:
		yield(beautiful_hide(), "hide_completed")
		queue_free()
	else:	
		beautiful_hide()