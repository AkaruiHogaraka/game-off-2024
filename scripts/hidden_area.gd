extends Node2D

@export var discovered: bool
@export var permanent: bool = true

func _ready() -> void:
	set_visible(true)
	$TileMapLayer.set_visible(true)
	
	if discovered:
		$TileMapLayer.modulate.a = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		discovered = true
		get_tree().create_tween().tween_property($TileMapLayer, "modulate:a", 0, 0)
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and not permanent:
		discovered = false
		get_tree().create_tween().tween_property($TileMapLayer, "modulate:a", 1, 0)

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"discovered": discovered
	}
	return data

func load_data(data: Dictionary) -> void:
	discovered = data["discovered"]
	
	if discovered:
		$TileMapLayer.modulate.a = 0
