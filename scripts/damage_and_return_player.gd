extends BaseDamagePlayer

func on_damaged() -> void:
	#GlobalScene.soft_respawn(GlobalReference.Player.last_safe_position)
	GlobalScene.last_door_respawn(GlobalReference.Player.last_door_position, GlobalReference.Player.last_door_scene)
