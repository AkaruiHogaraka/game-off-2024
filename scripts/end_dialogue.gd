extends BaseDialogueReader

@export var end_scene: Node2D
@export var collision: CollisionShape2D

func _on_end_writing() -> void:
	writer.hide_dialogue_box()
	collision.set_disabled(true)
	end_scene.play_end_scene()
