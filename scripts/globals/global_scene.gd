extends Node

var CurrentScene: Scene

func change_scene(scene: SceneConnection) -> void:
	scene.preload_connected_scene()
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.reset_velocities()
	
	var transition = load("res://prefabs/transition.tscn").instantiate()
	GlobalReference.Player.get_parent().add_child(transition)
	transition.global_position = GlobalReference.Player.global_position
	await transition.transition(1, 0, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO).finished
	
	CurrentScene.queue_free()
	CurrentScene = scene.scene
	GlobalReference.Player.get_parent().add_child(CurrentScene)
	
	var position: Vector2 = scene.node.get_global_position()
	GlobalReference.Player.set_global_position(Vector2(position.x, position.y))
	
	transition.transition(0, 1, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
	await get_tree().create_timer(0.2).timeout
	
	transition.queue_free()
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
