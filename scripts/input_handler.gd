class_name InputHandler extends Node

signal Interaction()
signal DirectionInput(_direction: float)
signal Jumping(_jump: bool, _direction: float)

var _raw_input: Vector2

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		Interaction.emit()
		
	_raw_input.x = Input.get_axis("move_left", "move_right")
	DirectionInput.emit(_raw_input.x)
	
	if Input.is_action_just_pressed("jump") and GlobalReference.Player.is_on_floor():
		_raw_input.y = 1
		Jumping.emit(true, _raw_input.y)

func _is_movement_occuring() -> bool:
	return abs(_raw_input.x) != 0 or abs(_raw_input.y) != 0
