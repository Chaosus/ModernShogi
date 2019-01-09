extends Label

var format
var show_seconds = false
var show_zeros = false

func _ready():
	UI.register_widget(UI.WIDGET_CLOCK, self)

func apply_theme(_theme):
	pass
	
func set_show_seconds(enabled):
	show_seconds = enabled

func set_show_zeroes(enabled):
	show_zeros = enabled

func set_format(format):
	self.format = format

func _process(_delta):
	if visible:
		var time = OS.get_time(false)
		var hours = time["hour"]
		var minutes = time["minute"]
		var seconds = time["second"]
		
		if minutes < 10:
			minutes = "0" + str(minutes)
		else:
			minutes = str(minutes)
			
		if show_seconds:
			if seconds < 10:
				seconds = "0" + str(seconds)
			else:
				seconds = str(seconds)
		
		if format == 0:
			if hours < 10 and show_zeros:
				hours = "0" + str(hours)
			else:
				hours = str(hours)
			if show_seconds:
				text = hours + ":" + minutes + ":" + seconds
			else:
				text = hours + ":" + minutes
		elif format == 1:
			
			var am = hours < 12
			
			hours = wrapi(hours, 0, 12)
			
			if hours < 10:
				if show_zeros:
					hours = "0" + str(hours)
				else:
					hours = str(hours)
			else:
				hours = str(hours)
					
			if show_seconds:
				text = hours + ":" + minutes  + ":" + seconds + (" a.m" if am else " p.m")
			else:
				text = hours + ":" + minutes + (" a.m" if am else " p.m")
				