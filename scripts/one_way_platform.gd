extends Node

@export var collision: CollisionShape2D
@export var platform_position: Marker2D

var in_area: bool 
var process_platform: bool

func _ready() -> void:
	GlobalReference.Player.Input_Handler.DownJump.connect(_disable_collision)
	process_platform = true

func _physics_process(delta: float) -> void:
	var disabled: bool = GlobalReference.Player.global_position.y >= platform_position.global_position.y
	if not process_platform: return
	collision.set_disabled(disabled)

func _disable_collision() -> void:
	collision.set_disabled(true)
	process_platform = false
	await get_tree().create_timer(0.05).timeout
	process_platform = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = false
