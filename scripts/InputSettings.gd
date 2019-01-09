extends "res://scripts/ui/FadeElement.gd"

# InputSettings.gd

var button_list = {}

func _set_key_action(action, defkey, key, defkey2, key2):
	if !button_list.has(action):
		return false
	var element = button_list[action][0]
	var element2 = button_list[action][1]
	element.set_buttons_list(button_list)
	element2.set_buttons_list(button_list)
	
	element.set_index(0)
	element.set_alt(element2)
	element2.set_index(1)
	element2.set_alt(element)
	
	element.set_default_key(defkey)
	element.set_current_key(key)
	element.set_action(action)
	element2.set_default_key(defkey2)
	element2.set_current_key(key2)
	element2.set_action(action)
	return true
	
func _setup_list():
	UI.input_list = self
	
	var start = $KeyBox/KeyGrid/VBox2
	
	button_list["rotate_camera_left"] = [start.get_node("KeyCameraRotateLeft/HBox/KEY"), start.get_node("KeyCameraRotateLeft/HBox/KEY_ALT")]
	button_list["rotate_camera_right"] = [$KeyBox/KeyGrid/VBox2/VBoxCameraRotateRight/HBoxContainer/BTN_KEY_CAMERA_RIGHT, $KeyBox/KeyGrid/VBox2/VBoxCameraRotateRight/HBoxContainer/BTN_KEY_CAMERA_RIGHT_ALT]
	button_list["rotate_camera_up"] = [$KeyBox/KeyGrid/VBox2/VBoxCameraRotateUp/HBoxContainer/BTN_KEY_CAMERA_UP, $KeyBox/KeyGrid/VBox2/VBoxCameraRotateUp/HBoxContainer/BTN_KEY_CAMERA_UP_ALT]
	button_list["rotate_camera_down"] = [$KeyBox/KeyGrid/VBox2/VBoxCameraRotateDown/HBoxContainer/BTN_KEY_CAMERA_DOWN, $KeyBox/KeyGrid/VBox2/VBoxCameraRotateDown/HBoxContainer/BTN_KEY_CAMERA_DOWN_ALT]
	button_list["reset_camera"] = [$KeyBox/KeyGrid/VBox2/VBoxCameraReset/HBoxContainer/BTN_KEY_CAMERA_RESET, $KeyBox/KeyGrid/VBox2/VBoxCameraReset/HBoxContainer/BTN_KEY_CAMERA_RESET_ALT]
	button_list["flip_board"] = [$KeyBox/KeyGrid/VBox2/VBoxFlipBoard/HBoxContainer/BTN_KEY_FLIP_BOARD, $KeyBox/KeyGrid/VBox2/VBoxFlipBoard/HBoxContainer/BTN_KEY_FLIP_BOARD_ALT]
	button_list["show_history"] = [$KeyBox/KeyGrid/VBox2/VBoxHistory/HBoxContainer/BTN_KEY_HISTORY, $KeyBox/KeyGrid/VBox2/VBoxHistory/HBoxContainer/BTN_KEY_HISTORY_ALT]
	button_list["history_back"] = [$KeyBox/KeyGrid/VBox2/VBoxHistoryBack/HBoxContainer/BTN_KEY_HISTORY_BACK, $KeyBox/KeyGrid/VBox2/VBoxHistoryBack/HBoxContainer/BTN_KEY_HISTORY_BACK_ALT]
	button_list["history_forward"] = [$KeyBox/KeyGrid/VBox2/VBoxHistoryForward/HBoxContainer/BTN_KEY_HISTORY_FORWARD, $KeyBox/KeyGrid/VBox2/VBoxHistoryForward/HBoxContainer/BTN_KEY_HISTORY_FORWARD_ALT]
	button_list["history_play"] = [$KeyBox/KeyGrid/VBox2/VBoxHistoryPlay/HBoxContainer/BTN_KEY_HISTORY_PLAY, $KeyBox/KeyGrid/VBox2/VBoxHistoryPlay/HBoxContainer/BTN_KEY_HISTORY_PLAY_ALT]
	button_list["history_play_reversed"] = [start.get_node("KeyHistoryPlayReversed/HBox/KEY"), start.get_node("KeyHistoryPlayReversed/HBox/KEY_ALT")]
	button_list["history_to_start"] = [$KeyBox/KeyGrid/VBox2/VBoxHistoryToStart/HBoxContainer/BTN_KEY_HISTORY_TO_START, $KeyBox/KeyGrid/VBox2/VBoxHistoryToStart/HBoxContainer/BTN_KEY_HISTORY_TO_START_ALT]
	button_list["history_to_end"] = [$KeyBox/KeyGrid/VBox2/VBoxHistoryToEnd/HBoxContainer/BTN_KEY_HISTORY_TO_END, $KeyBox/KeyGrid/VBox2/VBoxHistoryToEnd/HBoxContainer/BTN_KEY_HISTORY_TO_END_ALT]
	button_list["toggle_hint_mode"] = [start.get_node("KeyHintMode/HBox/KEY"), start.get_node("KeyHintMode/HBox/KEY_ALT")]
	
func setup_actions():
	_set_key_action("rotate_camera_left", Settings.SV_KEY_CAMERA_ROTATE_LEFT_DEF, Settings.SV_KEY_CAMERA_ROTATE_LEFT, Settings.SV_KEY_CAMERA_ROTATE_LEFT2_DEF, Settings.SV_KEY_CAMERA_ROTATE_LEFT2) 
	_set_key_action("rotate_camera_right", Settings.SV_KEY_CAMERA_ROTATE_RIGHT_DEF, Settings.SV_KEY_CAMERA_ROTATE_RIGHT, Settings.SV_KEY_CAMERA_ROTATE_RIGHT2_DEF, Settings.SV_KEY_CAMERA_ROTATE_RIGHT2)
	_set_key_action("rotate_camera_up", Settings.SV_KEY_CAMERA_ROTATE_UP_DEF, Settings.SV_KEY_CAMERA_ROTATE_UP, Settings.SV_KEY_CAMERA_ROTATE_UP2_DEF, Settings.SV_KEY_CAMERA_ROTATE_UP2) 
	_set_key_action("rotate_camera_down", Settings.SV_KEY_CAMERA_ROTATE_DOWN_DEF, Settings.SV_KEY_CAMERA_ROTATE_DOWN, Settings.SV_KEY_CAMERA_ROTATE_DOWN2_DEF, Settings.SV_KEY_CAMERA_ROTATE_DOWN2)
	_set_key_action("reset_camera", Settings.SV_KEY_CAMERA_RESET_DEF, Settings.SV_KEY_CAMERA_RESET, Settings.SV_KEY_CAMERA_RESET2_DEF, Settings.SV_KEY_CAMERA_RESET2)
	_set_key_action("flip_board", Settings.SV_KEY_FLIP_BOARD_DEF, Settings.SV_KEY_FLIP_BOARD, Settings.SV_KEY_FLIP_BOARD2_DEF, Settings.SV_KEY_FLIP_BOARD2)
	_set_key_action("show_history", Settings.SV_KEY_SHOW_HISTORY_DEF, Settings.SV_KEY_SHOW_HISTORY, Settings.SV_KEY_SHOW_HISTORY2_DEF, Settings.SV_KEY_SHOW_HISTORY2)
	_set_key_action("history_back", Settings.SV_KEY_HISTORY_BACK_DEF, Settings.SV_KEY_HISTORY_BACK, Settings.SV_KEY_HISTORY_BACK2_DEF, Settings.SV_KEY_HISTORY_BACK2)
	_set_key_action("history_forward", Settings.SV_KEY_HISTORY_FORWARD_DEF, Settings.SV_KEY_HISTORY_FORWARD, Settings.SV_KEY_HISTORY_FORWARD2_DEF, Settings.SV_KEY_HISTORY_FORWARD2)
	_set_key_action("history_play", Settings.SV_KEY_HISTORY_PLAY_DEF, Settings.SV_KEY_HISTORY_PLAY, Settings.SV_KEY_HISTORY_PLAY2_DEF, Settings.SV_KEY_HISTORY_PLAY2)
	_set_key_action("history_play_reversed", Settings.SV_KEY_HISTORY_PLAY_REVERSED_DEF, Settings.SV_KEY_HISTORY_PLAY_REVERSED, Settings.SV_KEY_HISTORY_PLAY2_REVERSED_DEF, Settings.SV_KEY_HISTORY_PLAY2_REVERSED)
	_set_key_action("history_to_start", Settings.SV_KEY_HISTORY_TO_START_DEF, Settings.SV_KEY_HISTORY_TO_START, Settings.SV_KEY_HISTORY_TO_START2_DEF, Settings.SV_KEY_HISTORY_TO_START2)
	_set_key_action("history_to_end", Settings.SV_KEY_HISTORY_TO_END_DEF, Settings.SV_KEY_HISTORY_TO_END, Settings.SV_KEY_HISTORY_TO_END2_DEF, Settings.SV_KEY_HISTORY_TO_END2)
	_set_key_action("toggle_hint_mode", Settings.SV_KEY_TOGGLE_HINT_MODE_DEF, Settings.SV_KEY_TOGGLE_HINT_MODE, Settings.SV_KEY_TOGGLE_HINT_MODE2_DEF, Settings.SV_KEY_TOGGLE_HINT_MODE2)
	
func apply_actions():
	for action in button_list.values():
		action[0].apply()
		action[1].apply()
		
func _ready():
	_setup_list()

func _on_SaveButton_pressed():
	for action in button_list.values():
		action[0].save()
		action[1].save()
	
func _on_DefaultButton_pressed():
	for action in button_list.values():
		action[0].reset()
		action[1].reset()