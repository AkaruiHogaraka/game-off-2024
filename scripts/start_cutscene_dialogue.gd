extends BaseDialogueReader

@export var walk_to: Marker2D
@export var lantern_progress: DialogueTrigger

func _on_end_writing() -> void:
	writer.hide_dialogue_box()
	
	lantern_progress.disable(true)
	
	GlobalReference.Player.process = false
	
	var distance: float = GlobalReference.Player.global_position.x - walk_to.global_position.x
	var direction: float = -1 if distance > 0 else 1
	var speed: float = GlobalReference.Player.move_speed * GlobalReference.Player._speed_multiplier
	
	GlobalReference.Player.on_move(direction)
	
	await create_tween().tween_property(GlobalReference.Player, "global_position:x", walk_to.global_position.x, distance / speed).finished
	
	GlobalReference.Player.on_move(0)
	GlobalReference.Player.set_sprite_direction(-1)
	GlobalReference.Player.process = true
	reset_dialogue()
	lantern_progress.disable(false)
