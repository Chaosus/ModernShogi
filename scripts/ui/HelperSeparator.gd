extends HSeparator

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	add_stylebox_override("separator", theme.get_stylebox("helper_separator", "HSeparator"))