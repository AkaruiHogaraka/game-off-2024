shader_type canvas_item;

uniform sampler2D main_texture: source_color;
uniform vec4 colour_one: source_color;
uniform vec4 replace_one: source_color;
uniform vec4 colour_two: source_color;
uniform vec4 replace_two: source_color;
uniform vec4 colour_three: source_color;
uniform vec4 replace_three: source_color;
uniform vec4 colour_four: source_color;
uniform vec4 replace_four: source_color;

vec3 quantize_color(vec3 color) {
    return vec3(round(color.r * 100.0) / 100.0,
                round(color.g * 100.0) / 100.0,
                round(color.b * 100.0) / 100.0);
}

void fragment() {
	COLOR = texture(main_texture, UV).rgba;
	
	if (colour_one.rgb == texture(main_texture, UV).rgb) {
		COLOR.rgb = quantize_color(replace_one.rgb);
	}

	if (colour_two.rgb == texture(main_texture, UV).rgb) {
		COLOR.rgb = quantize_color(replace_two.rgb);
	}

	if (colour_three.rgb == texture(main_texture, UV).rgb) {
		COLOR.rgb = quantize_color(replace_three.rgb);
	}

	if (colour_four.rgb == texture(main_texture, UV).rgb) {
		COLOR.rgb = quantize_color(replace_four.rgb);
	}
}
