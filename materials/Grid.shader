shader_type spatial;

//render_mode depth_draw_always;

uniform int width;

uniform int depth;

uniform vec4 border_color : hint_color;

uniform float thickness : hint_range(0.0, 0.5);

uniform sampler2D background;

uniform bool enable_background = false;

uniform bool enable_chess_coloring = true;

uniform bool enable_zones_coloring = true;

uniform vec4 background_color : hint_color;

uniform vec4 background_color2 : hint_color;

bool checker2D(vec2 texc)
{
  if ((int(floor(texc.x) + floor(texc.y)) & 1) == 0)
    return true;
  else
    return false;
}

void fragment()
{
	vec2 st = UV.xy * vec2(float(width), float(depth));
	vec2 origin = st;
	st = fract(st);
	vec2 bl = step(vec2(thickness), st);
	vec2 tr = step(vec2(thickness), vec2(1.0) - st);
	float pct = (bl.x * bl.y * tr.x * tr.y);
	if (pct > 0.0)
	{
		vec3 color = background_color.rgb;

		if(enable_chess_coloring) 
		{
			if(checker2D(origin))
			{
				color = background_color2.rgb;
			}
		}
		
		vec3 add_color = vec3(0.0);
		if(enable_zones_coloring) 
		{
			float y = floor(origin.y);
			
			if(y > 5.0)
			{
				add_color = vec3(1, 1, 1) / 2.0;
			}else if(y < 3.0) 
			{
				add_color = vec3(1, 1, 1) / 2.0;
			}
		}
		
		if(enable_background)
		{
			ALPHA = 0.0;
			ALBEDO = (texture(background, UV.xy).rgb * color.rgb + add_color);
		} 
		else 
		{
			ALBEDO = (color.rgb + add_color);
		}
	}
	else
		ALBEDO = border_color.rgb;
}