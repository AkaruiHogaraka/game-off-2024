extends Node

var CurrentScene: Scene

func change_scene(scene: SceneConnection, reality: bool = true) -> void:
	if not scene.preload_connected_scene(): return
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.reset_velocities()
	
	var transition = load("res://prefabs/transition.tscn").instantiate()
	GlobalReference.Player.get_parent().add_child(transition)
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	await transition.transition(1, 0, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO).finished
	
	CurrentScene.queue_free()
	CurrentScene = scene.scene
	
	if reality:
		GlobalReference.Game.reality_node.add_child(CurrentScene)
	else:
		GlobalReference.Game.dream_node.add_child(CurrentScene)
	
	var position: Vector2 = scene.node.get_global_position()
	GlobalReference.Player.set_global_position(Vector2(position.x, position.y))
	
	await get_tree().create_timer(0.2).timeout
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	transition.transition(0, 1, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
	await get_tree().create_timer(0.2).timeout
	
	transition.queue_free()
	GlobalReference.Player.Input_Handler.toggle_inputs(true)

func change_dream_scene(scene: SceneConnection, reality: bool) -> void:
	if scene == null:
		push_warning("There is no dream for this scene! Skipping...")
		return
	
	scene.preload_connected_scene()
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.reset_velocities()
	
	var old_scene: Scene = CurrentScene
	CurrentScene = scene.scene
	
	var node: Node2D
	var tween: Tween
	
	if reality:
		node = GlobalReference.Game.reality_node
		tween = GlobalReference.Game.transition(1, 0, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		GlobalReference.Player.global_position = GlobalReference.PlayerRealityPosition
	else:
		node = GlobalReference.Game.dream_node
		tween = GlobalReference.Game.transition(0, 1, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		GlobalReference.PlayerRealityPosition = GlobalReference.Player.global_position
	
	GlobalReference.Game.transition_node.set_position(((get_tree().root.get_final_transform() * GlobalReference.Player.get_global_transform_with_canvas()).origin))
	
	if node == null: 
		push_warning("Something went wrong while dreaming!")
		return # Something went wrong
	
	node.add_child(CurrentScene)
	GlobalReference.Player.reparent(node)
	GlobalReference.PlayerParent = node
	
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	
	await tween.finished
	old_scene.queue_free()
	
