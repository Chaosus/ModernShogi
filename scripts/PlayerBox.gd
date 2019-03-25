extends PanelContainer

# PlayerBox.gd

onready var index_label = $VBox/HBox/Index
onready var status_label = $VBox/HBox/Status
onready var status_box = $VBox/HBox/StatusRect
onready var country_label = $VBox/HBox/Country
onready var country_box = $VBox/HBox/CountryRect
onready var name_label = $VBox/HBox/Name

export(bool) var is_header = false

func _setup_header(value):
	if !value:
		status_label.visible = false
		status_box.visible = true
		
		country_label.visible = false
		country_box.visible = true
	else:
		status_label.visible = true
		status_box.visible = false
		
		country_label.visible = true
		country_box.visible = false

func _ready():
	if is_header:
		_setup_header(is_header)
