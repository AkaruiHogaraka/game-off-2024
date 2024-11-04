@tool extends Node2D

@export var target: Node2D 
@export var speed: float = 25

func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(target.global_position, delta * speed)
	global_position = global_position.round()
