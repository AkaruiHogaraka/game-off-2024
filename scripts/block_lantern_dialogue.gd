extends BaseDialogueReader

@export var return_marker: Marker2D
@export var area: DialogueTrigger

func _on_start_writing() -> void:
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	GlobalReference.Player.on_move(0)

func _on_end_writing() -> void:
	writer.hide_dialogue_box()
	
	GlobalReference.Player.process = false
	
	var distance: float = absf(GlobalReference.Player.global_position.x - return_marker.global_position.x)
	var direction: float = -1 if GlobalReference.Player.global_position.x - return_marker.global_position.x > 0 else 1
	var speed: float = GlobalReference.Player.move_speed * GlobalReference.Player._speed_multiplier
	
	GlobalReference.Player.on_move(direction)
	
	await create_tween().tween_property(GlobalReference.Player, "global_position:x", return_marker.global_position.x, distance / speed).finished
	
	GlobalReference.Player.on_move(0)
	GlobalReference.Player.set_sprite_direction(-1)
	GlobalReference.Player.process = true
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	area.in_area = false
	reset_dialogue()
