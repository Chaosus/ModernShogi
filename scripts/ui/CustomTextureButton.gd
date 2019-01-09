extends TextureButton

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	
func _on_mouse_entered():
	modulate.a = 0.5
	
func _on_mouse_exited():
	modulate.a = 1.0