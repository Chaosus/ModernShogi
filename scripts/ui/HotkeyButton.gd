extends Button

var _index = 0
var _action = null
var _defkey
var _defscancode
var _sv_id
var _sv_def_id
var _key = "?"
var _scancode = 0
var _listen = false
var _altbtn
var _blink_red
var _bval
var _buttons_list

func set_buttons_list(list):
	_buttons_list = list

func set_index(idx):
	_index = idx

func get_index():
	return _index

func get_scancode():
	return _scancode

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 2:
				reset()
				_on_unfocused()
				pressed = false
			if event.button_index == 3:
				delete()
				pressed = false

func set_default_key(key):
	_sv_def_id = key
	key = Profiles.get_value(key)
	_defkey = key
	_defscancode = OS.find_scancode_from_string(key)
	
func save():
	var key = _key
	if key == "?":
		key = ""
	Profiles.set_value(_sv_def_id, key)
	set_default_key(_sv_def_id)
		
func set_current_key(key):
	if key == 0:
		text = "?"
	else:
		_sv_id = key
		key = Profiles.get_value(_sv_id)
		if key == null or key == "" or _altbtn.text == key:
			key = "?"
			_scancode = 0
			return
		text = key
		_key = key
		_scancode = OS.find_scancode_from_string(key)
			
func apply():	
	if _scancode == 0:
		return
	if _altbtn.get_scancode() == _scancode:
		if _altbtn.get_index() > 0:
			_altbtn.text = "?"
			return
			
	var ie = InputEventKey.new()
	ie.scancode = _scancode
	InputMap.action_add_event(_action, ie)

func set_action(action):
	_action = action

func set_alt(button):
	_altbtn = button

func _ready():
	connect("pressed", self, "_on_pressed")
	connect("focus_exited", self, "_on_unfocused")
	connect("gui_input", self, "_gui_input")
	toggle_mode = true
	focus_mode = Control.FOCUS_CLICK
	UI.add_unnamed_medium_element(self)

func _on_pressed():
	if _listen:
		_on_unfocused()
	else:
		UI.key_enter_mode = true
		text = "[" + _key + "]"
		_listen =  true

func _on_unfocused():
	pressed = false
	UI.key_enter_mode = false
	text = _key
	_listen = false

func enable_input():
	UI.key_enter_mode = false
	
func _update_input_map(new_scancode):
	if _action != null and InputMap.has_action(_action):
		if new_scancode != _scancode or new_scancode == 0:
			if _scancode != 0:
				var ie = InputEventKey.new()
				ie.scancode = _scancode
				InputMap.action_erase_event(_action, ie)
		
			if new_scancode != 0:
				var ie2 = InputEventKey.new()
				ie2.scancode = new_scancode
				InputMap.action_add_event(_action, ie2)
				Profiles.set_value(_sv_id, text)
			else:
				if _scancode != 0:
					Profiles.set_value(_sv_id, "")

func reset():
	for group in _buttons_list.values():
		var btn0 = group[0]
		var btn1 = group[1]
		if btn0.get_scancode() != 0 and btn0.get_scancode() == _defscancode:
			btn0.delete()
		if btn1.get_scancode() != 0 and btn1.get_scancode() == _defscancode:
			btn1.delete()
		
	text = "?" if _defkey == "" else _defkey
	_key = text
	_update_input_map(_defscancode)
	_scancode = _defscancode

func delete():
	text = "?"
	_key = "?"
	_update_input_map(0)
	_scancode = 0

func _input(event):
	if _listen:
		if event is InputEventKey:
			if !event.pressed:
				if event.scancode == KEY_ESCAPE:
					pass
				elif event.scancode == KEY_QUESTION:
					pass
				elif event.scancode == KEY_BACKSPACE: # Сброс на пустое значение
					UI.key_enter_mode = false
					delete()
					_listen = false
				else:
					UI.key_enter_mode = false
					var tscancode = event.get_scancode_with_modifiers()
					var fail = false
					
					var ttext = OS.get_scancode_string(tscancode)
					for btn in _buttons_list.values():
						var tbtn = btn[0]
						var tbtn2 = btn[1]
						if tbtn != self:
							if tbtn.get_scancode() == tscancode:
								tbtn.blink()
								fail = true
						if tbtn2 != self:
							if tbtn2.get_scancode() == tscancode:
								tbtn2.blink()
								fail = true
					if !fail:
						text = ttext
						_update_input_map(tscancode)
						_scancode = tscancode
						_key = ttext
						_listen = false
						pressed = false
	
func blink():
	_blink_red = true
	self_modulate.r = 1.0
	self_modulate.g = 0.0
	self_modulate.b = 0.0
	_bval = 0.0

func _physics_process(delta):
	if _blink_red:
		self_modulate.g = _bval
		self_modulate.b = _bval
		_bval = clamp(_bval + 1 * delta, 0.0, 1.0)
		if _bval >= 1.0:
			_blink_red = false
