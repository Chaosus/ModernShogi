extends "res://scripts/ui/FadeElement.gd"

#	MainLayout.gd

func _ready():
	UI.set_main_layout(self)
	UI.set_version($VersionLabel.text)