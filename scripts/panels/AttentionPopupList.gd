extends "res://scripts/ui/FloatElement.gd"
class_name AttentionPopupList

# AttentionPopupList.gd - Управляет списком предупреждений

onready var timer = $Timer
onready var attention_popup_preset = preload("res://scenes/AttentionPopup.tscn")

var _ss_state = false
var _list = []

# Очистка списка предупреждений
func clear_popups() -> void:
	for item in _list:
		item.queue_free()
	_list.clear()

# Показывает предупреждение
func show_popup(prefix : String, text : String) -> void:
	for item in _list:
		if item.text == text: # не нужно пересоздавать то что уже существует
			item.start() # вместо этого заново покажем это
			return
	var instance = attention_popup_preset.instance()
	_list.append(instance)
	add_child(instance)
	if prefix != "":
		instance.prefix = prefix
	instance.text = text
	instance.start()
	instance.apply_theme(UI.get_current_subtheme())

func _ready() -> void:
	dir = Vector2(0.0, 1.0)
	rect_scale = UI.scale

func stop() -> void:
	_ss_state = false

func start() -> void:
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

func _on_Timer_timeout() -> void:
	if get_show_state() != ShowState.NONE:
		return
	
	beautiful_hide()
	_ss_state = false
	
	for item in _list:
		if item.get_show_state() == ShowState.NONE:
			item.beautiful_hide()
					