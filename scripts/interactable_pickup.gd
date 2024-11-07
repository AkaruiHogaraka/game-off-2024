extends BaseInteraction

@export var collision: CollisionShape2D
@export var item: BasePickupItem

var has_interacted: bool

func _initialise() -> void:
	collision.set_disabled(has_interacted)

func _on_interaction() -> void:
	if not in_area or has_interacted: return
	has_interacted = true
	can_interact = false
	collision.set_disabled(true)
	item.on_pickup()

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"has_interacted": has_interacted
	}
	
	return data

func load_data(data: Dictionary) -> void:
	has_interacted = data["has_interacted"]
	_initialise()
