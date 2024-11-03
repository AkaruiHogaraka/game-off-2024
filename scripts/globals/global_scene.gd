extends Node

var CurrentScene: Scene

func change_scene(scene: SceneConnection) -> void:
	scene.preload_connected_scene()
	# Transition
	
	CurrentScene.queue_free()
	CurrentScene = scene.scene
	GlobalReference.Player.get_parent().add_child(CurrentScene)
	
	var position: Vector2 = scene.node.get_global_position()
	GlobalReference.Player.set_global_position(Vector2(position.x, position.y))
