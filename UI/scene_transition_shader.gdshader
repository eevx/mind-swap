shader_type canvas_item;

uniform float progress : hint_range(0, 1);
uniform int reverse : hint_range(0, 1); // 0 = forward, 1 = reversed
uniform float diamondPixelSize = 10.0;

void fragment() {
    // Flip UVs when reversed
    vec2 dir_uv = mix(UV, vec2(1.0) - UV, float(reverse));

    float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
    float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
    float xDistance = abs(xFraction - 0.5);
    float yDistance = abs(yFraction - 0.5);

    float progress_amount = xDistance + yDistance + dir_uv.x + dir_uv.y;

    if (progress_amount > progress * 4.0) {
        discard;
    }
}
