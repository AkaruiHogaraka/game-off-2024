shader_type canvas_item;

uniform vec4 colour_one: source_color;
uniform vec4 replace_one: source_color;
uniform vec4 colour_two: source_color;
uniform vec4 replace_two: source_color;
uniform vec4 colour_three: source_color;
uniform vec4 replace_three: source_color;
uniform vec4 colour_four: source_color;
uniform vec4 replace_four: source_color;

void fragment() {
	if (colour_one.rgb == COLOR.rgb) {
		COLOR.rgb = replace_one.rgb;
	}
	
	if (colour_two.rgb == COLOR.rgb) {
		COLOR.rgb = replace_two.rgb;
	}
	
	if (colour_three.rgb == COLOR.rgb) {
		COLOR.rgb = replace_three.rgb;
	}
	
	if (colour_four.rgb == COLOR.rgb) {
		COLOR.rgb = replace_four.rgb;
	}
}
