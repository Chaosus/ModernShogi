extends "res://scripts/UIScreen.gd"

class Avatar:
	var tag
	var name
	var texture
	func _init(tag, name, texture):
		self.tag = tag
		self.name = name
		self.texture = load("res://ui/avatars/" + texture)
	
class AvatarCategory:
	var name
	var avatars = []
	func _init(name):
		self.name = name
	func append_avatar(avatar):
		avatars.append(avatar)
		return avatar
		
func _ready():
	self.title = "TITLE_AVATAR"

var categories = []

func create_avatars():
	var cat_std = AvatarCategory.new("AVACAT_STANDART")
	cat_std.append_avatar(Avatar.new(Globals.AVA_BLANK_SIMPLE, "AVA_BLANK_SIMPLE", "blank_simple.jpg"))
	cat_std.append_avatar(Avatar.new(Globals.AVA_BLANK_MAN, "AVA_BLANK_MAN", "blank_man.jpg"))
	cat_std.append_avatar(Avatar.new(Globals.AVA_BLANK_WOMAN,"AVA_BLANK_WOMAN", "blank_woman.jpg"))
	categories.append(cat_std)
	
	var cat_symbols = AvatarCategory.new("AVACAT_SYMBOLS")
	cat_symbols.append_avatar(Avatar.new(Globals.AVA_SYMBOL_YINYAN, "AVA_SYMBOL_YINYAN", "yin_yan.png"))
	categories.append(cat_symbols)
	
	var cat_sn = AvatarCategory.new("AVACAT_SUPERNATURAL")
	cat_sn.append_avatar(Avatar.new(Globals.AVA_SN_DRAGON, "AVA_SN_DRAGON1", "dragon.jpg"))
	categories.append(cat_sn)
	
	var cat_girls = AvatarCategory.new("AVACAT_FEMALE")
	cat_girls.append_avatar(Avatar.new(Globals.AVA_GIRL_1, "AVA_GIRL_1", "girl1.jpg"))
	cat_girls.append_avatar(Avatar.new(Globals.AVA_GIRL_2, "AVA_GIRL_2", "girl2.jpg"))
	cat_girls.append_avatar(Avatar.new(Globals.AVA_GIRL_3, "AVA_GIRL_3", "girl3.jpg"))
	cat_girls.append_avatar(Avatar.new(Globals.AVA_GIRL_ELF, "AVA_GIRL_ELF", "elf.jpg"))
	categories.append(cat_girls)
	
	for item in categories:
		add_category(item)
		
func add_category(category):
	var label = Label.new()
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.text = category.name
	label.size_flags_horizontal = Label.SIZE_EXPAND_FILL and Label.SIZE_EXPAND
	label.size_flags_vertical = Label.SIZE_SHRINK_CENTER
	label.rect_min_size = Vector2(300, 190)
	
	var box = get_node("ScrollContainer/Grid/TagContainer/")	
	box.add_child(label)
	
	var cbox = get_node("ScrollContainer/Grid/AvatarContainer/")
	var hbox = HBoxContainer.new()
	hbox.theme = preload("res://themes/hv_big_division.tres")
	cbox.add_child(hbox)
	
	for item in category.avatars:
		#UI.add_country(item.tag, item.name, item.texture)
		var vbox = VBoxContainer.new()
		vbox.theme = preload("res://themes/hv_medium_division.tres")
		var btn = TextureButton.new()
		btn.name = item.name
		btn.rect_min_size = Vector2(150, 150)
		btn.expand = true
		btn.stretch_mode = TextureButton.STRETCH_SCALE
		btn.texture_normal = item.texture
		btn.connect("pressed", self, "set_avatar", [ btn, item.tag ] )
		vbox.add_child(btn)
		var desc = Label.new()
		desc.text = item.name
		desc.align = Label.ALIGN_CENTER
		desc.valign = Label.VALIGN_CENTER
		desc.add_font_override("font", preload("res://material/fonts/small_font.tres"))
		vbox.add_child(desc)
		hbox.add_child(vbox)
		
func set_avatar(button, tag):
	pass
