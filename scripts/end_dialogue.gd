extends BaseDialogueReader

@export var walk_to: Marker2D
@export var end_scene: Node2D
@export var collision: CollisionShape2D

func _on_start_writing() -> void:
	GlobalReference.Player.process = false
	GlobalReference.Player.process_animation = true
	
	await get_tree().physics_frame
	
	var distance: float = absf(GlobalReference.Player.global_position.x - walk_to.global_position.x)
	var direction: float = -1 if GlobalReference.Player.global_position.x - walk_to.global_position.x > 0 else 1
	var speed: float = GlobalReference.Player.move_speed * 0.8
	
	GlobalReference.Player.on_move(direction)
	
	await create_tween().tween_property(GlobalReference.Player, "global_position:x", walk_to.global_position.x, distance / speed).finished
	
	GlobalReference.Player.on_move(0)
	GlobalReference.Player.set_sprite_direction(-1)

func _on_end_writing() -> void:
	writer.hide_dialogue_box()
	collision.set_disabled(true)
	end_scene.play_end_scene()
