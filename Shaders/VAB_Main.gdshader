shader_type canvas_item;

uniform vec2 camera_position = vec2(0.0);
uniform vec2 zoom = vec2(1.0);

uniform vec4 bg_color: source_color = vec4(0.33, 0.5, 1.0, 1.0);
uniform vec4 line_color: source_color = vec4(1.0, 1.0, 1.0, .25);
uniform vec4 major_line_color: source_color = vec4(1.0, 1.0, 1.0, .5);

uniform float grid_size = 16.0;
uniform float line_thickness = 1.0;
uniform int major_step = 4;

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE; // resolution of the screen e.g. 1920x1080
	vec2 screen_offset = (SCREEN_UV -.5) * screen_size; // offset(pixel) from the center of the screen
	vec2 world_pos = camera_position + (screen_offset / zoom); // actual world coord. of this pixel
	
	// Calculating distance from grid
	vec2 grid_uv = world_pos / grid_size;
	vec2 dist_from_line = abs(fract(grid_uv + 0.5) - 0.5) * grid_size * zoom; // tricky!!
	float min_dist = min(dist_from_line.x, dist_from_line.y);
	
	float half_thick = line_thickness * 0.5;
	float line_mask = 1.0 - smoothstep(half_thick - 0.5, half_thick + 0.5, min_dist);
	line_mask *= line_color.a;
	
	float major_size = grid_size * float(major_step);
	vec2 major_uv = world_pos / major_size;
	vec2 major_dist = abs(fract(major_uv + 0.5) - 0.5) * major_size * zoom;
	float major_mask = 1.0 - smoothstep(half_thick - 0.5, half_thick + 0.5, min(major_dist.x, major_dist.y));
	major_mask *= major_line_color.a;
	
	vec4 final_color = mix(bg_color, line_color, line_mask);
	final_color = mix(final_color, major_line_color, major_mask);
	final_color.a = 1.0;
	
	COLOR = final_color;
}