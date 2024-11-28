extends AnimatedSprite2D

func _ready() -> void:
	var nodes = get_tree().get_nodes_in_group("Campfire")
	
	for sprite in nodes:
		if sprite != self:
			set_frame_and_progress(sprite.get_frame(), sprite.get_frame_progress())
