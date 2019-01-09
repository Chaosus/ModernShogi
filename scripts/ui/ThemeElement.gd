extends RichTextLabel

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	self.theme = theme
	#self.normal_font = theme.get_font("small_font", "Main")
	#self.bold_font = theme.get_font("small_font", "Main")