extends Area2D

@export var can_dream: bool

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not GlobalItems.has_lantern:
		GlobalReference.Player._can_dream = can_dream
