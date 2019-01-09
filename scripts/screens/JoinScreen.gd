extends "res://scripts/UIScreen.gd"

# JoinScreen.gd

var address_type = 0
var obsmode = false

func _ready():
	self.title = "TITLE_JOIN"
	connect("visibility_changed", self, "_on_visibility_changed")

func go_back_if_possible():
	$Panel.beautiful_hide()
	return .go_back_if_possible()

func goto_screen(screen, set_previous = false):
	$Panel.beautiful_hide()
	return .goto_screen(screen, true)

func _on_visibility_changed():
	if visible:
		#$Panel.rect_position.y = 200
		$Panel.beautiful_show()

func _on_JoinButton_pressed():
	yield($Panel.beautiful_hide(), "fade_completed")
	GameStarter.set_from_screen(self)
	if address_type == 0:
		GameStarter.join(str($Panel/VBox/VBoxIP/HBoxIPV4/NumBox1.value) + "." + str($Panel/VBox/VBoxIP/HBoxIPV4/NumBox2.value) + "." +
		str($Panel/VBox/VBoxIP/HBoxIPV4/NumBox3.value) + "." + str($Panel/VBox/VBoxIP/HBoxIPV4/NumBox4.value), int($Panel/VBox/VBoxIP/HBoxPort/SpinBox.value), obsmode)
	elif address_type == 1:
		GameStarter.join($Panel/VBox/VBoxIP/HBoxIPV6/IPV6Box.text, int($Panel/VBox/VBoxIP/HBoxPort/SpinBox.value), obsmode)

func _on_NumBox1_value_changed(value):
	Profiles.set_value(Settings.SV_IPV4_1, int(value))

func _on_NumBox2_value_changed(value):
	Profiles.set_value(Settings.SV_IPV4_2, int(value))

func _on_NumBox3_value_changed(value):
	Profiles.set_value(Settings.SV_IPV4_3, int(value))

func _on_NumBox4_value_changed(value):
	Profiles.set_value(Settings.SV_IPV4_4, int(value))

func _on_SpinBox_value_changed(value):
	Profiles.set_value(Settings.SV_JOIN_PORT, int(value))

func _on_IPV6Box_text_changed(new_text):
	Profiles.set_value(Settings.SV_IPV6, new_text)

func _on_IPV6Box_text_entered(new_text):
	Profiles.set_value(Settings.SV_IPV6, new_text)

func _on_IPV4RadioBox_pressed():
	address_type = 0
	
func _on_IPV6RadioBox_pressed():
	address_type = 1

func _on_ObsModeBox_toggled(toggled):
	obsmode = toggled
