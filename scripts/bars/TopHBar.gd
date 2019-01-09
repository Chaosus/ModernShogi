extends "res://scripts/ui/FadeElement.gd"

# Name : TopHBar.gd

func _ready():
	UI.htopbar = self
	UI.add_theme_element(self)

func show_without_content():
	$HBox.hide()
	show()

func apply_theme(theme):
	self.theme = theme

func _on_ShowTopPanelButton_pressed():
	yield(beautiful_hide(), "fade_completed")
	get_node("../TopBar").beautiful_show()
	UI.topbar_was_visible = true
