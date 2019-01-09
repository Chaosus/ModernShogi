extends Node

# BackgroundMusic.gd

onready var player = $BackgroundMusicPlayer

class Song:
	var index
	var name
	var ss

enum {
	PLAY_ORDER_NEXT,
	PLAY_ORDER_RANDOM
}

enum {
	SMSTATE_NONE,
	SMSTATE_DISABLING,
	SMSTATE_ENABLING
}

var extension_extractor = RegEx.new()

func precompile_regex():
	extension_extractor.compile("(?<=\\.).*$")

func _process_composition(path, file_name):
	var song = Song.new()
	song.index = _compositions.size() + 1
	song.name = file_name
	
	var file = File.new()
	file.open(path + file_name, File.READ)
	song.ss = AudioStreamOGGVorbis.new()
	file.seek_end()
	var filesize = file.get_position()
	file.seek(0)
	song.ss.data = file.get_buffer(filesize)
	file.close()
	_compositions.append(song)

func load_compositions():
	var dir = Directory.new()
	var path = "user://Library/Songs/"
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir():
				var result = extension_extractor.search(file_name)
				if result:
					if result.get_string() == "ogg":
						_process_composition(path, file_name)
			file_name = dir.get_next()

var _compositions = []
var _count = 0
var _current_position = 0
var _current_idx = 0
var _smooth_state = SMSTATE_NONE
var _volume_level = 100
var _volume_level_internal
var _order = PLAY_ORDER_NEXT
var _switch = false
var _stopped = false

func set_sound_label(song):
	var label = UI.get_named_element(UI.LABEL_CURRENT_SONG)
	label.text = str(song.index) + ". " + song.name
	
func _ready():
	precompile_regex()
	load_compositions()
	_count = _compositions.size()
	if _count > 0:
		_current_idx = 0
		var c = _compositions[_current_idx]
		set_sound_label(c)
		player.stream = c.ss
	player.connect("finished", self, "play_other_composition")
	UI.music_player = self

func pause():
	_current_position = player.get_playback_position()
	_stopped = true
	player.stop()

func play():
	player.play(_current_position)
	_stopped = false
	player.play()

func set_volume(value):
	_volume_level = value / 100
	player.volume_db = linear2db(clamp(_volume_level, 0.0, 1.0))

func count():
	return _compositions.size()

func next_track():
	if _count > 1:
		_current_idx = wrapi(_current_idx + 1, 0, count())
		
		var c = _compositions[_current_idx]
		set_sound_label(c)
		player.stream = c.ss
		_switch = true
		if !_stopped:
			player.play()

func previous_track():
	if _count > 1:
		_current_idx = wrapi(_current_idx - 1, 0, count())
		
		var c = _compositions[_current_idx]
		set_sound_label(c)
		player.stream = c.ss
		_switch = true
		if !_stopped:
			player.play()	
			
func play_other_composition():
	if !_switch:
		var order = Profiles.get_current_settings().get_value(Settings.SV_SFX_MUSIC_ORDER)
		var temp
		if order == PLAY_ORDER_NEXT:
			temp = wrapi(_current_idx + 1, 0, _compositions.size())
		elif order == PLAY_ORDER_RANDOM:
			temp = randi() % _compositions.size()
			if _compositions.size() > 1:
				while(temp != _current_idx): # prevent loading same composition as before
					temp = randi() % _compositions.size()
		_current_idx = temp
		var c = _compositions[_current_idx]
		set_sound_label(c)
		player.stream = c.ss
		player.play()
	else:
		_switch = false
