class_name GameManager extends Node

@export var screen: CanvasLayer

@export var reality_viewport: SubViewport
@export var reality_node: Node2D
@export var reality_display: ColorRect

@export var dream_viewport: SubViewport
@export var dream_node: Node2D
@export var dream_display: ColorRect

@export var transition_node: Control

@export var reality_reference: Node2D

@export var min_size: Vector2 = Vector2.ZERO
@export var max_size: Vector2 = Vector2.ONE * 20

var progress: float

func _ready() -> void:
	GlobalReference.Game = self
	GlobalReference.PlayerRealityReference = reality_reference
	
	reality_node.reparent(reality_viewport)
	reality_viewport.size = reality_display.size
	reality_display.set_position(dream_display.position)
	
	dream_node.reparent(dream_viewport)
	dream_viewport.size = dream_display.size
	
	screen.set_visible(true)

func _physics_process(delta: float) -> void:
	transition_node.set_scale(min_size.lerp(max_size, progress))

func transition(from: int, to: int, duration: float, ease_mode: Tween.EaseType, trans_mode) -> Tween:
	progress = from
	transition_node.set_scale(min_size.lerp(max_size, progress))
	var tween: Tween = create_tween()
	tween.tween_property(self, "progress", to, duration)
	tween.set_ease(ease_mode)
	tween.set_trans(trans_mode)
	
	return tween
