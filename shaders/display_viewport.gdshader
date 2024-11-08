shader_type canvas_item;

uniform sampler2D main_texture: source_color;

void fragment() {
	COLOR = texture(main_texture, UV);
}
