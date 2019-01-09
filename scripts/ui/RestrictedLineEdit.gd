extends LineEdit

signal change_completed(new_text)
signal invalid_input

export(bool) var restricted = true

export(String) var previous_valid_text = ""

var first_set = true

func _ready():
	connect("text_changed", self, "_on_text_changed")
	connect("focus_exited", self, "_on_check_errors")
	#connect("gui_input", self,  "_on_gui_input")
	expand_to_text_length = true
	
#func _on_gui_input(e):
#	if e is InputEventKey:
#		if e.pressed:
#			var s = OS.get_scancode_string(e.scancode)
#			if Checks.is_valid_nickname_symbol(s):
#			 	print(s)

func _on_text_changed(new_text):
	# игнорировать первую установку текста по умолчанию
	if first_set:
		first_set = false
		previous_valid_text = text
		return
	# мгновенно передавать изменение если ограничений нет
	if !restricted:
		emit_signal("change_completed", new_text)
		return

		
func _on_check_errors():
	if restricted:
		# обработка ошибок
		if text.empty() or text.length() < 3:
			text = previous_valid_text
		else:
			var invalid_pos = []
			var index = 0
			var errors_found
			for symbol in text:
				if Checks.is_valid_nickname_symbol(symbol):
					continue
				errors_found = true
				break
			if errors_found:
				text = previous_valid_text
			else:
				previous_valid_text = text
			emit_signal("change_completed", text)
		