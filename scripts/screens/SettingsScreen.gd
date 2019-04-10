extends "res://scripts/UIScreen.gd"

# Settings.gd

onready var section_separator = $SimpleLayout/GBox/HBox
onready var label_current_tab = $SimpleLayout/GBox/HBox/Section/Panel/VBox/LABEL_CURRENT_TAB
onready var ai_engines_list = $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/AISettings/AISettingsBox/VBox/HBoxEngineFolder/EngineFolderButton 
onready var ai_exe_list = $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/AISettings/AISettingsBox/VBox/HBoxEngineExe/EngineExeButton
onready var ai_exe_list_error = $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/AISettings/AISettingsBox/VBox/HBoxEngineExe/EngineExeErrorLabel
onready var scroll_box = $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box

var scroll_ui = 0
var scroll_ai = 0
var scroll_gameplay = 0
var scroll_history = 0
var scroll_camera = 0
var scroll_styles = 0
var scroll_sound = 0
var scroll_input = 0
var scroll_widgets = 0
var scroll_other = 0

enum SettingsSection {
	NONE,
	UI,
	AI,
	GAMEPLAY,
	HISTORY,
	CAMERA,
	STYLES,
	SOUND,
	INPUT,
	WIDGETS,
	OTHER
}

var current_section = SettingsSection.UI

func apply_theme(theme):
	self.theme = theme


func _ready():
	self.title = "TITLE_SETTINGS"
	
	UI.add_theme_element(self)
	
	update_tab_text(current_section)
	
	var ui = get_section(SettingsSection.UI)
	var ai = get_section(SettingsSection.AI)
	var gameplay = get_section(SettingsSection.GAMEPLAY)
	var history = get_section(SettingsSection.HISTORY)
	var camera = get_section(SettingsSection.CAMERA)
	var styles = get_section(SettingsSection.STYLES)
	var sound = get_section(SettingsSection.SOUND)
	var widgets = get_section(SettingsSection.WIDGETS)
	var other = get_section(SettingsSection.OTHER)
	
	# UI
	UI.register_named_element(UI.RB_UI_LANGUAGE_ENGLISH, ui.get_node("LanguageBox/VBox/HBoxLanguageEN/LanguageEnglishRadioButton"))
	UI.register_named_element(UI.RB_UI_LANGUAGE_RUSSIAN, ui.get_node("LanguageBox/VBox/HBoxLanguageRU/LanguageRussianRadioButton"))
	UI.register_named_element(UI.RB_UI_LANGUAGE_CHINESE, ui.get_node("LanguageBox/VBox/HBoxLanguageZH/LanguageChineseRadioButton"))
	UI.register_named_element(UI.RB_UI_LANGUAGE_JAPANESE, ui.get_node("LanguageBox/VBox/HBoxLanguageJA/LanguageJapaneseRadioButton"))
	UI.register_named_element(UI.RB_UI_THEME_REALM_OF_GODS, ui.get_node("ThemesBox/HBox/VBoxTheme/VBox/HBoxThemeRealmOfGods/RB_UI_THEME_GODS"))
	UI.register_named_element(UI.RB_UI_THEME_REALM_OF_TITANS, ui.get_node("ThemesBox/HBox/VBoxTheme/VBox/HBoxThemeRealmOfTitans/RB_UI_THEME_TITANS"))
	UI.register_named_element(UI.RB_UI_THEME_REALM_OF_HUMANS, ui.get_node("ThemesBox/HBox/VBoxTheme/VBox/HBoxThemeRealmOfHumans/RB_UI_THEME_HUMANS"))
	UI.register_named_element(UI.RB_UI_THEME_REALM_OF_ANIMALS, ui.get_node("ThemesBox/HBox/VBoxTheme/VBox/HBoxThemeRealmOfAnimals/RB_UI_THEME_ANIMALS"))
	UI.register_named_element(UI.RB_UI_THEME_REALM_OF_GHOSTS, ui.get_node("ThemesBox/HBox/VBoxTheme/VBox/HBoxThemeRealmOfGhosts/RB_UI_THEME_GHOSTS"))
	UI.register_named_element(UI.RB_UI_THEME_REALM_OF_SINNERS, ui.get_node("ThemesBox/HBox/VBoxTheme/VBox/HBoxThemeRealmOfSinners/RB_UI_THEME_SINNERS"))
	UI.register_named_element(UI.RB_UI_FONT_MODERN, ui.get_node("FontBox/VBox/HBoxFontModern/RB_FONT_MODERN"))
	UI.register_named_element(UI.RB_UI_FONT_FRIENDLY, ui.get_node("FontBox/VBox/HBoxFontFriendly/RB_FONT_FRIENDLY"))
	UI.register_named_element(UI.CB_UI_FONT_OUTLINE, ui.get_node("FontBox/VBox/HBoxFontOutline/CB_FONT_OUTLINE"))
	UI.register_named_element(UI.CB_UI_TIPS_BUTTON, ui.get_node("MiscBox/VBox/HBoxButtonTips/CB_UI_TIPS_BUTTON"))
	UI.register_named_element(UI.SR_UI_PANEL_TRANSPARENCY, ui.get_node("MiscBox/VBox/HBoxPanelTransparency/PanelTransparencySlider"))
	# AI
	UI.register_named_element(UI.OB_AI_ENGINE_NAME, ai.get_node("AISettingsBox/VBox/HBoxEngineFolder/EngineFolderButton"))
	UI.register_named_element(UI.OB_AI_ENGINE_EXE, ai.get_node("AISettingsBox/VBox/HBoxEngineExe/EngineExeButton"))
	UI.register_named_element(UI.SR_AI_SKILL_LEVEL, ai.get_node("AISettingsBox/VBox/HBoxAISkillLevel/SkillLevelSlider"))
	UI.register_named_element(UI.LABEL_AI_SKILL_LEVEL, ai.get_node("AISettingsBox/VBox/HBoxAISkillLevel/SkillLevelSV"))
	# Gameplay
	UI.register_named_element(UI.CB_GAME_AUTOMOVE, gameplay.get_node("GeneralBox/VBox/HBoxAutomove/CB_AUTOMOVE"))
	UI.register_named_element(UI.CB_GAME_AUTOPROMOTION, gameplay.get_node("GeneralBox/VBox/HBoxAutopromotion/CB_AUTOPROMOTE"))
	UI.register_named_element(UI.CB_GAME_LASTMOVE, gameplay.get_node("GeneralBox/VBox/HBoxShowLastMove/CB_LASTMOVE"))
	UI.register_named_element(UI.CB_GAME_CASTLES, gameplay.get_node("GeneralBox/VBox/HBoxShowCastles/CB_CASTLES"))
	
	UI.register_named_element(UI.RB_GAME_AUTOSHOW_DISABLED, gameplay.get_node("ShowMovesModeBox/VBox/HBoxShowMoves1/RB_SHOW_MOVES_NONE"))
	UI.register_named_element(UI.RB_GAME_AUTOSHOW_MYSELF, gameplay.get_node("ShowMovesModeBox/VBox/HBoxShowMoves2/RB_SHOW_MOVES_MYSELF"))
	UI.register_named_element(UI.RB_GAME_AUTOSHOW_ALL, gameplay.get_node("ShowMovesModeBox/VBox/HBoxShowMoves3/RB_SHOW_MOVES_ALL"))

	# History - General
	UI.register_named_element(UI.CB_HISTORY_AUTO_SHOW, history.get_node("GeneralBox/VBox/HBoxAutoShowHistory/CB_HISTORY_AUTO_SHOW"))
	UI.register_named_element(UI.CB_HISTORY_AUTO_SCROLL, history.get_node("GeneralBox/VBox/HBoxHistoryAutoScroll/CB_HISTORY_AUTO_SCROLL"))
	# History - Panel
	UI.register_named_element(UI.RB_HISTORY_PANEL_CLASSIC, history.get_node("StylesBox/VBox/HBoxHistoryStyle1/RB_HISTORY_STYLE_CLASSIC"))
	UI.register_named_element(UI.RB_HISTORY_PANEL_CHESS, history.get_node("StylesBox/VBox/HBoxHistoryStyle2/RB_HISTORY_STYLE_CHESS"))
	UI.register_named_element(UI.SR_HISTORY_PANEL_SIZE, history.get_node("StylesBox/VBox/HBoxHistorySize/SLIDER_HISTORY_SIZE"))
	UI.register_named_element(UI.SB_HISTORY_ELEMENT_COUNT, history.get_node("StylesBox/VBox/HBoxHistoryCount/SB_HISTORY_SIZE"))
	# History - Playback
	UI.register_named_element(UI.CB_HISTORY_REVERT_BUTTON, history.get_node("PlaybackBox/VBox/PlaybackRevert/PlaybackRevertCheckBox"))
	UI.register_named_element(UI.RB_HISTORY_PLAYBACK_FROM_REPLAY, history.get_node("PlaybackBox/VBox/PlaybackFromReplay/PlaybackFromReplayRadioButton"))
	UI.register_named_element(UI.RB_HISTORY_PLAYBACK_FIXED_DURATION, history.get_node("PlaybackBox/VBox/PlaybackFixedDuration/PlaybackFixedDurationRadioButton"))
	UI.register_named_element(UI.SR_HISTORY_PLAYBACK_FIXED_DURATION, history.get_node("PlaybackBox/VBox/PlaybackFixedDuration2/PlaybackFixedDurationSlider"))
	UI.register_named_element(UI.LABEL_HISTORY_PLAYBACK_FIXED_DURATION, history.get_node("PlaybackBox/VBox/PlaybackFixedDuration2/PlaybackFixedDurationCurrent"))
	# History - Notation
	UI.register_named_element(UI.RB_HISTORY_NOTATION_JAPANESE, history.get_node("NotationBox/VBox/HBoxNotation1/RB_HISTORY_NOTATION_JAPANESE"))
	UI.register_named_element(UI.RB_HISTORY_NOTATION_SHORT, history.get_node("NotationBox/VBox/HBoxNotation2/RB_HISTORY_NOTATION_SHORT"))
	UI.register_named_element(UI.RB_HISTORY_NOTATION_FULL, history.get_node("NotationBox/VBox/HBoxNotation3/RB_HISTORY_NOTATION_FULL"))
	UI.register_named_element(UI.CB_HISTORY_Y_NUM, history.get_node("NotationBox/VBox/HBoxUseNumber/CB_HISTORY_USE_NUMBER"))
	UI.register_named_element(UI.CB_HISTORY_TURN_SYMBOL, history.get_node("NotationBox/VBox/HBoxHistoryTurnSymbol/CB_HISTORY_TURN_SYMBOL"))
	# History - Symbols
	UI.register_named_element(UI.RB_HISTORY_SYMBOLS_JP, history.get_node("SymbolsBox/VBox/HBoxHistorySymbols1/RB_HISTORY_SYMBOLS_JP"))	
	UI.register_named_element(UI.RB_HISTORY_SYMBOLS_EN, history.get_node("SymbolsBox/VBox/HBoxHistorySymbols2/RB_HISTORY_SYMBOLS_EN"))
	# Camera
	UI.register_named_element(UI.CB_CAMERA_ALLOW_YAW, camera.get_node("Box/VBox/HBoxAllowYaw/CB_CAMERA_ALLOW_YAW"))
	UI.register_named_element(UI.CB_CAMERA_ALLOW_PITCH, camera.get_node("Box/VBox/HBoxAllowPitch/CB_CAMERA_ALLOW_PITCH"))
	UI.register_named_element(UI.CB_CAMERA_ALLOW_ZOOM, camera.get_node("Box/VBox/HBoxAllowZoom/CB_CAMERA_ALLOW_ZOOM"))
	UI.register_named_element(UI.CB_CAMERA_ALLOW_PAN, camera.get_node("Box/VBox/HBoxAllowPan/CB_CAMERA_ALLOW_PAN"))
	UI.register_named_element(UI.CB_CAMERA_SWITCH_SIDES, camera.get_node("Box/VBox/HBoxSwitchSides/CB_CAMERA_SWITCH_SIDES"))
	UI.register_named_element(UI.CB_CAMERA_RESTRICT_YAW, camera.get_node("Box/VBox/HBoxRestrictYaw/CB_CAMERA_RESTRICT_YAW"))
	UI.register_named_element(UI.CB_CAMERA_INTERPOLATION, camera.get_node("Box/VBox/HBoxEnableInterpolation/CB_CAMERA_INTERPOLATION"))
	# Styles
	UI.register_named_element(UI.CHECKBOX_STYLES_UI_COLORING, styles.get_node("BoardStylesBox/VBox/HBoxBoardUIColoring/CB_STYLES_UI_COLORING"))
	UI.register_named_element(UI.CHECKBOX_STYLES_BOARD_MARKUP, styles.get_node("HBoxBoardMarkup/CB_STYLES_BOARD_MARKUP"))
	UI.register_named_element(UI.CHECKBOX_STYLES_CHESS_COLORING, styles.get_node("BoardStylesBox/VBox/HBoxBoardChessColoring/CB_STYLES_CHESS_COLORING"))
	UI.register_named_element(UI.CHECKBOX_STYLES_ZONES_COLORING, styles.get_node("HBoxBoardZonesColoring/CB_STYLES_ZONES_COLORING"))
	UI.register_named_element(UI.CHECKBOX_STYLES_GRID_COLOR_BLACK, styles.get_node("GridStylesBox/VBox/HBoxGridBlack/RB_STYLES_GRID_BLACK"))
	UI.register_named_element(UI.CHECKBOX_STYLES_GRID_COLOR_WHITE, styles.get_node("GridStylesBox/VBox/HBoxGridWhite/RB_STYLES_GRID_WHITE"))
	UI.register_named_element(UI.SLIDER_STYLES_GRID_THICKNESS, styles.get_node("GridStylesBox/VBox/HBoxGridThickness/VBoxGridThickness/SLIDER_GRID_THICKNESS"))
	UI.register_named_element(UI.LABEL_STYLES_GRID_THICKNESS_INPUT, styles.get_node("GridStylesBox/VBox/HBoxGridThickness/VBoxGridThickness/LABEL_CURRENT_GRID_THICKNESS"))
	# SFX
	UI.register_named_element(UI.CHECKBOX_SFX_UI_ENABLED, sound.get_node("SoundBox/VBox/HBoxEnableUISound/CB_SOUND_ENABLE_UI"))
	UI.register_named_element(UI.CHECKBOX_SFX_MOVE_ENABLED, sound.get_node("SoundBox/VBox/HBoxEnableMoveSound/CB_SOUND_ENABLE_MOVE"))
	UI.register_named_element(UI.CHECKBOX_SFX_3D_ENABLED, sound.get_node("SoundBox/VBox/HBoxEnable3DSound/CB_SOUND_ENABLE_3D"))
	
	UI.register_named_element(UI.CHECKBOX_SFX_SPEECH_ENABLED, sound.get_node("SpeechBox/VBox/HBoxEnableSpeech/CB_SOUND_ENABLE_SPEECH"))
	UI.register_named_element(UI.SLIDER_SOUND_SPEECH_VOLUME, sound.get_node("SpeechBox/VBox/HBoxEnableSpeechSlider/SLIDER_SPEECH_VOLUME"))
	UI.register_named_element(UI.CHECKBOX_SFX_CHECK_ENABLED, sound.get_node("SpeechBox/VBox/HBoxEnableCheckSound/CB_SOUND_ENABLE_CHECK"))
	
	UI.register_named_element(UI.CHECKBOX_SFX_MUSIC_ENABLED, sound.get_node("HBoxEnableMusic/CB_SOUND_ENABLE_MUSIC"))
	UI.register_named_element(UI.SLIDER_SOUND_MUSIC_VOLUME, sound.get_node("HBoxMusicVolume/SLIDER_MUSIC_VOLUME"))
	UI.register_named_element(UI.LABEL_CURRENT_SONG, sound.get_node("HBoxCurrentSong/LABEL_CURRENT_SONG_INPUT"))
	UI.register_named_element(UI.RB_MUSIC_PLAYORDER_NEXT, sound.get_node("HBoxMusicOrder/RB_SOUND_MUSIC_INORDER"))
	UI.register_named_element(UI.RB_MUSIC_PLAYORDER_RANDOMIZE, sound.get_node("HBoxMusicOrder/RB_SOUND_MUSIC_RANDOMIZE"))
	# Widgets
	# Sansara
	UI.register_named_element(UI.CB_WIDGETS_SANSARA_ENABLED, widgets.get_node("HBoxSansaraWidgetTitle/CB_WIDGET_SANSARA_ENABLED"))
	UI.register_named_element(UI.RB_WIDGETS_SANSARA_ORDER_NEXT, widgets.get_node("SansaraWidgetOrderBox/VBox/HBoxSansaraOrderNext/RB_SANSARA_ORDER_NEXT"))
	UI.register_named_element(UI.RB_WIDGETS_SANSARA_ORDER_PREVIOUS, widgets.get_node("SansaraWidgetOrderBox/VBox/HBoxSansaraOrderPrevious/RB_SANSARA_ORDER_PREVIOUS"))	
	# Clock
	UI.register_named_element(UI.CB_WIDGETS_CLOCK_ENABLED, widgets.get_node("HBoxClockWidgetTitle/CB_WIDGET_CLOCK_ENABLED"))
	UI.register_named_element(UI.CB_WIDGETS_CLOCK_SECONDS_ENABLED, widgets.get_node("ClockBox/VBox/HBoxClockShowSeconds/CB_CLOCK_SHOW_SECONDS"))
	UI.register_named_element(UI.RB_WIDGETS_CLOCK_FORMAT_24, widgets.get_node("ClockFormat/VBox/HBoxClockFormat24/RB_CLOCK_FORMAT_24"))
	UI.register_named_element(UI.RB_WIDGETS_CLOCK_FORMAT_12, widgets.get_node("ClockFormat/VBox/HBoxClockFormat12/RB_CLOCK_FORMAT_12"))
	# Quit
	UI.register_named_element(UI.CB_WIDGETS_QQ_ENABLED, widgets.get_node("HBoxQQWidgetTitle/CB_WIDGET_QUIT_ENABLED"))
	UI.register_named_element(UI.CB_WIDGETS_QQ_DIALOG_ENABLED, widgets.get_node("QQBox/VBox/HBoxGoodbayShow/CB_QQ_SHOW_DIALOG"))
	# Other
	UI.register_named_element(UI.LE_PROFILE_NAME, other.get_node("ProfileBox/VBox/HBoxUsername/UsernameLE"))
	UI.register_named_element(UI.RB_MASTER_USE_IPV4, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxIPV4/MasterIPV4RadioBox"))
	UI.register_named_element(UI.SB_MASTER_IPV4_1, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxIPV4/MasterIPV4Box1"))
	UI.register_named_element(UI.SB_MASTER_IPV4_2, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxIPV4/MasterIPV4Box2"))
	UI.register_named_element(UI.SB_MASTER_IPV4_3, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxIPV4/MasterIPV4Box3"))
	UI.register_named_element(UI.SB_MASTER_IPV4_4, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxIPV4/MasterIPV4Box4"))
	UI.register_named_element(UI.RB_MASTER_USE_IPV6, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxIPV6/MasterIPV6RadioBox"))
	UI.register_named_element(UI.LE_MASTER_IPV6, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxIPV6/MasterIPV6Box"))
	UI.register_named_element(UI.SB_MASTER_PORT, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxPort/MasterPortBox"))
	UI.register_named_element(UI.CB_LOOPBACK, other.get_node("DevMode/MasterServerIPBox/VBox/HBoxLoopback/LoopbackCheckBox"))
	setup_ai()
	
func show_aspect(theme, aspect):
	var s = get_section(SettingsSection.UI)
	match theme:
		UI.UITheme.REALM_OF_GODS:
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods").show()
			match aspect:
				0:
					s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods/HBoxAspectPurity/RB_UI_ASPECT_GODS_PURITY").pressed = true
				1:
					s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods/HBoxAspectRapture/RB_UI_ASPECT_GODS_RAPTURE").pressed = true		
				2:
					s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods/HBoxAspectWealth/RB_UI_ASPECT_GODS_WEALTH").pressed = true
		UI.UITheme.REALM_OF_TITANS:
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty").show()
		UI.UITheme.REALM_OF_HUMANS:
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty").show()
		UI.UITheme.REALM_OF_ANIMALS:
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty").show()
		UI.UITheme.REALM_OF_GHOSTS:
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty").show()
		UI.UITheme.REALM_OF_SINNERS:
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty").hide()
			s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners").show()
			match aspect:
				0:
					s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectFire/RB_UI_ASPECT_SINNERS_FIRE").pressed = true
				1:
					s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectPain/RB_UI_ASPECT_SINNERS_PAIN").pressed = true	
				2:
					s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectDespair/RB_UI_ASPECT_SINNERS_DESPAIR").pressed = true
				3:
					s.get_node("ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectColorless/RB_UI_ASPECT_SINNERS_COLORLESS").pressed = true
			
func get_section_btn(section):
	match section:
		SettingsSection.UI:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_UI
		SettingsSection.AI:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_AI
		SettingsSection.GAMEPLAY:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_GAMEPLAY
		SettingsSection.HISTORY:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_HISTORY
		SettingsSection.CAMERA:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_CAMERA
		SettingsSection.STYLES:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_STYLES
		SettingsSection.SOUND:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_SOUND
		SettingsSection.INPUT:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_INPUT
		SettingsSection.WIDGETS:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_WIDGETS
		SettingsSection.OTHER:
			return $SimpleLayout/GBox/SettingsPanel/SettingsList/BTN_SETTINGS_OTHER

func get_section(section):
	match section:
		SettingsSection.UI:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings
		SettingsSection.AI:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/AISettings
		SettingsSection.GAMEPLAY:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/GameplaySettings
		SettingsSection.HISTORY:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/HistorySettings
		SettingsSection.CAMERA:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/CameraSettings
		SettingsSection.STYLES:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/StylesSettings
		SettingsSection.SOUND:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/SoundSettings
		SettingsSection.INPUT:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/InputSettings
		SettingsSection.WIDGETS:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/WidgetSettings
		SettingsSection.OTHER:
			return $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/OtherSettings

func _on_AIPowerSlider_value_changed(value):
	UI.get_named_element(UI.SR_AI_SKILL_LEVEL2).value = value
	value = int(value)
	Profiles.set_current_settings(Settings.SV_AI_ENGINE_SKILL_LEVEL, value)
	UI.get_named_element(UI.LABEL_AI_SKILL_LEVEL).text = str(value)
	UI.get_named_element(UI.LABEL_AI_SKILL_LEVEL2).text = str(value)
	if UI.get_game().has_active_session():
		UI.get_ai().SetSkillLevel(value)
	
func setup_ai():
	var path = OS.get_executable_path()
	path = path.get_base_dir()
	path += "/engines"
	var dirs = Utility.get_dirs(path)
	ai_engines_list.clear()
	ai_engines_list.add_item("None")
	for entry in dirs:
		ai_engines_list.add_item(entry)

func _on_EngineFolderButton_item_selected(ID):
	ai_exe_list.clear()
	if ID == 0:
		ai_exe_list_error.visible = true
		ai_exe_list.visible = false
		Profiles.set_current_settings(Settings.SV_AI_ENGINE_FOLDER, "")
		Profiles.set_current_settings(Settings.SV_AI_ENGINE_EXE, "")
	else:
		ai_exe_list_error.visible = false
		ai_exe_list.visible = true
		var path = OS.get_executable_path()
		path = path.get_base_dir()
		var selected_text = ai_engines_list.get_item_text(ID)
		Profiles.set_current_settings(Settings.SV_AI_ENGINE_FOLDER, selected_text)
		path += "/engines/" + selected_text
		var _files = Utility.get_files(path, "exe")
		ai_exe_list.set_meta("path", path)
		for entry in _files:
			ai_exe_list.add_item(entry.get_file())
		if !_files.empty():
			_on_EngineExeButton_item_selected(0)
			ai_exe_list_error.visible = false
			ai_exe_list.visible = true
		else:
			Profiles.set_current_settings(Settings.SV_AI_ENGINE_EXE, "")
			ai_exe_list_error.visible = true
			ai_exe_list.visible = false
		
func _on_EngineExeButton_item_selected(ID):
	Profiles.set_current_settings(Settings.SV_AI_ENGINE_EXE, ai_exe_list.get_item_text(ID))
	if UI.get_game().has_active_session():
		UI.get_game().reinit_ai()
	
func hide_subsection(section):
	var s = get_section(section)
	s.beautiful_hide()
	yield(s, "fade_completed")
	section_separator.beautiful_hide()
	yield(section_separator, "fade_completed")
	current_section = SettingsSection.NONE

func select_subsection(section):
	UI.get_helper().hide_tooltip()
	update_tab_text(section)
	var s = get_section(current_section)
	s.hide()
	
	match current_section:
		SettingsSection.UI:
			scroll_ui = scroll_box.scroll_vertical
		SettingsSection.AI:
			scroll_ai = scroll_box.scroll_vertical
		SettingsSection.GAMEPLAY:
			scroll_gameplay = scroll_box.scroll_vertical
		SettingsSection.HISTORY:
			scroll_history = scroll_box.scroll_vertical
		SettingsSection.CAMERA:
			scroll_camera = scroll_box.scroll_vertical
		SettingsSection.STYLES:
			scroll_styles = scroll_box.scroll_vertical
		SettingsSection.SOUND:
			scroll_sound = scroll_box.scroll_vertical
		SettingsSection.INPUT:
			scroll_input = scroll_box.scroll_vertical
		SettingsSection.WIDGETS:
			scroll_widgets = scroll_box.scroll_vertical
		SettingsSection.OTHER:
			scroll_other = scroll_box.scroll_vertical

	current_section = section
	
	var btn = get_section_btn(current_section)
	btn.pressed = true
	s = get_section(current_section)
	s.show()
	update_scrollbox = true

var update_scrollbox = false

var secret_count = 0

func _process(delta):
	if Input.is_action_just_pressed("secret_key"):
		if secret_count == -1:
			$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/OtherSettings/DevMode.visible = false
			secret_count = 0
		secret_count += 1
		
	if secret_count >= 3:
		$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/OtherSettings/DevMode.visible = true
		secret_count = -1
		
	if update_scrollbox:
		match current_section:
			SettingsSection.UI:
				scroll_box.scroll_vertical = scroll_ui
			SettingsSection.AI:
				scroll_box.scroll_vertical = scroll_ai
			SettingsSection.GAMEPLAY:
				scroll_box.scroll_vertical = scroll_gameplay
			SettingsSection.HISTORY:
				scroll_box.scroll_vertical = scroll_history
			SettingsSection.CAMERA:
				scroll_box.scroll_vertical = scroll_camera
			SettingsSection.STYLES:
				scroll_box.scroll_vertical = scroll_styles
			SettingsSection.SOUND:
				scroll_box.scroll_vertical = scroll_sound
			SettingsSection.INPUT:
				scroll_box.scroll_vertical = scroll_input
			SettingsSection.WIDGETS:
				scroll_box.scroll_vertical = scroll_widgets
			SettingsSection.OTHER:
				scroll_box.scroll_vertical = scroll_other
		update_scrollbox = false

func update_tab_text(section):
	match section:
		SettingsSection.UI:
			label_current_tab.text = "BTN_SETTINGS_UI"
		SettingsSection.AI:
			label_current_tab.text = "BTN_SETTINGS_AI"
		SettingsSection.GAMEPLAY:
			label_current_tab.text = "BTN_SETTINGS_GAMEPLAY"
		SettingsSection.HISTORY:
			label_current_tab.text = "BTN_SETTINGS_HISTORY"
		SettingsSection.CAMERA:
			label_current_tab.text = "BTN_SETTINGS_CAMERA"
		SettingsSection.STYLES:
			label_current_tab.text = "BTN_SETTINGS_STYLES"
		SettingsSection.SOUND:
			label_current_tab.text = "BTN_SETTINGS_SOUND"
		SettingsSection.INPUT:
			label_current_tab.text = "BTN_SETTINGS_INPUT"
		SettingsSection.WIDGETS:
			label_current_tab.text = "BTN_SETTINGS_WIDGETS"
		SettingsSection.OTHER:
			label_current_tab.text = "BTN_SETTINGS_OTHER"

func show_subsection(section):
	if current_section != section:
		if current_section == SettingsSection.NONE:
			current_section = section
			
			update_tab_text(section)
			label_current_tab.beautiful_show()
			yield(label_current_tab, "fade_completed")
			
			section_separator.beautiful_show()
			yield(section_separator, "fade_completed")
			
			get_section(current_section).beautiful_show()
		else:
			select_subsection(section)
	#else:
	#		hide_subsection(current_section)

func open_history_subsection():
	get_section_btn(SettingsSection.HISTORY).pressed = true
	show_subsection(SettingsSection.HISTORY)

func open_styles_subsection():
	get_section_btn(SettingsSection.STYLES).pressed = true
	show_subsection(SettingsSection.STYLES)

func open_ai_subsection():
	get_section_btn(SettingsSection.AI).pressed = true
	show_subsection(SettingsSection.AI)



func _on_BTN_SETTINGS_UI_pressed():
	show_subsection(SettingsSection.UI)

func _on_BTN_SETTINGS_AI_pressed():
	show_subsection(SettingsSection.AI)

func _on_BTN_SETTINGS_GAMEPLAY_pressed():
	show_subsection(SettingsSection.GAMEPLAY)

func _on_BTN_SETTINGS_HISTORY_pressed():
	show_subsection(SettingsSection.HISTORY)
	
func _on_BTN_SETTINGS_CAMERA_pressed():
	show_subsection(SettingsSection.CAMERA)
	
func _on_BTN_SETTINGS_STYLES_pressed():
	show_subsection(SettingsSection.STYLES)
	
func _on_BTN_SETTINGS_SOUND_pressed():
	show_subsection(SettingsSection.SOUND)
	
func _on_BTN_SETTINGS_INPUT_pressed():
	show_subsection(SettingsSection.INPUT)
	
func _on_BTN_SETTINGS_WIDGETS_pressed():
	show_subsection(SettingsSection.WIDGETS)

func _on_BTN_SETTINGS_OTHER_pressed():
	show_subsection(SettingsSection.OTHER)
	
#func _on_BTN_BACK_pressed():
#	if current_section != SETTINGS_SECTION_NONE:
#		hide_subsection(current_section)
#	go_back_if_possible()

func go_back_if_possible():
	if.go_back_if_possible():
		UI.get_widget(UI.WIDGET_SETTINGS).show()
	
# UI - Language settings

func _on_LanguageEnglishRadioButton_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_LANGUAGE, Settings.Language.ENGLISH)
	UI.apply_language(Settings.Language.ENGLISH)

func _on_LanguageRussianRadioButton_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_LANGUAGE, Settings.Language.RUSSIAN)
	UI.apply_language(Settings.Language.RUSSIAN)

func _on_LanguageChineseRadioButton_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_LANGUAGE, Settings.Language.CHINESE)
	UI.apply_language(Settings.Language.CHINESE)
 
func _on_LanguageJapaneseRadioButton_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_LANGUAGE, Settings.Language.JAPANESE)
	UI.apply_language(Settings.Language.JAPANESE)
	
func _hide_aspects():
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty.visible = false
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods.visible = false
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners.visible = false
	
# UI - Themes settings

func _on_AISettingsButton_pressed():
	UI.get_root().open_ai_settings()

# UI - Gods Theme

func _on_RB_UI_THEME_GODS_pressed():
	_hide_aspects()
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods.visible = true
	
	if $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods/HBoxAspectPurity/RB_UI_ASPECT_GODS_PURITY.pressed:
		_on_RB_UI_ASPECT_GODS_PURITY_pressed()
	elif $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods/HBoxAspectRapture/RB_UI_ASPECT_GODS_RAPTURE.pressed:
		_on_RB_UI_ASPECT_GODS_RAPTURE_pressed()
	elif $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectGods/HBoxAspectWealth/RB_UI_ASPECT_GODS_WEALTH.pressed:
		_on_RB_UI_ASPECT_GODS_WEALTH_pressed()

func _on_RB_UI_ASPECT_GODS_PURITY_pressed():
	Profiles.set_current_settings(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_GODS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 0)
	UI.set_theme(UI.UITheme.REALM_OF_GODS, 0)
	
func _on_RB_UI_ASPECT_GODS_RAPTURE_pressed():
	Profiles.set_current_settings(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_GODS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 1)
	UI.set_theme(UI.UITheme.REALM_OF_GODS, 1)
	
func _on_RB_UI_ASPECT_GODS_WEALTH_pressed():
	Profiles.set_current_settings(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_GODS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 2)
	UI.set_theme(UI.UITheme.REALM_OF_GODS, 2)

# UI - Titans Theme

func _on_RB_UI_THEME_TITANS_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_TITANS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 0)
	UI.set_theme(UI.UITheme.REALM_OF_TITANS, UI.current_aspect)
	_hide_aspects()
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty.visible = true  # empty

# UI - Humans Theme

func _on_RB_UI_THEME_HUMANS_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_HUMANS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 0)
	UI.set_theme(UI.UITheme.REALM_OF_HUMANS, UI.current_aspect)
	_hide_aspects()
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty.visible = true  # empty

# UI - Animals Theme

func _on_RB_UI_THEME_ANIMALS_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_ANIMALS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 0)
	UI.set_theme(UI.UITheme.REALM_OF_ANIMALS, UI.current_aspect)
	_hide_aspects() 
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty.visible = true # empty

# UI - Ghosts Theme

func _on_RB_UI_THEME_GHOSTS_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_GHOSTS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 0)
	UI.set_theme(UI.UITheme.REALM_OF_GHOSTS, UI.current_aspect)
	_hide_aspects()
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectEmpty.visible = true # empty

# UI - Sinner Theme

func _on_RB_UI_THEME_SINNERS_pressed():
	_hide_aspects()
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners.visible = true

	if $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectFire/RB_UI_ASPECT_SINNERS_FIRE.pressed:
		_on_RB_UI_ASPECT_SINNERS_FIRE_pressed()
	elif $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectPain/RB_UI_ASPECT_SINNERS_PAIN.pressed:
		_on_RB_UI_ASPECT_SINNERS_PAIN_pressed()
	elif $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectDespair/RB_UI_ASPECT_SINNERS_DESPAIR.pressed:
		_on_RB_UI_ASPECT_SINNERS_DESPAIR_pressed()
	elif $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/ThemesBox/HBox/VBoxAspect/VBox/VBoxAspectSinners/HBoxAspectColorless/RB_UI_ASPECT_SINNERS_COLORLESS.pressed:
		_on_RB_UI_ASPECT_SINNERS_COLORLESS_pressed()
		
func _on_RB_UI_ASPECT_SINNERS_FIRE_pressed():
	Profiles.set_current_settings(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_SINNERS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 0)
	UI.set_theme(UI.UITheme.REALM_OF_SINNERS, 0)
	
func _on_RB_UI_ASPECT_SINNERS_PAIN_pressed():
	Profiles.set_current_settings(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_SINNERS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 1)
	UI.set_theme(UI.UITheme.REALM_OF_SINNERS, 1)

func _on_RB_UI_ASPECT_SINNERS_DESPAIR_pressed():
	Profiles.set_current_settings(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_SINNERS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 2)
	UI.set_theme(UI.UITheme.REALM_OF_SINNERS, 2)
	
func _on_RB_UI_ASPECT_SINNERS_COLORLESS_pressed():
	Profiles.set_current_settings(Settings.SV_UI_THEME, UI.UITheme.REALM_OF_SINNERS)
	Profiles.set_current_settings(Settings.SV_UI_ASPECT, 3)
	UI.set_theme(UI.UITheme.REALM_OF_SINNERS, 3)

# UI - Font

func _on_RB_FONT_MODERN_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_FONT, 0)
	UI.set_theme(UI.current_theme, UI.current_aspect)

func _on_RB_FONT_FRIENDLY_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_UI_FONT, 1)
	UI.set_theme(UI.current_theme, UI.current_aspect)

func _on_CB_FONT_OUTLINE_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_UI_FONT_OUTLINE_ENABLED, toggled)
	UI.set_theme(UI.current_theme, UI.current_aspect)

# UI - Tips

func _on_CB_UI_BUTTON_TIPS_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_UI_TIPS_BUTTON_ENABLED, toggled)

# AI

func _on_AILogCheckBox_toggled(toggled):
	Profiles.set_value(Settings.SV_AI_ENGINE_ENABLE_LOG, toggled)

# Gameplay

func _on_CB_AUTOMOVE_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_GAME_AUTOMOVE_ENABLED, toggled)
func _on_CB_AUTOMOVE_mouse_entered():
	UI.get_helper().show_tooltip("TT_AUTOMOVE", $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/GameplaySettings/GeneralBox/VBox/HBoxAutomove/CB_AUTOMOVE)
func _on_CB_AUTOMOVE_mouse_exited():
	UI.get_helper().hide_tooltip()
func _on_CB_AUTOMOVE_focus_entered():
	UI.get_helper().show_tooltip("TT_AUTOMOVE", $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/GameplaySettings/GeneralBox/VBox/HBoxAutomove/CB_AUTOMOVE)
func _on_CB_AUTOMOVE_focus_exited():
	UI.get_helper().hide_tooltip()

func _on_CB_AUTOPROMOTE_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_GAME_AUTOPROMOTION_ENABLED, toggled)
func _on_CB_AUTOPROMOTE_mouse_entered():
	UI.get_helper().show_tooltip("TT_AUTOPROMOTE", $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/GameplaySettings/GeneralBox/VBox/HBoxAutopromotion/CB_AUTOPROMOTE)
func _on_CB_AUTOPROMOTE_mouse_exited():
	UI.get_helper().hide_tooltip()
func _on_CB_AUTOPROMOTE_focus_entered():
	UI.get_helper().show_tooltip("TT_AUTOPROMOTE", $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/GameplaySettings/GeneralBox/VBox/HBoxAutopromotion/CB_AUTOPROMOTE)
func _on_CB_AUTOPROMOTE_focus_exited():
	UI.get_helper().hide_tooltip()

func _on_CB_LASTMOVE_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_GAME_LASTMOVE_ENABLED, toggled)
	var last_piece = UI.get_game().last_selected_piece
	if last_piece != null:
		last_piece.set_mark(toggled)
		last_piece.prev_nest.mark_last_move(toggled)
	
func _on_CB_GAME_SHOW_CASTLINGS_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_GAME_CASTLINGS_ENABLED, toggled) 
func _on_CB_GAME_SHOW_CASTLINGS_mouse_entered():
	UI.get_helper().show_tooltip("TT_CASTLINGS", $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/GameplaySettings/GeneralBox/VBox/HBoxShowCastles/CB_CASTLES)
func _on_CB_GAME_SHOW_CASTLINGS_mouse_exited():
	UI.get_helper().hide_tooltip()
		
func _on_RB_SHOW_MOVES_NONE_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_GAME_AUTOSHOW, Settings.HighlightOptions.DISABLED)
func _on_RB_SHOW_MOVES_MYSELF_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_GAME_AUTOSHOW, Settings.HighlightOptions.MYSELF)
func _on_RB_SHOW_MOVES_ALL_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_GAME_AUTOSHOW, Settings.HighlightOptions.ALL)

func _on_SLIDER_ANIM_SPEED_value_changed(value):
	Profiles.get_current_settings().set_value(Settings.SV_GAME_ANIM_SPEED, value)

# Graphics

# History

func _on_PlaybackFromReplayRadioButton_pressed():
	Profiles.set_value(Settings.SV_HISTORY_PLAYBACK_IS_FIXED, false)

func _on_PlaybackFixedDurationRadioButton_pressed():
	Profiles.set_value(Settings.SV_HISTORY_PLAYBACK_IS_FIXED, true)

func _on_PlaybackRevertCheckBox_toggled(toggled):
	Profiles.set_value(Settings.SV_HISTORY_PLAYBACK_REVERT, toggled)
	UI.get_game().gui.enable_playback_revert_button(toggled)
	
func _on_PlaybackFixedDurationSlider_value_changed(value):
	Profiles.set_value(Settings.SV_HISTORY_PLAYBACK_FIXED_DURATION, value)
	UI.get_named_element(UI.LABEL_HISTORY_PLAYBACK_FIXED_DURATION).text = str(value) + " " + TranslationServer.translate("LABEL_SECONDS2")
	
func _on_CB_HISTORY_AUTO_SHOW_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_AUTOSHOW_ENABLED, toggled)

func _on_SLIDER_HISTORY_SIZE_value_changed(value):
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_PANEL_SIZE, value)
	UI.get_history().set_scale(int(value))
	
func _on_SB_HISTORY_SIZE_value_changed(value):
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_ELEMENT_COUNT, int(value))
	UI.get_history().set_element_count(int(value))

func _on_CB_HISTORY_AUTO_SCROLL_toggled(toggled):
	UI.get_history().enable_autoscroll(toggled)

func _on_RB_HISTORY_STYLE_CLASSIC_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_PANEL_STYLE, 0)
	UI.get_history().set_panel_mode(0)

func _on_RB_HISTORY_STYLE_CHESS_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_PANEL_STYLE, 1)
	UI.get_history().set_panel_mode(1)

func _on_CB_HISTORY_TURN_SYMBOL_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_DRAW_TURN_SYMBOL, toggled)
	UI.get_history().set_turn_symbol(toggled)
	
func _on_RB_HISTORY_NOTATION_JAPANESE_pressed():
	if UI.get_history().notation_mode != 0:
		UI.get_named_element(UI.CB_HISTORY_Y_NUM).disabled = true
		UI.settings_en_was_pressed = UI.get_history().symbol_mode == 1
		UI.get_named_element(UI.RB_HISTORY_SYMBOLS_JP).pressed = true
		UI.get_named_element(UI.RB_HISTORY_SYMBOLS_EN).disabled = true
		Profiles.get_current_settings().set_value(Settings.SV_HISTORY_NOTATION_STYLE, 0)
		UI.get_history().set_notation_mode(0)

func _on_RB_HISTORY_NOTATION_SHORT_pressed():
	UI.get_named_element(UI.RB_HISTORY_SYMBOLS_EN).disabled = false
	UI.get_named_element(UI.CB_HISTORY_Y_NUM).disabled = false
	if UI.settings_en_was_pressed:
		UI.get_named_element(UI.RB_HISTORY_SYMBOLS_EN).pressed = true
		UI.settings_en_was_pressed = false
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_NOTATION_STYLE, 1)
	UI.get_history().set_notation_mode(1)

func _on_RB_HISTORY_NOTATION_FULL_pressed():
	UI.get_named_element(UI.RB_HISTORY_SYMBOLS_EN).disabled = false
	UI.get_named_element(UI.CB_HISTORY_Y_NUM).disabled = false
	if UI.settings_en_was_pressed:
		UI.get_named_element(UI.RB_HISTORY_SYMBOLS_EN).pressed = true
		UI.settings_en_was_pressed = false
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_NOTATION_STYLE, 2)
	UI.get_history().set_notation_mode(2)

func _on_CB_HISTORY_USE_NUMBER_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_NOTATION_USE_Y_NUMBER, toggled)
	UI.get_history().set_ynum_mode(toggled)

func _on_RB_HISTORY_SYMBOLS_JP_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_SYMBOLS, 0)
	UI.get_history().set_symbol_mode(0)

func _on_RB_HISTORY_SYMBOLS_EN_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_HISTORY_SYMBOLS, 1)
	UI.get_history().set_symbol_mode(1)

# Camera

func _on_CB_CAMERA_ALLOW_YAW_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_CAMERA_YAW_ENABLED, toggled)
	UI.get_game().reset_yaw()

func _on_CB_CAMERA_ALLOW_PITCH_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_CAMERA_PITCH_ENABLED, toggled)
	UI.get_game().reset_pitch()

func _on_CB_CAMERA_ALLOW_ZOOM_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_CAMERA_ZOOM_ENABLED, toggled)
	UI.get_game().reset_zoom()

func _on_CB_CAMERA_ALLOW_PAN_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_CAMERA_PAN_ENABLED, toggled)
	UI.get_game().reset_pan()

func _on_CB_CAMERA_SWITCH_SIDES_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_CAMERA_SWITCH_ENABLED, toggled)
	
func _on_CB_CAMERA_RESTRICT_YAW_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_CAMERA_RESTRICT_YAW, toggled)

func _on_CB_CAMERA_INTERPOLATION_toggled(toggled):
	Profiles.set_value(Settings.SV_CAMERA_SMOOTH_ENABLED, toggled)
	UI.get_game().current_view.stop_tweens()
			
# Styles

func _on_CB_STYLES_UI_COLORING_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_STYLES_BOARD_COLORING_UI_ENABLED, toggled)
	
func _on_CB_STYLES_CHESS_COLORING_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_STYLES_BOARD_COLORING_CHESS_ENABLED, toggled)
	UI.get_game().update_board_style()

func _on_RB_STYLES_GRID_BLACK_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_STYLES_GRID_COLOR, Settings.WebColor.BLACK)
	UI.get_game().update_grid_color()

func _on_RB_STYLES_GRID_WHITE_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_STYLES_GRID_COLOR, Settings.WebColor.WHITE)
	UI.get_game().update_grid_color()

func _on_SLIDER_GRID_THICKNESS_value_changed(value):
	match value:
		1.0:
			Profiles.get_current_settings().set_value(Settings.SV_STYLES_GRID_THICKNESS, UI.Thickness.TS_VERY_THIN)
			UI.get_named_element(UI.LABEL_STYLES_GRID_THICKNESS_INPUT).text = "SD_GAME_GRID_THICKNESS_VERY_THIN"
		2.0:
			Profiles.get_current_settings().set_value(Settings.SV_STYLES_GRID_THICKNESS, UI.Thickness.TS_THIN)
			UI.get_named_element(UI.LABEL_STYLES_GRID_THICKNESS_INPUT).text = "SD_GAME_GRID_THICKNESS_THIN"
		3.0:
			Profiles.get_current_settings().set_value(Settings.SV_STYLES_GRID_THICKNESS, UI.Thickness.TS_STANDART)
			UI.get_named_element(UI.LABEL_STYLES_GRID_THICKNESS_INPUT).text = "SD_GAME_GRID_THICKNESS_STANDART"
		4.0:
			Profiles.get_current_settings().set_value(Settings.SV_STYLES_GRID_THICKNESS, UI.Thickness.TS_SEMIBOLD)
			UI.get_named_element(UI.LABEL_STYLES_GRID_THICKNESS_INPUT).text = "SD_GAME_GRID_THICKNESS_SEMIBOLD"
		5.0:
			Profiles.get_current_settings().set_value(Settings.SV_STYLES_GRID_THICKNESS, UI.Thickness.TS_BOLD)
			UI.get_named_element(UI.LABEL_STYLES_GRID_THICKNESS_INPUT).text = "SD_GAME_GRID_THICKNESS_BOLD"
	UI.get_game().update_grid_thickness()

#	Sounds

func _on_CB_SOUND_ENABLE_UI_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_UI_ENABLED, toggled)

func _on_CB_SOUND_ENABLE_MOVE_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_MOVE_ENABLED, toggled)

func _on_CB_SOUND_ENABLE_3D_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_3D_ENABLED, toggled)

func _on_CB_SOUND_ENABLE_SPEECH_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_SPEECH_ENABLED, toggled)

func _on_SLIDER_SPEECH_VOLUME_value_changed(value):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_SPEECH_VOLUME, value)
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/SoundSettings/SpeechBox/VBox/HBoxEnableSpeechSlider/LABEL_SPEECH_VOLUME.text = str(int(value))
	
func _on_CB_SOUND_ENABLE_CHECK_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_CHECK_ENABLED, toggled)

func _on_CB_SOUND_ENABLE_MUSIC_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_MUSIC_ENABLED, toggled)
	if !toggled:
		UI.music_player.pause()
	else:
		UI.music_player.play()

func _on_WIDGET_PREVIOUS_TRACK_pressed():
	UI.music_player.previous_track()

func _on_WIDGET_NEXT_TRACK_pressed():
	UI.music_player.next_track() 

func _on_SLIDER_MUSIC_VOLUME_value_changed(value):
	Profiles.get_current_settings().set_value(Settings.SV_SFX_MUSIC_VOLUME, value)
	UI.music_player.set_volume(value)

func _on_RB_SOUND_MUSIC_INORDER_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_SFX_MUSIC_ORDER, 0)

func _on_RB_SOUND_MUSIC_RANDOMIZE_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_SFX_MUSIC_ORDER, 1)

# Other

func _on_CB_GAME_SETUP_UNRATED_pressed():
	pass # Replace with function body.

func _on_InputHelpWidget_pressed():
	var kg = $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/InputSettings/DescControl
	if kg.visible:
		kg.hide()
	else:
		kg.show()
# Widgets

var _sansara_setup_toggled = false
var _clock_setup_toggled = false
var _qq_setup_toggled = false

# Sansara settings

func _on_CB_WIDGET_SANSARA_ENABLED_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_SANSARA_ENABLED, toggled)
	UI.get_widget(UI.WIDGET_THEME_SWITCH).visible = toggled

func _on_CB_SANSARA_ORDER_NEXT_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_SANSARA_ORDER, 0)

func _on_CB_SANSARA_ORDER_PREVIOUS_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_SANSARA_ORDER, 1)

func _on_CB_SANSARA_ORDER_RANDOM_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_SANSARA_ORDER, 2)

func _on_CB_SANSARA_ORDER_CUSTOM_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_SANSARA_ORDER, 3)

func _on_SansaraIcon_mouse_entered():
	UI.get_helper().show_tooltip("DESC_WIDGET_SANSARA", $SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/WidgetSettings/HBoxSansaraWidgetTitle/SansaraIcon)

func _on_SansaraIcon_mouse_exited():
	UI.get_helper().hide_tooltip()

func _on_BTN_SANSARA_SETUP_pressed():
	if !_sansara_setup_toggled:
		get_tree().call_group("sansara_settings", "show")
	else:
		get_tree().call_group("sansara_settings", "hide")
	_sansara_setup_toggled = !_sansara_setup_toggled

# Clock settings

func _on_CB_WIDGET_CLOCK_ENABLED_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_CLOCK_ENABLED, toggled)
	UI.get_widget(UI.WIDGET_CLOCK).visible = toggled

func _on_BTN_CLOCK_SETUP_pressed():
	if !_clock_setup_toggled:
		get_tree().call_group("clock_settings", "show")
	else:
		get_tree().call_group("clock_settings", "hide")
	_clock_setup_toggled = !_clock_setup_toggled
	
func _on_RB_CLOCK_FORMAT_24_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_CLOCK_FORMAT, 0)
	UI.get_widget(UI.WIDGET_CLOCK).set_format(0)

func _on_RB_CLOCK_FORMAT_12_pressed():
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_CLOCK_FORMAT, 1)
	UI.get_widget(UI.WIDGET_CLOCK).set_format(1)

func _on_CB_CLOCK_SHOW_SECONDS_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_CLOCK_SECONDS_ENABLED, toggled)
	UI.get_widget(UI.WIDGET_CLOCK).set_show_seconds(toggled)

func _on_CB_CLOCK_SHOW_ZEROES_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_CLOCK_ZEROES_ENABLED, toggled)
	UI.get_widget(UI.WIDGET_CLOCK).set_show_zeroes(toggled)

# Quit widget

func _on_CB_WIDGET_QUIT_ENABLED_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_QQ_ENABLED, toggled)
	UI.get_widget(UI.WIDGET_QUICK_QUIT).visible = toggled

func _on_BTN_QUIT_SETUP_pressed():
	if !_qq_setup_toggled:
		get_tree().call_group("qq_settings", "show")
	else:
		get_tree().call_group("qq_settings", "hide")
	_qq_setup_toggled = !_qq_setup_toggled

func _on_CB_QQ_SHOW_DIALOG_toggled(toggled):
	Profiles.get_current_settings().set_value(Settings.SV_WIDGET_QQ_DIALOG_ENABLED, toggled)

func _on_UsernameLE_text_changed(new_text):
	Profiles.get_current_profile().nickname = new_text

func _on_PanelTransparency_value_changed(value):
	Profiles.set_value(Settings.SV_UI_PANEL_TRANSPARENCY, int(value))
	var t = str(int((value / 255.0) * 100.0)) + "%"
	$SimpleLayout/GBox/HBox/Section/Panel/VBox/Box/VBox/HBox/UISettings/MiscBox/VBox/HBoxPanelTransparency/PanelTransparencyLabel.text = t
	
	var a = float(255 - value) / 255.0
	
	UI.get_history().self_modulate.a = a
	UI.get_game().gui.ai_log_panel.self_modulate.a = a
	UI.get_game().gui.piece_style_panel.self_modulate.a = a

# Master server settings event handlers

func _on_MasterIPV4RadioBox_pressed():
	Profiles.set_value(Settings.SV_MASTER_USE_IPV6, false)

func _on_MasterIPV4Box1_value_changed(value):
	Profiles.set_value(Settings.SV_MASTER_IPV4_1, int(value))

func _on_MasterIPV4Box2_value_changed(value):
	Profiles.set_value(Settings.SV_MASTER_IPV4_2, int(value))

func _on_MasterIPV4Box3_value_changed(value):
	Profiles.set_value(Settings.SV_MASTER_IPV4_3, int(value))

func _on_MasterIPV4Box4_value_changed(value):
	Profiles.set_value(Settings.SV_MASTER_IPV4_4, int(value))

func _on_MasterIPV6RadioBox_pressed():
	Profiles.set_value(Settings.SV_MASTER_USE_IPV6, true)

func _on_MasterIPV6Box_text_entered(new_text):
	Profiles.set_value(Settings.SV_MASTER_IPV6, new_text)
	
func _on_MasterIPV6Box_text_changed(new_text):
	Profiles.set_value(Settings.SV_MASTER_IPV6, new_text)
	
func _on_MasterPortBox_value_changed(value):
	Profiles.set_value(Settings.SV_MASTER_PORT, int(value))


