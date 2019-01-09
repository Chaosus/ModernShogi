extends "res://scripts/UIScreen.gd"

onready var symbol = $Symbol

const START_SPEED = 0.0

var speed = START_SPEED

var rotating = false

func start_rotating():
	rotating = true

func stop_rotating():
	rotating = false
	
func play_connection_established():
	UI.sfx_player.play_server_connection_established()

func play_connection_failed():
	UI.sfx_player.play_server_connection_failed()

func reset():
	speed = START_SPEED

func show_tryagain_btn():
	UI.show_back_btn()
	$VBox/BTN_TRYAGAIN.show()

func hide_tryagain_btn():
	UI.hide_back_btn()
	$VBox/BTN_TRYAGAIN.hide()

func goto_enter_screen():
	goto_screen(UI.SCREEN_MP_ENTER)

func goto_signup_screen():
	goto_screen(UI.SCREEN_MP_CREATE_PROFILE)
	
func goto_server_screen():
	goto_screen(UI.SCREEN_MP)

func _ready():
	self.title = "TITLE_LOADING"
	$Symbol.position = Vector2(UI.get_resolution().x / 2, UI.get_resolution().y / 2 - 128)
	clear_messages()

func show_message(message, index):
	match index:
		0:
			$VBox/LABEL_LOADING.visible = true
			$VBox/LABEL_LOADING.text = message
		1:
			$VBox/LABEL_LOADING2.visible = true
			$VBox/LABEL_LOADING2.text = message
		2:
			$VBox/LABEL_LOADING3.visible = true
			$VBox/LABEL_LOADING3.text = message
	
func clear_messages():
	$VBox/LABEL_LOADING.visible = false
	$VBox/LABEL_LOADING2.visible = false
	$VBox/LABEL_LOADING3.visible = false
	$VBox/BTN_TRYAGAIN.visible = false

func go_back_if_possible():
	if .go_back_if_possible():
		stop_rotating()

func _physics_process(delta):
	
	symbol.rotation = wrapf(symbol.rotation + speed * delta, 0.0, TAU)
	
	if rotating:
		speed = clamp(speed + 1.0 * delta, 0.0, 50.0)
	else:
		speed = clamp(speed - 1.0 * delta, 0.0, 50.0)

func set_enter_screen_as_previous():
	previous_screen = UI.get_screen(UI.SCREEN_MP_ENTER)

func _on_LoadingScreen_visibility_changed():
	if visible:
		UI.get_widget(UI.WIDGET_SETTINGS).hide()
		previous_screen = UI.get_named_element(UI.SCREEN_MAIN_MENU)

func _on_BTN_TRYAGAIN_pressed():
	UI.get_root().reconnect()
	
	
