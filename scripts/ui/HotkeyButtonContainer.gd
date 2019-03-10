extends HBoxContainer

# HotkeyButtonContainer.gd

onready var lock_icon = $LockIcon

onready var joy_icon = $JoyIcon

onready var hbtn = $Button

export(bool) var locked = false setget set_locked, get_locked

func set_locked(locked):
	call_deferred("_set_locked", locked)
	
func _set_locked(locked):
	hbtn.locked = locked
	lock_icon.set_visible(locked)

func get_locked():
	return lock_icon.get_visible()

func get_button():
	return hbtn
