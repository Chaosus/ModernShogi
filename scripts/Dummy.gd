extends Spatial

var piece_template

onready var mesh = $Mesh

func setup(piece_template, side):
	self.piece_template = piece_template
	if side == 0:
		rotation.y = PI

func update_piece_theme():
	return
	
	var texture = piece_template.get_texture()
	var material = piece_template.material
	material.set_shader_param("piece_texture", texture)
	mesh.material_override = material
#	if piece_template.importance == Games.IMP_MINOR:
#		scale -= Vector3(0.15, 0.0, 0.15)
#	elif piece_template.importance == Games.IMP_MAJOR:
#		scale += Vector3(0.15, 0.0, 0.15)

func _ready():
	update_piece_theme()
