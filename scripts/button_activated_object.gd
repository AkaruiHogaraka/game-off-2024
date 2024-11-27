extends Node2D

@export var collision: CollisionShape2D
@export var all_pressed: bool = true
@export var turn_on: bool = true

@export var on_sprite: Sprite2D
@export var off_sprite: Sprite2D

@export var buttons: Array[ActivateButton]

func _physics_process(delta: float) -> void:
	off_sprite.set_visible(_is_buttons_pressed() if not turn_on else not _is_buttons_pressed())
	on_sprite.set_visible(not _is_buttons_pressed() if not turn_on else _is_buttons_pressed())
	collision.set_disabled(_is_buttons_pressed() if not turn_on else not _is_buttons_pressed())
	collision.set_visible(not _is_buttons_pressed() if not turn_on else _is_buttons_pressed())

func _is_buttons_pressed() -> bool:
	for button in buttons:
		if not button.activated and all_pressed: 
			return false
		if button.activated and not all_pressed:
			return true
	
	if all_pressed:
		return true
	else:
		return false
