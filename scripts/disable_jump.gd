extends Area2D

@export var enable: bool

var in_area: bool

func _physics_process(delta: float) -> void:
	if in_area:
	
		GlobalReference.Player.Input_Handler.set_can_jump(enable)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not GlobalItems.require_lantern:
		in_area = true
