extends Control

var has_dreamed: bool = false
@export var is_dream: bool

func _ready() -> void:
	GlobalReference.Player.Input_Handler.Dream.connect(_on_dream)

func _on_dream() -> void:
	has_dreamed = true

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"has_dreamed": has_dreamed
	}
	
	return data

func load_data(data: Dictionary) -> void:
	has_dreamed = data["has_dreamed"]
	
	if not GlobalScene.CurrentScene.is_alternate_scene_dream == is_dream:
		set_visible(not has_dreamed)
