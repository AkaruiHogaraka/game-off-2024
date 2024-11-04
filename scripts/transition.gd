extends Node2D

signal move_on()

@export var min_size: Vector2 = Vector2.ZERO
@export var max_size: Vector2 = Vector2.ONE * 10

var progress: float

func _physics_process(delta: float) -> void:
	$Circle.set_scale(min_size.lerp(max_size, progress))

func transition(from: int, to: int, duration: float, ease_mode: Tween.EaseType, trans_mode) -> Tween:
	progress = from
	var tween: Tween = create_tween()
	tween.tween_property(self, "progress", to, duration)
	tween.set_ease(ease_mode)
	tween.set_trans(trans_mode)
	
	return tween
