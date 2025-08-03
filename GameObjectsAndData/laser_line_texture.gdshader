shader_type canvas_item;

uniform sampler2D line_tex;
uniform float scroll_speed : hint_range(-5.0, 5.0) = 1.0; // positive = forward along line
uniform float tile_scale : hint_range(0.1, 10.0) = 1.0;   // how many repeats over length
uniform vec4 tint = vec4(1,1,1,1);

void fragment() {

	float offset = TIME * scroll_speed;

	vec2 uv = vec2(fract(UV.x * tile_scale + offset), UV.y);
	vec4 texcol = texture(line_tex, uv);
	COLOR = texcol * tint;
}
