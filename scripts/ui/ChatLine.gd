extends LineEdit

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	add_stylebox_override("normal", theme.get_stylebox("normal_chatline", "LineEdit"))
	add_stylebox_override("focus", theme.get_stylebox("focus_chatline", "LineEdit"))