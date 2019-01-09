extends Spatial

onready var camera = $Camera

func disable():
	set_process(false)
	set_process_input(false)
		
func make_current():
	set_process(true)
	set_process_input(true)
	camera.make_current()

func _ready():
	disable()