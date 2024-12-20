class_name GameManager extends Node

@export var main_screen: CanvasLayer

@export var screen: CanvasLayer
@export var combined_viewport: SubViewport

@export var reality_viewport: SubViewport
@export var reality_node: Node2D
@export var reality_display: ColorRect
@export var reality_gem_count: Label
@export var reality_heart_ui: HeartUI
@export var reality_inventory_ui: TextureRect

@export var dream_viewport: SubViewport
@export var dream_node: Node2D
@export var dream_display: ColorRect
@export var dream_gem_count: Label
@export var dream_heart_ui: HeartUI
@export var dream_inventory_ui: TextureRect

@export var transition_node: Transition

@export var reality_reference: Node2D

@export var camera_come_from: Vector2
@export var camera_tween_time: float

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
	
	transition_node.mask.get_parent().set_position(((get_tree().root.get_final_transform() * GlobalReference.Player.get_global_transform_with_canvas()).origin))
	transition_node.transition(0, 1, 0, Tween.EASE_IN, Tween.TRANS_EXPO)
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	if GlobalScene.IsRestarting: 
		call_deferred("clear_previous_game")
	
	dream_gem_count.text = "x%s" % GlobalItems.gems
	reality_gem_count.text = "x%s" % GlobalItems.dream_gems
	dream_gem_count.get_parent().set_visible(false)

func clear_previous_game() -> void:
	GlobalScene.IsRestarting = false
	
	await get_tree().physics_frame
	
	GlobalReference.temp_game_screen.queue_free()
	
	await get_tree().create_timer(0.24 * 3).timeout
	
	get_tree().current_scene.queue_free()
