extends DialogueTrigger

func _on_body_enter_extra() -> void:
	await get_tree().create_timer(0.5).timeout
	
	GlobalReference.Player.set_sprite_direction(1)
	
	await get_tree().create_timer(1.0).timeout
	
	GlobalReference.Player.set_sprite_direction(-1)
	
	await get_tree().create_timer(0.5).timeout
