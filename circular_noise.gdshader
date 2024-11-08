shader_type canvas_item;

uniform float radius = 0.25;
uniform float noise_strength = 0.05;
uniform float noise_scale = 10.0;
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec2 texture_size = vec2(240.0, 160.0); // Set this to the texture's width and height
uniform vec2 pixel_resolution = vec2(10.0, 10.0); // Resolution of pixelation (higher = larger pixels)

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
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

    // Calculate distance from the circle center to the center of the pixel
    float dist = distance(vec2((pixel_uv.x - center.x) * aspect_ratio + center.x, pixel_uv.y), center);

    // Generate noise based on grid-aligned UVs
    float noise = (random(pixel_uv * noise_scale) - 0.5) * noise_strength;
    float noisy_radius = radius + noise;

    // Check if the distance is within the noisy radius to draw the entire pixel
    if (dist > noisy_radius) {
        discard; // Only show the screen texture within the noisy circle
    }
	
	COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	
    // Sample the screen texture for visible areas
    vec4 screen_color = texture(screen_texture, SCREEN_UV);
    COLOR = vec4(screen_color.rgb, 1.0); // Use screen texture's color with full alpha
}