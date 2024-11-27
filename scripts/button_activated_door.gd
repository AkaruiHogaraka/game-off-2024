extends Node2D

@export var collision: CollisionShape2D
@export var turn_on: bool = true

@export var on_sprite: Sprite2D
@export var off_sprite: Sprite2D

@export var buttons: Array[ActivateButton]

var activated: bool

func _physics_process(delta: float) -> void:
	activated = _is_buttons_pressed()
	_open_door()

func _open_door() -> void:
	off_sprite.set_visible(activated if not turn_on else not activated)
	on_sprite.set_visible(not activated if not turn_on else activated)
	collision.set_disabled(activated if not turn_on else not activated)

func _is_buttons_pressed() -> bool:
	for button in buttons:
		if not button.activated: 
			return false
	return true

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"activated": activated
	}
	
	return data

func load_data(data: Dictionary) -> void:
	activated = data["activated"]
	if activated:
		_open_door()
		set_physics_process_internal(not activated)
