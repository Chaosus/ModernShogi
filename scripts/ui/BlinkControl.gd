extends Control

export(float) var blink_frequency = 3.0

export(bool) var blink_from_start = true

var blink = true

var incr = false

func _ready():
	UI.add_theme_element(self)
	blink = blink_from_start

func apply_theme(theme):
	self.theme = theme

func set_blink(blink):
	self.blink = blink
	modulate.a = 1.0

func _physics_process(delta):
	if blink:
		if incr:
			modulate.a += blink_frequency * delta
			if modulate.a >= 1.0:
				incr = false
		else:
			modulate.a -= blink_frequency * delta
			if modulate.a <= 0.0:
				incr = true