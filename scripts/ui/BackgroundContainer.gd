extends Control

func _ready():
	self_modulate.r = 0.88
	self_modulate.g = 0.88
	self_modulate.b = 0.88
	UI._background_containers.append(self)

func set_i(i):
	self_modulate.r = i
	self_modulate.g = i
	self_modulate.b = i