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
	if (colour_one == COLOR) {
		COLOR = replace_one;
	}
	
	if (colour_two == COLOR) {
		COLOR = replace_two;
	}
	
	if (colour_three == COLOR) {
		COLOR = replace_three;
	}
	
	if (colour_four == COLOR) {
		COLOR = replace_four;
	}
}
