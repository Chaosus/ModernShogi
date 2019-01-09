extends Button

func _ready():
	UI.add_theme_element(self)
	connect("pressed", self, "_on_pressed")
	focus_mode = Control.FOCUS_NONE
	
func _on_pressed():
	UI.sfx_player.play_big_btn()
	
func apply_theme(theme):
	add_stylebox_override("normal", theme.get_stylebox("big_normal", "Button"))
	add_stylebox_override("focus", theme.get_stylebox("big_focus", "Button"))
	add_font_override("font", theme.get_font("big_font", "Button"))