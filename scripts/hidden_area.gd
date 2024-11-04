extends Node2D

@export var discovered: bool

func _ready() -> void:
	$TileMapLayer.set_visible(true)
	
	if discovered:
		$TileMapLayer.modulate.a = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		discovered = true
		get_tree().create_tween().tween_property($TileMapLayer, "modulate:a", 0, 0.2)
