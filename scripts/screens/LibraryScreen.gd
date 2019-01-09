extends "res://scripts/UIScreen.gd"

onready var tree = $HBox/FileTree

onready var file_name_control = $HBox/FileInfo/VBox/HBoxTitle/LABEL_FILE_NAME_INPUT

onready var replay_info = $HBox/FileInfo/VBox/ReplayInfo
onready var replay_date_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxDate/LABEL_REPLAY_DATE_INPUT
onready var replay_place_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxPlace/LABEL_REPLAY_PLACE_INPUT
onready var replay_time_min_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxTimeControl/LABEL_REPLAY_TIMECONTROL_MINUTES
onready var replay_time_byo_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxTimeControl/LABEL_REPLAY_TIMECONTROL_BYOYOMI
onready var replay_handicap_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxHandicap/LABEL_REPLAY_HANDICAP_INPUT
onready var replay_black_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxSenteName/LABEL_REPLAY_SENTE_NAME_INPUT
onready var replay_white_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxGoteName/LABEL_REPLAY_GOTE_NAME_INPUT
onready var replay_move_count_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxMoveCounter/LABEL_REPLAY_MOVECOUNT_INPUT
onready var replay_result_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxResult/LABEL_REPLAY_RESULT_INPUT
onready var replay_winner_control = $HBox/FileInfo/VBox/ReplayInfo/HBoxWinner/LABEL_REPLAY_WINNER_INPUT

onready var dir_info = $HBox/FileInfo/VBox/DirInfo
onready var dir_type_control = $HBox/FileInfo/VBox/DirInfo/LABEL_DIR_TYPE_INPUT
onready var dir_filecount_control = $HBox/FileInfo/VBox/DirInfo/HBoxFileCount/LABEL_DIR_FILECOUNT_INPUT
onready var dir_subdir_control = $HBox/FileInfo/VBox/DirInfo/HBoxSubDirCount/LABEL_DIR_SUBDIR_COUNT_INPUT
onready var dir_filecount_control2 = $HBox/FileInfo/VBox/DirInfo/HBoxAllFileCount/LABEL_DIR_FILECOUNT_INPUT2

var _play_was_visible = false
var _replay_selected = false
var _current_replay = null
var _current_replay_item = null
var _path = null

var selected_replay_name = null

func _on_LibraryDelete_pressed():
	var fdlg = get_node("../../../../DeleteFileDialog")
	fdlg.update_mode(0)
	fdlg.set_title("DESC_DELETE_FILE")
	if !fdlg.is_connected("yes_pressed", self, "delete_file"):
		fdlg.connect("yes_pressed", self, "delete_file")
	fdlg.beautiful_show()

func delete_file():
	if _replay_selected:
		var path = _current_replay.path + _current_replay.filename
		if Utility.delete_file(path):
			tree.remove_replay(path)
			replay_info.hide()
			file_name_control.text = ""
			hide_play_control()

func _on_LibraryExplorer_pressed():
	_path.erase(0, 6)
	var path = OS.get_user_data_dir() +  _path
	
	OS. shell_open("file://" + path)
	
func _on_LibraryPlayWidget_pressed():
	if _replay_selected:
		GameStarter.set_from_screen(self)
		GameStarter.start_replay(_current_replay)

func _ready():
	self.title = "TITLE_LIBRARY"

func beautiful_hide():
	tree.set_process_input(false)
	_play_was_visible = UI.get_widget(UI.WIDGET_LIBRARY_PLAY).visible
	hide_play_control()
	hide_explorer_control()
	return .beautiful_hide()

func beautiful_show():
	tree.set_process_input(true)
	set_previous_screen(UI.get_named_element(UI.SCREEN_MAIN_MENU))
	#tree.dclick = 0
	if _play_was_visible:
		show_play_control()
	return .beautiful_show()

func hide_play_control():
	UI.hide_library_play_btn()
	UI.hide_library_delete_btn()
	
func hide_explorer_control():
	UI.hide_library_explorer_btn()
	
func show_explorer_control():
	UI.show_library_explorer_btn()

func show_play_control():
	UI.show_library_play_btn()
	UI.show_library_delete_btn()
	
func load_folder(path, name, file_count, subdir_count, file_count2, is_root):
	_path = path
	file_name_control.text = name
	
	dir_type_control.text = "LABEL_DIR_TYPE_NORMAL" if !is_root else "LABEL_DIR_TYPE_ROOT"
	
	dir_filecount_control.text = str(file_count)
	dir_subdir_control.text = str(subdir_count)
	dir_filecount_control2.text = str(file_count2)
	
	replay_info.hide()
	dir_info.show()
	_replay_selected = false

func load_song(path, name):
	file_name_control.text = name
	replay_info.hide()
	dir_info.hide()
	_replay_selected = false

func load_profile(path, name):
	file_name_control.text = name
	replay_info.hide()
	dir_info.hide()
	_replay_selected = false

func load_replay(item, path, name):
	
	selected_replay_name = name
	file_name_control.text = name
	_path = item.get_meta("path")
	
	dir_info.hide()
	replay_info.show()
	
	var replay = ReplayParser.parse_replay(path, name)
			
	replay_date_control.text = replay.date
	replay_place_control.text = replay.place
	
	replay_time_min_control.text = str(replay.time_control.minutes)
	replay_time_byo_control.text = str(replay.time_control.byoyomi)
	
	replay_handicap_control.text = replay.handicap
	
	replay_black_control.text = replay.black_name
	replay_white_control.text = replay.white_name
	
	replay_move_count_control.text = str(replay.move_count)
	
	replay_result_control.text = Checks.get_game_result_str(replay.result)
	replay_winner_control.text = replay.winner
	
	_current_replay = replay
	_current_replay_item = item
	_replay_selected = true



