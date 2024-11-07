extends BaseInteraction

@export var collision: CollisionShape2D

var has_interacted: bool

func _initialise() -> void:
	collision.set_disabled(has_interacted)

func _on_interaction() -> void:
	if not in_area: return
	
	has_interacted = true
	GlobalReference.Player.set_interaction_display(false)

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"has_interacted": has_interacted
	}
	
	return data

func load_data(data: Dictionary) -> void:
	has_interacted = data["has_interacted"]
	_initialise()
