extends Spatial

signal anim_completed
signal select_completed

enum SpeedType {
	MOVE, # скорость перемещения
	LIFT, # скорость поднятия и опускания
	REVERT	# скорость переворота
}

func get_move_speed(speed_type):
	var game_speed_preset = game_instance.game_speed
	match speed_type:
		SpeedType.MOVE:
			match game_speed_preset:
				Games.GameSpeed.SLOW:
					return 7
				Games.GameSpeed.MEDIUM:
					return 15
				Games.GameSpeed.HIGH:
					return 30
		SpeedType.LIFT:
			match game_speed_preset:
				Games.GameSpeed.SLOW:
					return 4
				Games.GameSpeed.MEDIUM:
					return 8
				Games.GameSpeed.HIGH:
					return 12
		SpeedType.REVERT:
			match game_speed_preset:
				Games.GameSpeed.SLOW:
					return 6
				Games.GameSpeed.MEDIUM:
					return 12
				Games.GameSpeed.HIGH:
					return 18
	return 0

const UPPER_H = 0.8 # высота поднятия

onready var mesh = $Mesh

var piece_template = null
var game_template = null
var game_instance = null
var game_session = null
var board = null

var nest = null # гнездо нахождения
var side = 0 # 0 - сентэ, 1 - готэ, далее цифры для вариантов с 3-4 игроками
var special = 0 # специальное состояние(для превращений и прочее)
var selected = false # выбрана ли фигура ?
var temp_moves = [] # временные ходы
var current_moves = [] # текущие ходы
var protected_moves = [] # защищаемые клетки
var in_storage # фигура в резерве
var last_storage_stack # последнее хранилище в котором эта фигура была
var disabled
var was_promoted = false
var need_update = true
var was_need_update = false
var on_top = false
var prev_nest = null
	

func get_en_symbol():
	var s = Checks.get_piece_symbol(get_type(), Games.NotationLetters.ENGLISH, is_promoted())
	if side == 1:
		return s.to_upper()
	return s

# Возвращает значимость фигуры для AI
func get_weight():
	if in_storage:
		return piece_template.weight * 1.3 # 30%
	var weight = piece_template.promoted_weight if is_promoted() else piece_template.weight
	return weight

# Возвращает true если фигура играет королевскую роль
func is_royal():
	return piece_template.type == Games.ShogiPieceTypes.KING

# Возвращает true если фигура была превращена
func is_promoted():
	return special == Games.PieceStates.PROMOTED

# Возвращает имя фигуры
func get_name():
	if is_promoted():
		return piece_template.get_promoted_name()
	else:
		return piece_template.get_name()
		
# Возвращает тип фигуры
func get_type():
	return piece_template.type

# Возвращает позицию фигуры, или -1, -1 если фигура в резерве
func get_pos():
	if in_storage:
		return Vector2(-1, -1)
	return Vector2(nest.x, nest.y)

# Начальная настройка фигуры
func setup(template, game, nest, side, special = Games.PieceStates.NORMAL):
	self.piece_template = template
	self.nest = nest
	if nest != null:
		nest.piece = self
	else:
		in_storage = true
		last_storage_stack = game.session.players[side].get_storage_stack(template.type)
	self.side = side
	self.special = special
	if special == Games.PieceStates.PROMOTED:
		rotation.z = PI
	
	self.game_template = game.session.game_template
	self.game_instance = game
	self.game_session = game.session
	self.board = game.board
	
	self.mesh.mesh = template.mesh
	if nest != null:
		translation = nest.get_translation() + Vector3(0, Globals.SHOGI_PIECE_SIZE_Y, 0)
	if side==0:
		rotation.y = deg2rad(180)
	update_piece_theme()
	if template.importance == Games.PieceImportance.MINOR:
		scale -= Vector3(0.15, 0.0, 0.15)
	elif template.importance == Games.PieceImportance.MAJOR:
		scale += Vector3(0.15, 0.0, 0.15)
	add_to_group("piece")
		
###############################################
# Функции маркирования доски возможными ходами
###############################################

func append_attack(nest, piece):
	if piece.in_storage:
		return
	if side == 0:
		nest.sente_attacks.append(piece)
	elif side == 1:
		nest.gote_attacks.append(piece)

func erase_attack(nest, piece):
	if side == 0:
		nest.sente_attacks.erase(piece)
	elif side == 1:
		nest.gote_attacks.erase(piece)

func append_move(nest):
	if !temp_moves.has(nest):
		temp_moves.append(nest)

func append_drop_move(nest):
	append_move(nest)

func append_protection(nest):
	if !protected_moves.has(nest):
		var protects = nest.sente_protects if side == 0 else nest.gote_protects
		if !protects.has(self):
			protects.append(self)
		protected_moves.append(nest)

func erase_move(nest):
	if !temp_moves.has(nest):
		temp_moves.erase(nest)

func append_real_move(nest):
	if current_moves.has(nest):
		return
	append_attack(nest, self)
	current_moves.append(nest)	
	
func add_moves():
	for target in current_moves:
		game_session.players[side].moves.append(Moves.Move.new(self, target, false))
		match(get_target_promotion_type(target)):
			PromotionType.NO:
				game_session.players[side].ai_moves.append(Moves.Move.new(self, target, false))
			PromotionType.YES:
				game_session.players[side].ai_moves.append(Moves.Move.new(self, target, false))
				game_session.players[side].ai_moves.append(Moves.Move.new(self, target, true))
			PromotionType.FORCE_YES:
				game_session.players[side].ai_moves.append(Moves.Move.new(self, target, true))
	return current_moves.size()

var temp_nest = null
#var temp_storage = false


func make_virtual_move(target):
	if self.nest != null:
		self.nest.piece = null
	self.nest = target
	self.nest.piece = self
	return game_instance.get_moves(1 if self.side == 0 else 0)
	
func make_temp_move(new_nest):
	
	# Удаляем старое место фигуры и сохраняем его в буфере
	if self.nest != null:
		self.nest.temp_piece = self
		self.nest.piece = null

	temp_nest = self.nest
	# Сохраняем старую фигуру
	new_nest.temp_piece = new_nest.piece
	if new_nest.temp_piece != null:
		new_nest.temp_piece.disabled = true
	# Присваиваем новое место фигуре
	self.nest = new_nest
	new_nest.piece = self

func restore_temp_move():
	# Восстанавливаем старую фигуру
	if self.nest.temp_piece != null:
		self.nest.temp_piece.disabled = false
	self.nest.piece = self.nest.temp_piece
	self.nest.temp_piece = null
	
	self.nest = temp_nest
	if self.nest != null:
		self.nest.piece = self
	
# Удаляет невозможные ходы из массива временных ходов(МЕДЛЕННО И НЕПРАВИЛЬНО)
func remove_checkmate_moves():
	
	var erase_nests = []
	
	for nest in temp_moves:
		make_temp_move(nest)
		
		#game_instance.update_test_moves(0)
		#game_instance.update_test_moves(1)
		
		game_instance.update_test_moves(1 if side == 0 else 0)
		
		if game_instance.king_in_check(side):
			erase_nests.append(nest)
	 	
		restore_temp_move()
		game_instance.clear_attacks()
	 
	for nest in erase_nests:
		if temp_moves.has(nest):
			temp_moves.erase(nest)

# Обновляет временные ходы
func update_temp_moves():
	if in_storage:
		return
	if !disabled:
		game_template.make_moves(self, true)

# Преобразует временные ходы в возможные ходы
func update_real_moves():
	current_moves.clear() # очистка массива предыдущих ходов
	
	for nest in temp_moves:
		append_real_move(nest)

func has_move(move):
	if current_moves.has(move) or protected_moves.has(move):
		return true
	return false
 
func clear_moves():
	temp_moves.clear() # очистка массива временных ходов
	
	for nest in protected_moves:
		var protects = nest.sente_protects if side == 0 else nest.gote_protects
		if protects.has(self):
			protects.erase(self)
	protected_moves.clear() # очистка массива защитных ходов
	
# Создаёт массив временных ходов
func update_moves():
	clear_moves()
	game_template.make_moves(self, false)

func get_moves():
	return current_moves

func show_moves(mark):
	for move in current_moves:
		move.mark_tile(Globals.MarkMode.MOVE, mark)
	for move in protected_moves:
		move.mark_tile(Globals.MarkMode.PROTECTION, mark)

# Скрывает все ходы
func _hide_moves():
	for move in current_moves:
		move.mark_tile(Globals.MarkMode.MOVE, false)
	for move in protected_moves:
		move.mark_tile(Globals.MarkMode.PROTECTION, false)
	for move in current_moves:
		move.mark_tile(Globals.MarkMode.ENEMY_MOVE, false)
	for move in protected_moves:
		move.mark_tile(Globals.MarkMode.PROTECTION, false)

func show_enemy_moves(mark):
	for move in current_moves:
		move.mark_tile(Globals.MarkMode.ENEMY_MOVE, mark)
	for move in protected_moves:
		move.mark_tile(Globals.MarkMode.PROTECTION, mark)

func disable_all_moves():
	for move in current_moves:
		move.mark_tile(Globals.MarkMode.MOVE, false)
	for move in protected_moves:
		move.mark_tile(Globals.MarkMode.PROTECTION, false)
	for move in current_moves:
		move.mark_tile(Globals.MarkMode.ENEMY_MOVE, false)

func update_piece_theme():
	var texture = piece_template.get_texture()
	var shader = preload("res://materials/Piece.shader")
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_param("piece_texture", texture)
	mesh.material_override = material

func hide_current_nest_masks():
	if game_instance.current_nest != null:
		if game_instance.current_nest.piece != null:
			game_instance.current_nest.hide_masks()
			game_instance.current_nest.piece._hide_moves()

func get_player():
	return game_session.players[side]

# Применяется для хода назад по истории
func move_backward(record, boost):
	if !boost:
		# заблокировать тайлы во время хода фигуры
		game_instance.nest_select_lock = true
	
	hide_current_nest_masks()
	
	var prev_nest = record.prev_nest
	var next_nest = record.next_nest
	var eaten = record.eaten
	
	var steps = 0
	var drop = record.drop
	
	if drop:
		prev_nest = get_player().get_storage_stack(get_type())
		steps += prev_nest.size()
	
	if !boost:
		_lift_up(0)
		yield(self, "anim_completed")
	
	if self.is_promoted():
		if record.piece_was_promoted:
			if boost:
				self.unpromote()
			else:
				_revert()
				yield(self, "anim_completed")
				self.unpromote()
	
	# Вернуть съеденную фигуру
	if eaten != null:
		if eaten.last_storage_stack != null:
			eaten.last_storage_stack.pop()
		eaten.need_update = true
		eaten.last_storage_stack = null
		eaten.in_storage = false
		eaten._change_side(1 if eaten.side == 0 else 0)
		eaten.nest = next_nest
		record.next_nest.piece = eaten
		eaten.temp_moves.clear()
		if boost:
			eaten.translation = next_nest.get_piece_pos()
		else:
			eaten._lift_up(0)
			yield(eaten, "anim_completed")
			eaten._move_to_nest(next_nest)
			yield(eaten, "anim_completed")
			eaten.show_moves(false)
		get_player().all_pieces.erase(eaten)
		eaten.get_player().all_pieces.append(eaten)
		if record.eaten_was_promoted:
			eaten.promote(boost)
		if !boost:
			eaten._lift_down(0)
			yield(eaten, "anim_completed")
	
	disable_all_moves()
	selected = false
	
	if !boost:
		_move_to_nest(prev_nest)
		yield(self, "anim_completed")
	else:
		self.translation = prev_nest.get_piece_pos()
		if drop:
			prev_nest.push(self)
	
	#if drop:
	#	if !boost:
			#_lift_down()
			#yield(self, "anim_completed")
		#prev_nest.push(self)
		
	temp_moves.clear()
	
	# завершить ход
	
	self.nest.hide_masks()
	if eaten == null:
		self.nest.piece = null
	
	# не играть звуки и не опускать фигуру, если включена быстрая перемотка
	if !boost:
		_lift_down(0)
		yield(self, "anim_completed")
		
		if drop:
			prev_nest.push(self)
			
		var sfx
		if Profiles.get_current_settings().get_value(Settings.SV_SFX_MOVE_ENABLED):
			if Profiles.get_current_settings().get_value(Settings.SV_SFX_3D_ENABLED):
				sfx = game_instance.get_node("MoveSFX3D")
				sfx.translation = translation
			else:
				sfx = game_instance.get_node("MoveSFX")
			sfx.play()
			
	if !drop:
		self.nest = prev_nest
		self.nest.piece = self
		mark_need_update(prev_nest, next_nest)
	else:
		prev_nest = null
		self.nest = null
		self.in_storage = true
		self.on_top = true
		set_mark(false)
	
	set_mark(false)
	
	game_instance.backward_turn(boost)

# Применяется для хода вперёд по истории
func move_forward(record, boost):
	if !boost:
		# заблокировать тайлы во время хода фигуры
		game_instance.nest_select_lock = true
	
	hide_current_nest_masks()
	
	var prev_nest = record.prev_nest
	var next_nest = record.next_nest
	var drop = record.drop
	
	if drop:
		var stack = get_player().get_storage_stack(get_type())
		stack.pop()
		self.in_storage = false
		stack.update_text()
	
	disable_all_moves()
	selected = false
	
	# не поднимать фигуру если ускорение включено
	if !boost:
		_lift_up(0)
		yield(self, "anim_completed")
			
	# не перемещать фигуру если ускорение включено
	if !boost:
		_move_to_nest(next_nest)
		yield(self, "anim_completed")
	else:
		self.translation = next_nest.get_piece_pos()
	
	# превратить фигуру
	if record.piece_was_promoted:
		self.promote(boost)
		if !boost:
			yield(self, "anim_completed")
	
	if next_nest.piece != null:
		next_nest.piece.set_mark(false)
		record.eaten = next_nest.piece
		record.eaten_was_promoted = record.eaten.is_promoted()
		game_instance.eat(record.eaten, self)
	else:
		record.eaten = null
		
	temp_moves.clear()
	
	# завершить ход
	
	if !drop:
		self.nest.hide_masks()
		self.nest.piece = null
	
	# не играть звуки и не опускать фигуру, если включена быстрая перемотка
	if !boost:
		_lift_down(0)
		yield(self, "anim_completed")
		var sfx
		if Profiles.get_current_settings().get_value(Settings.SV_SFX_MOVE_ENABLED):
			if Profiles.get_current_settings().get_value(Settings.SV_SFX_3D_ENABLED):
				sfx = game_instance.get_node("MoveSFX3D")
				sfx.translation = translation
			else:
				sfx = game_instance.get_node("MoveSFX")
			sfx.play()
	
	self.nest = next_nest
	self.nest.piece = self
	
	if game_instance.last_selected_piece != null:
		game_instance.last_selected_piece.set_mark(false)
		#if game_instance.last_selected_piece.prev_nest != null:
		#	game_instance.last_selected_piece.prev_nest.mark_last_move(false)
	game_instance.last_selected_piece = self
	if Profiles.get_value(Settings.SV_GAME_LASTMOVE_ENABLED):
		game_instance.last_selected_piece.set_mark(true)
		#if game_instance.last_selected_piece.prev_nest != null:
		#	game_instance.last_selected_piece.prev_nest.mark_last_move(true)
	
	mark_need_update(prev_nest, next_nest)
	game_instance.forward_turn(boost, next_nest, prev_nest, record.piece_was_promoted)

enum PromotionType {
	NO,
	YES,
	FORCE_YES
}

func get_target_promotion_type(target):
	if !piece_template.special.has(Games.PieceTag.PROMOTABLE) or in_storage:
		return PromotionType.NO
		
	if piece_template.type == Games.ShogiPieceTypes.KNIGHT:
		if side == 0:
			if target.y == 1 or target.y == 2:
				return PromotionType.FORCE_YES
		else:
			if target.y == game_template.depth or target.y == game_template.depth - 1:
				return PromotionType.FORCE_YES
				
	elif piece_template.type == Games.ShogiPieceTypes.PAWN or piece_template.type == Games.ShogiPieceTypes.LANCE:
		if side == 0:
			if target.y == 1:
				return PromotionType.FORCE_YES
		else:
			if target.y == game_template.depth:
				return PromotionType.FORCE_YES		

	if target.is_promotable_for(self):
		return PromotionType.YES
	
	return PromotionType.NO

func set_mark(mark):
	mesh.material_override.set_shader_param("selected", 1.0 if mark else 0.0)

# Метод обычного перемещения фигуры в основной игре, не используется в повторах
func move_or_eat(next_nest, is_mp_move, promote):
	if current_moves.has(next_nest):
		game_instance.piece_lock = true
		game_instance.nest_select_lock = true
		var promoted
		if promote == 0:
			promoted = false
		elif promote == 1:
			promoted = true
		elif promote == -1:
			promoted = false
			if piece_template.special.has(Games.PieceTag.PROMOTABLE):
				if !is_promoted():
					# forced promotion
					var pos = next_nest.pos
					# dirty hack I should fix it
					if game_template.tag == Games.GameType.SHOGI:
						if piece_template.type == Games.ShogiPieceTypes.KNIGHT:
							if side == 0:
								if pos.y == 1 or pos.y == 2:
									promoted = true
							else:
								if pos.y == game_template.depth or pos.y == game_template.depth - 1:
									promoted = true
						elif piece_template.type == Games.ShogiPieceTypes.PAWN or piece_template.type == Games.ShogiPieceTypes.LANCE:
							if side == 0:
								if pos.y == 1:
									promoted = true
							else:
								if pos.y == game_template.depth:
									promoted = true
					
					if !promoted:
						if next_nest.is_promotable_for(self):				
							if Profiles.get_current_settings().get_value(Settings.SV_GAME_AUTOPROMOTION_ENABLED):
								if piece_template.type == Games.ShogiPieceTypes.LANCE:
									if side == 0:
										if next_nest.pos.y == 2:
											promoted = true
									elif side == 1:
										if next_nest.pos.y == 8:
											promoted = true
								elif piece_template.type == Games.ShogiPieceTypes.PAWN or piece_template.type == Games.ShogiPieceTypes.BISHOP or piece_template.type == Games.ShogiPieceTypes.ROOK:
									promoted = true
							if !promoted:
								game_instance.gui.show_promotion_dialog(self)
								yield(game_instance.gui.get_promotion_dialog(), "done")
								var result = game_instance.gui.get_promotion_dialog_result()
								if result == 1:
									promoted = true
		
		if is_mp_move:
			if !in_storage:
				game_instance.send_move(self, self.nest.x, self.nest.y, next_nest.x, next_nest.y, promoted)
			else:
				game_instance.send_drop_move(self, next_nest.x, next_nest.y)
			return
		
		if !Profiles.get_value(Settings.SV_GAME_LASTMOVE_ENABLED):
			set_mark(false)
		
		var steps = 0
		if in_storage:
			if last_storage_stack != null:
				last_storage_stack.pop()
				steps += last_storage_stack.size()
				last_storage_stack = null
		show_moves(false)
		next_nest.mark_tile(Globals.MarkMode.SELECT, true)
		selected = false
		if is_skip_anim():
			_teleport_to_nest(next_nest)
		else:
			_move_to_nest(next_nest)
			yield(self, "anim_completed")
		
		if promoted == true:
			if is_skip_anim():
				promote(true)
			else:
				promote(false)
				yield(self, "anim_completed")
		
		temp_moves.clear()
		
		var eaten = null
		if next_nest.piece != null:
			eaten = next_nest.piece
			eaten.set_mark(false)
			eaten.was_promoted = eaten.is_promoted()
			game_instance.eat(next_nest.piece, self)
		if in_storage:
			in_storage = false
			if !is_skip_anim():
				_lift_down(0)
		else:
			if self.nest != null:	
				self.nest.hide_masks()
				self.nest.piece = null
			if !is_skip_anim():
				_lift_down(0)
		
		if !is_skip_anim():
			yield(self, "anim_completed")
			var sfx
			if Profiles.get_current_settings().get_value(Settings.SV_SFX_MOVE_ENABLED):
				if Profiles.get_current_settings().get_value(Settings.SV_SFX_3D_ENABLED):
					sfx = game_instance.get_node("MoveSFX3D")
					sfx.translation = translation
				else:
					sfx = game_instance.get_node("MoveSFX")
				sfx.play()
		if self.nest != null:
			self.nest.mark_tile(Globals.MarkMode.SELECT, false)
			
		var prev_nest = self.nest
		self.prev_nest = prev_nest
		
		game_instance.gui.history_erase_next_moves()
		game_instance.add_to_history(self, promoted, prev_nest, next_nest)
		
		self.nest = next_nest
		self.nest.piece = self
		self.nest.mark_tile(Globals.MarkMode.SELECT, false)
		
		if game_instance.last_selected_piece != null:
			game_instance.last_selected_piece.set_mark(false)
			#if game_instance.last_selected_piece.prev_nest != null:
			#	game_instance.last_selected_piece.prev_nest.mark_last_move(false)
		game_instance.last_selected_piece = self
		if Profiles.get_value(Settings.SV_GAME_LASTMOVE_ENABLED):
			game_instance.last_selected_piece.set_mark(true)
			#if game_instance.last_selected_piece.prev_nest != null:
			#	game_instance.last_selected_piece.prev_nest.mark_last_move(true)
			
		mark_need_update(prev_nest, next_nest)
		game_instance.next_turn(prev_nest, next_nest, promoted)
		game_instance.piece_lock = false

func mark_need_update(prev_nest, next_nest):
	need_update = true
	 
	for piece in next_nest.sente_protects:
		piece.need_update = true 
	for piece in next_nest.gote_protects:
		piece.need_update = true
	for piece in next_nest.sente_attacks:
		piece.need_update = true
	for piece in next_nest.gote_attacks:
		piece.need_update = true
		
	if prev_nest != null:
		for piece in prev_nest.sente_protects:
			piece.need_update = true
		for piece in prev_nest.gote_protects:
			piece.need_update = true
		for piece in prev_nest.sente_attacks:
			piece.need_update = true
		for piece in prev_nest.gote_attacks:
			piece.need_update = true


				
func get_fullname():
	if game_session.is_ai() or game_session.is_replay() or game_session.is_multiplayer():
		return (game_session.get_white_player_name() if side else game_session.get_black_player_name()) + " " + TranslationServer.translate(get_name())
	else:
		var gramma = piece_template.promoted_gramma if is_promoted() else piece_template.gramma
		var s
		match gramma:
			Games.GrammaType.FEMALE:
				s = "LABEL_BLACK" if !side else "LABEL_WHITE"
			Games.GrammaType.NEUTRAL:
				s = "LABEL_BLACK2" if !side else "LABEL_WHITE2"	
			Games.GrammaType.MALE:
				s = "LABEL_BLACK3" if !side else "LABEL_WHITE3"	
		return TranslationServer.translate(s) + " " + TranslationServer.translate(get_name())

func is_skip_anim():
	return game_instance.is_skip_anim()
 
func select(ai_move = false):
	
	if game_session.is_gameover():
		return
		
	if game_instance.piece_lock:
		return
			
	if game_instance.lift_lock:
		return
	
	if !ai_move:
		
		if UI.dialog_visible:
			return
		
		if game_session.is_multiplayer():
			if side != game_session.get_your_side() or !game_session.has_other_player():
				return
		elif game_instance.session.is_ai():
			if side != game_session.get_your_side():
				return
	
		if current_moves.empty():
			return
	
	# Обработка выделения на мгновенной скорости
	if is_skip_anim():
		if(!selected):
			game_instance.current_piece = self
			selected = true
			show_moves(true)
		else:
			selected = false
			show_moves(false)
			game_instance.current_piece = null
			
		emit_signal("select_completed")
		
		if !ai_move:
			# сдвинуть фигуру если существует только один ход(экономия времени)
			if Profiles.get_current_settings().get_value(Settings.SV_GAME_AUTOMOVE_ENABLED):
				if current_moves.size() == 1:
					move_or_eat(current_moves[0], game_session.is_multiplayer(), -1)
		
		return
	
	game_instance.lift_lock = true
	if game_instance.current_piece != null and game_instance.current_piece != self:
		if game_instance.current_piece.selected:
			game_instance.current_piece.selected = false
			game_instance.current_piece.show_moves(false)
			game_instance.current_piece._lift_down(0)
			if game_instance.current_piece.in_storage:
				game_instance.current_piece.last_storage_stack.update_text()
			
	
	if(!selected):
		game_instance.current_piece = self
		_lift_up(0)
		selected = true
		#set_mark(true)
		show_moves(true)
	else:
		_lift_down(0)
		selected = false
		show_moves(false)
		var material = mesh.material_override
		material.set_shader_param("selected", 0.0)
		#set_mark(false)
		game_instance.current_piece = null
	
	yield(self, "anim_completed")
	game_instance.lift_lock = false
	
	emit_signal("select_completed")
	
	if in_storage:
		if !selected:
			if last_storage_stack != null:
				last_storage_stack.dummy.visible = false
		return
	
	if !ai_move:
		# сдвинуть фигуру если существует только один ход(экономия времени)
		if Profiles.get_current_settings().get_value(Settings.SV_GAME_AUTOMOVE_ENABLED):
			if current_moves.size() == 1:
				move_or_eat(current_moves[0], game_session.is_multiplayer(), -1)


func unpromote():
	rotation.z = 0
	special = Games.PieceStates.NORMAL

# Переворачивает фигуру(можно использовать из редактора доски).
# Также используется внутри класса.
func promote(boost):
	# фигуру невозможно перевернуть поскольку она не-превращаема
	if !piece_template.has_special(Games.PieceTag.PROMOTABLE):
		return
	# внутренний переворот
	var promoted = false
	if special == Games.PieceStates.NORMAL:
		promoted = true
		special = Games.PieceStates.PROMOTED
	else:
		special = Games.PieceStates.NORMAL
	# визуальный переворот
	if !boost:
		_revert()
	else:
		rotation.z = PI if is_promoted() else 0

# Приватный метод мгновенного переворота фигуры
func _change_side(new_side):
	side = new_side
	rotation.y += deg2rad(180)

###############################################
# Методы визуального модифицирования(приватные)
###############################################

# Метод перемещения фигуры в указанное гнездо
func _move_to_nest(nest):
	var t = translation
	var d = nest.translation
	d.y = UPPER_H
	d.y = translation.y
	var move_speed = get_move_speed(SpeedType.MOVE)
	while t.distance_squared_to(d) > 0.1:
		var v
		if side == 0:
			v = (t - d).normalized() * move_speed * get_process_delta_time()
		else:
			v = (d - t).normalized() * move_speed * get_process_delta_time()
		
		if is_promoted():
			translate(Vector3(-v.x, 0.0, v.z))
		else:
			translate(Vector3(v.x, 0.0, v.z))
		t = translation
		yield(get_tree(), "idle_frame")
	translation = d
	emit_signal("anim_completed")

func _teleport_to_nest(nest):
	translation = nest.translation

# Метод опускания фигуры вниз
func _lift_down(steps):
	var f = translation.y
	var d =  translation.y + UPPER_H + 0.28 * steps
	var t = Globals.SHOGI_PIECE_SIZE_Y
	var lift_speed = get_move_speed(SpeedType.LIFT)
	while(f < d):
		var s = lift_speed * get_process_delta_time()
		var v = Vector3(0.0, s * -1, 0.0)
		if is_promoted():
			translate(-v)
		else:
			translate(v)
		f += s
		yield(get_tree(), "idle_frame")
	translation.y = t
	emit_signal("anim_completed")

# Метод опускания фигуры на поверхность доски
func _lift_down_to_surface():
	var f = translation.y
	var d = Globals.SHOGI_PIECE_SIZE_Y
	var t = f - d
	var lift_speed = get_move_speed(SpeedType.LIFT)
	while(f > d):
		var s = lift_speed * get_process_delta_time()
		var v = Vector3(0.0, s * -1, 0.0)
		if is_promoted():
			translate(-v)
		else:
			translate(v)
		f -= s
		yield(get_tree(), "idle_frame")
	translation.y = t
	emit_signal("anim_completed")

# Метод поднятия фигуры вверх
func _lift_up(steps):
	var f = translation.y
	var d = translation.y + UPPER_H + 0.28 * steps
	var t = f + d
	var lift_speed = get_move_speed(SpeedType.LIFT)
	while(f < d):
		var s = lift_speed * get_process_delta_time()
		var v = Vector3(0.0, s * 1, 0.0)
		if is_promoted():
			translate(-v)
		else:
			translate(v)
		f += s
		yield(get_tree(), "idle_frame")
	translation.y = t
	emit_signal("anim_completed")

# Метод переворота фигуры
func _revert():
	var f = 0.0
	var revert_speed = get_move_speed(SpeedType.REVERT)
	while f < PI:
		var s = revert_speed * get_process_delta_time()
		rotate_z(s)
		f += s
		yield(get_tree(), "idle_frame")
	rotation.z = PI if is_promoted() else 0
	emit_signal("anim_completed")