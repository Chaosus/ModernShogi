extends Area

# StorageNest.gd

onready var mesh = $Mesh
onready var material = preload("res://materials/storage_nest.tres")
onready var material_opp = preload("res://materials/storage_nest_opponent.tres")

var game_instance
var piece_type
var dummy
var side
var x_index
var z_index
var board
var pieces = []
var selected = false
var text = null

func add_moves():
	var move_count = 0
	if !pieces.empty():
		var piece = pieces.back()
		move_count += piece.add_moves()
	return move_count

func empty():
	return pieces.empty()

func update_top_piece():
	if !pieces.empty():
		var piece = pieces.back()
		piece.update_moves()

func update_temp_moves():
	if !pieces.empty():
		var piece = pieces.back()
		piece.update_temp_moves()

func remove_checkmate_moves():
	if !pieces.empty():
		var piece = pieces.back()
		piece.remove_checkmate_moves()

func update_realmoves_top_piece():
	if !pieces.empty():
		var piece = pieces.back()
		piece.update_real_moves()

func size():
	return pieces.size()

func get_piece_pos():
	return translation + Vector3(0, Globals.SHOGI_PIECE_SIZE_Y, 0)

func get_sfen():
	if pieces.size() > 0:
		if pieces.size() == 1:
			return Checks.get_sfen_piece_symbol(piece_type, side, false)
		return str(pieces.size()) + Checks.get_sfen_piece_symbol(piece_type, side, false)
	else:
		return ""
		
func _ready():
	add_to_group("storage_nest")
	visible = false
	mesh.visible = false

func update_text():
	if text == null:
		return
	if pieces.size() == 0:
		text.visible = false
	else:
		text.visible = true
	text.set_text(str(pieces.size()))
	text.update()

func peek_top_piece():
	if pieces.size() > 0:
		return pieces.back()
	else:
		return null

func select_top_piece():
		
	var piece = pieces.back()
	
	if !piece.selected:
		if pieces.size() > 1:
			dummy.visible = true
	
	piece.visible = true
	piece.select()
	
	if piece.selected:
		if pieces.size() - 1 <= 0:
			text.visible = false
		else:
			text.set_text(str(pieces.size()-1))
	else:
		text.set_text(str(pieces.size()))
		text.visible = true
	text.update()
	
	return piece

func push(piece):
	
	visible = true
	piece.translation = translation
	
	var prev_piece = peek_top_piece()
	if prev_piece != null:
		prev_piece.on_top = false
		prev_piece.visible = false
		
	piece.last_storage_stack = self
	pieces.push_back(piece)
	
	piece.visible = true
	piece.on_top = true
	
	if text != null:
		text.visible = true
		
	update_text()

func pop():
	var piece = pieces.pop_back()
	piece.on_top = false
	
	var prev_piece = peek_top_piece()
	if prev_piece != null:
		prev_piece.on_top = true
		prev_piece.visible = true
	else:
		visible = false
	
	update_text()
	return piece

func clear():
	for piece in pieces:
		piece.free()
	pieces.clear()
	
func cleanup():
	for piece in pieces:
		piece.free()
	pieces.clear()
	if text != null:
		text.free()
		text = null
	
func setup(piece_template, side, x_index, importance, board):
	input_ray_pickable = true
	
	self.piece_type = piece_template.type
	self.side = side
	self.x_index = x_index
	self.z_index = importance
	self.board = board
	self.game_instance = board.game_instance
	
	var offset_x = 4.15 + x_index
	var offset_z = 1.0 + (z_index * 1.5)
	if side == 0:
		translation = Vector3(offset_x * board.board_scale, Globals.SHOGI_PIECE_SIZE_Y, offset_z * board.board_scale)
	else:
		translation = Vector3(-offset_x * board.board_scale, Globals.SHOGI_PIECE_SIZE_Y, -offset_z * board.board_scale)
	
	
	if importance == Games.PieceImportance.MEDIUM:
		scale.x = 0.85
		scale.z = 0.85
	
	if importance == Games.PieceImportance.MAJOR:
		scale.x = 1.0
		scale.z = 1.0
	
	scale.y = 1.0
	
	var text_prefab  = preload("res://scenes/TextFlat3D.tscn")
	text = text_prefab.instance()
	text.add_to_group("storage_text")
	add_child(text)
	text.set_as_toplevel(true)
	text.translation += Vector3(0, -1.159, 0)
	text.rotation.y = deg2rad(180)
	
	var v = Vector2(0.0, 1.6) #Vector2(-0.25 if side == 0 else 0.25, 1.8)
	text.translation += ((Vector3(-v.x, 0, v.y) if side == 0 else Vector3(v.x, 0, -v.y)))

	# Создание обманки фигуры
	
	dummy = preload("res://scenes/Dummy.tscn").instance()
	dummy.setup(piece_template, side)
	dummy.visible = false
	add_child(dummy)
	
func _input(event):
	if game_instance.nest_select_lock:
		return
	if event is InputEventMouseButton:
		if visible:
			if selected:
				if event.pressed:
					if event.button_index == 1:
						if game_instance.session.turn_side == side:
								select_top_piece()

func invert(side):
	if side == 1:
		text.rotation.y = 0
	elif side == 0:
		text.rotation.y = deg2rad(180)

func nest_update():
	var side
	if game_instance.session.is_multiplayer():
		side = game_instance.session.get_your_side()
	else:
		side = game_instance.session.turn_side
	
	if self.side == side:
		mesh.set_surface_material(0, material)
	else:
		mesh.set_surface_material(0, material_opp)
	
func _on_StorageNest_mouse_entered():
	if game_instance.nest_select_lock:
		return
	var piece = peek_top_piece()
	if piece != null:
		var side
		if game_instance.session.is_multiplayer():
			side = game_instance.session.get_your_side()
		else:
			side = game_instance.session.turn_side
		
		if side != self.side:
			if Profiles.get_value(Settings.SV_GAME_AUTOSHOW) == Settings.HighlightOptions.ALL:
				piece.show_enemy_moves(true)
		else:
			var option = Profiles.get_value(Settings.SV_GAME_AUTOSHOW)
			if option == Settings.HighlightOptions.ALL or option == Settings.HighlightOptions.MYSELF:
				piece.show_moves(true)
	nest_update()
	if visible:
		mesh.visible = true
		if !game_instance.session.is_replay():
			selected = true

func _on_StorageNest_mouse_exited():
	if game_instance.nest_select_lock:
		return
	var piece = peek_top_piece()
	if piece != null:
		if !piece.selected:
			piece.disable_all_moves()
	nest_update()
	if visible:
		mesh.visible = false
		selected = false
