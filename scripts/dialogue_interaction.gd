extends BaseInteraction

@export var area: Area2D

@export var dialogue: BaseDialogueReader

func _initialise() -> void:
	dialogue.EndDialogue.connect(_on_end_dialogue)

func _on_interaction() -> void:
	if not can_interact or not in_area: return
	
	dialogue.reset_dialogue()
	
	dialogue.on_read_line()
	can_interact = false
	area.set_monitoring(can_interact)
	GlobalReference.Player.Input_Handler.toggle_inputs(false)
	
	await get_tree().physics_frame
	dialogue.can_input = true

func _on_end_dialogue() -> void:
	dialogue.reset_dialogue()
	GlobalReference.Player.Input_Handler.toggle_inputs(true)
	
	await GlobalReference.Player.Input_Handler.InteractionLetGo
	
	can_interact = true
	area.set_monitoring(true)
