extends "res://scripts/ui/FadeElement.gd"

var country_tag = 0

export(bool) var side = false

func _ready():
	UI.add_theme_element(self)

func apply_theme(theme):
	self.theme = theme
	$Panel.add_stylebox_override("panel", theme.get_stylebox("appbar", "PanelContainer"))
	$Panel/VBoxContainer/CountryBox/CountryIcon.tooltip = UI.get_country_name(country_tag)
	if side:
		$Panel/VBoxContainer/CountryBox/CountryIcon.tooltip_align = 2
	
func _on_HideButton_pressed():
	get_tree().call_group("player_panel", "beautiful_hide")
