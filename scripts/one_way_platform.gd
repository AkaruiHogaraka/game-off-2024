extends Node2D

var in_area: bool 
var process_platform: bool

func _ready() -> void:
	$Area2D.connect("body_entered", _on_body_entered)
	$Area2D.connect("body_exited", _on_body_exited)
	GlobalReference.Player.Input_Handler.DownJump.connect(_disable_collision)

func _physics_process(delta: float) -> void:
	if not process_platform: return
	$StaticBody2D/CollisionShape2D.set_disabled(GlobalReference.Player.global_position.y >= $Marker2D.global_position.y)

func _disable_collision() -> void:
	$StaticBody2D/CollisionShape2D.set_disabled(true)
	process_platform = false
	await get_tree().create_timer(0.5).timeout
	process_platform = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = false
