extends DialogueTrigger

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not in_area and not GlobalItems.has_lantern:
		in_area = true
		
		await _on_body_enter_extra()
		
		GlobalItems.require_lantern = true
		
		dialogue.reset_dialogue()
		dialogue.can_input = true
		dialogue.on_read_line()
