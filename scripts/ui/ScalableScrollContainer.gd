extends ScrollContainer

# ScalableScrollContainer.gd

export(bool) var full_scale = false

export(int) var sub_offset_x = 0
export(int) var sub_offset_y = 0

var resolution = Vector2(0, 0)

func _ready():
	resolution = UI.get_resolution()
	_on_update()
	connect("visibility_changed", self, "_on_update")
	UI.add_theme_element(self)
	
func apply_theme(theme):
	self.theme = theme
	
func _on_update():
	var tx = resolution.x
	var ty = resolution.y - 128
	if full_scale:
		rect_min_size.x = tx
		rect_min_size.y = ty
	else:
		rect_min_size.x = tx - sub_offset_x
		rect_min_size.y = ty - sub_offset_y
	rect_size = rect_min_size