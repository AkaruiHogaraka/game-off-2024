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

@export var camera_come_from: Vector2
@export var camera_tween_time: float

@export var min_size: Vector2 = Vector2.ZERO
@export var max_size: Vector2 = Vector2.ONE * 20
@export_range(0, 1) var start_progress: int

var progress: float

func _ready() -> void:
	GlobalReference.Game = self
	GlobalReference.PlayerRealityReference = reality_reference
	GlobalReference.DreamMaterial = dream_node.get_material()
	GlobalReference.RealityMaterial = dream_node.get_material()
	
	reality_node.reparent(reality_viewport)
	reality_viewport.size = reality_display.size
	reality_display.set_position(dream_display.position)
	
	dream_node.reparent(dream_viewport)
	dream_viewport.size = dream_display.size
	
	screen.set_visible(true)
	get_tree().set_current_scene(self)
	
	progress = start_progress
	transition_node.set_position(((get_tree().root.get_final_transform() * GlobalReference.Player.get_global_transform_with_canvas()).origin))
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	if GlobalScene.IsRestarting: pan_camera()

func pan_camera() -> void:
	var tween: Tween = get_tree().create_tween()
	var destination: Vector2 = GlobalScene.CurrentScene.scene_camera.global_position
	GlobalScene.CurrentScene.scene_camera.global_position.y = camera_come_from.y
	tween.tween_property(GlobalScene.CurrentScene.scene_camera, "global_position:y", destination.y, camera_tween_time)
	tween.set_ease(Tween.EASE_IN_OUT)

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
