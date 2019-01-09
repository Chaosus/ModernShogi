extends Control
class_name BeautyElement

#########################################################################
#							BeautyElement.gd
#########################################################################
# Базовый класс для перезаписи поведения элементов интерфейса игры.
#########################################################################

# Сигнал совершения скрытия или показа элемента
signal fade_completed

# Сигнал совершения показа элемента
signal show_completed

# Сигнал совершения скрытия элемента
signal hide_completed

# Состояние элемента
enum ShowState {
	NONE = 0, # элемент виден
	HIDDEN = 1, # элемент скрыт
	SHOW = 2, # элемент в процессе показа
	HIDE = 3 # элемент в процессе скрытия
}

# Скорость скрытия/показа элемента
export(float) var fade_speed = 3.0

# Скрыть элемент по настоящему после скрытия
export(bool) var hide_after_fade = true

# Элемент скрыт по умолчанию
export(bool) var hidden_by_default = false

# (private) Состояние элемента.
var _state = ShowState.NONE

func show_or_hide():
	if _state == ShowState.NONE:
		beautiful_hide()
	else:
		beautiful_show()

# Стартовая функция
func _ready():
	setup()

# Начальная установка
func setup():
	if hidden_by_default:
		_state = ShowState.HIDDEN
		if hide_after_fade:
			hide()
	else:
		_state = ShowState.NONE

# Возвращает состояние показа элемента
func get_show_state():
	return _state

# Немедленно показывает элемент, минуя фазы анимации, возвращает самого себя.
func immediate_show():
	_state = ShowState.NONE
	show()
	return self

# Показывает элемент, возвращает самого себя.
func beautiful_show():
	_state = ShowState.SHOW
	show()
	return self

# Скрывает элемент, возвращает самого себя.
func beautiful_hide():
	_state = ShowState.HIDE
	return self
