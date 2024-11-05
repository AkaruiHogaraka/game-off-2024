extends Node

var CurrentScene: Scene

var SaveData: Array[Dictionary]

var internal_scene_change_cooldown: bool

func change_scene(scene: SceneConnection, reality: bool = true) -> void:
	if not scene.preload_connected_scene() or internal_scene_change_cooldown: return
	
	internal_scene_change_cooldown = true
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.reset_velocities()
	
	save_nodes()
	
	var transition = load("res://prefabs/transition.tscn").instantiate()
	GlobalReference.Player.get_parent().add_child(transition)
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	await transition.transition(1, 0, 0.3, Tween.EASE_OUT, Tween.TRANS_LINEAR).finished
	
	CurrentScene.queue_free()
	CurrentScene = scene.scene
	
	if reality:
		GlobalReference.Game.reality_node.add_child(CurrentScene)
	else:
		GlobalReference.Game.dream_node.add_child(CurrentScene)
	
	var position: Vector2 = scene.node.get_global_position()
	GlobalReference.Player.set_global_position(Vector2(position.x, position.y))
	
	load_nodes()
	
	await get_tree().create_timer(0.2).timeout
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	transition.transition(0, 1, 0.3, Tween.EASE_OUT, Tween.TRANS_EXPO)
	
	GlobalReference.Player.set_collision_layer_value(3, true)
	await get_tree().create_timer(0.2).timeout
	
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	internal_scene_change_cooldown = false
	transition.queue_free()

func change_dream_scene(scene: SceneConnection, reality: bool) -> void:
	if scene == null:
		push_warning("There is no dream for this scene! Skipping...")
		return
		
	if internal_scene_change_cooldown: return
	
	internal_scene_change_cooldown = true
	
	GlobalReference.Player.set_collision_layer_value(3, false)
	
	scene.preload_connected_scene()
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.reset_velocities()
	
	save_nodes()
	
	var temp_clone = GlobalReference.Player.duplicate(0)
	temp_clone.remove_child(temp_clone.get_child(temp_clone.get_child_count() - 1))
	temp_clone.set_collision_layer_value(3, false)
	
	var old_scene: Scene = CurrentScene
	CurrentScene = scene.scene
	
	var node: Node2D
	var tween: Tween
	
	if reality:
		GlobalReference.Game.dream_node.add_child(temp_clone)
		temp_clone.global_position = GlobalReference.Player.global_position
	else:
		GlobalReference.Game.reality_node.add_child(temp_clone)
		temp_clone.global_position = GlobalReference.Player.global_position
		GlobalReference.PlayerRealityReference.global_position = GlobalReference.Player.global_position
	
	if reality:
		node = GlobalReference.Game.reality_node
		tween = GlobalReference.Game.transition(1, 0, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		GlobalReference.Player.global_position = GlobalReference.PlayerRealityPosition
		GlobalReference.Player.toggle_fog(true)
	else:
		node = GlobalReference.Game.dream_node
		tween = GlobalReference.Game.transition(0, 1, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		GlobalReference.PlayerRealityPosition = GlobalReference.Player.global_position
		GlobalReference.Player.toggle_fog(false)
	
	GlobalReference.Game.transition_node.set_position(((get_tree().root.get_final_transform() * (old_scene.scene_camera.get_global_transform_with_canvas()).origin)))
	
	if node == null: 
		push_warning("Something went wrong while dreaming!")
		return # Something went wrong
	
	node.add_child(CurrentScene)
	GlobalReference.Player.reparent(node)
	GlobalReference.PlayerParent = node
	
	load_nodes()
	
	if not reality: GlobalReference.Player.Input_Handler.toggle_inputs(true)
	
	await tween.finished
	
	if reality: GlobalReference.Player.Input_Handler.toggle_inputs(true)
	GlobalReference.Player.set_collision_layer_value(3, true)
	
	internal_scene_change_cooldown = false
	
	old_scene.queue_free()
	temp_clone.queue_free()

func save_nodes() -> void:
	var save_nodes = get_tree().get_nodes_in_group("Save")
	for node in save_nodes:
		if not node.has_method("save_data"): 
			push_warning("%s is marked to save but doesn't have a save function" % node)
			continue
		
		var new_data = node.call("save_data")
		
		print(new_data)
		
		for i in SaveData.size():
			if SaveData[i]["path"] == new_data["path"]:
				SaveData.remove_at(i)
				break
		
		SaveData.push_back(new_data)
		
func load_nodes() -> void:
	var save_nodes = get_tree().get_nodes_in_group("Save")
	for node in save_nodes:
		if not node.has_method("load_data"):
			push_warning("%s is marked to save but doesn't have a load function" % node)
			continue
		
		for i in SaveData.size():
			if SaveData[i]["path"] == node.get_path():
				node.call("load_data", SaveData[i])
				break
