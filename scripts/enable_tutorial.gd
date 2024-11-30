extends Node2D

@export var tutorial: Control
@export var disable_hitbox: CollisionShape2D

func enable_tutorial() -> void:
	tutorial.set_visible(true)
	disable_hitbox.set_disabled(false)
	tutorial.set_modulate(Color.GREEN)
	
	await get_tree().create_timer(0.24).timeout
	if tutorial == null: return
	
	tutorial.set_modulate(Color.RED)
	
	await get_tree().create_timer(0.24).timeout
	if tutorial == null: return
	
	tutorial.set_modulate(Color.WHITE)
