extends "res://scripts/ui/FadeElement.gd"
class_name UIScreen

# UIScreen.gd

export(bool) var hide_layout = false

export(bool) var hide_appbar = false

var previous_screen = null setget set_previous_screen, get_previous_screen

var title = "-" setget set_title, get_title

var tag = 0

func is_current():
	return UI.get_current_screen() == self

func set_title(name):
	title = name
	
func get_title():
	return title

static func update_title(name):
	UI.change_appbar_text(name)

func immediate_show():
	update_title(title)
	if hide_appbar:
		UI.get_appbar().hide()
	else:
		UI.get_appbar().show()
	return .immediate_show()

func beautiful_show():
	update_title(title)
	if hide_appbar:
		UI.get_appbar().hide()
	else:
		UI.get_appbar().show()
	return .beautiful_show()

func beautiful_hide():
	return .beautiful_hide()
				
func get_previous_screen():
	return previous_screen

func set_previous_screen(screen):
	previous_screen = screen

func show_itself(immediate = false):
	UI.get_helper().hide_tooltip()
	UI.set_current_screen(self)
	if immediate:
		return immediate_show()
	return beautiful_show()

func hide():
	if UI.get_helper() != null:
		UI.get_helper().hide_tooltip()
	.hide()

func _show_screen(screen):
	
	UI.get_helper().hide_tooltip()
	
	if screen.hide_layout:
		yield(UI.get_main_layout().beautiful_hide(), "fade_completed")
	else:
		if !UI.get_main_layout().visible:
			UI.get_main_layout().show()
			UI.get_main_layout().modulate.a = 1.0
			UI.get_main_layout()._state = ShowState.NONE
	
	beautiful_hide()
	screen.beautiful_show()
	
	UI.set_current_screen(screen)
		
func go_back_if_possible():
	# Нельзя использовать эту операцию на невидимом экране
	
	if UI.key_enter_mode:
		return false
	
	if UI.get_current_screen() != self:
		return false
	
	# Нельзя использовать если предыдущий экран == текущему экрану
	if previous_screen == self:
		return false
	
	if previous_screen == UI.get_root().main_menu:
		UI.get_main_layout().get_node("VersionLabel").beautiful_show()
	
	#if self.get_show_state() == SS_NONE and previous_screen.get_show_state() == SS_HIDDEN:
	if previous_screen != null and previous_screen != self:
		_show_screen(previous_screen)
		if previous_screen.previous_screen != null:
			UI.show_back_btn()
		else:
			UI.hide_back_btn()
	
	return true

# Переход на другой экран
func goto_screen(screen, set_previous = true):
	
	# Нельзя использовать эту операцию на невидимом экране
	if UI.get_current_screen() != self:
		return
		
	var s = UI.get_named_element(screen)
	
	if s == self:
		return
	
	if UI.get_current_screen() == UI.get_root().main_menu:
		UI.get_main_layout().get_node("VersionLabel").beautiful_hide()
		
	if s == UI.get_root().main_menu:
		UI.get_widget(UI.WIDGET_SETTINGS).show()
		UI.get_main_layout().get_node("VersionLabel").beautiful_show()
			
	if set_previous:
		s.previous_screen = self
		
	if s.previous_screen != null:
		UI.show_back_btn()
	else:
		UI.hide_back_btn()
			
	_show_screen(s)
	
	return s