extends DialogueTrigger

func _on_body_enter_extra() -> void:
	await get_tree().create_timer(1.0).timeout
	
	GlobalReference.Player.sprite.play("wake_up")
	
	await GlobalReference.Player.sprite.animation_finished
	
	GlobalReference.Player.process_animation = true
	await get_tree().create_timer(0.5).timeout
