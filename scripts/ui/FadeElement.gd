extends "res://scripts/ui/BeautyElement.gd"
class_name FadeElement

# FadeElement.gd

# Этот наследник BeautyElement использует альфа канал 
# для скрытия и показа своего содержимого.

# Начальная установка
func setup():
	.setup()
	if hidden_by_default:
		modulate.a = 0.0

func immediate_show():
	modulate.a = 1.0
	return .beautiful_show()
		
# Показывает элемент, возвращает самого себя.
func beautiful_show():
	modulate.a = 0.0
	return .beautiful_show()

func _physics_process(delta):
	var step = fade_speed * delta
	match _state:
		ShowState.HIDE:
			modulate.a = clamp(modulate.a - step, 0.0, 1.0)
			if modulate.a == 0.0:
				_state = ShowState.HIDDEN
				if(hide_after_fade):
					hide()
				emit_signal("fade_completed")
				emit_signal("hide_completed")
		ShowState.SHOW:
			modulate.a = clamp(modulate.a + step, 0.0, 1.0)
			if modulate.a == 1.0:
				_state = ShowState.NONE
				emit_signal("fade_completed")
				emit_signal("show_completed")