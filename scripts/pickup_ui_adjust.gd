@tool class_name ItemPickupUI extends Control

@export var item_texture_rect: TextureRect
@export var item_label: Label

@export var text_nine_rect: NinePatchRect
@export var texture_nine_rect: NinePatchRect
@export var main_container: HBoxContainer

func _physics_process(delta: float) -> void:
	var box_size: float = texture_nine_rect.size.x + text_nine_rect.size.x - 3
	main_container.position.x = -(box_size / 2)
