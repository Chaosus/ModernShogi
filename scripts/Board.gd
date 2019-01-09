extends Spatial

onready var volume = $VolumeMesh
onready var surface = $SurfaceMesh
onready var storage_table_0 = $PieceTable0
onready var storage_table_1 = $PieceTable1

export(float) var board_scale = 2.0
export(float) var board_thickness = 1.0

var game_instance
var game_template

func update_board_style():
	surface.get_surface_material(0).set_shader_param("enable_chess_coloring", Profiles.get_current_settings().get_value(Settings.SV_STYLES_BOARD_COLORING_CHESS_ENABLED))
	surface.get_surface_material(0).set_shader_param("enable_zones_coloring", Profiles.get_current_settings().get_value(Settings.SV_STYLES_BOARD_COLORING_ZONES_ENABLED))

func update_grid_color():
	surface.get_surface_material(0).set_shader_param("border_color", Settings.get_color(Profiles.get_current_settings().get_value(Settings.SV_STYLES_GRID_COLOR)))

func update_grid_thickness():
	var thickness = Profiles.get_current_settings().styles_grid_thickness_val()
	surface.get_surface_material(0).set_shader_param("thickness", thickness)
 
func update_background_color(aspect):
	
	var color = Color("EFC086")
	var color2 = Color("EFC086")
	
	var t = UI.get_current_theme().aspects[aspect].theme
	
	var settings = Profiles.get_current_settings()
	if settings.get_value(Settings.SV_STYLES_BOARD_COLORING_UI_ENABLED):
		color = t.get_color("board_color", "Game")
		color2 = t.get_color("board_color2", "Game")
	
	volume.get_surface_material(0).albedo_color = color
	storage_table_0.get_surface_material(0).albedo_color = color
	storage_table_1.get_surface_material(0).albedo_color = color
	surface.get_surface_material(0).set_shader_param("background_color", color)
	surface.get_surface_material(0).set_shader_param("background_color2", color2)

# Вовращает вектор позиции на доске
func get_boardpos(x, y):
	var c = board_scale
	var t = 0.0 if game_template.tiles_even else (0.11 * board_scale) # 0.22(for 2.0) #1.6666
	var tx = x * c
	var ty = y * (c + (0.0 if game_template.tiles_even else t))
	var p2w = 0 if Checks.is_pow2(game_template.width) else -board_scale + board_scale / 2
	var p2d = 0 if Checks.is_pow2(game_template.depth) else -board_scale + board_scale / 2
	
	var t2 = 0.0
	if !game_template.tiles_even:
		t2 = board_scale / 1.816
		
	var sz = Vector2(board_scale / 2 - p2w, (board_scale) / 2 - p2d + t2) # 1.1(for 2.0)
	var half_w = (game_template.width) / 2 * board_scale
	var half_d = (game_template.depth) / 2 * board_scale
	#return Vector3(tx - sz.x, 0.002, ty - sz.y)
	return Vector3(tx - sz.x - half_w, 0.0, ty - sz.y - half_d)

func update_board():
	
	var settings = Profiles.get_current_settings()
	surface.get_surface_material(0).set_shader_param("enable_background", false)
	
	
func cleanup():
	pass

func setup(game_instance, settings):
	
	self.game_instance = game_instance
	self.game_template = game_instance.session.game_template
	
	var board_translation_y = -board_thickness / 2.0 - 0.02
	
	volume.translation.y = board_translation_y
	volume.scale = Vector3(game_template.width * board_scale, board_thickness, game_template.depth * board_scale)
	
	surface.translation.y = 0
	surface.scale = Vector3(game_template.width * board_scale, board_thickness, game_template.depth * board_scale)
	
	storage_table_0.scale = Vector3(game_template.width, board_thickness, game_template.depth)	
	storage_table_0.translation.x = 13.5
	storage_table_0.translation.y = board_translation_y
	storage_table_0.translation.z = 5.5
	
	storage_table_1.scale = Vector3(game_template.width, board_thickness, game_template.depth)	
	storage_table_1.translation.x = -13.5
	storage_table_1.translation.y = board_translation_y
	storage_table_1.translation.z = -5.5
	
	if !game_template.tiles_even:
		surface.scale.z += 1 * board_scale
		volume.scale.z += 1 * board_scale
	
	surface.get_surface_material(0).set_shader_param("width", game_template.width)
	surface.get_surface_material(0).set_shader_param("depth", game_template.depth)
	update_board()

	
