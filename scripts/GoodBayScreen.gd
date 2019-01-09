extends "res://scripts/UIScreen.gd"

func _input(event):
	if visible:
		if event is InputEventKey or event is InputEventMouseButton:
			if event.pressed:
				$QuitTimer.stop()
				begin_goodbye_screen_hide()
				
func begin_goodbye_screen_hide():
	yield(beautiful_hide(), "fade_completed")
	UI.get_root().quit()
	
func _on_QuitTimer_timeout():
	begin_goodbye_screen_hide()

func _on_GoodbayScreen_visibility_changed():	
	if visible:
		$QuitTimer.start()
