extends BaseDialogueReader

@export var area: Area2D
@export var tutorial: Control
@export var enable_areas: Array[Area2D]

func _on_end_writing() -> void:
	area.disable(true)
	writer.hide_dialogue_box()
	
	GlobalReference.Player.set_collision_layer_value(3, true)
	GlobalReference.Player.set_collision_layer_value(6, true)
	GlobalReference.Player.set_speed_multiplier(1.0)
		
	if GlobalReference.Player._interaction_object != null:
		if GlobalReference.Player._interaction_object.has_method("_let_go_interaction"):
			GlobalReference.Player._interaction_object._let_go_interaction(true)
		
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	GlobalReference.Player.Input_Handler.set_can_jump(false)
	
	tutorial.set_visible(true)
	can_input = false
	
	for area in enable_areas:
		area.set_monitoring(true)
	
	tutorial.set_modulate(Color.GREEN)
	await get_tree().create_timer(0.24).timeout
	if tutorial == null: return
	tutorial.set_modulate(Color.RED)
	await get_tree().create_timer(0.24).timeout
	if tutorial == null: return
	tutorial.set_modulate(Color.WHITE)
