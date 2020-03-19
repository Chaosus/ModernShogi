extends Area

# Tile.gd

onready var move_ally_mesh = $Meshes/MoveAllyMesh
onready var move_enemy_mesh = $Meshes/MoveEnemyMesh
onready var protect_enemy_mesh = $Meshes/ProtectEnemyMesh
onready var protect_ally_mesh = $Meshes/ProtectAllyMesh
onready var select_ally_mesh = $Meshes/SelectAllyMesh
onready var select_neutral_mesh = $Meshes/SelectNeutralMesh
onready var select_enemy_mesh = $Meshes/SelectEnemyMesh
onready var last_move_mesh = $Meshes/LastMoveMesh

var gameplay
var game_instance
var board

var pos = Vector2(-1, -1)
var letter = ""
var highlighted = false
var piece = null
var temp_piece = null
var sente_attacks = []
var gote_attacks = []
var sente_protects = []
var gote_protects = []
var debug_mode = false
var x
var y

# Соседние клетки

var nest_left = null
var nest_right = null
var nest_up = null
var nest_down = null
var nest_left_up = null
var nest_left_down = null
var nest_right_up = null
var nest_right_down = null

func get_piece_pos():
	return translation + Vector3(0, Globals.SHOGI_PIECE_SIZE_Y, 0)

func hide_all_masks():
	move_ally_mesh.visible = false
	move_enemy_mesh.visible = false
	protect_enemy_mesh.visible = false
	protect_ally_mesh.visible = false
	select_ally_mesh.visible = false
	select_neutral_mesh.visible = false
	select_enemy_mesh.visible = false
	
func cleanup():
	hide_all_masks()
	highlighted = false
	piece = null
	temp_piece = null
	sente_attacks.clear()
	gote_attacks.clear()
	sente_protects.clear()
	gote_protects.clear()

func empty():
	return piece == null

func clear_attacks(side):
	if side == 0:
		sente_attacks.clear()
	elif side == 1:
		gote_attacks.clear()

func clear_all_attacks():
	clear_attacks(0)
	clear_attacks(1)

func get_neightbour(v):
	var next = null
	if v.x < 0 and v.y == 0:
		next = nest_left
	elif v.x > 0 and v.y == 0:
		next = nest_right
	elif v.x == 0 and v.y < 0:
		next = nest_up
	elif v.x == 0 and v.y > 0:
		next = nest_down
	elif v.x < 0 and v.y < 0:
		next = nest_left_up
	elif v.x > 0 and v.y < 0:
		next = nest_right_up
	elif v.x < 0 and v.y > 0:
		next = nest_left_down
	elif v.x > 0 and v.y > 0:
		next = nest_right_down
	return next

func update_scale():
	var thickness = Profiles.get_current_settings().styles_grid_thickness_val()
	$Meshes.scale.x = board.board_scale / 2 - (thickness * 2)
	$Meshes.scale.z = board.board_scale / 2 - (thickness * 2)

# Устанавливает гнездо
func setup(game_instance, x, y):
	self.game_instance = game_instance
	self.gameplay = game_instance.session.game_template
	self.board = game_instance.board
	pos = Vector2(x, y)
	
	if !gameplay.tiles_even:
		scale.z += board.board_scale / 19
	
	#scale.x += board.line_thickness * 1.5
	#scale.z += board.line_thickness * 1.5
	
	self.x = game_instance.session.game_template.width - x + 1
	self.y = y
	
	letter = Checks.get_index_letter(pos.y)
	
	translation = board.get_boardpos(x, y) + Vector3(0, 0.001, 0)

func mark_tile(mode, mark):
	match mode:
		Globals.MarkMode.SELECT:
			select_ally_mesh.visible = mark
		Globals.MarkMode.ENEMY_SELECT:
			select_enemy_mesh.visible = mark
		Globals.MarkMode.MOVE:
			move_ally_mesh.visible = mark
		Globals.MarkMode.ENEMY_MOVE:
			move_enemy_mesh.visible = mark
		Globals.MarkMode.PROTECTION:
			protect_ally_mesh.visible = mark
		Globals.MarkMode.ENEMY_PROTECTION:
			protect_enemy_mesh.visible = mark
		Globals.MarkMode.LAST_MOVE:
			last_move_mesh.visible = mark

func mark_last_move(mark):
	mark_tile(Globals.MarkMode.LAST_MOVE, mark)

func get_tile_str():
	return str(x)+","+str(y)

func get_piece_str():
	if piece != null:
		return piece.get_fullname() + " sente attacks = " + str(sente_attacks.size()) + " gote attacks = " + str(gote_attacks.size()) 
	else:
		return " sente attacks = " + str(sente_attacks.size()) + " gote attacks = " + str(gote_attacks.size()) 


# Функция сокрытия всех меток тайлов
func hide_masks():
	select_ally_mesh.visible = false
	select_neutral_mesh.visible = false
	select_enemy_mesh.visible = false
	
#	move_ally_mesh.visible = false
#	move_enemy_mesh.visible = false
#	protect_ally_mesh.visible = false
#	protect_enemy_mesh.visible = false

func highlight_debug():
	move_ally_mesh.visible = true
	debug_mode = true

func is_promotable_for(piece):
	if piece.in_storage:
		return false
	if piece.side == 0:
		if pos.y <= 3 or piece.get_pos().y <= 3:
			return true
	elif piece.side == 1:
		if pos.y >= 7 or piece.get_pos().y >= 7:
			return true
	return false

# Функция выделения клетки.
func highlight(enable):
	var mp = game_instance.session.is_multiplayer()
	var cside = game_instance.session.turn_side if game_instance.session.is_pvp() else game_instance.session.get_your_side()
	var side = game_instance.session.get_your_side() if mp else cside
	
	if debug_mode:
		return false
	highlighted = enable
	if enable:
		# снять выделение с предыдущего тайла
		if game_instance.current_nest != null:
			if game_instance.current_nest != self:
				game_instance.current_nest.highlight(false)
		
		# поменять текущий тайл на выделенный
		game_instance.current_nest = self
		
		hide_masks()
		if piece != null:
			if piece.side == side:
				select_ally_mesh.visible = true
			else:
				select_enemy_mesh.visible = true
		else:
			select_neutral_mesh.visible = true
	else:
		game_instance.current_nest = null
		hide_masks()
	
	# показывать возможные ходы фигуры при наведении
	if game_instance.current_piece == null:
		if piece != null:
			if piece.side != side:
				if Profiles.get_value(Settings.SV_GAME_AUTOSHOW) == Settings.HighlightOptions.ALL:
					piece.show_enemy_moves(enable)
					return true
			else:
				if !enable:
					if piece == game_instance.current_piece:
						return false
				# не показывать свои ходы во время хода другого игрока(?)
				#if mp and enable and !game_instance.is_your_turn():
				#	return
				var option = Profiles.get_value(Settings.SV_GAME_AUTOSHOW)
				if option == Settings.HighlightOptions.ALL or option == Settings.HighlightOptions.MYSELF:
					piece.show_moves(enable)
					return true
	return false

# Функция нажатия на клетку главным действием.
func main_action():
	if game_instance.nest_select_lock:
		return
	if game_instance.has_panel_focus():
		return
	if game_instance.session.is_observer():
		return
	if piece != null:
		# выбор другой фигуры
		if piece.side == game_instance.session.turn_side:
			piece.select()
		else:
			# если ваша фигура выбрана
			if game_instance.current_piece != null:
				# попытаться съесть другую фигуру
				game_instance.current_piece.move_or_eat(self, game_instance.session.is_multiplayer(), -1)
	else: # пустой тайл
		# если ваша фигура выбрана
		if game_instance.current_piece != null:
			# попытаться зайти вашей фигурой в текущий тайл
			game_instance.current_piece.move_or_eat(self, game_instance.session.is_multiplayer(), -1)

func hide_tooltip():
	UI.get_helper().hide_tooltip()

func show_tooltip():
	var pos_str = str(x) + "," + str(y) + " (" + str(x) + "," + letter + ")"
	if piece != null:
		UI.get_helper().show_cursor_tooltip(pos_str + "\n" + piece.get_fullname(), Vector2(0.0, -80.0))
	else:
		UI.get_helper().show_cursor_tooltip(pos_str, Vector2(0.0, -80.0))
		
func secondary_action():
	
	if game_instance.current_tooltip_nest != self:
		show_tooltip()
		game_instance.current_tooltip_nest = self
	else:
		if UI.get_helper().visible:
			hide_tooltip()
		else:
			show_tooltip()
	
		# if game_instance.nest_select_lock:
		# return
		#if piece != null:
		#if gameplay.gamemode == Games.GAME_MODE_EDITOR:
		#	piece.promote()

var already_showed_moves = false
var mouse_over_piece = false

func _physics_process(delta):
	if visible:
		if mouse_over_piece:
			if !already_showed_moves:
				if game_instance.nest_select_lock:
					return
				else:
					_on_PieceNest_mouse_entered()
			
func _on_PieceNest_mouse_entered():
	mouse_over_piece = true
	if game_instance.nest_select_lock:
		return
	already_showed_moves = highlight(true)
	
func _on_PieceNest_mouse_exited():
	mouse_over_piece = false
	already_showed_moves = false
	highlight(false)
