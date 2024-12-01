extends Node2D

@export var camera: Camera2D
@export var elements: Control
@export var title_label: Label
@export var credit_label: Label
@export var time_label: Label
@export var collectable_parent: Control
@export var collectables_label: Label
@export var next_label: Label

var can_continue: bool

func _ready() -> void:
	elements.set_visible(false)
	title_label.set_visible(false)
	credit_label.set_visible(false)
	time_label.set_visible(false)
	collectable_parent.set_visible(false)
	next_label.set_visible(false)

func _unhandled_input(event: InputEvent) -> void:
	if can_continue and Input.is_action_just_pressed("interact"):
		can_continue = false
		reset_game()

func play_end_scene() -> void:
	GlobalScene.CurrentScene.scene_camera.get_child(0).set_enabled(false)
	camera.set_enabled(true)
	
	var colour_one: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_one")
	var colour_two: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_two")
	var colour_three: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_three")
	var colour_four: Color = GlobalReference.DreamMaterial.get("shader_parameter/replace_four")
	
	await get_tree().create_timer(0.5).timeout
	
	await fade_out_shader(GlobalReference.DreamMaterial, colour_one, colour_two, colour_three, colour_four, 0.24)
	
	await get_tree().create_timer(0.5).timeout
	
	elements.set_visible(true)
	
	title_label.set_visible(true)
	credit_label.set_visible(true)
	fade_in_shader(title_label.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	await fade_in_shader(credit_label.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	
	await get_tree().create_timer(1.0).timeout
	
	collectable_parent.set_visible(true)
	exponential_count(GlobalItems.gems, 1.0, _on_update_gem_count)
	await fade_in_shader(collectable_parent.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	
	await get_tree().create_timer(0.6).timeout
	
	time_label.set_visible(true)
	exponential_count(round(GlobalReference.GameTime), 1.0, _on_update_game_time)
	await fade_in_shader(time_label.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	
	await get_tree().create_timer(1.2).timeout
	
	next_label.set_visible(true)
	await fade_in_shader(next_label.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	can_continue = true

func reset_game() -> void:
	get_tree().set_current_scene(GlobalReference.Game)
	
	title_label.set_visible(true)
	credit_label.set_visible(true)
	var colour_one: Color = title_label.get_material().get("shader_parameter/replace_one")
	var colour_two: Color = title_label.get_material().get("shader_parameter/replace_two")
	var colour_three: Color = title_label.get_material().get("shader_parameter/replace_three")
	var colour_four: Color = title_label.get_material().get("shader_parameter/replace_four")
	fade_out_shader(credit_label.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	
	collectable_parent.set_visible(true)
	fade_out_shader(collectable_parent.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	
	time_label.set_visible(true)
	fade_out_shader(time_label.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	
	next_label.set_visible(true)
	await fade_out_shader(next_label.get_material(), colour_one, colour_two, colour_three, colour_four, 0.24)
	
	await get_tree().create_timer(0.3).timeout
	
	GlobalScene.SaveData = []
	GlobalReference.PlayerRealityPosition = Vector2.ZERO
	GlobalScene.CurrentScene = null
	
	next_label.get_parent().queue_free()
	
	await get_tree().physics_frame
	
	var game = load("res://scenes/game.tscn").instantiate()
	get_tree().root.call_deferred("add_child", game)
	
	var screen = GlobalReference.Game.main_screen.duplicate()
	get_tree().root.add_child(screen)
	GlobalReference.temp_game_screen = screen
	
	screen.get_child(0).get_child(0).get_material().set("shader_parameter/main_texture", ImageTexture.create_from_image(GlobalReference.Game.combined_viewport.get_texture().get_image()))
	
	fade_in_shader(GlobalReference.DreamMaterial, colour_one, colour_two, colour_three, colour_four, 0.24)
	
	GlobalItems.reset_items()
	GlobalReference.end_game_time()
	GlobalScene.IsRestarting = true
	
	await get_tree().physics_frame

func fade_out_shader(mat: Material, col_one: Color, col_two: Color, col_three: Color, col_four: Color, time: float) -> void:
	mat.set("shader_parameter/replace_four", col_three)
	
	await get_tree().create_timer(time).timeout
	
	mat.set("shader_parameter/replace_three", col_two)
	mat.set("shader_parameter/replace_four", col_two)
	
	await get_tree().create_timer(time).timeout
	
	mat.set("shader_parameter/replace_two", col_one)
	mat.set("shader_parameter/replace_three", col_one)
	mat.set("shader_parameter/replace_four", col_one)
	
	await get_tree().create_timer(time).timeout

func fade_in_shader(mat: Material, col_one: Color, col_two: Color, col_three: Color, col_four: Color, time) -> void:
	mat.set("shader_parameter/replace_two", col_two)
	mat.set("shader_parameter/replace_three", col_two)
	mat.set("shader_parameter/replace_four", col_two)
	
	await get_tree().create_timer(time).timeout
	
	mat.set("shader_parameter/replace_three", col_three)
	mat.set("shader_parameter/replace_four", col_three)
	
	await get_tree().create_timer(time).timeout
	
	mat.set("shader_parameter/replace_four", col_four)
	
	await get_tree().create_timer(time).timeout

func exponential_count(target_value: int, duration: float, callback: Callable) -> void:
	var elapsed_time = 0.0
	var start_value = 0
	var exponential_factor = 5
	while elapsed_time < duration:
		var t = elapsed_time / duration
		var eased_value = start_value + (target_value - start_value) * (1 - exp(-exponential_factor * t))
		callback.call(round(eased_value))
		
		elapsed_time += get_physics_process_delta_time()
		await get_tree().create_timer(get_physics_process_delta_time()).timeout
		
	callback.call(target_value)

func _on_update_gem_count(value: int) -> void:
	if collectables_label == null: return
	collectables_label.text = "x %s/15" % [value if value >= 10 else "0" + "%s" % [value]]

func _on_update_game_time(value: int) -> void:
	if time_label == null: return
	var minutes = value / 60
	var seconds = value % 60
	var formatted_time = "%02d:%02d" % [minutes, seconds]
	time_label.text = formatted_time
