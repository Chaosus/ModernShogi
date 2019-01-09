extends "res://scripts/ui/BeautyElement.gd"

#	FloatElement.gd

# 	Этот наследник BeautyElement использует изменение позиции и альфа канал для скрытия
# 	и показа своего содержимого.

export(Vector2) var dir

var _start_position

var _end_position

var _position

func setup():
	.setup()
	if hidden_by_default:
		modulate.a = 0.0
	_start_position = Vector2(float(rect_position.x), float(rect_position.y))
		
	if hidden_by_default:
		_end_position = _start_position
		_start_position = _start_position + Vector2(dir.x * rect_size.x * UI.scale.x, dir.y * rect_size.y * UI.scale.y)
	else:
		_end_position = _start_position - Vector2(dir.x * rect_size.x * UI.scale.x, dir.y * rect_size.y * UI.scale.y)
				
	_position = rect_position

func update_x():
	var new_x = rect_position.x
	_start_position.x = new_x
	_position.x = new_x

func update_y():
	var new_y = rect_position.y
	_start_position.y = new_y
	_position.y = new_y

func update_end():
	_end_position = _start_position
	_start_position = _start_position + Vector2(dir.x * rect_size.x, dir.y * rect_size.y)
			
func beautiful_show():
	modulate.a = 0.0
	return .beautiful_show()
	
func _physics_process(delta):
	var step = fade_speed * delta
	match _state:
		ShowState.HIDE:
			var stepa = 4 * delta
			modulate.a = clamp(modulate.a - stepa, 0.0, 1.0)
			_position.x = _position.x - (dir.x * step)
			_position.y = _position.y - (dir.y * step)
			rect_position.x = int(floor(_position.x))
			rect_position.y = int(floor(_position.y))
			var t = false
			if dir.x < 0:
				if _position >= _end_position:
					t = true
			else:
				if _position <= _end_position:
					t = true
					
			if t:
				rect_position = _end_position
				_position = rect_position
			
			if modulate.a == 0.0 and t:
				_state = ShowState.HIDDEN
				if(hide_after_fade):
					hide()
				emit_signal("fade_completed")
				
		ShowState.SHOW:
			var stepa = 2 * delta
			modulate.a = clamp(modulate.a + stepa, 0.0, 1.0)
			_position.x = _position.x + (dir.x * step)
			_position.y = _position.y + (dir.y * step)
			rect_position.x = int(floor(_position.x))
			rect_position.y = int(floor(_position.y))
			var t = false
			if dir.x < 0:
				if _position <= _start_position:
					t = true
			else:
				if _position >= _start_position:
					t = true
					
			if t:
				rect_position = _start_position
				_position = rect_position
			
			if modulate.a == 1.0 and t:
					_state = ShowState.NONE
					emit_signal("fade_completed")
		