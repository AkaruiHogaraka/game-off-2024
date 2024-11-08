class_name Transition extends Node2D

@export var min_size: Vector2 = Vector2.ZERO
@export var max_size: Vector2 = Vector2.ONE * 10
@export var mask: Node

var progress: float

func _physics_process(delta: float) -> void:
	if mask == null: $Circle.set_scale(min_size.lerp(max_size, progress))
	elif mask: mask.get_material().set("shader_parameter/radius", lerp(min_size.x, max_size.x, progress))

func transition(from: int, to: int, duration: float, ease_mode: Tween.EaseType, trans_mode, max_size_override: bool = false, max_size: Vector2 = Vector2.ZERO) -> Tween:
	progress = from
	
	if max_size_override: self.max_size = max_size
	
	if mask == null: $Circle.set_scale(min_size.lerp(max_size, progress))
	elif mask: mask.get_material().set("shader_parameter/radius", lerp(min_size.x, max_size.x, progress))
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "progress", to, duration)
	tween.set_ease(ease_mode)
	tween.set_trans(trans_mode)
	
	return tween
