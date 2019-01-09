extends Node

#----------------------------------------------------------------#
# Функции маркирования доски возможными ходами
#----------------------------------------------------------------#

enum TestResult {
	INVALID,
	VALID,
	EMPTY,
	ENEMY,
	ALLY,
	ITSELF,
}

enum HookMove {
	HM_ORTHO_LEFT,
	HM_ORTHO_RIGHT,
	HM_ORTHO_UP,
	HM_ORTHO_DOWN,
	HM_DIAGONAL_LEFT_UP
	HM_DIAGONAL_RIGHT_UP
	HM_DIAGONAL_LEFT_DOWN
	HM_DIAGONAL_RIGHT_DOWN
}

class Move:
	var piece
	var nest
	var promotion
	func _init(piece, nest, promotion):
		self.piece = piece
		self.nest = nest
		self.promotion = promotion

func is_orthogonal(a, b):
	return (a.x == b.x and a.y != b.y) or (a.y == b.y and a.x != b.x)

func is_move_target_valid(piece, nest):
	if nest == null:
		return TestResult.INVALID
	if nest.piece != null:
		if nest.piece.side != piece.side:
			return TestResult.ENEMY
		else:
			if nest.piece == piece:
				return TestResult.ITSELF
			else:
				return TestResult.ALLY
	else:
		return TestResult.EMPTY

func add_drop_move(piece, nest):
	if nest.piece == null:
		if is_move_target_valid(piece, nest) == TestResult.EMPTY:
			piece.append_drop_move(nest)
			
func add_move_itself(piece):
	piece.append_move(piece.nest)

func add_moves_knight_updown(piece, up, checkmate):
	var side = piece.side
	var nest = piece.nest
	if !up:
		side = !side
	if !side:
		if nest.nest_up != null:
			if checkmate:
				if side == 0:
					if nest.nest_up.nest_left_up != null:
						nest.nest_up.nest_left_up.sente_attacks.append(piece)
					if nest.nest_up.nest_right_up != null:
						nest.nest_up.nest_right_up.sente_attacks.append(piece)
				elif side == 1:
					if nest.nest_up.nest_left_up != null:
						nest.nest_up.nest_left_up.gote_attacks.append(piece)
					if nest.nest_up.nest_right_up != null:
						nest.nest_up.nest_right_up.gote_attacks.append(piece)
			else:
				add_move(piece, nest.nest_up.nest_left_up)
				add_move(piece, nest.nest_up.nest_right_up)
	else:
		if nest.nest_down != null:
			if checkmate:
				if side == 0:
					if nest.nest_down.nest_left_down != null:
						nest.nest_down.nest_left_down.sente_attacks.append(piece)
					if nest.nest_down.nest_right_down != null:
						nest.nest_down.nest_right_down.sente_attacks.append(piece)
				elif side == 1:
					if nest.nest_down.nest_left_down != null:
						nest.nest_down.nest_left_down.gote_attacks.append(piece)
					if nest.nest_down.nest_right_down != null:
						nest.nest_down.nest_right_down.gote_attacks.append(piece)
			else:
				add_move(piece, nest.nest_down.nest_left_down)
				add_move(piece, nest.nest_down.nest_right_down)
			
func add_moves_knight_leftright(piece, up):
	var side = piece.side
	var nest = piece.nest
	if !up:
		side = !side
	if !side:
		if nest.nest_left != null:
			piece.add_move(piece, nest.nest_left.nest_left_up)
		if nest.nest_right != null:
			piece.add_move(piece, nest.nest_right.nest_right_up)
	else:
		if nest.nest_left != null:
			piece.add_move(piece, nest.nest_left.nest_left_down)
		if nest.nest_right != null:
			piece.add_move(piece, nest.nest_right.nest_right_down)
			

	
func add_move(piece, nest):
	var result = is_move_target_valid(piece, nest)
	match result:
		TestResult.INVALID:
			return
		TestResult.ALLY:
			piece.append_protection(nest)
		TestResult.ITSELF:
			piece.append_move(nest)
		TestResult.ENEMY:
			piece.append_move(nest)
		TestResult.EMPTY:
			piece.append_move(nest)
	
func erase_move(piece, nest):
	piece.erase_move(nest)
			
func add_move_line(piece, dir, size, checkmate):
	var nest = piece.nest
	var side = piece.side
	var next = nest.get_neightbour(dir)
	var player = piece.game_instance.session.players[side]
	var counter = 0
	while true:
		if next == null:
			break
		if size > 0:
			counter += 1
			if counter > size:
				break
		if checkmate:
			if side == 0:
				next.sente_attacks.append(piece)
			elif side == 1:
				next.gote_attacks.append(piece)
			if next.piece != null:
				break
		else:
			var result = is_move_target_valid(piece, next)
			match result:
					TestResult.ALLY: # союзная фигура
						add_move(piece, next) # взять под защиту
						break
					TestResult.ENEMY: # вражеская фигура 
						add_move(piece, next) # атаковать
						break
					TestResult.EMPTY: # пустая клетка - продолжить
						add_move(piece, next)
					TestResult.ITSELF: # стартовая клетка - зарезервировано на будущее
						pass
		next = next.get_neightbour(dir)		
		
func add_move_up_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(0, -1), size, checkmate)
	else:
		add_move_line(piece, Vector2(0, 1), size, checkmate)

func add_move_down_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(0, 1), size, checkmate)
	else:
		add_move_line(piece, Vector2(0, -1), size, checkmate)

func add_move_left_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(-1, 0), size, checkmate)
	else:
		add_move_line(piece, Vector2(1, 0), size, checkmate)
		
func add_move_right_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(1, 0), size, checkmate)
	else:
		add_move_line(piece, Vector2(-1, 0), size, checkmate)
		
func add_move_leftup_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(-1, -1), size, checkmate)
	else:
		add_move_line(piece, Vector2(1, 1), size, checkmate)			

func add_move_rightup_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(1, -1), size, checkmate)
	else:
		add_move_line(piece, Vector2(-1, 1), size, checkmate)		

func add_move_leftdown_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(1, 1), size, checkmate)
	else:
		add_move_line(piece, Vector2(-1,-1), size, checkmate)			

func add_move_rightdown_line(piece, size = -1, checkmate = false):
	if !piece.side:
		add_move_line(piece, Vector2(-1, 1), size, checkmate)
	else:
		add_move_line(piece, Vector2(1, -1), size, checkmate)
		
func add_gold_moves(piece, checkmate = false):
	add_move_leftup_line(piece, 1, checkmate)
	add_move_up_line(piece, 1, checkmate)
	add_move_rightup_line(piece, 1, checkmate)
	add_move_left_line(piece, 1, checkmate)
	add_move_right_line(piece, 1, checkmate)
	add_move_down_line(piece, 1, checkmate)

func add_king_moves(piece, size = 1, checkmate = false):
	add_move_leftup_line(piece, size, checkmate)
	add_move_up_line(piece, size, checkmate)
	add_move_rightup_line(piece, size, checkmate)
	add_move_left_line(piece, size, checkmate)
	add_move_right_line(piece, size, checkmate)
	add_move_leftdown_line(piece, size, checkmate)
	add_move_down_line(piece, size, checkmate)
	add_move_rightdown_line(piece, size, checkmate)
	
func add_drop_moves(piece):
	var game = piece.game_session.game_template
	for i in range(1, game.width + 1):
		for j in range(1, game.depth + 1):
			add_drop_move(piece, piece.game_instance.get_nest(i, j))
			
func add_drop_moves_limit(piece, s):
	var game = piece.game_session.game_template
	var limit = game.depth - s + 1 if piece.side == 1 else s
	for i in range(1, game.width + 1):
		for j in range(1, game.depth + 1):
			if !piece.side:
				if j <= limit:
					continue
			else:
				if j >= limit:
					continue
			add_drop_move(piece, piece.game_instance.get_nest(i, j))
		
func add_drop_moves_pawn(piece):
	var game = piece.game_instance
	var gameplay = game.session.game_template
	var limit = gameplay.depth if piece.side == 1 else 1
	
	var valid_lines = []
	for i in range(1, gameplay.width + 1):
		var temp_line = []
		var valid = true
		for j in range(1, gameplay.depth + 1):
			var nest = game.get_nest(i, j)
			temp_line.append(nest)
			if nest.piece != null:
				if nest.piece.side == piece.side:
					if !nest.piece.is_promoted():
						if nest.piece.piece_template.type == Games.ShogiPieceTypes.PAWN:
							valid = false
							break
		if valid:
			valid_lines.append(temp_line)
							
	for line in valid_lines:
		for nest in line:
			# Ограничить последнюю линию
			if !piece.side:
				if nest.pos.y <= limit:
					continue
			else:
				if nest.pos.y >= limit:
					continue
			add_drop_move(piece, nest)

	
#	var game = piece.game_session.game_template
#	for i in range(1, game.width + 1):
#		for j in range(1, game.depth + 1):
#			if j >= game_depth - 1:
#				break
#			add_drop_move(piece, piece.game_instance.get_nest(i, j))