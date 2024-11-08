shader_type canvas_item;

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
	if (colour_one.rgb == COLOR.rgb) {
		COLOR.rgb = quantize_color(replace_one.rgb);
	}

	if (colour_two.rgb == COLOR.rgb) {
		COLOR.rgb = quantize_color(replace_two.rgb);
	}

	if (colour_three.rgb == COLOR.rgb) {
		COLOR.rgb = quantize_color(replace_three.rgb);
	}

	if (colour_four.rgb == COLOR.rgb) {
		COLOR.rgb = quantize_color(replace_four.rgb);
	}
}
