extends VSeparator

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	add_stylebox_override("separator", theme.get_stylebox("widget_separator", "VSeparator"))
