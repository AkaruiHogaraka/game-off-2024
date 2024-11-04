shader_type canvas_item;

uniform vec2 circle_center;  // Center of the circle
uniform float circle_radius;  // Radius of the circle
uniform sampler2D dither_texture; // Dither pattern texture

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;  // Normalize coordinates
    vec2 diff = uv - circle_center; // Calculate distance from circle center
    float dist = length(diff);  // Get distance from center

    // Determine if pixel is inside the circle
    if (dist < circle_radius) {
        float dither_value = texture(dither_texture, uv).r;  // Get dither value from texture
        float alpha = smoothstep(circle_radius - 0.01, circle_radius, dist) * (1.0 - dither_value);  // Apply dither
        COLOR = vec4(1.0, 1.0, 1.0, alpha); // Set circle color (white in this case)
    } else {
        discard;  // Discard pixels outside the circle
    }
}