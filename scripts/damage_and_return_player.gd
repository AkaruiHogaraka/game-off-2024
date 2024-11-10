extends BaseDamagePlayer

func on_damaged() -> void:
	GlobalScene.soft_respawn(GlobalReference.Player.last_safe_position)
