extends "res://scripts/ui/FloatElement.gd"

onready var timer = $Timer
onready var attention_preset = preload("res://scenes/GameInfoPanel.tscn")

var _ss_state = false

var _list = []

func create_simple_popup(text : String) -> void:
	var instance = attention_preset.instance()
	_list.append(instance)
	
func _ready():
	dir = Vector2(0.0, 1.0)
	rect_scale = UI.scale

func start():
	if _ss_state:
		#beautiful_hide()
		timer.start()
		return
	
	_ss_state = true
	var res = UI.get_resolution()
	rect_size.x = res.x
	#rect_min_size = Vector2(res.x, res.y/2)
	rect_position.x = 0
	rect_position.y = -res.y/3
	update_x()
	update_y()
	update_end()
	yield(beautiful_show(), "fade_completed")
	timer.start()
	
func _on_Timer_timeout():
	if get_show_state() != ShowState.NONE:
		return
	
	beautiful_hide()
	_ss_state = false

	var children = get_children()
	for item in children:
		if item is CenterContainer:
			var children2 = item.get_children()
			for item2 in children2:
				if item2 is InfoPanel:
					if item2.get_show_state() == ShowState.NONE:
						item2.beautiful_hide()