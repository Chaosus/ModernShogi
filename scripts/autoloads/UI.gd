extends Node

# UI.gd

# Список элементов

enum {
	GUI_DLG_LEAVE,
	GUI_DLG_LEAVE2,
	GUI_DLG_PROMOTION,
	GUI_DLG_RESIGN,
	GUI_DLG_GAMEOVER,
	GUI_DLG_SAVE,
	GUI_DLG_TAKEBACK,
	GUI_DLG_SERVER_SHUTDOWN
}

enum {
	
	# UI settings
	
	RB_UI_LANGUAGE_ENGLISH,
	RB_UI_LANGUAGE_RUSSIAN,
	RB_UI_LANGUAGE_CHINESE,
	RB_UI_LANGUAGE_JAPANESE,
	
	RB_UI_THEME_REALM_OF_GODS,
	RB_UI_THEME_REALM_OF_TITANS,
	RB_UI_THEME_REALM_OF_HUMANS,
	RB_UI_THEME_REALM_OF_ANIMALS,
	RB_UI_THEME_REALM_OF_GHOSTS,
	RB_UI_THEME_REALM_OF_SINNERS,
	
	RB_UI_FONT_MODERN,
	RB_UI_FONT_FRIENDLY,
	
	CB_UI_FONT_OUTLINE,
	CB_UI_TIPS_BUTTON,
	SR_UI_PANEL_TRANSPARENCY,
	
	# AI settings
	
	OB_AI_ENGINE_NAME,
	OB_AI_ENGINE_EXE,
	SR_AI_SKILL_LEVEL,
	SR_AI_SKILL_LEVEL2,
	LABEL_AI_SKILL_LEVEL,
	LABEL_AI_SKILL_LEVEL2,
	CB_AI_ENABLE_LOG,
	
	# Gameplay settings
	
	CB_GAME_AUTOMOVE,
	CB_GAME_AUTOPROMOTION,
	CB_GAME_LASTMOVE,
	CB_GAME_CASTLES,
	RB_GAME_AUTOSHOW_DISABLED,
	RB_GAME_AUTOSHOW_MYSELF,
	RB_GAME_AUTOSHOW_ALL,
	
	# History settings
	
	CB_HISTORY_AUTO_SHOW,
	SR_HISTORY_PANEL_SIZE,
	SB_HISTORY_ELEMENT_COUNT,
	CB_HISTORY_AUTO_SCROLL,
	CB_HISTORY_TURN_SYMBOL,
	RB_HISTORY_PANEL_CLASSIC,
	RB_HISTORY_PANEL_CHESS,
	CB_HISTORY_REVERT_BUTTON,
	RB_HISTORY_PLAYBACK_FROM_REPLAY,
	RB_HISTORY_PLAYBACK_FIXED_DURATION,
	SR_HISTORY_PLAYBACK_FIXED_DURATION,
	LABEL_HISTORY_PLAYBACK_FIXED_DURATION,
	RB_HISTORY_NOTATION_JAPANESE,
	RB_HISTORY_NOTATION_SHORT,
	RB_HISTORY_NOTATION_FULL,
	CB_HISTORY_Y_NUM,
	RB_HISTORY_SYMBOLS_JP,
	RB_HISTORY_SYMBOLS_EN,
	
	# Camera settings
	
	CB_CAMERA_ALLOW_YAW,
	CB_CAMERA_ALLOW_PITCH,
	CB_CAMERA_ALLOW_ZOOM,
	CB_CAMERA_ALLOW_PAN,
	CB_CAMERA_SWITCH_SIDES,
	CB_CAMERA_RESTRICT_YAW,
	
	# Styles settings
	
	CHECKBOX_STYLES_UI_COLORING,
	CHECKBOX_STYLES_CHESS_COLORING,
	CHECKBOX_STYLES_ZONES_COLORING,
	CHECKBOX_STYLES_GRID_COLOR_BLACK,
	CHECKBOX_STYLES_GRID_COLOR_WHITE,
	CHECKBOX_STYLES_BOARD_MARKUP,
	SLIDER_STYLES_GRID_THICKNESS,
	LABEL_STYLES_GRID_THICKNESS_INPUT,
	
	# Sound settings
	
	CHECKBOX_SFX_UI_ENABLED,
	CHECKBOX_SFX_MOVE_ENABLED,
	CHECKBOX_SFX_3D_ENABLED,
	CHECKBOX_SFX_CHECK_ENABLED,
	CHECKBOX_SFX_SPEECH_ENABLED,
	CHECKBOX_SFX_MUSIC_ENABLED,
	SLIDER_SOUND_VOLUME,
	SLIDER_SOUND_SPEECH_VOLUME,
	SLIDER_SOUND_MUSIC_VOLUME,
	LABEL_CURRENT_SONG,
	RB_MUSIC_PLAYORDER_NEXT,
	RB_MUSIC_PLAYORDER_RANDOMIZE,
	
	# Widgets settings
	
	CB_WIDGETS_SANSARA_ENABLED,
	RB_WIDGETS_SANSARA_ORDER_NEXT,
	RB_WIDGETS_SANSARA_ORDER_PREVIOUS,
	CB_WIDGETS_DARKMODE_ENABLED,
	CB_WIDGETS_CLOCK_ENABLED,
	CB_WIDGETS_CLOCK_SECONDS_ENABLED,
	RB_WIDGETS_CLOCK_FORMAT_24,
	RB_WIDGETS_CLOCK_FORMAT_12,
	CB_WIDGETS_MUSICPLAYER_ENABLED,
	CB_WIDGETS_QQ_ENABLED,
	CB_WIDGETS_QQ_DIALOG_ENABLED,
	
	# Other settings
	RB_MASTER_USE_IPV4,
	RB_MASTER_USE_IPV6,
	SB_MASTER_IPV4_1,
	SB_MASTER_IPV4_2,
	SB_MASTER_IPV4_3,
	SB_MASTER_IPV4_4,
	LE_MASTER_IPV6,
	CB_LOOPBACK,
	SB_MASTER_PORT,
	LE_PROFILE_NAME,
	
	# Экран входа на сервер
	LE_MP_USERNAME,
	LE_MP_PASSWORD,
	CB_MP_SAVE_PASSWORD,
	BTN_SIGNUP,
	BTN_RESTORE_PASSWORD,
	
	# Экраны
	
	SCREEN_LOGO,
	SCREEN_FIRST,
	SCREEN_MAIN_MENU,
	SCREEN_SETTINGS,
	SCREEN_LIBRARY,
	SCREEN_LOADING,
	SCREEN_LOADGAME,
	SCREEN_SETUP,
	SCREEN_HOST,
	SCREEN_JOIN_IP,
	SCREEN_LOGIN,
	SCREEN_SERVER,
	SCREEN_ACCOUNT,
	SCREEN_QUIT_CONFIRMATION,
	SCREEN_GOODBAY,
	SCREEN_EXTRAS,
	SCREEN_SELECT_COUNTRY,
	SCREEN_SELECT_AVATAR,
	SCREEN_SELECT_COLOR,
	SCREEN_GAME
}

enum Screens {
	LOGO,
	FIRST,
	MAIN_MENU,
	SETTINGS,
	LIBRARY,
	LOADING,
	NEWGAME
	SETUP,
	HOST,
	JOIN,
	QUIT_CONFIRMATION,
	GOODBAY,
	EXTRAS,
	SELECT_COUNTRY,
	SELECT_AVATAR,
	SELECT_COLOR,
	GAME
}

var scale
var _ver_str

func get_current_peer():
	return get_tree().get_network_peer()

var server_list_enabled = false

func set_version(text):
	_ver_str = text

func get_version():
	return _ver_str

# Контроль звука

var sfx_player
var music_player

# Контроль экрана

var screen_center
var unsupported_res = false

func set_clear_color(color):
	VisualServer.set_default_clear_color(color)

# Контроль игры

var dialog_visible = false
var ai_panel
var ai_log_panel
var ai_log_hidden = false
var piece_style_hidden = false

var key_enter_mode = false

# Контроль темы

var themes = {}
var sansara_order = 0

enum UITheme {
	REALM_OF_SINNERS,
	REALM_OF_GHOSTS,
	REALM_OF_ANIMALS,
	REALM_OF_HUMANS,
	REALM_OF_TITANS,
	REALM_OF_GODS,
	LIMITER
}

const UI_THEME_DEFAULT = 3;

enum FLATBOX_SIDES {
	FBOX_NORMAL,
	FBOX_WITHOUT_RIGHT,
	FBOX_WITHOUT_TOP
}

var input_list

func create_flatbox_without_right_side(bg_color, border_color, border_width, corner_radius = 0, left_offset = -1, top_offset = -1):
	var box = StyleBoxFlat.new()
	box.bg_color = bg_color
	box.border_color = border_color
	box.border_width_left = border_width
	box.border_width_top = border_width
	box.border_width_right = 0
	box.border_width_bottom = border_width
	if corner_radius > 0:
		box.corner_radius_top_left = corner_radius
		box.corner_radius_top_right = corner_radius
		box.corner_radius_bottom_left = corner_radius
		box.corner_radius_bottom_right = corner_radius
		box.corner_detail = 8
	box.content_margin_left = left_offset
	box.content_margin_top = top_offset
	return box

func create_flatbox_without_top_side(bg_color, border_color, border_width, corner_radius = 0, left_offset = -1, top_offset = -1):
	var box = StyleBoxFlat.new()
	box.bg_color = bg_color
	box.border_color = border_color
	box.border_width_left = border_width
	box.border_width_top = 0
	box.border_width_right = 0
	box.border_width_bottom = border_width
	if corner_radius > 0:
		box.corner_radius_top_left = corner_radius
		box.corner_radius_top_right = corner_radius
		box.corner_radius_bottom_left = corner_radius
		box.corner_radius_bottom_right = corner_radius
		box.corner_detail = 8
	box.content_margin_left = left_offset
	box.content_margin_top = top_offset
	return box

func create_flatbox(bg_color, border_color, border_width, corner_radius = 0, left_offset = -1, top_offset = -1):
	var box = StyleBoxFlat.new()
	box.bg_color = bg_color
	box.border_color = border_color
	box.border_width_left = border_width
	box.border_width_top = border_width
	box.border_width_right = border_width
	box.border_width_bottom = border_width
	if corner_radius > 0:
		box.corner_radius_top_left = corner_radius
		box.corner_radius_top_right = corner_radius
		box.corner_radius_bottom_left = corner_radius
		box.corner_radius_bottom_right = corner_radius
		box.corner_detail = 8
	box.content_margin_left = left_offset
	box.content_margin_top = top_offset
	return box

func _create_theme(data, current_index = 0):
	var empty_flat_box = StyleBoxEmpty.new()
	
	var mbox = create_flatbox(data.background_color, data.element_color, 0)
	var treebox = mbox
	var treebox2 = create_flatbox_without_right_side(data.background_color, data.element_hover_color, 4)
	var box = create_flatbox(data.background_color, data.element_color, 2)
	var cbox = create_flatbox(data.background_color, data.element_color, 2, 0, 20, 20)
	var fbox = create_flatbox(data.background_color, data.element_hover_color, 4, 0, 20, 20)
	var pbox = create_flatbox(data.background_color, data.element_hover_color, 2)
	var rbox = create_flatbox(data.background_color, data.element_color, 2, 20)
	
	var theme = Theme.new()
	
	var _font
	var _appbar
	var _big
	var _medium
	var _small
	_font = preload("res://fonts/modern.tres")
	_appbar = preload("res://fonts/modern_appbar.tres")
	_big = preload("res://fonts/modern_big.tres")
	_medium = preload("res://fonts/modern_medium.tres")
	_small = preload("res://fonts/modern_small.tres")
	
	data.element_disabled_color = data.element_pressed_color.darkened(0.15)
	
	theme.default_font = _font
	theme.set_font("medium_font", "Main", _medium)
	theme.set_font("small_font", "Main", _small)
	theme.set_font("appbar_font", "Main", _appbar)
	theme.set_color("appbar_color", "Main", data.appbar_color)
	theme.set_color("panel_color", "Main", data.panel_color)
	theme.set_color("background_color", "Main", data.background_color)
	theme.set_color("element_color", "Main", data.element_color)
	theme.set_color("element_hover_color", "Main", data.element_hover_color)
	theme.set_color("element_pressed_color", "Main", data.element_pressed_color)
	theme.set_color("element_disabled_color", "Main", data.element_disabled_color)
	theme.set_color("board_color", "Game", data.board_color)
	theme.set_color("board_color2", "Game", data.board_color2)
	
	# Button
	
	var button_color_color = data.element_color
	var button_color_disabled_color = data.element_disabled_color
	var button_color_hover = data.element_hover_color
	var button_color_pressed = data.element_pressed_color
	
	theme.set_color("font_color", "Button", button_color_color)
	theme.set_color("font_color_disabled", "Button", button_color_disabled_color)
	theme.set_color("font_color_hover", "Button", button_color_hover)
	theme.set_color("font_color_pressed", "Button", button_color_pressed)
	
	theme.set_font("big_font", "Button", _big)
	theme.set_font("medium_font", "Button", _medium)
	
	var button_big_focus = empty_flat_box
	var button_big_normal = rbox
	var button_disabled = empty_flat_box
	var button_focus = empty_flat_box
	var button_hover = empty_flat_box
	var button_normal = empty_flat_box
	var button_pressed = empty_flat_box
	
	theme.set_stylebox("big_focus", "Button", button_big_focus)
	theme.set_stylebox("big_normal", "Button", button_big_normal)
	theme.set_stylebox("disabled", "Button", button_disabled)
	theme.set_stylebox("focus", "Button", button_focus)
	theme.set_stylebox("hover", "Button", button_hover)
	theme.set_stylebox("normal", "Button", button_normal)
	theme.set_stylebox("pressed", "Button", button_pressed)
	
	# CheckBox
	
	var checkbox_color = data.element_color
	var checkbox_color_disabled_color = data.element_color - Color(0, 0, 0, 0.5)
	var checkbox_color_hover = data.element_hover_color
	var checkbox_color_pressed = data.element_pressed_color
	
	theme.set_color("font_color", "CheckBox", checkbox_color)
	theme.set_color("font_color_disabled", "CheckBox", checkbox_color_disabled_color)
	theme.set_color("font_color_hover", "CheckBox", checkbox_color_hover)
	theme.set_color("font_color_pressed", "CheckBox", checkbox_color_pressed)
	
	theme.set_constant("hseparation", "CheckBox", 20)
	
	theme.set_icon("unchecked", "CheckBox", data.cb0)
	theme.set_icon("checked", "CheckBox", data.cb1)
	theme.set_icon("radio_unchecked", "CheckBox", data.rb0)
	theme.set_icon("radio_checked", "CheckBox", data.rb1)
	
	theme.set_icon("radio_unchecked", "PopupMenu", data.rb0)
	theme.set_icon("radio_checked", "PopupMenu", data.rb1)
	
	theme.set_stylebox("disabled", "CheckBox", empty_flat_box)
	theme.set_stylebox("focus", "CheckBox", empty_flat_box)
	theme.set_stylebox("hover", "CheckBox", empty_flat_box)
	theme.set_stylebox("normal", "CheckBox", empty_flat_box)
	theme.set_stylebox("pressed", "CheckBox", empty_flat_box)
	
	# CheckButton
	
	theme.set_constant("hseparation", "CheckButton", 40)
	theme.set_icon("off", "CheckButton", data.cbn0)
	theme.set_icon("on", "CheckButton", data.cbn1)
	
	# SpinBox
	
	theme.set_icon("updown", "SpinBox", data.updown)
	
	# OptionButton
	
	theme.set_stylebox("normal", "OptionButton", box)
	theme.set_stylebox("hover", "OptionButton", pbox)
	
	#theme.set_icon("arrow","OptionButton", data.cb0)
	
	# GridContainer
	
	theme.set_constant("hseparation", "GridContainer", 0)
	theme.set_constant("vseparation", "GridContainer", 0)
	
	# ItemList
	
	theme.set_color("font_color", "ItemList", data.element_color)
	theme.set_color("font_color_selected", "ItemList", data.element_hover_color)
	theme.set_stylebox("bg", "ItemList", box)
	theme.set_stylebox("bg_focus", "ItemList", fbox)
	
	# Label
	
	theme.set_color("font_color", "Label", data.element_color)
	theme.set_color("font_color_shadow", "Label", Color("00000000"))
	theme.set_font("appbar", "Label", preload("res://material/fonts/appbar_font.tres"))
	
	# LineEdit
	
	theme.set_color("cursor_color", "LineEdit", data.element_color)
	theme.set_color("font_color", "LineEdit", data.element_color)
	theme.set_color("font_color_selected", "LineEdit", data.element_color)
	theme.set_color("selection_color", "LineEdit", data.element_hover_color)
	
	var content_offset = 15
	
	theme.set_constant("minimum_spaces", "LineEdit", 12)
	theme.set_stylebox("focus", "LineEdit", create_flatbox(data.background_color, data.element_hover_color, 4, 0, content_offset))
	theme.set_stylebox("normal", "LineEdit", create_flatbox(data.background_color, data.element_color, 2, 0, content_offset))
	theme.set_stylebox("read_only", "LineEdit", create_flatbox(data.element_color - Color(0, 0, 0, 0.5), data.element_color, 2, 0, content_offset))
	
	# PanelContainer
	
	var appbar = StyleBoxFlat.new()
	appbar.bg_color = data.appbar_color
	
	var background = StyleBoxFlat.new()
	background.bg_color = data.background_color
	
	var panel = StyleBoxFlat.new()
	panel.bg_color = data.panel_color
	
	theme.set_stylebox("appbar", "PanelContainer", appbar)
	theme.set_stylebox("background", "PanelContainer", background)
	theme.set_stylebox("panel", "PanelContainer", panel)
	
	# PopupPanel
	
	theme.set_stylebox("panel", "PopupPanel", box)
	theme.set_stylebox("panel", "PopupMenu", box)
	theme.set_color("font_color", "PopupMenu", data.element_color)
	
	# RichTextLabel
	
	theme.set_color("default_color", "RichTextLabel", data.element_color)
	theme.set_color("font_color_selected", "RichTextLabel", data.element_pressed_color)
	theme.set_color("selection_color", "RichTextLabel", data.element_hover_color)
	theme.set_stylebox("focus", "RichTextLabel", create_flatbox(data.background_color, data.element_hover_color, 4, 0, content_offset, content_offset))
	theme.set_stylebox("normal", "RichTextLabel", create_flatbox(data.background_color, data.element_color, 2, 0, content_offset, content_offset))
	
	# TextEdit
	theme.set_color("selection_color", "TextEdit", data.element_pressed_color)
	theme.set_color("word_highlighted_color", "TextEdit", data.element_color.inverted())
	theme.set_color("font_color", "TextEdit", data.element_color)
	theme.set_stylebox("normal", "TextEdit", cbox)
	theme.set_stylebox("focus", "TextEdit", fbox)
	
	# Tree
	
	theme.set_icon("arrow", "Tree", data.fr0)
	theme.set_icon("arrow_collapsed", "Tree", data.fr1)
	
	theme.set_constant("item_margin", "Tree", 40)
	 
	theme.set_color("font_color", "Tree", data.element_color)
	theme.set_color("font_color_selected", "Tree", data.element_hover_color)
	theme.set_color("guide_color", "Tree", data.element_color - Color(0,0,0,0.2))
	#theme.set_color("relationship_line_color", "Tree", data.element_color)
	
	theme.set_stylebox("bg", "Tree", treebox)
	theme.set_stylebox("bg_focus", "Tree", treebox)
	theme.set_stylebox("selected", "Tree", treebox2)
	theme.set_stylebox("selected_focus", "Tree", treebox2)
	
	# HSlider
	
	theme.set_icon("grabber", "HSlider", data.hs_grabber)
	theme.set_icon("grabber_highlight", "HSlider", data.hs_grabber_highlight)
	var hs_line = StyleBoxLine.new()
	hs_line.color = data.element_pressed_color
	hs_line.thickness = 5
	theme.set_stylebox("grabber_area", "HSlider", hs_line) 
	var hs_slider = StyleBoxLine.new()
	hs_slider.color = data.panel_color.darkened(0.5)
	hs_slider.thickness = 5
	theme.set_stylebox("slider", "HSlider", hs_slider) 
	
	# HSeparator
	
	theme.set_constant("separation", "HSeparator", 0)
	var hseparator = StyleBoxLine.new()
	hseparator.color = data.element_color
	hseparator.thickness = 2
	hseparator.vertical = false
	theme.set_stylebox("separator", "HSeparator", hseparator)
	
	var hseparator2 = StyleBoxLine.new()
	hseparator2.color = data.element_color
	hseparator2.thickness = 2
	hseparator2.vertical = false
	theme.set_stylebox("helper_separator", "HSeparator", hseparator2)
	
	# VSeparator
	
	theme.set_constant("separation", "VSeparator", 0)
	
	var vseparator = StyleBoxLine.new()
	vseparator.color = data.element_color
	vseparator.thickness = 2
	vseparator.vertical = true
	vseparator.grow_end = 0
	vseparator.grow_begin = 0
	theme.set_stylebox("separator", "VSeparator", vseparator)
	
	var vseparator2 = StyleBoxLine.new()
	vseparator2.color = data.element_color
	vseparator2.thickness = 2
	vseparator2.vertical = true
	vseparator2.grow_end = 0
	vseparator2.grow_begin = 0
	theme.set_stylebox("widget_separator", "VSeparator", vseparator2)
	
	# VScrollBar
	
	var vsbar_grabber = StyleBoxFlat.new()
	vsbar_grabber.bg_color = data.element_hover_color
	theme.set_stylebox("grabber", "VScrollBar", vsbar_grabber)
	var vsbar_grabber_highlight = StyleBoxFlat.new()
	vsbar_grabber_highlight.bg_color = data.element_hover_color
	theme.set_stylebox("grabber_highlight", "VScrollBar", vsbar_grabber_highlight)
	var vsbar_grabber_pressed = StyleBoxFlat.new()
	vsbar_grabber_pressed.bg_color = data.element_pressed_color
	theme.set_stylebox("grabber_pressed", "VScrollBar", vsbar_grabber_pressed)
	var vsscroll = StyleBoxFlat.new()
	vsscroll.bg_color = data.element_hover_color
	vsscroll.draw_center = true
	vsscroll.border_width_left = 15
	vsscroll.border_width_right = 15
	vsscroll.border_color = data.appbar_color
	theme.set_stylebox("scroll", "VScrollBar", vsscroll)
	
	# HScrollBar
	
	var hsbar_grabber = StyleBoxFlat.new()
	hsbar_grabber.bg_color = data.element_hover_color
	theme.set_stylebox("grabber", "HScrollBar", hsbar_grabber)
	var hsbar_grabber_highlight = StyleBoxFlat.new()
	hsbar_grabber_highlight.bg_color = data.element_hover_color
	theme.set_stylebox("grabber_highlight", "HScrollBar", hsbar_grabber_highlight)
	var hsbar_grabber_pressed = StyleBoxFlat.new()
	hsbar_grabber_pressed.bg_color = data.element_pressed_color
	theme.set_stylebox("grabber_pressed", "HScrollBar", hsbar_grabber_pressed)
	var hsscroll = StyleBoxFlat.new()
	hsscroll.bg_color = data.element_hover_color
	hsscroll.draw_center = true
	hsscroll.border_width_top = 15
	hsscroll.border_width_bottom = 15
	hsscroll.border_color = data.appbar_color
	theme.set_stylebox("scroll", "HScrollBar", hsscroll)
	
	# HBoxContainer / VBoxContainer
	
	theme.set_constant("separation", "VBoxContainer", 45)
	
	# Box theme
	
	var small_font = preload("res://material/fonts/small_font.tres")
	var box_style = create_flatbox_without_top_side(data.panel_color, data.element_color, 1)
	var box_theme = Theme.new()
	box_theme.default_font = small_font
	box_theme.set_constant("separation", "HBoxContainer", 0)
	box_theme.set_stylebox("panel", "PanelContainer", box_style)
	
	var st = SubTheme.new()
	st.theme = theme
	st.box_theme = box_theme
	st.background_i = data.background_i
	
	if themes.has(data.tag):
		themes[data.tag].aspects.append(st)
	else:
		var t = GameTheme.new()
		t.data = data
		t.current_aspect = current_index
		t.aspects.append(st)
		themes[data.tag] = t
		
	return theme

class SubTheme:
	var theme
	var box_theme
	var background_i

class GameTheme:
	func theme():
		return aspects[0]
	var current_aspect
	var data
	var aspects = []

class ThemeData:
	var tag
	var name
	var appbar_color
	var panel_color
	var header_color
	var background_color
	var background_i
	var board_color
	var board_color2
	var element_color
	var element_hover_color
	var element_pressed_color
	var element_disabled_color
	var updown
	var cb0
	var cb1
	var cbn0
	var cbn1
	var rb0
	var rb1
	var fr0
	var fr1
	var hs_grabber
	var hs_grabber_highlight

func init_themes():
	
	var realm_of_sinners = ThemeData.new()
	realm_of_sinners.cbn0 = preload("res://sansara/icons/white/checkbtn0.png")
	realm_of_sinners.cbn1 = preload("res://sansara/icons/white/checkbtn1.png")
	realm_of_sinners.cb0 = preload("res://sansara/icons/white/checkbox0.png")
	realm_of_sinners.rb0 = preload("res://sansara/icons/white/radio0.png")
	realm_of_sinners.fr0 = preload("res://sansara/icons/white/list_down.png")
	realm_of_sinners.fr1 = preload("res://sansara/icons/white/list_up.png")
	realm_of_sinners.hs_grabber = preload("res://sansara/icons/white/slider0.png")
	realm_of_sinners.hs_grabber_highlight = preload("res://sansara/icons/white/slider1.png")
	realm_of_sinners.updown = preload("res://sansara/icons/white/updown.png")
	
	realm_of_sinners.tag = UITheme.REALM_OF_SINNERS
	realm_of_sinners.name = "UI_THEME_REALM_OF_SINNERS"
	realm_of_sinners.appbar_color = Color("232323")
	realm_of_sinners.panel_color = Color("1C1C1C")
	realm_of_sinners.background_color = Color("121212")
	realm_of_sinners.background_i = 0.88
	realm_of_sinners.board_color = Color("707070")
	realm_of_sinners.board_color2 = Color("303030")
	
	realm_of_sinners.cb1 = preload("res://sansara/icons/white/checkbox1_orange.png")
	realm_of_sinners.rb1 = preload("res://sansara/icons/white/radio1_orange.png")
	realm_of_sinners.element_color = Color("FFFFFF")
	realm_of_sinners.element_pressed_color = Color("FF8000")
	realm_of_sinners.element_hover_color = realm_of_sinners.element_pressed_color
	_create_theme(realm_of_sinners)
	
	realm_of_sinners.cb1 = preload("res://sansara/icons/white/checkbox1_crimson.png")
	realm_of_sinners.rb1 = preload("res://sansara/icons/white/radio1_crimson.png")
	realm_of_sinners.element_pressed_color = Color("CC3333")
	realm_of_sinners.element_hover_color = realm_of_sinners.element_pressed_color
	_create_theme(realm_of_sinners)
	
	realm_of_sinners.cb1 = preload("res://sansara/icons/white/checkbox1_green.png")
	realm_of_sinners.rb1 = preload("res://sansara/icons/white/radio1_green.png")
	realm_of_sinners.element_pressed_color = Color("4CFF00")
	realm_of_sinners.element_hover_color = realm_of_sinners.element_pressed_color #Color("808080")
	_create_theme(realm_of_sinners)
	
	realm_of_sinners.cb1 = preload("res://sansara/icons/white/checkbox1.png")
	realm_of_sinners.rb1 = preload("res://sansara/icons/white/radio1.png")
	realm_of_sinners.element_color = Color("FFFFFF").darkened(0.3)
	realm_of_sinners.element_pressed_color = Color("FFFFFF")
	realm_of_sinners.element_hover_color = realm_of_sinners.element_pressed_color
	_create_theme(realm_of_sinners)
	
	var realm_of_ghosts = ThemeData.new()
	realm_of_ghosts.tag = UITheme.REALM_OF_GHOSTS
	realm_of_ghosts.name = "UI_THEME_REALM_OF_GHOSTS"
	realm_of_ghosts.appbar_color = Color("1b0000")
	realm_of_ghosts.panel_color = Color("321911")
	realm_of_ghosts.background_color = Color("40241a")
	realm_of_ghosts.background_i = 0.88
	realm_of_ghosts.element_color = Color("FF9600")
	realm_of_ghosts.element_hover_color = Color("FFBF00")
	realm_of_ghosts.element_pressed_color = Color("FFFF00")
	realm_of_ghosts.board_color = Color("FFE97F")
	realm_of_ghosts.board_color2 = Color("FFE97F").darkened(0.4)
	realm_of_ghosts.cb0 = preload("res://sansara/icons/orange/checkbox0.png")
	realm_of_ghosts.cb1 = preload("res://sansara/icons/orange/checkbox1.png")
	realm_of_ghosts.cbn0 = preload("res://sansara/icons/orange/checkbtn0.png")
	realm_of_ghosts.cbn1 = preload("res://sansara/icons/orange/checkbtn1.png")
	realm_of_ghosts.rb0 = preload("res://sansara/icons/orange/radio0.png")
	realm_of_ghosts.rb1 = preload("res://sansara/icons/orange/radio1.png")
	realm_of_ghosts.fr0 = preload("res://sansara/icons/orange/list_down.png")
	realm_of_ghosts.fr1 = preload("res://sansara/icons/orange/list_up.png")
	realm_of_ghosts.hs_grabber = preload("res://sansara/icons/orange/slider0.png")
	realm_of_ghosts.hs_grabber_highlight = preload("res://sansara/icons/orange/slider1.png")
	realm_of_ghosts.updown = preload("res://sansara/icons/orange/updown.png")
	_create_theme(realm_of_ghosts)
	
	var realm_of_animals = ThemeData.new()
	realm_of_animals.tag = UITheme.REALM_OF_ANIMALS
	realm_of_animals.name = "UI_THEME_REALM_OF_ANIMALS"
	realm_of_animals.appbar_color = Color("003D00")
	realm_of_animals.panel_color = Color("295F14")
	realm_of_animals.background_color = Color("33691E")
	realm_of_animals.background_i = 0.88
	realm_of_animals.element_color = Color("87FF77")
	realm_of_animals.element_hover_color = Color("4CCD00")
	realm_of_animals.element_pressed_color = Color("4CFF00")
	realm_of_animals.board_color = Color("CCFF90")
	realm_of_animals.board_color2 = Color("008000")
	realm_of_animals.cb0 = preload("res://sansara/icons/green/checkbox0.png")
	realm_of_animals.cb1 = preload("res://sansara/icons/green/checkbox1.png")
	realm_of_animals.cbn0 = preload("res://sansara/icons/green/checkbtn0.png")
	realm_of_animals.cbn1 = preload("res://sansara/icons/green/checkbtn1.png")
	realm_of_animals.rb0 = preload("res://sansara/icons/green/radio0.png")
	realm_of_animals.rb1 = preload("res://sansara/icons/green/radio1.png")
	realm_of_animals.fr0 = preload("res://sansara/icons/green/list_down.png")
	realm_of_animals.fr1 = preload("res://sansara/icons/green/list_up.png")
	realm_of_animals.hs_grabber = preload("res://sansara/icons/green/slider0.png")
	realm_of_animals.hs_grabber_highlight = preload("res://sansara/icons/green/slider1.png")
	realm_of_animals.updown = preload("res://sansara/icons/green/updown.png")
	_create_theme(realm_of_animals)
	
	var realm_of_humans = ThemeData.new()
	realm_of_humans.tag = UITheme.REALM_OF_HUMANS
	realm_of_humans.name = "UI_THEME_REALM_OF_HUMANS"
	realm_of_humans.appbar_color = Color("002171")
	realm_of_humans.panel_color = Color("0D47A1")
	realm_of_humans.background_color = Color("5472D3")
	realm_of_humans.background_i = 0.88
	realm_of_humans.element_color = Color("C6FFFF")
	realm_of_humans.element_hover_color = Color("7FC9FF")
	realm_of_humans.element_pressed_color = Color("7FFFFF")
	realm_of_humans.board_color = Color("A17FFF")
	realm_of_humans.board_color2 = Color("21007F")
	realm_of_humans.cb0 = preload("res://sansara/icons/cyan/checkbox0.png")
	realm_of_humans.cb1 = preload("res://sansara/icons/cyan/checkbox1.png")
	realm_of_humans.cbn0 = preload("res://sansara/icons/cyan/checkbtn0.png")
	realm_of_humans.cbn1 = preload("res://sansara/icons/cyan/checkbtn1.png")
	realm_of_humans.rb0 = preload("res://sansara/icons/cyan/radio0.png")
	realm_of_humans.rb1 = preload("res://sansara/icons/cyan/radio1.png")
	realm_of_humans.fr0 = preload("res://sansara/icons/cyan/list_down.png")
	realm_of_humans.fr1 = preload("res://sansara/icons/cyan/list_up.png")
	realm_of_humans.hs_grabber = preload("res://sansara/icons/cyan/slider0.png")
	realm_of_humans.hs_grabber_highlight = preload("res://sansara/icons/cyan/slider1.png")
	realm_of_humans.updown = preload("res://sansara/icons/white/updown.png")
	_create_theme(realm_of_humans)
	
	var realm_of_titans = ThemeData.new()
	realm_of_titans.tag = UITheme.REALM_OF_TITANS
	realm_of_titans.name = "UI_THEME_REALM_OF_TITANS"
	realm_of_titans.appbar_color = Color("7F0000")
	realm_of_titans.panel_color = Color("B71C1C")
	realm_of_titans.background_color = Color("F05545")
	realm_of_titans.background_i = 0.88
	realm_of_titans.element_color = Color("FFFFFF")
	realm_of_titans.element_hover_color = Color("FFB870")
	realm_of_titans.element_pressed_color = Color("FFFF8D")
	realm_of_titans.board_color = Color("F05545")
	realm_of_titans.board_color2 = Color("7F0000")
	realm_of_titans.cb0 = preload("res://sansara/icons/white/checkbox0.png")
	realm_of_titans.cb1 = preload("res://sansara/icons/white/checkbox1.png")
	realm_of_titans.cbn0 = preload("res://sansara/icons/white/checkbtn0.png")
	realm_of_titans.cbn1 = preload("res://sansara/icons/white/checkbtn1.png")
	realm_of_titans.rb0 = preload("res://sansara/icons/white/radio0.png")
	realm_of_titans.rb1 = preload("res://sansara/icons/white/radio1.png")
	realm_of_titans.fr0 = preload("res://sansara/icons/white/list_down.png")
	realm_of_titans.fr1 = preload("res://sansara/icons/white/list_up.png")
	realm_of_titans.hs_grabber = preload("res://sansara/icons/white/slider0.png")
	realm_of_titans.hs_grabber_highlight = preload("res://sansara/icons/white/slider1.png")
	realm_of_titans.updown = preload("res://sansara/icons/white/updown.png")
	_create_theme(realm_of_titans)
	
	var realm_of_gods = ThemeData.new()
	realm_of_gods.tag = UITheme.REALM_OF_GODS
	realm_of_gods.name = "UI_THEME_REALM_OF_GODS"
	realm_of_gods.appbar_color = Color("FFFFFF")
	realm_of_gods.background_color = Color("F5F5F5")
	realm_of_gods.board_color = Color("FFFFFF")
	realm_of_gods.board_color2 = Color("6B00A0")

	realm_of_gods.cb0 = preload("res://sansara/icons/dark/checkbox0.png")
	realm_of_gods.cb1 = preload("res://sansara/icons/dark/checkbox1.png")
	realm_of_gods.cbn0 = preload("res://sansara/icons/dark/checkbtn0.png")
	realm_of_gods.cbn1 = preload("res://sansara/icons/dark/checkbtn1.png")
	realm_of_gods.rb0 = preload("res://sansara/icons/dark/radio0.png")
	realm_of_gods.rb1 = preload("res://sansara/icons/dark/radio1.png")
	realm_of_gods.fr0 = preload("res://sansara/icons/dark/list_down.png")
	realm_of_gods.fr1 = preload("res://sansara/icons/dark/list_up.png")
	realm_of_gods.hs_grabber = preload("res://sansara/icons/blue/slider0.png")
	realm_of_gods.hs_grabber_highlight = preload("res://sansara/icons/blue/slider1.png")
	realm_of_gods.updown = preload("res://sansara/icons/dark/updown.png")
	
	realm_of_gods.appbar_color = Color("FFFFFF")
	realm_of_gods.panel_color = Color("FAFAFA")
	realm_of_gods.element_color = Color("000000")
	realm_of_gods.element_hover_color = Color("328FFE")
	realm_of_gods.background_i = 1.0
	realm_of_gods.element_pressed_color = realm_of_gods.element_hover_color
	_create_theme(realm_of_gods)

	realm_of_gods.cb0 = preload("res://sansara/icons/white/checkbox0.png")
	realm_of_gods.cb1 = preload("res://sansara/icons/white/checkbox1.png")
	realm_of_gods.cbn0 = preload("res://sansara/icons/white/checkbtn0.png")
	realm_of_gods.cbn1 = preload("res://sansara/icons/white/checkbtn1.png")
	realm_of_gods.rb0 = preload("res://sansara/icons/white/radio0.png")
	realm_of_gods.rb1 = preload("res://sansara/icons/white/radio1.png")
	realm_of_gods.fr0 = preload("res://sansara/icons/white/list_down.png")
	realm_of_gods.fr1 = preload("res://sansara/icons/white/list_up.png")
	realm_of_gods.hs_grabber = preload("res://sansara/icons/white/slider0.png")
	realm_of_gods.hs_grabber_highlight = preload("res://sansara/icons/white/slider1.png")
	realm_of_gods.updown = preload("res://sansara/icons/white/updown.png")
	
	realm_of_gods.element_color = Color("FFFFFF")
	realm_of_gods.appbar_color = Color("790e8b")
	realm_of_gods.panel_color = Color("ab47bc")
	realm_of_gods.background_color = realm_of_gods.panel_color
	realm_of_gods.element_hover_color = Color("D9BAFF")
	realm_of_gods.background_i = 0.88
	realm_of_gods.element_pressed_color = realm_of_gods.element_hover_color
	_create_theme(realm_of_gods)
	
	
	
#	realm_of_gods.appbar_color = Color("c67c00")
#	realm_of_gods.panel_color = Color("ffab00")
#	realm_of_gods.background_color = Color("ffab00")
#	realm_of_gods.element_color = Color("000000")
#	realm_of_gods.element_hover_color = Color("ffdd4b")
#	realm_of_gods.element_pressed_color = realm_of_gods.element_hover_color
#	realm_of_gods.background_i = 0.88
#	_create_theme(realm_of_gods)
	
func show_aspect(theme, aspect):
	get_named_element(SCREEN_SETTINGS).show_aspect(theme, aspect)
					
var box_theme = null

func set_theme_font(idx, aspect):
	var font
	var appbar
	var big
	var medium
	var small
	match idx:
		0:
			font = preload("res://fonts/modern.tres")
			appbar = preload("res://fonts/modern_appbar.tres")
			big = preload("res://fonts/modern_big.tres")
			medium = preload("res://fonts/modern_medium.tres")
			small = preload("res://fonts/modern_small.tres")
		1:
			font = preload("res://fonts/friendly.tres")
			appbar = preload("res://fonts/friendly_appbar.tres")
			big = preload("res://fonts/friendly_big.tres")
			medium = preload("res://fonts/friendly_medium.tres")
			small = preload("res://fonts/friendly_small.tres")
	
	var t = get_current_theme()
	if t.aspects.size() <= aspect:
		aspect = 0
	var theme = t.aspects[aspect].theme
	theme.default_font = font
	var box_theme = t.aspects[aspect].box_theme
	box_theme.default_font = small
	theme.set_font("appbar_font", "Main", appbar)
	theme.set_font("big_font", "Button", big)
	theme.set_font("medium_font", "Main", medium)
	theme.set_font("small_font", "Main", small)

func set_ui_theme(theme_idx, aspect):
	
	var t = themes[theme_idx]
	if t.aspects.size() <= aspect:
		aspect = 0
	var a = t.aspects[aspect]
	t.current_aspect = aspect
	var main_theme = a.theme
	
	set_clear_color(main_theme.get_color("panel_color", "Main"))
	
	_main_layout.theme = main_theme
	
	for item in _widgetbars:	
		item.apply_theme(main_theme)
	
	for item in _scrollcontainers:
		item.apply_theme(main_theme)
	
	for item in _widgets.values():
		item.apply_theme(main_theme)
		
	for item in _tbtns:
		item.apply_theme(main_theme)
	
	for item in _elements:
		item.apply_theme(main_theme)
	
	for item in _small_elements:
		item.theme = main_theme
		item.add_font_override("font", main_theme.get_font("small_font", "Main"))
	
	for item in _medium_elements:
		item.theme = main_theme
		item.add_font_override("font", main_theme.get_font("medium_font", "Main"))
	
	for item in _background_containers:
		item.set_i(a.background_i)
	
# Other

func get_real_resolution() -> Vector2:
	var s = OS.get_screen_size() # Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	return s
	
func get_resolution() -> Vector2:
	return Vector2(1920, 1080)
	#return Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

func get_current_resolution():
	return Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

func set_resolution(v):
	ProjectSettings.set_setting("display/window/size/width", v.x)
	ProjectSettings.set_setting("display/window/size/height",v.y)
	ProjectSettings.set_setting("display/window/size/test_width", v.x)
	ProjectSettings.set_setting("display/window/size/test_height",v.y)
	return ProjectSettings.save()

enum UIElement {
	UI_SCREEN,
	UI_BIG_BUTTON,
	UI_MEDIUM_BUTTON,
	UI_SMALL_BUTTON
}

enum Thickness {
	TS_DEFAULT = 3,
	TS_VERY_THIN = 1
	TS_THIN = 2,
	TS_STANDART = 3,
	TS_SEMIBOLD = 4
	TS_BOLD = 5
}

func apply_language(ui_language) -> void:
	match ui_language:
		Settings.Language.ENGLISH:
			TranslationServer.set_locale("en")
		Settings.Language.RUSSIAN:			
			TranslationServer.set_locale("ru")
		Settings.Language.CHINESE:
			TranslationServer.set_locale("zh")
		Settings.Language.JAPANESE:
			TranslationServer.set_locale("ja")

##################################################################################################################
# 																	Главные элементы
##################################################################################################################

var _super_menu
var _main_container
var _main_layout
var _game_scene
var _helper

func set_helper(element):
	_helper = element

func get_helper():
	return _helper

func set_root(element):
	_super_menu = element
	
func get_root():
	return _super_menu

func set_main_container(element):
	_main_container = element
	
func get_main_container():
	return _main_container
	
func set_main_layout(element):
	_main_layout = element

func get_main_layout():
	return _main_layout

func set_game(element):
	_game_scene = element
	
func get_game():
	return _game_scene
	
func get_ai():
	return _game_scene.ai

func get_history():
	return _game_scene.gui.history_panel

func get_loading_screen():
	return _named_elements[SCREEN_LOADING]
	
func hide_main_layout():
	yield(_main_layout.beautiful_hide(), "fade_completed")

func hide_main_container():
	_main_container.visible = false

func show_main_layout():
	_main_layout.beautiful_show()
	yield(_main_layout, "fade_completed")

func show_main_container():
	_main_container.visible = true

func is_scene_test():
	return _main_layout == null

var current_theme = -1
var current_aspect = -1
	
func set_theme(theme, aspect):
	#if theme != current_theme or aspect != :
	current_theme = theme
	current_aspect = aspect
	
	set_theme_font(Profiles.get_current_settings().get_value(Settings.SV_UI_FONT), aspect)
	set_ui_theme(theme, aspect)
	
	if UI.get_game() != null:
		UI.get_game().update_background_color()
	_main_container.show()

func get_current_theme():
	return themes[current_theme]

func get_current_subtheme():
	return themes[current_theme].aspects[themes[current_theme].current_aspect].theme

#  Контроль виджетов

var _widgets = {}
var _tbtns = []

enum {
	WIDGET_BACKBTN = 1,
	WIDGET_SETTINGS = 2,
	WIDGET_THEME_SWITCH = 3,
	WIDGET_QUICK_QUIT = 4,
	WIDGET_HIDEBAR_TOP = 5,
	WIDGET_SHOWBAR_TOP = 6,
	WIDGET_HIDEBAR_LEFT = 7,
	WIDGET_SHOWBAR_LEFT = 8,
	WIDGET_HIDEBAR_RIGHT = 9,
	WIDGET_SHOWBAR_RIGHT = 10,
	WIDGET_STYLE_PIECE = 11,
	WIDGET_HISTORY = 12,
	WIDGET_FLIP = 13,
	WIDGET_TOGGLE_HINT_MODE = 14,
	WIDGET_CLOCK = 60,
	WIDGET_NEWGAME = 300,
	WIDGET_CLOSEGAME = 301,
	WIDGET_LIBRARY_PLAY = 110,
	WIDGET_LIBRARY_DELETE = 111,
	WIDGET_LIBRARY_EXPLORER = 112,
	WIDGET_CREATE_SERVER = 198,
	WIDGET_REFRESH_SERVER_LIST = 199,
	WIDGET_ACCOUNT = 200,
	WIDGET_RESIGN = 201,
	WIDGET_TAKEBACK = 202,
	WIDGET_AI = 800,
}

func register_widget(id, widget):
	_widgets[id] = widget

func unregister_widget(id):
	_widgets.erase(id)

func add_texbtn(btn):
	_tbtns.append(btn)

func remove_texbtn(btn):
	_tbtns.erase(btn)

func get_widget(id):
	return _widgets[id]

func show_account_btn():
	_widgets[WIDGET_ACCOUNT].show()

func hide_account_btn():
	_widgets[WIDGET_ACCOUNT].hide()

func show_back_btn():
	_widgets[WIDGET_BACKBTN].show()

func hide_back_btn():
	_widgets[WIDGET_BACKBTN].hide()

func show_settings_btn():
	_widgets[WIDGET_SETTINGS].show()

func hide_settings_btn():
	_widgets[WIDGET_SETTINGS].hide()
	
func show_library_play_btn():
	_widgets[WIDGET_LIBRARY_PLAY].show()

func hide_library_play_btn():
	_widgets[WIDGET_LIBRARY_PLAY].hide()
 
func show_library_delete_btn():
	_widgets[WIDGET_LIBRARY_DELETE].show()

func hide_library_delete_btn():
	_widgets[WIDGET_LIBRARY_DELETE].hide()

func show_library_explorer_btn():
	_widgets[WIDGET_LIBRARY_EXPLORER].show()

func hide_library_explorer_btn():
	_widgets[WIDGET_LIBRARY_EXPLORER].hide()

var topbar = null
var htopbar = null

var game_left_bar_mode = 1
var game_left_bar_m0
var game_left_bar_m1

func get_left_bar():
	match game_left_bar_mode:
		0:
			return game_left_bar_m0
		1:
			return game_left_bar_m1
	return null

var game_left_hbar
var game_right_bar
var game_right_hbar

var topbar_was_visible = true
var leftbar_was_visible = false
var rightbar_was_visible = false
var history_was_visible = false

func register_widgetbar(element):
	_widgetbars.append(element)

func get_appbar():
	return _widgetbars[0]

func get_title():
	return _widgetbars[0].title.text

func change_appbar_text(new_text):
	_widgetbars[0].title.text = new_text

func show_appbar():
	_widgetbars[0].appbar.beautiful_show()
	return _widgetbars[0].appbar

func hide_appbar():
	_widgetbars[0].appbar.beautiful_hide()
	return _widgetbars[0].appbar
	
# Обработка страны

var country_button
var country_button2

var country_label

var country_tag = 0
var country_list = {}

class Country:
	var tag
	var texture
	func _init(p_tag, p_texture):
		tag = p_tag
		texture = p_texture


func clear_countries():
	country_list.clear()

func add_country(tag, text, texture):
	country_list[tag] = Country.new(text, texture)

func get_country_raw_name(tag):
	return country_list[tag].tag
	
func get_country_name(tag):
	return TranslationServer.translate(country_list[tag].tag)

func get_country_texture(tag):
	return country_list[tag].texture
	
func register_country_button(button):
	country_button = button

func register_country_button2(button):
	country_button2 = button

func register_country_label(label):
	country_label = label

func set_country_button(texture):
	country_button.texture_normal = texture

func set_country_label(tag):
	country_label.text = TranslationServer.translate(tag)

func get_country_button():
	return country_button
	
func get_country_label():
	return country_label
	
func get_country_tag():
	return country_tag


# Все элементы интерфейса

# статические элементы

var _widgetbars = []
var _big_buttons = []
var _medium_buttons = []
var _small_buttons = []

var _current_screen = null

func set_current_screen(screen):
	_current_screen = screen
	
func get_current_screen():
	return _current_screen


func get_appbar_color(ui_theme):
	match ui_theme:
		UITheme.UI_THEME_REALM_OF_GODS:
			 return Color("f9f9f9")
		UITheme.UI_THEME_REALM_OF_SINNERS:
			return Color("2f2f2f")

func get_inverted_appbar_color(ui_theme):
	match ui_theme:
		UITheme.UI_THEME_REALM_OF_GODS:
			 return Color("2f2f2f")
		UITheme.UI_THEME_REALM_OF_SINNERS:
			 return Color("f9f9f9")

var _named_elements = {}

var _elements = []

var _medium_elements = []

var _small_elements = []

var _chats = []

var _scrollcontainers = []

var _background_containers = []

func register_scrollcontainer(element):
	_scrollcontainers.append(element)

func add_theme_element(element):
	_elements.append(element)

func remove_theme_element(element):
	if _elements.has(element):
		_elements.erase(element)

func add_unnamed_small_element(element):
	_small_elements.append(element)

func add_unnamed_medium_element(element):
	_medium_elements.append(element)

func add_chat(element):
	_chats.append(element)
	
	
func clear_ui():
	_big_buttons.clear()
	_medium_buttons.clear()
	_small_buttons.clear()

enum StaticElementType {
	SET_BIG_BUTTON,
	SET_MEDIUM_BUTTON,
	SET_SMALL_BUTTON
}



func register_static_element(element_type, element):
	match(element_type):
		StaticElementType.SET_BIG_BUTTON:
			_big_buttons.append(element)

func register_named_element(name, element):
	assert(element != null)
	_named_elements[name] = element
	return element

func get_named_element(name):
	if _named_elements.has(name):
		return _named_elements[name]
	return null
 
func apply_theme_to_ui(theme, aspect):
	match theme:
		UITheme.REALM_OF_GODS:
			get_named_element(RB_UI_THEME_REALM_OF_GODS).pressed = true
		UITheme.REALM_OF_TITANS:
			get_named_element(RB_UI_THEME_REALM_OF_TITANS).pressed = true
		UITheme.REALM_OF_HUMANS:
			get_named_element(RB_UI_THEME_REALM_OF_HUMANS).pressed = true
		UITheme.REALM_OF_ANIMALS:
			get_named_element(RB_UI_THEME_REALM_OF_ANIMALS).pressed = true
		UITheme.REALM_OF_GHOSTS:
			get_named_element(RB_UI_THEME_REALM_OF_GHOSTS).pressed = true
		UITheme.REALM_OF_SINNERS:
			get_named_element(RB_UI_THEME_REALM_OF_SINNERS).pressed = true
	show_aspect(theme, aspect)

var settings_en_was_pressed

# 	Apply all settings(should be called only when profile loaded or changed)
func apply_profile(profile):
	
	var settings = profile.settings
	
	# UI
	
	match settings.get_value(Settings.SV_UI_LANGUAGE):
		Settings.Language.ENGLISH:
			get_named_element(RB_UI_LANGUAGE_ENGLISH).pressed = true
		Settings.Language.RUSSIAN:
			get_named_element(RB_UI_LANGUAGE_RUSSIAN).pressed = true
		Settings.Language.CHINESE:
			get_named_element(RB_UI_LANGUAGE_CHINESE).pressed = true
		Settings.Language.JAPANESE:
			get_named_element(RB_UI_LANGUAGE_JAPANESE).pressed = true
			
	apply_theme_to_ui(settings.get_value(Settings.SV_UI_THEME), settings.get_value(Settings.SV_UI_ASPECT))
	
	match settings.get_value(Settings.SV_UI_FONT):
		0:
			get_named_element(RB_UI_FONT_MODERN).pressed = true
		1:
			get_named_element(RB_UI_FONT_FRIENDLY).pressed = true
	
	#get_named_element(CB_UI_FONT_OUTLINE).pressed = settings.get_value(Settings.SV_UI_FONT_OUTLINE_ENABLED)
	
	get_named_element(CB_UI_TIPS_BUTTON).pressed = settings.get_value(Settings.SV_UI_TIPS_BUTTON_ENABLED)
	
	var panel_transparency = settings.get_value(Settings.SV_UI_PANEL_TRANSPARENCY)
	
	get_named_element(SR_UI_PANEL_TRANSPARENCY).value = float(panel_transparency)
	
	var a = float(255 - panel_transparency) / 255.0
	
	UI.get_history().self_modulate.a = a
	
	get_game().gui.ai_log_panel.self_modulate.a = a
	
	get_game().gui.piece_style_panel.self_modulate.a = a
	
	# GAMEPLAY
	
	get_named_element(CB_GAME_AUTOMOVE).pressed = settings.get_value(Settings.SV_GAME_AUTOMOVE_ENABLED)
	
	get_named_element(CB_GAME_AUTOPROMOTION).pressed = settings.get_value(Settings.SV_GAME_AUTOPROMOTION_ENABLED)
	
	get_named_element(CB_GAME_LASTMOVE).pressed = settings.get_value(Settings.SV_GAME_LASTMOVE_ENABLED)
	
	get_named_element(CB_GAME_CASTLES).pressed = settings.get_value(Settings.SV_GAME_CASTLES_ENABLED)
	
	match settings.get_value(Settings.SV_GAME_AUTOSHOW):
		Settings.HighlightOptions.DISABLED:
			get_named_element(RB_GAME_AUTOSHOW_DISABLED).pressed = true
		Settings.HighlightOptions.MYSELF:
			get_named_element(RB_GAME_AUTOSHOW_MYSELF).pressed = true
		Settings.HighlightOptions.ALL:
			get_named_element(RB_GAME_AUTOSHOW_ALL).pressed = true
	
	# HISTORY
	
	var history = UI.get_history()
	var history_autoshow = bool(settings.get_value(Settings.SV_HISTORY_AUTOSHOW_ENABLED))
	var history_autoscroll = bool(settings.get_value(Settings.SV_HISTORY_AUTOSCROLL_ENABLED))
	var history_element_count = int(settings.get_value(Settings.SV_HISTORY_ELEMENT_COUNT))
	var history_panelstyle = int(settings.get_value(Settings.SV_HISTORY_PANEL_STYLE))
	var history_panelsize = int(settings.get_value(Settings.SV_HISTORY_PANEL_SIZE))
	var history_revert = bool(settings.get_value(Settings.SV_HISTORY_PLAYBACK_REVERT))
	var history_playback_is_fixed = bool(settings.get_value(Settings.SV_HISTORY_PLAYBACK_IS_FIXED))
	var history_playback_fixed_duration = float(settings.get_value(Settings.SV_HISTORY_PLAYBACK_FIXED_DURATION))
	var history_notation_style = int(settings.get_value(Settings.SV_HISTORY_NOTATION_STYLE))
	var history_ynum = bool(settings.get_value(Settings.SV_HISTORY_NOTATION_USE_Y_NUMBER))
	var history_turn_symbols = bool(settings.get_value(Settings.SV_HISTORY_DRAW_TURN_SYMBOL))
	var history_symbols = int(settings.get_value(Settings.SV_HISTORY_SYMBOLS))
	
	# SV_HISTORY_AUTOSHOW_ENABLED
	get_named_element(CB_HISTORY_AUTO_SHOW).pressed = history_autoshow
	
	# SV_HISTORY_AUTOSCROLL_ENABLED
	get_named_element(CB_HISTORY_AUTO_SCROLL).pressed = history_autoscroll
	history.enable_autoscroll(history_autoscroll)
	
	# SV_HISTORY_ELEMENT_COUNT
	get_named_element(SB_HISTORY_ELEMENT_COUNT).value = history_element_count
	history.set_element_count(history_element_count)
	
	# SV_HISTORY_PANEL_STYLE
	match history_panelstyle:
		0:
			get_named_element(RB_HISTORY_PANEL_CLASSIC).pressed = true
			history.set_panel_mode(0)
		1:
			get_named_element(RB_HISTORY_PANEL_CHESS).pressed = true
			history.set_panel_mode(1)
	
	# SV_HISTORY_PANEL_SIZE
	get_named_element(SR_HISTORY_PANEL_SIZE).value = history_panelsize
	
	# SV_HISTORY_REVERT
	get_named_element(CB_HISTORY_REVERT_BUTTON).pressed = history_revert
	UI.get_game().gui.enable_playback_revert_button(history_revert)

	# SV_HISTORY_PLAYBACK_IS_FIXED
	if history_playback_is_fixed:
		get_named_element(RB_HISTORY_PLAYBACK_FIXED_DURATION).pressed = true
	else:
		get_named_element(RB_HISTORY_PLAYBACK_FROM_REPLAY).pressed = true

	# SV_HISTORY_PLAYBACK_DURATION
	get_named_element(SR_HISTORY_PLAYBACK_FIXED_DURATION).value = history_playback_fixed_duration
	get_named_element(LABEL_HISTORY_PLAYBACK_FIXED_DURATION).text = str(history_playback_fixed_duration) + " " + TranslationServer.translate("LABEL_SECONDS2")
	
	# SV_HISTORY_NOTATION_STYLE
	var ja_was_pressed = false
	match history_notation_style:
		0:
			get_named_element(RB_HISTORY_NOTATION_JAPANESE).pressed = true
			UI.get_named_element(UI.RB_HISTORY_SYMBOLS_EN).disabled = true
			ja_was_pressed = true
			history.set_notation_mode(0)
		1:
			get_named_element(RB_HISTORY_NOTATION_SHORT).pressed = true
			history.set_notation_mode(1)
		2:
			get_named_element(RB_HISTORY_NOTATION_FULL).pressed = true
			history.set_notation_mode(2)
	
	# SV_HISTORY_NOTATION_USE_Y_NUMBER
	get_named_element(CB_HISTORY_Y_NUM).pressed = history_ynum
	if ja_was_pressed:
		UI.get_named_element(UI.CB_HISTORY_Y_NUM).disabled = true
	history.set_ynum_mode(history_ynum)
	
	# SV_HISTORY_DRAW_TURN_SYMBOL
	get_named_element(CB_HISTORY_TURN_SYMBOL).pressed = history_turn_symbols
	history.set_turn_symbol(history_turn_symbols)
	
	# SV_HISTORY_SYMBOLS
	match history_symbols:
		Games.NotationLetters.JAPANESE:
			get_named_element(RB_HISTORY_SYMBOLS_JP).pressed = true
			history.set_symbol_mode(0)
		Games.NotationLetters.ENGLISH:
			if !ja_was_pressed:
				get_named_element(RB_HISTORY_SYMBOLS_EN).pressed = true
			settings_en_was_pressed = true
			history.set_symbol_mode(1)
	
	# CAMERA
			
	get_named_element(CB_CAMERA_ALLOW_YAW).pressed = bool(settings.get_value(Settings.SV_CAMERA_YAW_ENABLED))
	get_named_element(CB_CAMERA_ALLOW_PITCH).pressed = bool(settings.get_value(Settings.SV_CAMERA_PITCH_ENABLED))
	get_named_element(CB_CAMERA_ALLOW_ZOOM).pressed = bool(settings.get_value(Settings.SV_CAMERA_ZOOM_ENABLED))
	get_named_element(CB_CAMERA_ALLOW_PAN).pressed = bool(settings.get_value(Settings.SV_CAMERA_PAN_ENABLED))
	get_named_element(CB_CAMERA_SWITCH_SIDES).pressed = bool(settings.get_value(Settings.SV_CAMERA_SWITCH_ENABLED))
	get_named_element(CB_CAMERA_RESTRICT_YAW).pressed = bool(settings.get_value(Settings.SV_CAMERA_RESTRICT_YAW))
	
	# STYLES
	
	get_named_element(CHECKBOX_STYLES_BOARD_MARKUP).pressed = settings.get_value(Settings.SV_STYLES_BOARD_MARKUP_ENABLED)
	get_named_element(CHECKBOX_STYLES_UI_COLORING).pressed = settings.get_value(Settings.SV_STYLES_BOARD_COLORING_UI_ENABLED)
	get_named_element(CHECKBOX_STYLES_CHESS_COLORING).pressed = settings.get_value(Settings.SV_STYLES_BOARD_COLORING_CHESS_ENABLED)
	get_named_element(CHECKBOX_STYLES_ZONES_COLORING).pressed = settings.get_value(Settings.SV_STYLES_BOARD_COLORING_ZONES_ENABLED)
	
	match settings.get_value(Settings.SV_STYLES_GRID_COLOR):
		Settings.WebColor.BLACK:
			get_named_element(CHECKBOX_STYLES_GRID_COLOR_BLACK).pressed = true
		Settings.WebColor.WHITE:
			get_named_element(CHECKBOX_STYLES_GRID_COLOR_WHITE).pressed = true
	
	var slider = get_named_element(SLIDER_STYLES_GRID_THICKNESS)
	var slider_label = get_named_element(LABEL_STYLES_GRID_THICKNESS_INPUT)
	match settings.get_value(Settings.SV_STYLES_GRID_THICKNESS):
		Thickness.TS_VERY_THIN:		
			slider.value = 1
			slider_label.text = "SD_GAME_GRID_THICKNESS_VERY_THIN"
		Thickness.TS_THIN:		
			slider.value = 2
			slider_label.text = "SD_GAME_GRID_THICKNESS_THIN"
		Thickness.TS_STANDART:
			slider.value = 3
			slider_label.text = "SD_GAME_GRID_THICKNESS_STANDART"
		Thickness.TS_SEMIBOLD:
			slider.value = 4
			slider_label.text = "SD_GAME_GRID_THICKNESS_SEMIBOLD"
		Thickness.TS_BOLD:
			slider.value = 5
			slider_label.text = "SD_GAME_GRID_THICKNESS_BOLD"
	
	# SFX	
	
	get_named_element(CHECKBOX_SFX_UI_ENABLED).pressed = settings.get_value(Settings.SV_SFX_UI_ENABLED)
	get_named_element(CHECKBOX_SFX_MOVE_ENABLED).pressed = settings.get_value(Settings.SV_SFX_MOVE_ENABLED)
	get_named_element(CHECKBOX_SFX_3D_ENABLED).pressed = settings.get_value(Settings.SV_SFX_3D_ENABLED)
	get_named_element(CHECKBOX_SFX_SPEECH_ENABLED).pressed = settings.get_value(Settings.SV_SFX_SPEECH_ENABLED)
	get_named_element(SLIDER_SOUND_SPEECH_VOLUME).value = settings.get_value(Settings.SV_SFX_SPEECH_VOLUME)
	get_named_element(CHECKBOX_SFX_CHECK_ENABLED).pressed = settings.get_value(Settings.SV_SFX_CHECK_ENABLED)
	get_named_element(CHECKBOX_SFX_MUSIC_ENABLED).pressed = settings.get_value(Settings.SV_SFX_MUSIC_ENABLED)
	get_named_element(SLIDER_SOUND_MUSIC_VOLUME).value = settings.get_value(Settings.SV_SFX_MUSIC_VOLUME)	
	match settings.get_value(Settings.SV_SFX_MUSIC_ORDER):
		0:
 			get_named_element(RB_MUSIC_PLAYORDER_NEXT).pressed = true
		1:
			get_named_element(RB_MUSIC_PLAYORDER_RANDOMIZE).pressed = true
	
	# WIDGETS
	
	# Sansara Ring widget
	
	if settings.get_value(Settings.SV_WIDGET_SANSARA_ENABLED):
		get_named_element(CB_WIDGETS_SANSARA_ENABLED).pressed = true
		get_widget(WIDGET_THEME_SWITCH).visible = true
	else:
		get_named_element(CB_WIDGETS_SANSARA_ENABLED).pressed = false
		get_widget(WIDGET_THEME_SWITCH).visible = false
	match settings.get_value(Settings.SV_WIDGET_SANSARA_ORDER):
		0:
			get_named_element(RB_WIDGETS_SANSARA_ORDER_NEXT).pressed = true
		1:
			get_named_element(RB_WIDGETS_SANSARA_ORDER_PREVIOUS).pressed = true
	
	# Clock widget
	
	if settings.get_value(Settings.SV_WIDGET_CLOCK_ENABLED):
		get_named_element(CB_WIDGETS_CLOCK_ENABLED).pressed = true
		get_widget(WIDGET_CLOCK).visible = true
	else:
		get_named_element(CB_WIDGETS_CLOCK_ENABLED).pressed = false
		get_widget(WIDGET_CLOCK).visible = false
	
	var widget_clock_seconds_enabled = settings.get_value(Settings.SV_WIDGET_CLOCK_SECONDS_ENABLED)
	#var widget_clock_zeroes_enabled = settings.get_value(Settings.SV_WIDGET_CLOCK_ZEROES_ENABLED)
	
	get_named_element(CB_WIDGETS_CLOCK_SECONDS_ENABLED).pressed = widget_clock_seconds_enabled
	# get_named_element(CB_WIDGETS_CLOCK_ZEROES_ENABLED).pressed = widget_clock_zeroes_enabled
	
	get_widget(WIDGET_CLOCK).set_show_seconds(widget_clock_seconds_enabled)
	get_widget(WIDGET_CLOCK).set_show_zeroes(false)
	
	match settings.get_value(Settings.SV_WIDGET_CLOCK_FORMAT):
		0:
			UI.get_widget(WIDGET_CLOCK).set_format(0)
			get_named_element(RB_WIDGETS_CLOCK_FORMAT_24).pressed = true
		1:
			UI.get_widget(WIDGET_CLOCK).set_format(1)
			get_named_element(RB_WIDGETS_CLOCK_FORMAT_12).pressed = true
	
	# Quick Quit widget
	
	if settings.get_value(Settings.SV_WIDGET_QQ_ENABLED):
		get_named_element(CB_WIDGETS_QQ_ENABLED).pressed = true
		get_widget(WIDGET_QUICK_QUIT).visible = true
	else:
		get_named_element(CB_WIDGETS_QQ_ENABLED).pressed = false
		get_widget(WIDGET_QUICK_QUIT).visible = false
	get_named_element(CB_WIDGETS_QQ_DIALOG_ENABLED).pressed = settings.get_value(Settings.SV_WIDGET_QQ_DIALOG_ENABLED)
	
	# Other
	
	get_named_element(LE_PROFILE_NAME).text = Profiles.get_current_profile().nickname
	get_named_element(CB_LOOPBACK).pressed = Profiles.get_value(Settings.SV_LOOPBACK_MODE)
	
	# Multiplayer
	
	get_named_element(LE_MP_USERNAME).text = Profiles.get_current_profile().nickname
	if Profiles.get_value(Settings.SV_MP_SAVE_PASSWORD):
		get_named_element(LE_MP_PASSWORD).text = Profiles.get_value(Settings.SV_MP_PASSWORD)
		get_named_element(CB_MP_SAVE_PASSWORD).pressed = true
	
	# Master server setup
	
	if Profiles.get_value(Settings.SV_MASTER_USE_IPV6):
		get_named_element(RB_MASTER_USE_IPV6).pressed = true
	else:
		get_named_element(RB_MASTER_USE_IPV4).pressed = true
	get_named_element(SB_MASTER_IPV4_1).value = int(Profiles.get_value(Settings.SV_MASTER_IPV4_1))
	get_named_element(SB_MASTER_IPV4_2).value = int(Profiles.get_value(Settings.SV_MASTER_IPV4_2))
	get_named_element(SB_MASTER_IPV4_3).value = int(Profiles.get_value(Settings.SV_MASTER_IPV4_3))
	get_named_element(SB_MASTER_IPV4_4).value = int(Profiles.get_value(Settings.SV_MASTER_IPV4_4))
	get_named_element(LE_MASTER_IPV6).text = Profiles.get_value(Settings.SV_MASTER_IPV6)
	get_named_element(SB_MASTER_PORT).value = int(Profiles.get_value(Settings.SV_MASTER_PORT))
	
	# AI

	var folder = settings.get_value(Settings.SV_AI_ENGINE_FOLDER)
	var exe = settings.get_value(Settings.SV_AI_ENGINE_EXE)
	
	var folder_box = get_named_element(OB_AI_ENGINE_NAME)
	var exe_box = get_named_element(OB_AI_ENGINE_EXE)
	
	for idx in range(folder_box.get_item_count()):
		if folder_box.get_item_text(idx) == folder:
			folder_box.select(idx)
			UI.get_root().settings_screen._on_EngineFolderButton_item_selected(idx)
			break
			
	for idx in range(exe_box.get_item_count()):
		if exe_box.get_item_text(idx) == exe:
			exe_box.select(idx)
			break
	
	var skill_level = settings.get_value(Settings.SV_AI_ENGINE_SKILL_LEVEL)
	get_named_element(SR_AI_SKILL_LEVEL).value = skill_level
	get_named_element(SR_AI_SKILL_LEVEL2).value = skill_level
	get_named_element(LABEL_AI_SKILL_LEVEL).text = str(skill_level)
	get_named_element(LABEL_AI_SKILL_LEVEL2).text = str(skill_level)

	var enable_log = settings.get_value(Settings.SV_AI_ENGINE_ENABLE_LOG)
	get_named_element(CB_AI_ENABLE_LOG).pressed = enable_log
	
	input_list.setup_actions()
	input_list.apply_actions()
	
	profile.apply()

func current_settings():
	return Profiles.get_current_profile().settings

func apply_current_profile():
	apply_profile(Profiles.get_current_profile())
	
func get_master_ip():
	var ip
	if Profiles.get_value(Settings.SV_MASTER_USE_IPV6):
		ip = Profiles.get_value(Settings.SV_MASTER_IPV6)
	else:
		ip = str(Profiles.get_value(Settings.SV_MASTER_IPV4_1)) + "." + str(Profiles.get_value(Settings.SV_MASTER_IPV4_2)) + "." + str(Profiles.get_value(Settings.SV_MASTER_IPV4_3)) + "." + str(Profiles.get_value(Settings.SV_MASTER_IPV4_4))
	return ip

func get_master_port():
	return Profiles.get_value(Settings.SV_MASTER_PORT)

# Диалоги

# Вызов диалога, Режимы - 0(YesNo), 1(NoYes), 2(Ok)
func call_dialog(desc, button_mode = 2):
	var dialog = preload("res://scenes/PopupDialog.tscn").instance()
	dialog.self_destruct = true
	dialog.update_mode(button_mode)
	get_current_screen().add_child(dialog)
	dialog.set_title(desc)
	dialog.apply_theme(UI.get_current_subtheme())
	dialog.beautiful_show()
	return dialog

func call_data_dialog(caption, desc):
	var dialog = preload("res://scenes/PopupDataDialog.tscn").instance()
	dialog.self_destruct = true
	get_current_screen().add_child(dialog)
	dialog.set_caption(caption)
	dialog.set_data(desc)
	dialog.apply_theme(UI.get_current_subtheme())
	dialog.beautiful_show()
	return dialog

# Вызов диалога присоединения к обычной игре
func call_joining_dialog():
	var dialog = preload("res://scenes/AwaitDialog.tscn").instance()
	dialog.self_destruct = true
	dialog.set_title("MP_AWAIT_PERMISSION")
	get_current_screen().add_child(dialog)
	dialog.apply_theme(UI.get_current_subtheme())
	dialog.beautiful_show()
	dialog.start()
	return dialog

# Вызов диалога ввода пароля при присоединении к приватной игре
func call_password_dialog():
	var dialog = preload("res://scenes/PasswordDialog.tscn").instance()
	dialog.self_destruct = true
	get_current_screen().add_child(dialog)
	dialog.apply_theme(UI.get_current_subtheme())
	dialog.beautiful_show()
	return dialog