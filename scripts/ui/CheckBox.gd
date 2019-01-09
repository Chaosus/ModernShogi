extends CheckBox
 
# CheckBox.gd

func _ready():
	connect("pressed", self, "_on_toggled")

func _on_toggled():
	UI.sfx_player.play_cb(pressed)
	