extends Node2D

@export var camera: Camera2D
@export var camera_destination: Marker2D
@export var time_label: Label
@export var collectables_label: Label
@export var next_label: Label
@export var camera_time: float = 1.0

var can_continue: bool

func _unhandled_input(event: InputEvent) -> void:
	if can_continue and Input.is_action_just_pressed("interact"):
		can_continue = false
		reset_game()

func _play_end_scene() -> void:
	GlobalScene.CurrentScene.scene_camera.get_child(0).set_enabled(false)
	camera.set_enabled(true)
	
	var tween: Tween = get_tree().create_tween()
	camera.get_parent().global_position = GlobalScene.CurrentScene.scene_camera.global_position
	next_label.get_parent().global_position.x = GlobalScene.CurrentScene.scene_camera.global_position.x
	tween.tween_property(camera.get_parent(), "global_position:y", camera_destination.global_position.y, camera_time)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	collectables_label.set_visible(true)
	# Count up collectables
	
	await get_tree().create_timer(1.0).timeout
	
	time_label.set_visible(true)
	
	await  get_tree().create_timer(1.0).timeout
	
	next_label.set_visible(true)
	can_continue = true

func reset_game() -> void:
	var colour_one: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_one")
	var colour_two: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_two")
	var colour_three: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_three")
	var colour_four: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_four")
	
	GlobalReference.DreamMaterial.set("shader_parameter/replace_four", colour_three)
	
	await get_tree().create_timer(0.24).timeout
	
	GlobalReference.DreamMaterial.set("shader_parameter/replace_three", colour_two)
	GlobalReference.DreamMaterial.set("shader_parameter/replace_four", colour_two)
	
	await get_tree().create_timer(0.24).timeout
	
	GlobalReference.DreamMaterial.set("shader_parameter/replace_two", colour_one)
	GlobalReference.DreamMaterial.set("shader_parameter/replace_three", colour_one)
	GlobalReference.DreamMaterial.set("shader_parameter/replace_four", colour_one)
	
	GlobalScene.SaveData = []
	GlobalReference.PlayerRealityPosition = Vector2.ZERO
	GlobalScene.CurrentScene = null
	
	GlobalScene.IsRestarting = true
	get_tree().current_scene.queue_free()
	var game = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(game)
	
	GlobalReference.DreamMaterial.set("shader_parameter/replace_two", colour_two)
	GlobalReference.DreamMaterial.set("shader_parameter/replace_three", colour_three)
	GlobalReference.DreamMaterial.set("shader_parameter/replace_four", colour_four)
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GlobalReference.Player.Input_Handler.toggle_inputs(false)
		GlobalReference.Player.reset_velocities()
		_play_end_scene()
