extends CheckBox

# RadioBox.gd

var _play_sfx = true

func _ready():
	connect("pressed", self, "_on_pressed")
	
func _on_pressed():
	UI.sfx_player.play_rb()