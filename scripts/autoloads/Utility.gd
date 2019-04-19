extends Node

# Utility.gd

# Содержит вспомогательные методы

# Возвращает число файлов в папке
func get_file_count(path, name):
	var dir = Directory.new()
	var counter = 0
	var length = name.length()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if file_name == '.' or file_name == '..':
				file_name = dir.get_next()
				continue
			if !dir.current_is_dir():
				if file_name.substr(0, length) == name:
					counter += 1

			file_name = dir.get_next()
	return counter

func delete_file(path : String) -> bool:
	return Directory.new().remove(path) == OK

# Возвращает список под-папок из указанной папки.
func get_dirs(path):
	var dir = Directory.new()
	if dir.open(path) != OK:
		return []
	var dirs = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if file_name == '.' or file_name == '..':
			file_name = dir.get_next()
			continue
		if dir.current_is_dir():
			dirs.append(file_name)
		
		file_name = dir.get_next()
	return dirs

# Возвращает список файлов из указанной папки.
func get_files(path, filter = "", preserve_dir = false):
	var dir = Directory.new()
	if dir.open(path) != OK:
		return []
	var files = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name != ""):
		if file_name == '.' or file_name == '..':
			file_name = dir.get_next()
			continue
		if preserve_dir:
			file_name = path + file_name
		if !dir.current_is_dir():
			if filter != "":
				if file_name.get_extension() == filter:
					files.append(file_name)
			else:
				files.append(file_name)
		
		file_name = dir.get_next()
	return files