extends TextureButton

class_name Widget

# Widget.gd

export(bool) var unnamed = false

export(int) var tag

export(bool) var tooltip_enabled = false

export(bool) var toggleable = false

var pressed2 = false

export(int, "Never", "WhenBackButtonExist", "WhenGameOpened") var tooltip_change = 0

export(String) var tooltip = ""

export(int, "LeftAlign", "CenterAlign", "RightAlign", "TopLeftAlign", "TopRightAlign") var tooltip_align = 0

signal on_left_button_pressed()

signal on_right_button_pressed()

var color_mask_normal
var color_mask_hover
var color_mask_pressed
var color_mask_hover_pressed
var color_mask_disabled

func _ready() -> void:
	if unnamed:
		UI.add_texbtn(self)
	else:
		UI.register_widget(tag, self)
	connect("pressed", self, "_on_pressed")
	connect("gui_input", self, "_gui_input")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	
var button_index = 0

func set_disabled(value : bool) -> void:
	if value:
		modulate = color_mask_disabled
	else:
		modulate = color_mask_normal
	.set_disabled(value)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if unnamed:
			UI.remove_texbtn(self)
		else:
			UI.unregister_widget(tag)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			button_index = event.button_index

func _physics_process(_delta):
	if button_index > 0:
		if button_index == 1:
			emit_signal("on_left_button_pressed")
			button_index = 0
		if button_index == 2:
			emit_signal("on_right_button_pressed")
			button_index = 0

func _on_pressed():
	if tooltip == "BTN_HIDE_PANEL" or tooltip == "BTN_SHOW_PANEL":
		UI.get_helper().hide_tooltip()
	UI.sfx_player.play_widget(tag)
	if toggleable:
		emit_signal("toggled", pressed)
		pressed2 = !pressed2
		if disabled:
				modulate = color_mask_disabled
		else:
			if pressed2:
				modulate = color_mask_hover_pressed
			else:
				modulate = color_mask_normal

func _on_mouse_entered():
	if disabled:
		modulate = color_mask_disabled
	else:
		if toggleable and pressed2:
			modulate = color_mask_hover_pressed
		else:
			modulate = color_mask_hover
		
	if tooltip_enabled:
		if tooltip_change == 1:
			if UI.get_widget(UI.WIDGET_BACKBTN).visible:
				UI.get_helper().show_tooltip_centered(tooltip, self)
				return
		elif tooltip_change == 2:
			if UI.get_current_screen().tag == UI.SCREEN_GAME:
				UI.get_helper().show_tooltip_centered(tooltip, self)
				return
		if tooltip_align == 0:
			UI.get_helper().show_tooltip_left(tooltip, self)
		elif tooltip_align == 1:
			UI.get_helper().show_tooltip_centered(tooltip, self)
		elif tooltip_align == 2:
			UI.get_helper().show_tooltip_right(tooltip, self)
		elif tooltip_align == 3:
			UI.get_helper().show_tooltip_left_top(tooltip, self)
		elif tooltip_align == 4:
			UI.get_helper().show_tooltip_right_top(tooltip, self)

func _on_mouse_exited():
	if tooltip_enabled:
		UI.get_helper().hide_tooltip()
	if disabled:
		modulate = color_mask_disabled
	else:
		if toggleable and pressed2:
			modulate = color_mask_pressed
		else:
			modulate = color_mask_normal
	
func _on_focus_entered():
	if disabled:
		modulate = color_mask_disabled.darkened(0.25)
	else:
		if toggleable and pressed2:
			modulate = color_mask_hover_pressed
		else:
			modulate = color_mask_hover
	
func _on_focus_exited():
	if disabled:
		modulate = color_mask_disabled
	else:
		if toggleable and pressed2:
			modulate = color_mask_pressed
		else:
			modulate = color_mask_normal

func apply_current_theme():
	var theme = UI.get_current_subtheme()
	apply_theme(theme)

func apply_theme(theme):
	color_mask_normal = theme.get_color("element_color", "Main")
	color_mask_hover = theme.get_color("element_hover_color", "Main")
	color_mask_pressed = theme.get_color("element_pressed_color", "Main")
	color_mask_disabled = theme.get_color("element_disabled_color", "Main")
	color_mask_hover_pressed = color_mask_hover.linear_interpolate(color_mask_pressed, 0.5)
	
	if disabled:
		modulate = color_mask_disabled
	else:
		if toggleable and pressed2:
			modulate = color_mask_pressed
		else:
			modulate = color_mask_normal