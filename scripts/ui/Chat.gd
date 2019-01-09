extends RichTextLabel

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	self.theme = theme