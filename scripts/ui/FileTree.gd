extends Tree

# FileTree.gd

var _parent_screen

var _profiles_list = []
var _replays_list = {}
var _songs_list = []
var _dir_list = []

var _extension_extractor = RegEx.new()

func _add_replay(path, name, element):
	_replays_list[path + name] = element

func remove_replay(name):
	_replays_list[name].free()
	_replays_list.erase(name)

func _add_profile(element):
	_profiles_list.append(element)

func _add_song(element):
	_songs_list.append(element)

func _dir_process(root, path, name, is_root_dir):
	var item = self.create_item(root)
	item.set_text(0, name)
	item.set_meta("is_root", is_root_dir)
	item.set_meta("path", path)
	_dir_list.append(item)
	return item

func _file_process(root, path, name):
	var item = null
	var ext = _parse_extension(name)
	match ext:
		"profile":
			item = self.create_item(root)
			item.set_text(0, name)
			item.set_meta("path", path)
			_add_profile(item)
			return true
		"kif":
			item = self.create_item(root)
			item.set_text(0, name)
			item.set_meta("path", path) 
			_add_replay(path, name, item)
			return true
		"mkif":
			item = self.create_item(root)
			item.set_text(0, name)
			item.set_meta("path", path) 
			_add_replay(path, name, item)
			return true
		"ogg":
			item = self.create_item(root)
			item.set_text(0, name)
			item.set_meta("path", path)
			_add_song(item)
			return true
	return false

#var dclick = 0

func _on_item_selected():
	#dclick = 0
	var item = self.get_selected()
	if _replays_list.has(item.get_meta("path") + item.get_text(0)):
		_parent_screen.show_play_control()
		_parent_screen.hide_explorer_control()
		_parent_screen.load_replay(item, item.get_meta("path"), item.get_text(0))
	elif _songs_list.has(item):
		_parent_screen.show_play_control()
		_parent_screen.hide_explorer_control()
		_parent_screen.load_song(item.get_meta("path"), item.get_text(0))
	elif _profiles_list.has(item):
		_parent_screen.hide_play_control()
		_parent_screen.hide_explorer_control()
		_parent_screen.load_profile(item.get_meta("path"), item.get_text(0))
	elif _dir_list.has(item):
		_parent_screen.hide_play_control()
		_parent_screen.show_explorer_control()
		_parent_screen.load_folder(item.get_meta("path"),  item.get_text(0), item.get_meta("filecount"), item.get_meta("subdirs"), item.get_meta("filecount2"), item.get_meta("is_root"))

#func _input(event):
#	if _parent_screen.visible:
#		if event is InputEventMouseButton:
#			if event.button_index == 1:
#				if event.pressed:
#					dclick += 1
#					if dclick > 1:
#						dclick = 0
#						var item = self.get_selected()
#						if _replays_list.has(item):
#							_parent_screen._on_LibraryPlayWidget_pressed()
			
func _open_subdirectory(root, path, directory, level):
	var dir = Directory.new()
	var filecount = 0
	var filecount2 = 0
	var subdircount = 0
	path = path + directory + "/"
	if dir.open(path) == OK:
		var dir_child = _dir_process(root, path, directory, level < 2)
		dir_child.set_text(0, directory)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if file_name == '.' or file_name == '..':
				file_name = dir.get_next()
				continue
			if dir.current_is_dir():
				filecount2 +=_open_subdirectory(dir_child, path, file_name, level + 1)
				subdircount += 1
			else:
				if _file_process(dir_child, path, file_name):
					filecount += 1
			file_name = dir.get_next()
		dir_child.set_meta("filecount", filecount)
		dir_child.set_meta("subdirs", subdircount)
		dir_child.set_meta("filecount2", filecount2)
		return filecount + filecount2

func _parse_extension(file_name):
	var result = _extension_extractor.search(file_name)
	if result:
		return result.get_string()
	return null

func _precompile_regex():
	_extension_extractor.compile("(?<=\\.).*$")
	
func _ready():
	_precompile_regex()
	_parent_screen = get_parent().get_parent()
	rect_min_size.x = UI.get_resolution().x - 800
	rect_min_size.y = UI.get_resolution().y - 128
	connect("item_selected", self, "_on_item_selected")

func open_library():
	
	_profiles_list.clear()
	_replays_list.clear()
	_songs_list.clear()
	_dir_list.clear()
	clear()
		
	var dir = Directory.new()
	var path = "user://Library/"
	
	if !dir.dir_exists(path):
		dir.make_dir(path)
	
	if dir.open(path) == OK:
		var root = self.create_item()
		root.set_text(0, "Library")
		
		if !dir.dir_exists(path + "Replays/"):
			dir.make_dir(path + "Replays/")
		
		if !dir.dir_exists(path + "Replays/KIF/"):
			dir.make_dir(path + "Replays/KIF/")
		
		if !dir.dir_exists(path + "Replays/MKIF/"):
			dir.make_dir(path + "Replays/MKIF/")
		
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if file_name == '.' or file_name == '..':
				file_name = dir.get_next()
				continue
			if dir.current_is_dir():
				_open_subdirectory(root, path, file_name, 0)
			
			file_name = dir.get_next()