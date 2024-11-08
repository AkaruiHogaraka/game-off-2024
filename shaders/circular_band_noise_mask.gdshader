shader_type canvas_item;

uniform float radius_inner = 0.1;      // Radius of the center circle
uniform float radius_middle = 0.2;     // Radius of the second band
uniform float radius_outer = 0.3;      // Radius of the outer band
uniform float noise_strength = 0.05;   // Noise amount for edge
uniform float noise_scale = 10.0;      // Scale for noise effect
uniform float colour_tolerance = 0.01;
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec2 texture_size = vec2(240.0, 160.0);
uniform vec2 pixel_resolution = vec2(10.0, 10.0);
uniform vec4 colour_0 : source_color; // Primary color for inner band
uniform vec4 colour_1 : source_color; // Second color for middle band
uniform vec4 colour_2 : source_color; // Third color for outer band
uniform vec4 colour_3 : source_color; // Fourth color for farthest band

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Determine the current band and allowable colors
bool is_color_allowed(float dist, vec4 colour) {
    bool matches_colour_0 = length(colour - colour_0) < colour_tolerance;
    bool matches_colour_1 = length(colour - colour_1) < colour_tolerance;
    bool matches_colour_2 = length(colour - colour_2) < colour_tolerance;

    if (dist < radius_inner) {
        return true; // Center circle allows all colors
    } else if (dist < radius_middle) {
        return matches_colour_0 || matches_colour_1 || matches_colour_2;
    } else if (dist < radius_outer) {
        return matches_colour_0 || matches_colour_1;
    } else {
        return matches_colour_0;
    }
}

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);

    // Aspect ratio adjustment for circular shape
    float aspect_ratio = texture_size.x / texture_size.y;
    vec2 adjusted_uv = vec2((uv.x - center.x) * aspect_ratio + center.x, uv.y);

    // Calculate grid cell size based on pixel resolution
    vec2 cell_size = pixel_resolution / texture_size;

    // Snap UV to the nearest pixel center based on pixel resolution
    vec2 pixel_uv = (floor(uv / cell_size) + vec2(0.5, 0.5)) * cell_size;

    // Calculate distance from the center of the pixel to the circle center
    float dist = distance(vec2((pixel_uv.x - center.x) * aspect_ratio + center.x, pixel_uv.y), center);

    // Generate noise for the edge of each band
    float noise = (random(pixel_uv * noise_scale) - 0.5) * noise_strength;
    dist += noise;

    // Sample the screen texture at this fragment’s UV
    vec4 screen_color = texture(screen_texture, SCREEN_UV);

    // Discard based on color and distance from center
    if (!is_color_allowed(dist, screen_color)) {
        discard;
    }

    COLOR = screen_color;
}
