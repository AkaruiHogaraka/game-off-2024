class_name DialogueTrigger extends Area2D

@export var dialogue: BaseDialogueReader

var in_area: bool

func _ready() -> void:
	disable(false)

func disable(value: bool = true) -> void:
	set_monitoring(not value)

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"is_monitoring": false
	}
	
	return data

func load_data(data: Dictionary):
	if not data["is_monitoring"]:
		get_parent().queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not in_area:
		in_area = true
		
		await _on_body_enter_extra()
		
		dialogue.reset_dialogue()
		dialogue.can_input = true
		dialogue.on_read_line()

func _on_body_enter_extra() -> void:
	await get_tree().create_timer(1).timeout
