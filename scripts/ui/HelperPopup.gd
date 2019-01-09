extends PopupPanel

var cbox
var label

func _ready():
	cbox = $CBox
	label = $CBox/Label
	label.connect("minimum_size_changed", self, "update_tooltip")
	UI.set_helper(self)
	UI.add_theme_element(self)
	UI.add_unnamed_small_element(label)
	rect_scale = UI.scale

func apply_theme(theme):
	self.theme = theme

func show():
	if Profiles.get_value(Settings.SV_UI_TIPS_BUTTON_ENABLED):
		.show()

func update_tooltip():
	rect_size = label.rect_size + Vector2(20,20)
	cbox.rect_size = rect_size

func show_cursor_tooltip(text, offset):
	hide_tooltip()
	label.text = text
	rect_position = get_viewport().get_mouse_position() + offset - Vector2(rect_size.x / 2, 0)
	show()

func show_tooltip(text, control):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(-control.rect_size.x / 2.0, control.rect_size.y)
	show()
	
func show_tooltip_unaligned(text, control):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(0, control.rect_size.y * UI.scale.y)
	
func show_tooltip_left(text, control):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(0, control.rect_size.y  * UI.scale.y)
	show()

func show_tooltip_centered(text, control):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(-rect_size.x / 2 * UI.scale.x + control.rect_size.x / 2 * UI.scale.x, control.rect_size.y * UI.scale.y)
	show()
	
func show_tooltip_right(text, control):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(-rect_size.x * UI.scale.x + control.rect_size.x * UI.scale.x, control.rect_size.y * UI.scale.y)
	show()
	
func show_tooltip_left_top(text, control):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(0, -rect_size.y)
	show()	

func show_tooltip_right_top(text, control):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(-rect_size.x + control.rect_size.x, -rect_size.y)
	show()

func show_tooltip_offset(text, control, offset):
	hide_tooltip()
	label.text = text
	rect_position = control.rect_global_position + Vector2(-control.rect_size.x / 2.0, control.rect_size.y) + offset
	show()

func hide_tooltip():
	hide()
	label.rect_size = Vector2(0.0, 0.0)
	label.text = ""