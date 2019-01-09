extends Spatial

onready var quad = $Sprite3D
onready var label = $Viewport/Label

var text

func set_text(t): 
	text = t
	
func get_text():
	return text

func update():
	label.text = text
	quad.get_surface_material(0).albedo_texture = $Viewport.get_texture()

func _ready():
	var material = SpatialMaterial.new()
	material.flags_transparent = true
	material.flags_unshaded = true
	material.albedo_texture = $Viewport.get_texture()
	quad.set_surface_material(0, material)
	