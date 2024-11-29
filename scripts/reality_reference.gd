extends Node2D

func update_sprite_direction() -> void:
	$Sprite2D.scale = GlobalReference.Player.sprite_parent.scale
