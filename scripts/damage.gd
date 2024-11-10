class_name BaseDamagePlayer extends Node

@export var internal_cooldown: float = 1.0

var cooldown: float

func _ready() -> void:
	cooldown = 0.0

func _physics_process(delta: float) -> void:
	if cooldown >= 0: cooldown -= delta

func on_damaged() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and cooldown <= 0:
		cooldown = internal_cooldown
		on_damaged()
