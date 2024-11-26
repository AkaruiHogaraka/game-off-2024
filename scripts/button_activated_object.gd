extends Node2D

@export var collision: CollisionShape2D

@export var on_sprite: Sprite2D
@export var off_sprite: Sprite2D

@export var buttons: Array[ActivateButton]

func _physics_process(delta: float) -> void:
	off_sprite.set_visible(not _is_buttons_pressed())
	on_sprite.set_visible(_is_buttons_pressed())
	collision.set_disabled(not _is_buttons_pressed())

func _is_buttons_pressed() -> bool:
	for button in buttons:
		if not button.activated: 
			return false
	return true
