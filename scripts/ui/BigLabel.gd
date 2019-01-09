extends Label

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	add_font_override("font", theme.get_font("big_font", "Button"))
