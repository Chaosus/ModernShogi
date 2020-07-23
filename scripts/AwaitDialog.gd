extends "res://scripts/dialogs/PopupBase.gd"

# AwaitDialog.gd

signal cancel
signal timeout

onready var desc_label = $VBoxContainer/HBoxDesc/Desc
onready var timer_label = $VBoxContainer/HBoxTimer/TimerLabel

var cancel_pressed = false
var timeout_happens = false

var current_time = 0

export(int) var max_time = 20

func _ready():
	timer_label.text = str(max_time)
	
func start():
	$Timer.start()

func set_title(text):
	$VBoxContainer/HBoxDesc/Desc.text = text

func _on_CancelButton_pressed():
	cancel_pressed = true
	if !timeout_happens:
		Network.stop_joining()
		emit_signal("cancel")
		destroy()

func _on_Timer_timeout():
	current_time += 1
	timer_label.text = str(max_time - current_time)
	if current_time >= max_time:
		timeout_happens = true
		Network.stop_joining()
		if !cancel_pressed:
			emit_signal("timeout")
		destroy()
	
