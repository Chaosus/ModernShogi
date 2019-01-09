extends Node

# Искусственный интеллект

var gi
var game
var human_player
var cpu_player
var side = 0
var thread

onready var timer = $Timer

class AITile:
	var x
	var y
	func _init(x, y):
		self.x = x
		self.y = y
		
class AIGame:
	var width
	var depth
	var data = {}
	func _init(width, depth):
		self.width = width
		self.depth = depth
	func set_tile(x, y, piece):
		if piece != null:
			piece = AIPiece.new(piece.get_type(), piece.side)
		data[Vector2(x, y)] = piece
	func get_tile(x, y):
		return data[Vector2(x, y)]
	func display():
		for i in width:
			var s = ""
			for j in depth:
				var p = data[Vector2(j, i)]
				if p == null:
					s += "x"
				else:
					s += Checks.get_piece_symbol(p.piece_template.type, Games.NL_ENGLISH)
			print(s)
			
class AIPiece:
	var template
	var side
	var in_storage = false
	
	func _init(template, side):
		self.template = template
		self.side = side
	
	func get_weight():
		if in_storage:
			return template.promoted_weight * 1.3 # 30%
		var weight = template.promoted_weight if is_promoted() else template.weight
		return weight

class AIMoveSorter:
	static func sort(a, b):
		if a.weight > b.weight:
			 return true
		return false

class AIGraphNode:
	var subject
	var from
	var target
	var promotion
	var weight
	var depth
	var subnodes = []
	var possible_moves = []
	var cpu_move
	func _init(piece, target, cpu_move):
		self.subject = piece
		self.from = piece.nest
		self.target = target
		self.cpu_move = cpu_move
		promotion = 0
		weight = 0.0
		depth = 0
	func make_virtual_move():
		possible_moves = subject.make_virtual_move(target)
	func unmake_virtual_move():
		subject.nest = from
		from.piece = subject
	
class AIGraph:
	var subnodes = []
	var min_depth
	var max_depth
	
	func _init(min_depth, max_depth):
		self.min_depth = min_depth
		self.max_depth = max_depth
		
	func append(node):
		subnodes.append(node)
		
	func compute_weight(node):
		var weight = 0
		var piece = node.target.piece
		if piece != null:
			weight += piece.get_weight()
		return weight
	
	func compute_best(nodes):
		for node in nodes:
			if node.cpu_move:
				node.weight += compute_weight(node)
			else:
				node.weight -= compute_weight(node)
			node.depth += 1
		nodes.sort_custom(AIMoveSorter, "sort")
		var best_weight = nodes[0].weight
		var best_nodes = []
		for node in nodes:
			if node.weight != best_weight:
				break
			best_nodes.append(node)
		return best_nodes
		
	func process(gi):
		var best_nodes = compute_best(subnodes)
#		for node in best_nodes:
#			node.make_virtual_move() 
#			node.unmake_virtual_move()
#		gi.update_all_moves(null, null)
		return best_nodes[0] # temp

func setup(game_instance, human_player, cpu_player):
	gi = game_instance
	self.human_player = human_player
	self.cpu_player = cpu_player
	timer.connect("timeout", self, "make_decision")
	
	# Создание виртуальной и упрощенной игры
#	game = AIGame.new(gi.game_template.width, gi.game_template.depth)
#	for i in gi.game_template.width:
#		for j in gi.game_template.depth:
#			game.set_tile(i, j, gi.get_nest(i + 1, j + 1).piece)
#	game.display()
	
func _ready():
	pass

func start():
	timer.start()

func make_move(move):
	var piece = move.subject
	piece.select(true)
	yield(piece, "select_completed")
	piece.move_or_eat(move.target, false, move.promotion)

# Оценка хода
func compute_weight(move):
	var weight = 0
	var tp = move.target.piece
	if tp != null:
		weight += tp.get_weight()
	return weight
	
func make_decision():
	if cpu_player.ai_moves.size() == 0:
		return
	
	#return # temp
	
	var graph = AIGraph.new(5, 10)
	var cpu_moves = []
	
	for move in cpu_player.ai_moves:
		var piece = move.piece
		var target = move.nest
		graph.append(AIGraphNode.new(piece, target, true))
	
#	for move in cpu_moves:
#		move.weight = compute_weight(move)
#		move.depth += 1
#
#	cpu_moves.sort_custom(AIMoveSorter, "sort")
#
#	var best_weight = cpu_moves[0].weight
#
#	for move in cpu_moves:
#		if move.weight != best_weight:
#			break
#		graph.append(move)
	
	var best_move = graph.process(gi)
	make_move(best_move)

func _process(delta):
	pass