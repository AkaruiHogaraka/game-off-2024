extends Node2D

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	$CanvasLayer/Transition2.transition(0, 14, 0.8, Tween.EASE_IN, Tween.TRANS_EXPO)

func _on_timer_timeout() -> void:
	var scene = load("res://scenes/game.tscn").instantiate()
	
	get_tree().root.add_child(scene)
	
	get_tree().root.move_child(self, get_tree().root.get_child_count() - 1)
	
	await get_tree().physics_frame
	
	await $CanvasLayer/Transition.transition(0, 14, 1.0, Tween.EASE_IN, Tween.TRANS_EXPO).finished
	queue_free()
