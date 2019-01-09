shader_type spatial;

render_mode depth_draw_alpha_prepass, shadows_disabled;

uniform float edge_tolerance = 0.5;
uniform sampler2D main_texture;
uniform sampler2D piece_texture;

uniform float alpha = 1.0;
uniform float selected = 0.0;

void fragment()
{
	ALPHA = alpha;
	
	vec3 main_color = texture(main_texture, UV).rgb;
	vec3 piece_color = texture(piece_texture, UV).rgb;
	if (piece_color.g > edge_tolerance)
		ALBEDO = main_color;
	else
		ALBEDO = main_color * piece_color;
	float s = selected / 2.0;
	ALBEDO.rgb -= s;
}