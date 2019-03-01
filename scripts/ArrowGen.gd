extends Spatial

# ArrowGen.gd

signal show_done

onready var mesh = $MeshInstance

var alpha = 0.0

var mat = null

var state = 0

var initialized = false
func begin_hide():
	state = 2
	
func _process(delta):
	if initialized:
		if state != 0:
			mat.albedo_color.a = alpha
			if state == 1:
				visible = true
				alpha = clamp(alpha + (2.5 * delta), 0.0, 1.0)
				if alpha >= 1.0:
					emit_signal("show_done")
					state = 0
			elif state == 2:
				alpha = clamp(alpha - (2.5 * delta), 0.0, 1.0)
				if alpha <= 0.0:
					visible = false
					emit_signal("show_done")
					state = 0
	
func _ready():
	pass

func setup(from, to, promotion):
	var offset = (-from.translation.z + to.translation.z) * 2.0
	
	var from_t = Vector2(-from.translation.x, -from.translation.z)
	var to_t = Vector2(-to.translation.x, -to.translation.z + offset)
	
	gen_mesh(from_t, to_t, promotion)
	
	translation = Vector3(-from_t.x, 0.01, -from_t.y)
	
	rotate_y(from_t.angle_to_point(to_t) + deg2rad(90))
	initialized = true
	state = 1
	
func gen_mesh(from, to, promotion):
	
	var d = from.distance_to(to)
	var st = SurfaceTool.new()
	var bh = 0.3
	
	st.clear()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var c = 2.0
	var d2 = d * 2.0
	var length = d * c
	var spike
	var spike_h = bh
	 
	var a
	var a2
	var t
	var t2
	var v
	var v2
	var end_len = 3.0
	var end = length - end_len
	var tend = (length - end) #(length - end - 2.0) - (length - d)
	var lim = 10.0
	var is_end = false
	var s
	var s2
	var h
	var h2
	var z
	var z2
	var color = Vector3(0.0, 0.8, 0.0) if !promotion else Vector3(0.8, 0.0, 0.8)
	var j = 0.0
	for i in range(0, length + 1.0):
		
#		if i == int(length):
#			if d < 2.0:
#				break
		
		var fi = float(i)
		
		t = fi / (length + 15.0 )
		t2 = (fi + 1.0) / (length + 15.0 )
		
		var ht = fi / length
		var ht2 = (fi + 1.0) / length
		
		z = fi / c
		z2 = ((fi / c) + (1.0 / c)) 
		
		h = bh - sin(( PI * 2.0) / ( 1.0 + ht)) * (d / 5.0 - 1.0 + 0.3)
		h2 = bh - sin(( PI * 2.0) / ( 1.0 + ht2)) * (d / 5.0 - 1.0 + 0.3)
		
		#a = 0.8
		#a2 = 0.8
		a = ht + 0.3
		a2 = ht2 + 0.3
		
		if i > end:
			is_end = true
			t = ((tend - j) / 4.0)
			t2 = ((tend - j - 1.0) / 4.0)
			j += 1.0
		
		if i == int(length):
			t2 = 0.0
		
		if d < 3.0:
			h = bh
			h2 = bh
		
		if !is_end:
			st.add_color(Color(color.x, color.y, color.z, a))
			st.add_vertex(Vector3(-t, h, z))
			st.add_color(Color(color.x, color.y, color.z, a))
			st.add_vertex(Vector3(t, h, z))
			st.add_color(Color(color.x, color.y, color.z, a2))
			st.add_vertex(Vector3(-t2, h2, z2))
	
			st.add_color(Color(color.x, color.y, color.z, a))
			st.add_vertex(Vector3(t, h, z))
			st.add_color(Color(color.x, color.y, color.z, a2))
			st.add_vertex(Vector3(t2, h2, z2))
			st.add_color(Color(color.x, color.y, color.z, a2))
			st.add_vertex(Vector3(-t2, h2, z2))
		else:
			st.add_color(Color(color.x, color.y, color.z, a))
			st.add_vertex(Vector3(-t, h, z))
			st.add_color(Color(color.x, color.y, color.z, a))
			st.add_vertex(Vector3(t, h, z))
			st.add_color(Color(color.x, color.y, color.z, a2))
			st.add_vertex(Vector3(-t2, h2, z2))

			st.add_color(Color(color.x, color.y, color.z, a))
			st.add_vertex(Vector3(t, h, z))
			st.add_color(Color(color.x, color.y, color.z, a2))
			st.add_vertex(Vector3(t2, h2, z2))
			st.add_color(Color(color.x, color.y, color.z, a2))
			st.add_vertex(Vector3(-t2, h2, z2))
	
	mesh.mesh = st.commit()
	mat = preload("res://materials/Arrow.material").duplicate()
	mesh.set_surface_material(0, mat)

