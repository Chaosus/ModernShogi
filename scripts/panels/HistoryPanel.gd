extends "res://scripts/ui/FadeElement.gd"

const RIGHT_PANEL_OFFSET = 142

var history
var first_show = true
var update_required = false
var test = false
var _right_panel_offset = RIGHT_PANEL_OFFSET
var max_length = 10
var tmode = 1
var erase_mode = true
var _move_lock = false
var force_mode = false
var temp_autoscroll_disabled = false

var is_play_proc = false
var is_play_back_proc = false

const PIECE_BTN_SIZE = 80
const SHARP_SIZE = 80
const BTN_SIZE = 200
const SIZE_Y = 80
const SCROLLBAR_WIDTH = 30

const enable_chess = false
var _focused = false

onready var head = $VBox/VBoxControl/HBox
onready var head_shogi = $VBox/VBoxShogi/HBoxTableHeader
onready var vbox_shogi = $VBox/VBoxShogi/HistoryScrollContainer/VBox
onready var sbox_shogi = $VBox/VBoxShogi/HistoryScrollContainer
onready var head_chess = $VBox/VBoxChess/HBoxTableHeader
onready var vbox_chess = $VBox/VBoxChess/HistoryScrollContainer/VBox
onready var sbox_chess = $VBox/VBoxChess/HistoryScrollContainer
onready var revert_button = $VBox/VBoxControl/HBox/PlayReverseHistoryButton
var rb_group
var rb_group2

var vboxes = []
var sboxes = []

var mp_mode = false

enum NotationMode {
	JAPANESE,
	SHORT,
	FULL	
}

enum SymbolMode {
	JAPANESE,
	ENGLISH	
}

enum PanelMode {
	SHOGI,
	CHESS
}

var notation_mode = -1
var symbol_mode = -1
var panel_mode = -1
var ynum_mode = false


func set_element_count(value):
	max_length = value
	yield(get_tree(), "idle_frame")
	update_all_size()
	update_scroll()

func update_scroll():
	var ml = max_length
	sbox_shogi.scroll_vertical = ((history.get_current_index() - ml / 2) - 1.0) * 80
	sbox_chess.scroll_vertical = (((history.get_current_index() + 1) / 2 - ml / 2) - 1.0) * 80
	
func set_ynum_mode(mode):
	if ynum_mode != mode:
		ynum_mode = mode
		update_records_text()

var enable_history_autoscroll

func enable_playback_revert_button(toggled):
	$VBox/VBoxControl/HBox/PlayReverseHistoryButton.visible = toggled

func enable_autoscroll(value):
	enable_history_autoscroll = value

func is_autoscroll_enabled():
	return enable_history_autoscroll

func update_records_text():
	if history.get_count() == 0:
		return
	var btns = get_tree().get_nodes_in_group("hbtn0")
	var btns2 = get_tree().get_nodes_in_group("hbtn1")
	for idx in range(history.get_count()):
		var record = history.get_record_or_null(idx)
		var string = _get_record_str(record)
		btns[idx].text = string
		btns2[idx].text = string

func set_notation_mode(mode):
	if notation_mode != mode:
		notation_mode = mode
		update_records_text()
		
func set_symbol_mode(mode):
	if symbol_mode != mode:
		symbol_mode = mode
		update_records_text()

var draw_turn_symbol

func set_turn_symbol(toggled):
	if draw_turn_symbol != toggled:
		draw_turn_symbol = toggled
		update_records_text()

func set_panel_mode(mode):
	var count = 0
	if panel_mode != mode:		
		panel_mode = mode
		match mode:
			Games.HistoryMode.SHOGI:
				$VBox/VBoxShogi.show()
				$VBox/VBoxChess.hide()
				head.rect_min_size.x = 450 * rect_scale.x
				head.rect_size.x = 450 * rect_scale.x
				rect_min_size.x = 450 * rect_scale.x
				rect_size.x = 450 * rect_scale.x
			Games.HistoryMode.CHESS:
				$VBox/VBoxShogi.hide()
				$VBox/VBoxChess.show()
				head.rect_min_size.x = 700 * rect_scale.x
				head.rect_size.x = 700 * rect_scale.x
				rect_min_size.x = 700 * rect_scale.x
				rect_size.x = 700 * rect_scale.x
		
		update_position()
		yield(get_tree(), "idle_frame")
		update_all_size()
#		update_size(Games.HistoryMode.SHOGI)
#		update_size(Games.HistoryMode.CHESS)
		
#		UI.get_game().stop()
#		is_play_proc = false
#		update_play_btn()
		
func set_scale(value):
	var s = 1.0
	match value:
		0:
			s = 0.6
		1:
			s = 0.8
	
	rect_scale = Vector2(s, s)
	update_position()		

func update_panel_position(right_panel):
	if !right_panel:
		_right_panel_offset = 0
	else:
		_right_panel_offset = RIGHT_PANEL_OFFSET
	update_position()

func clear():
	history.clear()
	_move_lock = false
	is_play_proc = false
	update_play_btn()
	update_required = false
	for vbox in vboxes:
		for i in range(vbox.get_child_count()):
			vbox.get_child(i).queue_free()
	sbox_shogi.scroll_vertical = 0
	sbox_chess.scroll_vertical = 0
	update_size(panel_mode)
	rect_min_size.y = 124
	rect_size.y = rect_min_size.y

func get_record_count():
	return history.get_count()
	
func _ready():
	rb_group = ButtonGroup.new()
	rb_group2 = ButtonGroup.new()
	
	UI.add_theme_element(self)
	
	history = Games.History.new()
	
	vboxes.append(vbox_shogi)
	vboxes.append(vbox_chess)
	
	sboxes.append(sbox_shogi)
	sboxes.append(sbox_chess)
	
	set_panel_mode(0)
	set_symbol_mode(0)
	
	if test:
		test = false
		var side = 0
		for i in range(13 * 2):
			var record = Games.Record.new()
			record.side = side
			record.id = i
			side = wrapi(side + 1, 0, 2) 
			add_record(record, false)
			mark_history_index()
	
func apply_theme(theme):
	self.theme = theme
	sbox_shogi.theme = theme
	sbox_chess.theme = theme

#var requires_scroll_update = false

func add_record(record, increase_selection):
	
	record.previous_record = history.get_previous()
	
	_add_record(record, Games.HistoryMode.SHOGI)
	_add_record(record, Games.HistoryMode.CHESS)
	
	history.add_record(record, increase_selection)
	
	mark_history_index()
	
	update_size(panel_mode)
	if is_autoscroll_enabled():
		yield(get_tree(), "idle_frame")
		update_scroll()

func _get_record_str(record):
	return " " + (("▲" if record.side == 0 else "△") if draw_turn_symbol else "") + " " + record.get_full_string(notation_mode, ynum_mode, symbol_mode)
	
func _add_record(record, history_mode):
	
	var vbox = vboxes[history_mode]
	
	var button = Button.new()
	button.add_to_group("hbtn" + ("0" if history_mode == 0 else "1"))
	button.text = _get_record_str(record)
	button.flat = true
	button.toggle_mode = true
	button.group = rb_group if history_mode == 0 else rb_group2
	button.connect("pressed", self, "_on_record_pressed", [button, record])
	button.align = Button.ALIGN_LEFT
	button.size_flags_vertical = 0
	button.size_flags_horizontal = 0
	
	if history_mode == Games.HistoryMode.SHOGI:
		button.rect_min_size = Vector2(280, SIZE_Y)
	else:
		if history.get_count() % 2 == 0:
			button.rect_min_size = Vector2(310, SIZE_Y)
		else:
			button.rect_min_size = Vector2(280, SIZE_Y)
	
	button.rect_size = button.rect_min_size
	
	if history_mode == Games.HistoryMode.SHOGI:
		var vb = VBoxContainer.new()
		vb.add_constant_override("separation", 0)
		vb.size_flags_horizontal = SIZE_EXPAND_FILL
		var hbox = HBoxContainer.new()
		vb.add_child(hbox)
		hbox.add_constant_override("separation", 0)
		hbox.size_flags_horizontal = SIZE_EXPAND_FILL
		#hbox.rect_clip_content = true
		var label_n = Label.new()
		label_n.text = str(history.get_count() + 1)
		label_n.rect_min_size.x = SHARP_SIZE
		label_n.align = Label.ALIGN_CENTER
		label_n.valign = Label.ALIGN_CENTER
		hbox.add_child(label_n)
		var vseparator = VSeparator.new()
		hbox.add_child(vseparator)
		#hbox.add_child(piece_button)
		hbox.add_child(button)
		var hseparator = HSeparator.new()
		vb.add_child(hseparator)
		vbox.add_child(vb)
		record.mbox1 = hbox
		record.box1 = button
	elif history_mode == Games.HistoryMode.CHESS:
		
		if history.get_count() % 2 == 0:
			#button.rect_min_size.x += SCROLLBAR_WIDTH / 2 + 14
			var hbox = HBoxContainer.new()
			hbox.add_constant_override("separation", 0)
			hbox.size_flags_horizontal = SIZE_EXPAND_FILL
			#hbox.rect_min_size = Vector2(BTN_SIZE + PIECE_BTN_SIZE + 15, SIZE_Y)
			var label_n = Label.new()
			label_n.text = str((history.get_count() / 2) + 1)
			label_n.rect_min_size = Vector2(SHARP_SIZE, 0)
			label_n.align = Label.ALIGN_CENTER
			label_n.valign = Label.ALIGN_CENTER
			hbox.add_child(label_n)
			var vseparator = VSeparator.new()
			hbox.add_child(vseparator)
			hbox.add_child(button)
		
			var hseparator = HSeparator.new()
			record.mbox2 = hbox
			record.box2 = button
			vbox.add_child(hbox)
			vbox.add_child(hseparator)
		else:
			record.box2 = button
			record.mbox2 = null
			var last_record_box = history.get_last_record().mbox2
			var vseparator = VSeparator.new()
			last_record_box.add_child(vseparator)
			last_record_box.add_child(button)

func update_position():
	rect_position.x = UI.get_real_resolution().x - (rect_size.x * rect_scale.x) - (_right_panel_offset * UI.scale.x)
	rect_position.y = 128 * UI.scale.y
	

# Стирает последующую историю
func erase_next_moves():
	
	var count = history.clear_until_selected()
	
	if count == 0:
		return
	
	update_size(panel_mode)

func mark_history_index():
	
	if history.get_current_index() == 0:
		history.unmark_first()
		return
	history.mark_last()

func _on_record_pressed(button, record):
	
	if mp_mode:
		return
		
	if UI.get_game().nest_select_lock:
		return
	
	if history.current_index == record.id + 1:
		button.pressed = true
		return
	
	temp_autoscroll_disabled = true
	
	if record.id < history.current_index:
		UI.get_game().play(record.id + 1, true)
	else:
		UI.get_game().play(record.id + 1, true)

func history_forward(boost):
	if !force_mode:
		if mp_mode:
			return
	if history.is_max():
		return
	if _move_lock:
		return
	_move_lock = true
	UI.get_game().forward_move(history.next(), boost)
	mark_history_index()
	yield(UI.get_game(), "turn_changed")
	_move_lock = false
	if is_autoscroll_enabled() and !temp_autoscroll_disabled:
		yield(get_tree(), "idle_frame")
		update_scroll()

func history_back(boost, force = false):
	if !force:
		if mp_mode:
			return
	if history.is_min():
		return
	if _move_lock:
		return
	_move_lock = true
	UI.get_game().backward_move(history.previous(), boost)
	mark_history_index()
	yield(UI.get_game(), "turn_changed")
	_move_lock = false
	if is_autoscroll_enabled() and !temp_autoscroll_disabled:
		yield(get_tree(), "idle_frame")
		update_scroll()

var _bproc = false

func history_to_start():
	if _bproc:
		UI.get_game().stop()
		_bproc = false
	else:
		if history.is_min():
			return
		if _move_lock:
			return
		if is_play_proc:
			return
		UI.get_game().play(0, true)
		_bproc = true

func history_to_end():
	if _bproc:
		UI.get_game().stop()
		_bproc = false
	else:
		if history.is_max():
			return
		if _move_lock:
			return
		if is_play_proc:
			return
		UI.get_game().play(get_record_count(), true)
		_bproc = true

func history_to_end_forced():
	force_mode = true
	UI.get_game().play(get_record_count(), true)
	
func play():
	if history.is_max():
		return
	if !is_play_proc:
		UI.get_game().play(get_record_count(), false)
	else:
		UI.get_game().stop()
	_bproc = false
	is_play_proc = !is_play_proc
	is_play_back_proc = false
	update_play_btn()
	update_play_back_btn()

func play_back():
	if history.is_min():
		return
	if !is_play_back_proc:
		UI.get_game().play(0, false)
	else:
		UI.get_game().stop()
	_bproc = false
	is_play_proc = false
	is_play_back_proc = !is_play_back_proc
	update_play_btn()
	update_play_back_btn()
	
func update_play_btn():
	if is_play_proc:
		$VBox/VBoxControl/HBox/PlayHistoryButton.texture_normal = preload("res://ui/buttons/pause.png")
	else:
		$VBox/VBoxControl/HBox/PlayHistoryButton.texture_normal = preload("res://ui/buttons/play.png")

func update_play_back_btn():
	if is_play_back_proc:
		$VBox/VBoxControl/HBox/PlayReverseHistoryButton.texture_normal = preload("res://ui/buttons/pause.png")
	else:
		$VBox/VBoxControl/HBox/PlayReverseHistoryButton.texture_normal = preload("res://ui/buttons/play_reversed.png")

func has_focus():
	if visible:
		return Rect2(rect_position, rect_size * rect_scale).has_point(get_viewport().get_mouse_position())
	return false

func update_size(history_mode):
	var count
	var vbox
	var sbox
	if history_mode == Games.HistoryMode.SHOGI:
		count = (history.get_count())
	else:
		count = (history.get_count()) / 2
		
	vbox = vboxes[history_mode]
	sbox = sboxes[history_mode]
	
	var vy = clamp(count + 1, 0, max_length) * SIZE_Y
	
	rect_min_size.y = vy
	rect_size.y = vy
	sbox.rect_min_size.y = vy
	sbox.rect_size.y = vy

func update_all_size(): 
	update_size(Games.HistoryMode.SHOGI)
	update_size(Games.HistoryMode.CHESS)

# Обработчики кнопок

func _on_ToBeginningHistoryBtn_pressed():
	history_to_start()
	
func _on_BackHistoryBtn_pressed():
	history_back(false)

func _on_PlayReverseHistoryButton_pressed():
	play_back()
	
func _on_PlayHistoryButton_pressed():
	play()
	
func _on_ForwardHistoryBtn_pressed():
	history_forward(false)
	
func _on_ToEndHistoryBtn_pressed():
	history_to_end()

func _on_SettingsHistoryBtn_pressed():
	yield(beautiful_hide(), "fade_completed")
	UI.get_root().open_history_settings()

func _on_HideHistoryBtn_pressed():
	beautiful_hide()