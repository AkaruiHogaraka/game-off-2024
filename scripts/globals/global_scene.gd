extends Node

var CurrentScene: Scene
var NewMask: MaskPreset

var SaveData: Array[Dictionary]
var SavedSpawnedObjects: Array[Node2D]

var internal_scene_change_cooldown: bool
var IsRestarting: bool
var is_soft_respawning: bool
var is_respawning: bool
var is_holding_lantern: bool

func change_scene(scene: SceneConnection, reality: bool = true) -> bool:
	if internal_scene_change_cooldown or not scene.preload_connected_scene(): return false
	var position: Vector2 = scene.node.get_global_position()
	var old_scene: Scene = CurrentScene
	var new_scene: Scene = scene.scene
	NewMask = new_scene.mask_settings
	
	internal_scene_change_cooldown = true
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.reset_velocities()
	GlobalReference.Player.on_interaction_let_go()
	GlobalReference.Game.transition_node.set_visible(false)
	GlobalReference.Player.interaction_sprite.set_visible(false)
	
	save_nodes()
	
	var transition = load("res://prefabs/misc/transition.tscn").instantiate()
	transition.set_visible(false)
	GlobalReference.Game.reality_node.call_deferred("add_child", transition)
	await get_tree().physics_frame
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	transition.transition(1.0, 0, 0.5 * CurrentScene.mask_settings.max_size, Tween.EASE_OUT, Tween.TRANS_LINEAR, true, Vector2(CurrentScene.mask_settings.max_size, 1))
	await get_tree().physics_frame
	transition.set_visible(true)
	await get_tree().create_timer(0.5 * CurrentScene.mask_settings.max_size).timeout
	
	if reality:
		GlobalReference.Game.reality_node.call_deferred("add_child", new_scene)
	else:
		GlobalReference.Game.dream_node.call_deferred("add_child", new_scene)
	
	GlobalReference.Player.set_collision_layer_value(3, true)
	old_scene.disable_collision()
	
	await get_tree().physics_frame
	
	GlobalReference.Player.reset_velocities()
	GlobalReference.Player.set_global_position(Vector2(position.x, position.y + 0.01))
	
	new_scene.set_mask()
	
	await get_tree().physics_frame
	
	if is_holding_lantern:
		GlobalReference.Player.Inventory.items[GlobalReference.Player.Inventory.item_index].on_item_equip()
	
	old_scene.set_visible(false)
	old_scene.scene_camera.get_child(0).set_enabled(false)
	
	load_nodes()
	remove_nodes()
	
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	transition.transition(0, 1, 0.3, Tween.EASE_OUT, Tween.TRANS_EXPO)
	
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	GlobalReference.Player.set_speed_multiplier(1.0)
	
	if GlobalReference.Player._interaction_object != null:
		if GlobalReference.Player._interaction_object.has_method("_let_go_interaction"):
			GlobalReference.Player._interaction_object._let_go_interaction(true)
	
	await get_tree().create_timer(0.3).timeout
	old_scene.queue_free()
	CurrentScene = new_scene
	transition.queue_free()
	
	await get_tree().physics_frame
	internal_scene_change_cooldown = false
	
	GlobalReference.Player._is_currently_interacting = false
	GlobalReference.Player.set_speed_multiplier(1.0)
	GlobalReference.Player.Input_Handler.set_can_jump(true)
	GlobalReference.Player.set_interaction_display(false)
	return true

func change_dream_scene(scene: SceneConnection, reality: bool, initial_setup: bool = false) -> void:
	if internal_scene_change_cooldown or is_soft_respawning: return
	if scene == null or scene.scene_path.is_empty():
		push_warning("There is no dream for this scene! Skipping...")
		return
	
	internal_scene_change_cooldown = true
	GlobalReference.Game.transition_node.set_visible(true)
	
	var temp_clone = GlobalReference.Player.duplicate(0)
	temp_clone.remove_child(temp_clone.get_child(temp_clone.get_child_count() - 1))
	temp_clone.set_collision_layer_value(3, false)
	
	if GlobalItems.has_lantern:
		for item in GlobalReference.Player.Inventory.items:
			if item.name == "Lantern":
				var lantern = item.duplicate(4)
				temp_clone.add_child(lantern)
				lantern.on_passive_item_effect()
	
	await get_tree().physics_frame
	
	GlobalReference.Player.set_collision_layer_value(3, false)
	GlobalReference.Player.set_collision_layer_value(6, false)
	
	scene.preload_connected_scene()
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.reset_velocities()
	
	save_nodes()
	if not reality:
		save_spawned_objects()
	
	var old_scene: Scene = CurrentScene
	CurrentScene = scene.scene
	
	var node: Node2D
	var tween: Tween
	
	if reality:
		GlobalReference.Game.dream_node.add_child(temp_clone)
		temp_clone.global_position = GlobalReference.Player.global_position
		node = GlobalReference.Game.reality_node
	else:
		GlobalReference.Game.dream_gem_count.get_parent().set_visible(true)
		GlobalReference.Game.reality_node.add_child(temp_clone)
		temp_clone.global_position = GlobalReference.Player.global_position
		GlobalReference.PlayerRealityReference.global_position = GlobalReference.Player.global_position
		GlobalReference.PlayerRealityReference.update_sprite_direction()
		node = GlobalReference.Game.dream_node
	
	var anim: AnimatedSprite2D = temp_clone.get_child(1).get_child(0)
	anim.play(GlobalReference.Player.sprite.get_animation())
	temp_clone.get_child(1).get_child(1).get_child(0).play(GlobalReference.Player.sprite.get_animation())
	anim.set_frame_and_progress(GlobalReference.Player.sprite.get_frame(), GlobalReference.Player.sprite.get_frame_progress())
	temp_clone.get_child(1).get_child(1).get_child(0).set_frame_and_progress(GlobalReference.Player.sprite.get_frame(), GlobalReference.Player.sprite.get_frame_progress())
	
	if node == null: 
		push_warning("Something went wrong while dreaming!")
		return # Something went wrong
	
	node.call_deferred("add_child", CurrentScene)
	GlobalReference.Player.call_deferred("reparent", node)
	GlobalReference.PlayerParent = node
	
	await get_tree().physics_frame
	
	if reality:
		GlobalReference.Player.global_position = GlobalReference.PlayerRealityPosition
		GlobalReference.Game.transition_node.mask.get_parent().set_position(((get_tree().root.get_final_transform() * GlobalReference.Player.get_global_transform_with_canvas()).origin))
		if initial_setup: GlobalReference.Game.transition_node.mask.get_parent().position.y = 420
		tween = GlobalReference.Game.transition_node.transition(1, 0, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		GlobalReference.Player.toggle_fog(true)
		CurrentScene.set_mask()
	else:
		GlobalReference.Game.transition_node.mask.get_parent().set_position(((get_tree().root.get_final_transform() * GlobalReference.Player.get_global_transform_with_canvas()).origin))
		tween = GlobalReference.Game.transition_node.transition(0, 1, 0.5, Tween.EASE_OUT, Tween.TRANS_EXPO)
		GlobalReference.PlayerRealityPosition = GlobalReference.Player.global_position
		GlobalReference.Player.toggle_fog(false)
	
	await get_tree().physics_frame
	
	if is_holding_lantern:
		GlobalReference.Player.Inventory.items[GlobalReference.Player.Inventory.item_index].on_item_equip()
	
	load_nodes()
	if reality:
		load_spawned_objects()
	
	if not initial_setup:
		
		GlobalReference.Player.set_collision_layer_value(3, true)
		GlobalReference.Player.set_collision_layer_value(6, true)
		GlobalReference.Player.set_speed_multiplier(1.0)
		
		if GlobalReference.Player._interaction_object != null:
			if GlobalReference.Player._interaction_object.has_method("_let_go_interaction"):
				GlobalReference.Player._interaction_object._let_go_interaction(true)
		
		if not reality: GlobalReference.Player.Input_Handler.toggle_inputs(true)
	
	await tween.finished
	
	remove_nodes()
	if reality and not initial_setup: GlobalReference.Player.Input_Handler.toggle_inputs(true)
	
	if old_scene != null: old_scene.free()
	temp_clone.queue_free()
	
	await get_tree().physics_frame
	internal_scene_change_cooldown = false
	if reality:
		adjust_spawned_objects()

func soft_respawn(position: Vector2) -> void:
	if is_soft_respawning: return
	
	if not GlobalReference.Game.reality_node == GlobalReference.Player.get_parent():
		await change_dream_scene(CurrentScene.alternate_scene, true)
		return
	
	is_soft_respawning = true
	
	if not GlobalReference.Player.reduce_health(1): return
	
	GlobalReference.Game.transition_node.set_visible(false)
	internal_scene_change_cooldown = true
	
	GlobalReference.Player.process = false
	GlobalReference.Player.global_position = round(GlobalReference.Player.global_position)
	
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	
	var transition = load("res://prefabs/misc/transition.tscn").instantiate()
	transition.set_visible(false)
	GlobalReference.Player.get_parent().call_deferred("add_child", transition)
	await get_tree().physics_frame
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	transition.transition(1, 0, 0.3, Tween.EASE_OUT, Tween.TRANS_LINEAR)
	await get_tree().physics_frame
	transition.set_visible(true)
	await get_tree().create_timer(0.3).timeout
	
	GlobalReference.Player.global_position = position
	GlobalReference.Player.reset_velocities()
	
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	var tween: Tween = transition.transition(0, 1, 0.3, Tween.EASE_OUT, Tween.TRANS_LINEAR)
	
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	GlobalReference.Player.process = true
	GlobalReference.Player.set_speed_multiplier(1.0)
	
	if GlobalReference.Player._interaction_object != null:
		if GlobalReference.Player._interaction_object.has_method("_let_go_interaction"):
			GlobalReference.Player._interaction_object._let_go_interaction(true)
	
	is_soft_respawning = false
	
	await tween.finished
	
	internal_scene_change_cooldown = false
	transition.queue_free()

func last_door_respawn(pos, scene_path) -> void:
	if is_respawning: return
	
	var scene_resource: Resource = load(scene_path)
	var old_scene: Scene = CurrentScene
	var new_scene: Scene = scene_resource.instantiate()
	new_scene.current_scene_path = scene_path
	new_scene.set_visible(false)
	
	GlobalReference.Player.process = false
	GlobalReference.Player.global_position = round(GlobalReference.Player.global_position)
	GlobalReference.Game.transition_node.set_visible(false)
	
	internal_scene_change_cooldown = true
	is_respawning = true
	
	var transition = load("res://prefabs/misc/transition.tscn").instantiate()
	transition.set_visible(false)
	GlobalReference.Game.reality_node.call_deferred("add_child", transition)
	await get_tree().physics_frame
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	transition.transition(1, 0, 0.3, Tween.EASE_OUT, Tween.TRANS_LINEAR)
	await get_tree().physics_frame
	transition.set_visible(true)
	await get_tree().create_timer(0.3).timeout
	
	GlobalReference.Game.reality_node.call_deferred("add_child", new_scene)
	await get_tree().physics_frame
	
	GlobalReference.Player.global_position = pos
	new_scene.set_mask()
	new_scene.set_visible(true)
	
	clear_temp_data()
	load_nodes()
	remove_nodes()
	
	GlobalReference.Player.current_health = GlobalReference.Player.starting_health
	GlobalReference.Game.reality_heart_ui.reset_hearts()
	GlobalReference.Game.dream_heart_ui.reset_hearts()
	
	old_scene.set_visible(false)
	old_scene.scene_camera.get_child(0).set_enabled(false)
	
	transition.global_position = GlobalReference.Player.global_position + (Vector2.UP * 8)
	transition.transition(0, 1, 0.3, Tween.EASE_OUT, Tween.TRANS_EXPO)
	
	GlobalReference.Player.process = true
	GlobalReference.Player.set_speed_multiplier(1.0)
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	
	if GlobalReference.Player._interaction_object != null:
		if GlobalReference.Player._interaction_object.has_method("_let_go_interaction"):
			GlobalReference.Player._interaction_object._let_go_interaction(true)
	
	await get_tree().create_timer(0.3).timeout
	is_respawning = false
	is_soft_respawning = false
	old_scene.queue_free()
	CurrentScene = new_scene
	transition.queue_free()
	
	await get_tree().physics_frame
	internal_scene_change_cooldown = false
	
	GlobalReference.Player.Input_Handler.toggle_inputs(true)

func save_spawned_objects() -> void:
	SavedSpawnedObjects.clear()
	for item in GlobalReference.Player.Inventory.items:
		if item.name == "Block Wand":
			for i in range(0, 3):
				if i > item.spawned_objects.size() - 1: 
					break
				var block_object = item.spawned_objects[item.spawned_objects.size() - 1 - i]
				if block_object == null: continue
				var object = block_object.duplicate()
				block_object.get_parent().add_child(object)
				object.remove_from_group("RemoveOnLoad")
				object.moveable = object.get_child(1)
				object.void_block = true
				object.set_visible(false)
				object.set_collision_layer(0)
				SavedSpawnedObjects.push_front(object)

func load_spawned_objects() -> void:
	for item in GlobalReference.Player.Inventory.items:
		if item.name == "Block Wand":
			for object in SavedSpawnedObjects:
				item.spawned_objects.push_back(object)
				object.void_block = false
				object.set_visible(true)
				object.set_collision_layer_value(8, true)

func adjust_spawned_objects() -> void:
	for object in SavedSpawnedObjects:
		object.add_to_group("RemoveOnLoad")

func save_nodes() -> void:
	var save_nodes = get_tree().get_nodes_in_group("Save")
	for node in save_nodes:
		if not node.has_method("save_data"): 
			push_warning("%s is marked to save but doesn't have a save function" % node.name)
			continue
		
		var new_data = node.call("save_data")
		
		print(new_data)
		
		for i in SaveData.size():
			if SaveData[i]["path"] == new_data["path"]:
				SaveData.remove_at(i)
				break
		
		SaveData.push_back(new_data)

func remove_nodes() -> void:
	var remove_nodes = get_tree().get_nodes_in_group("RemoveOnLoad")
	for node in remove_nodes:
		node.queue_free()

func load_nodes() -> void:
	var save_nodes = get_tree().get_nodes_in_group("Save")
	for node in save_nodes:
		if not node.has_method("load_data"):
			push_warning("%s is marked to save but doesn't have a load function" % node.name)
			continue
		
		for i in SaveData.size():
			if SaveData[i]["path"] == node.get_path():
				node.call("load_data", SaveData[i])
				break

func clear_temp_data() -> void:
	var keywords: Array[String] = ["HealthHeal"]
	var remove_at: Array[int]
	
	for data in SaveData:
		for keyword in keywords:
			if String(data["path"]).contains(keyword):
				SaveData.erase(data)
