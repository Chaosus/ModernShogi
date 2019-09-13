extends Node

# Profiles.gd

const CURRENT_VERSION = 1205

class ProfileSettings:
	
	var settings = {}
	var default_settings = {}
	
	func append_settings(name, value):
		default_settings[name] = value
		settings[name] = value
	
	func fill():
		# UI
		
		append_settings(Settings.SV_UI_LANGUAGE, Settings.Language.ENGLISH)
		append_settings(Settings.SV_UI_THEME, UI.UI_THEME_DEFAULT)
		append_settings(Settings.SV_UI_ASPECT, 0)
		append_settings(Settings.SV_UI_FONT, 0)
		append_settings(Settings.SV_UI_FONT_OUTLINE_ENABLED, 0)
		append_settings(Settings.SV_UI_TIPS_BUTTON_ENABLED, true)
		append_settings(Settings.SV_UI_PANEL_TRANSPARENCY, 128)
		
		# Gameplay
		
		append_settings(Settings.SV_GAME_AUTOMOVE_ENABLED, true)
		append_settings(Settings.SV_GAME_AUTOPROMOTION_ENABLED, true)
		append_settings(Settings.SV_GAME_LASTMOVE_ENABLED, true)
		append_settings(Settings.SV_GAME_CASTLES_ENABLED, true)
		append_settings(Settings.SV_GAME_AUTOSHOW, Settings.HighlightOptions.ALL)
		append_settings(Settings.SV_GAME_ANIM_SPEED, 2)
		append_settings(Settings.SV_GAME_ANIM_LIFTUP_ENABLED, true)
		append_settings(Settings.SV_GAME_ANIM_DROP_ENABLED, true)
		append_settings(Settings.SV_GAME_ANIM_TAKE_ENABLED, true)
		
		# History
		
		append_settings(Settings.SV_HISTORY_AUTOSHOW_ENABLED, true)
		append_settings(Settings.SV_HISTORY_AUTOSCROLL_ENABLED, true)
		append_settings(Settings.SV_HISTORY_PANEL_SIZE, 2)
		append_settings(Settings.SV_HISTORY_ELEMENT_COUNT, 8)
		append_settings(Settings.SV_HISTORY_PANEL_STYLE, 0)
		append_settings(Settings.SV_HISTORY_PLAYBACK_REVERT, true)
		append_settings(Settings.SV_HISTORY_PLAYBACK_IS_FIXED, false)
		append_settings(Settings.SV_HISTORY_PLAYBACK_FIXED_DURATION, 0)
		append_settings(Settings.SV_HISTORY_NOTATION_STYLE, 2)
		append_settings(Settings.SV_HISTORY_NOTATION_USE_Y_NUMBER, false)
		append_settings(Settings.SV_HISTORY_DRAW_TURN_SYMBOL, true)
		append_settings(Settings.SV_HISTORY_SYMBOLS, 1)
		
		# Camera
		
		append_settings(Settings.SV_CAMERA_YAW_ENABLED, true)
		append_settings(Settings.SV_CAMERA_PITCH_ENABLED, true)
		append_settings(Settings.SV_CAMERA_ZOOM_ENABLED, true)
		append_settings(Settings.SV_CAMERA_PAN_ENABLED, false)
		append_settings(Settings.SV_CAMERA_SWITCH_ENABLED, false)
		append_settings(Settings.SV_CAMERA_RESTRICT_YAW, true)
		append_settings(Settings.SV_CAMERA_SMOOTH_ENABLED, true)
		append_settings(Settings.SV_CAMERA_SMOOTH_SPEED, 1.0)
		
		# Styles
		
		append_settings(Settings.SV_STYLES_BOARD_MARKUP_ENABLED, true)
		append_settings(Settings.SV_STYLES_BOARD_COLORING_UI_ENABLED, false)
		append_settings(Settings.SV_STYLES_BOARD_COLORING_CHESS_ENABLED, false)
		append_settings(Settings.SV_STYLES_BOARD_COLORING_ZONES_ENABLED, false)
		append_settings(Settings.SV_STYLES_GRID_COLOR,Settings.WebColor.BLACK)
		append_settings(Settings.SV_STYLES_GRID_THICKNESS, UI.Thickness.TS_STANDART)
		append_settings(Settings.SV_STYLES_PIECE_THEME, 2)
		
		# SFX
		
		append_settings(Settings.SV_SFX_UI_ENABLED, true)
		append_settings(Settings.SV_SFX_UI_VOLUME, 100)
		append_settings(Settings.SV_SFX_MOVE_ENABLED, true)
		append_settings(Settings.SV_SFX_MOVE_VOLUME, 100)
		append_settings(Settings.SV_SFX_3D_ENABLED, true)
		append_settings(Settings.SV_SFX_SPEECH_ENABLED, false) 
		append_settings(Settings.SV_SFX_SPEECH_VOLUME, 100) 
		append_settings(Settings.SV_SFX_CHECK_ENABLED, false) 
		append_settings(Settings.SV_SFX_MUSIC_ENABLED, false) 
		append_settings(Settings.SV_SFX_MUSIC_VOLUME, 100)
		append_settings(Settings.SV_SFX_MUSIC_ORDER, 0)
		
		# Widgets
		
		append_settings(Settings.SV_WIDGET_SANSARA_ENABLED, true)
		append_settings(Settings.SV_WIDGET_SANSARA_ORDER, 0)
		append_settings(Settings.SV_WIDGET_CLOCK_ENABLED, true)
		append_settings(Settings.SV_WIDGET_CLOCK_SECONDS_ENABLED, false)
		append_settings(Settings.SV_WIDGET_CLOCK_ZEROES_ENABLED, false)
		append_settings(Settings.SV_WIDGET_CLOCK_FORMAT, 0)
		append_settings(Settings.SV_WIDGET_QQ_ENABLED, false)
		append_settings(Settings.SV_WIDGET_QQ_DIALOG_ENABLED, true)
		
		# IP Config
		
		append_settings(Settings.SV_IPV4_1, 127)
		append_settings(Settings.SV_IPV4_2, 0)
		append_settings(Settings.SV_IPV4_3, 0)
		append_settings(Settings.SV_IPV4_4, 1)
		append_settings(Settings.SV_IPV6, "::1")
		append_settings(Settings.SV_JOIN_PORT, 55669)
		
		append_settings(Settings.SV_MASTER_USE_IPV6, false) 
		append_settings(Settings.SV_MASTER_IPV4_1, 176)
		append_settings(Settings.SV_MASTER_IPV4_2, 113)
		append_settings(Settings.SV_MASTER_IPV4_3, 83)
		append_settings(Settings.SV_MASTER_IPV4_4, 33)
		append_settings(Settings.SV_MASTER_IPV6, "::1")
		append_settings(Settings.SV_MASTER_PORT, 9009)
		append_settings(Settings.SV_LOOPBACK_MODE, false)
		
		# AI
		
		append_settings(Settings.SV_AI_ENGINE_FOLDER, "YaneuraOu")
		append_settings(Settings.SV_AI_ENGINE_EXE, "YaneuraOu2018KPPT_nosse.exe")
		append_settings(Settings.SV_AI_ENGINE_SKILL_LEVEL, 0)
		append_settings(Settings.SV_AI_ENGINE_ENABLE_LOG, false)

		# Profile
		
		append_settings(Settings.SV_MP_PASSWORD, "")
		append_settings(Settings.SV_MP_SAVE_PASSWORD, false)
		append_settings(Settings.SV_MP_SIGNED, false)
		
		# Keys
		
		append_key(Settings.SV_KEY_UI_UP_DEF, "Up", Settings.SV_KEY_UI_UP2_DEF, "", Settings.SV_KEY_UI_UP, Settings.SV_KEY_UI_UP2)
		append_key(Settings.SV_KEY_UI_DOWN_DEF, "Down", Settings.SV_KEY_UI_DOWN2_DEF, "", Settings.SV_KEY_UI_DOWN, Settings.SV_KEY_UI_DOWN2)
		append_key(Settings.SV_KEY_UI_LEFT_DEF, "Left", Settings.SV_KEY_UI_LEFT2_DEF, "", Settings.SV_KEY_UI_LEFT, Settings.SV_KEY_UI_LEFT2)
		append_key(Settings.SV_KEY_UI_RIGHT_DEF, "Right", Settings.SV_KEY_UI_RIGHT2_DEF, "", Settings.SV_KEY_UI_RIGHT, Settings.SV_KEY_UI_RIGHT2)
		append_key(Settings.SV_KEY_UI_ACTION_DEF, "Enter", Settings.SV_KEY_UI_ACTION2_DEF, "", Settings.SV_KEY_UI_ACTION, Settings.SV_KEY_UI_ACTION2)
		
		append_key(Settings.SV_KEY_CAMERA_ROTATE_LEFT_DEF, "A", Settings.SV_KEY_CAMERA_ROTATE_LEFT2_DEF, "", Settings.SV_KEY_CAMERA_ROTATE_LEFT, Settings.SV_KEY_CAMERA_ROTATE_LEFT2)
		append_key(Settings.SV_KEY_CAMERA_ROTATE_RIGHT_DEF, "D", Settings.SV_KEY_CAMERA_ROTATE_RIGHT2_DEF, "", Settings.SV_KEY_CAMERA_ROTATE_RIGHT, Settings.SV_KEY_CAMERA_ROTATE_RIGHT2)
		append_key(Settings.SV_KEY_CAMERA_ROTATE_UP_DEF, "W", Settings.SV_KEY_CAMERA_ROTATE_UP2_DEF, "", Settings.SV_KEY_CAMERA_ROTATE_UP, Settings.SV_KEY_CAMERA_ROTATE_UP2)
		append_key(Settings.SV_KEY_CAMERA_ROTATE_DOWN_DEF, "S", Settings.SV_KEY_CAMERA_ROTATE_DOWN2_DEF, "", Settings.SV_KEY_CAMERA_ROTATE_DOWN, Settings.SV_KEY_CAMERA_ROTATE_DOWN2)
		append_key(Settings.SV_KEY_CAMERA_RESET_DEF, "Space", Settings.SV_KEY_CAMERA_RESET2_DEF, "", Settings.SV_KEY_CAMERA_RESET, Settings.SV_KEY_CAMERA_RESET2)
		append_key(Settings.SV_KEY_FLIP_BOARD_DEF, "F", Settings.SV_KEY_FLIP_BOARD2_DEF, "", Settings.SV_KEY_FLIP_BOARD, Settings.SV_KEY_FLIP_BOARD2)
		
		append_key(Settings.SV_KEY_SHOW_HISTORY_DEF, "H", Settings.SV_KEY_SHOW_HISTORY2_DEF, "", Settings.SV_KEY_SHOW_HISTORY, Settings.SV_KEY_SHOW_HISTORY2)
		append_key(Settings.SV_KEY_HISTORY_BACK_DEF, "Z", Settings.SV_KEY_HISTORY_BACK2_DEF, "", Settings.SV_KEY_HISTORY_BACK, Settings.SV_KEY_HISTORY_BACK2)
		append_key(Settings.SV_KEY_HISTORY_FORWARD_DEF, "C", Settings.SV_KEY_HISTORY_FORWARD2_DEF, "", Settings.SV_KEY_HISTORY_FORWARD, Settings.SV_KEY_HISTORY_FORWARD2)
		append_key(Settings.SV_KEY_HISTORY_PLAY_REVERSED_DEF, "", Settings.SV_KEY_HISTORY_PLAY2_REVERSED_DEF, "", Settings.SV_KEY_HISTORY_PLAY_REVERSED, Settings.SV_KEY_HISTORY_PLAY2_REVERSED)
		append_key(Settings.SV_KEY_HISTORY_PLAY_DEF, "X", Settings.SV_KEY_HISTORY_PLAY2_DEF, "", Settings.SV_KEY_HISTORY_PLAY, Settings.SV_KEY_HISTORY_PLAY2)
		append_key(Settings.SV_KEY_HISTORY_TO_START_DEF, "", Settings.SV_KEY_HISTORY_TO_START2_DEF, "", Settings.SV_KEY_HISTORY_TO_START, Settings.SV_KEY_HISTORY_TO_START2)
		append_key(Settings.SV_KEY_HISTORY_TO_END_DEF, "", Settings.SV_KEY_HISTORY_TO_END2_DEF, "", Settings.SV_KEY_HISTORY_TO_END, Settings.SV_KEY_HISTORY_TO_END2)
		append_key(Settings.SV_KEY_TOGGLE_HINT_MODE_DEF, "R", Settings.SV_KEY_TOGGLE_HINT_MODE2_DEF, "", Settings.SV_KEY_TOGGLE_HINT_MODE, Settings.SV_KEY_TOGGLE_HINT_MODE2)
		
		
	
	func _init():
		fill()
		
	func append_key(defkey, defval, defkey2, defval2, val, val2):
		append_settings(defkey, defval)
		append_settings(defkey2, defval2)
		append_settings(val, defval)
		append_settings(val2, defval2)
		
	func styles_grid_thickness_val():
		match get_value(Settings.SV_STYLES_GRID_THICKNESS):
			UI.Thickness.TS_VERY_THIN:
				return 0.01
			UI.Thickness.TS_THIN:
				return 0.02
			UI.Thickness.TS_STANDART:
				return 0.03
			UI.Thickness.TS_SEMIBOLD:
				return 0.04
			UI.Thickness.TS_BOLD:
				return 0.05
		return 0
	
	# Применяет настройки
	func apply():
		UI.apply_language(get_value(Settings.SV_UI_LANGUAGE))
		UI.set_theme(get_value(Settings.SV_UI_THEME), get_value(Settings.SV_UI_ASPECT))
		
		if get_value(Settings.SV_SFX_MUSIC_ENABLED):
			UI.music_player.play()
		else:
			UI.music_player.pause()
		UI.get_game().update_style_settings()
	
	func add_value(value):
		settings.append(value)
	
	func set_value(index, value):
		settings[index] = value
		
	func get_value(index):
		if index >= Settings.SV_LIMITER:
			return 0
		var value = settings[index]
		if value == null:
			return default_settings[index]
		return value
	
	func save(file):
		for idx in range(Settings.SV_LIMITER):
			file.store_var(settings[idx])
	
	func read(file):
		for idx in range(Settings.SV_LIMITER):
			set_value(idx, file.get_var())
		
#########################################################
#													Профиль
#########################################################

# Пол игрока
enum Gender {
	GENDER_UNKNOWN,
	GENDER_MALE,
	GENDER_FEMALE
}

class Profile:
	var temp = true
	var filename = "current.profile"
	var nickname = "Player"
	var password = ""
	var save_password = ""
	var country = Globals.Countries.UNKNOWN
	var settings
	func _init():
		settings = ProfileSettings.new()
	func apply():
		settings.apply()

static func read_profile(filename):
	var file = File.new()
	if file.open("user://%s" % filename, File.READ) != OK:
		return null
	
	var version = file.get_32()
	if version != CURRENT_VERSION:
		file.close()
		return null
		
	var profile = Profile.new()
	profile.temp = false
	profile.filename = filename
	profile.nickname = file.get_line()
	profile.country = file.get_16()
	profile.settings.read(file)
	file.close()
	return profile
	
static func save_profile(profile):
	#if profile.temp:
	#	return
	
	var file = File.new()
	if file.open("user://%s" % profile.filename, File.WRITE) != OK:
		return false
		
	# Profile Version
	file.store_32(CURRENT_VERSION)
	
	file.store_line(profile.nickname)
	file.store_16(profile.country)
	profile.settings.save(file)
	file.close()
	return true

static func remove_profile(nickname):
	var dir = Directory.new()
	var path = "user://" + nickname + ".profile"
	if dir.file_exist(path):
		if dir.remove(path) == OK:
			print("Removing success")
		else:
			print("Removing cancelled. File is busy")

func get_profile_list():
	var dir = Directory.new()
	var list = []
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir():
				if file_name.ends_with(".profile"):
					#print("Found profile: " + file_name)
					list.append(file_name)
			file_name = dir.get_next()
	else:
		print("CREATING LIBRARY DIRECTORY...")
		if dir.make_dir_recursive("user://") == OK:
			print("SUCCESS")
		else:
			print("FAILED")
	return list

#########################################################
# Временной профиль
#########################################################
var temp_profile = null

func create_temp_profile():
	temp_profile = Profile.new()
	return temp_profile

func get_temp_profile():
	return temp_profile
	
#########################################################
# Список профилей
#########################################################
var profiles = {}

func add_profile(profile):
	if profiles.has(profile):
		return false
	profiles[profile.nickname] = profile
	return true

func get_profile(nickname):
	if profiles.has(nickname):
		return profiles[nickname]
	return null
	
#########################################################
# Текущий профиль
#########################################################
var current_profile

func set_current_profile(profile):
	current_profile = profile
	return current_profile
	
func get_current_profile():
	return current_profile
	
func get_current_settings():
	return current_profile.settings

func get_value(sv):
	return current_profile.settings.get_value(sv)
	
func get_username():
	return current_profile.nickname

func set_current_settings(sv, value):
	current_profile.settings.set_value(sv, value)

func set_value(sv, value):
	current_profile.settings.set_value(sv, value)

func apply_current_settings():
	UI.apply_profile(current_profile)

func save_current_profile():
	save_profile(current_profile)
	
