shader_type canvas_item;

uniform vec2 camera_position = vec2(0.0);
uniform vec2 zoom = vec2(1.0);

uniform vec4 bg_color: source_color = vec4(.11, .12, .14, 1.0);
uniform vec4 line_color: source_color = vec4(1.0, 1.0, 1.0, .10);
uniform vec4 major_line_color: source_color = vec4(1.0, 1.0, 1.0, .22);

uniform float grid_size = 64.0;
uniform float line_thickness = 1.0;
uniform int major_step = 5;

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	
	vec2 screen_offset = (SCREEN_UV - 0.5) * screen_size;
	vec2 world_pos = camera_position + (screen_offset / zoom);
	
	vec2 grid_uv = world_pos / grid_size;
	vec2 dist_from_line = abs(fract(grid_uv + 0.5) - 0.5) * grid_size * zoom;
	float min_dist = min(dist_from_line.x, dist_from_line.y);
	
	float half_thick = line_thickness * 0.5;
	float line_mask = 1.0 - smoothstep(half_thick - 0.5, half_thick + 0.5, min_dist);
	
	float major_size = grid_size * float(major_step);
	vec2 major_uv = world_pos / major_size;
	vec2 major_dist = abs(fract(major_uv + 0.5) - 0.5) * major_size * zoom;
	float major_mask = 1.0 - smoothstep(half_thick - 0.5, half_thick + 0.5, min(major_dist.x, major_dist.y));
	
	vec4 final_color = mix(bg_color, line_color, line_mask);
	final_color = mix(final_color, major_line_color, major_mask);
	
	COLOR = final_color;
}