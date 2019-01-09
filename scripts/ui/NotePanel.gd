extends PanelContainer

onready var label = $Label

var show_proc = false
var hide_proc = false
var hidden = true
var showed = false

func _ready():
	visible = false

func start_show_or_hide(text):
	if show_proc:
		return
	if hide_proc:
		return
	if hidden:
		start_show(text)
	elif showed:
		start_hide()

func start_show(text):
	label.text = text
	show_proc = true
	visible = true
	
func start_hide():
	yield(label.beautiful_hide(), "fade_completed")
	hide_proc = true

func _physics_process(delta):
	if show_proc:
		rect_position.y += 1 * delta
		if rect_position.y >= 256:
			rect_position.y = 256
			yield(label.beautiful_show(), "fade_completed")
			show_proc = false
			showed = true
	if hide_proc:
		rect_position.y -= 1 * delta
		if rect_position.y == 0:
			rect_position.y = 0
			hide_proc = false		
			visible = false