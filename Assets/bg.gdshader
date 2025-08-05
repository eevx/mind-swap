shader_type canvas_item;

global uniform vec2 mouse_pos;
uniform float threshold = 0.9;
uniform float threshold_amplitude = 0.01;
uniform float scroll_speed = 0.05;
uniform sampler2D star_texture;

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	//screen_uv = vec2((SCREEN_UV.x - 0.5) * SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x, SCREEN_UV.y - 0.5) + vec2(0.5, 0.5);
	float dist_to_mouse = distance(screen_uv, mouse_pos);
	vec2 direction_to_mouse = mouse_pos - screen_uv;
	vec2 scrolling_screen_uv = mod(screen_uv + TIME * scroll_speed, 1.);
	float mask = smoothstep(0., 0.4, dist_to_mouse);
	vec2 warped_screen_uv = mix(scrolling_screen_uv + direction_to_mouse * (1. - dist_to_mouse) * 0.2, scrolling_screen_uv, mask);
	
	float starfield1 = texture(star_texture, warped_screen_uv).r;
	float starfield2 = texture(star_texture, scrolling_screen_uv).r;
	float time_varying_threshold = threshold + sin(TIME) * threshold_amplitude;
	starfield1 = step(time_varying_threshold, starfield1);
	starfield2 = step(time_varying_threshold, starfield2);
	COLOR.rgb = vec3(starfield2 + starfield1);
}
