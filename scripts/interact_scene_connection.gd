extends BaseInteraction

@export var scene_connection: SceneConnection
@export var invalid_sfx: AudioStreamPlayer

var changed_once: bool

func _on_interaction() -> void:
	if not in_area: return
	if not GlobalScene.CurrentScene.is_alternate_scene_dream:
		GlobalAudio.play_sfx(invalid_sfx)
		return
	
	if changed_once: return
	GlobalReference.Player.set_interaction_display(false)
	GlobalReference.Player.update_last_door_position(get_parent().global_position, GlobalScene.CurrentScene.current_scene_path if not scene_connection.node_path.contains("Door") else scene_connection.scene_path)
	changed_once = await GlobalScene.change_scene(get_parent().get_child(0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and can_interact: 
		in_area = true
		GlobalReference.Player.set_is_in_interaction_area(false, self, true)
		GlobalReference.Player.set_interaction_display(GlobalScene.CurrentScene.is_alternate_scene_dream)
		GlobalReference.Player.set_is_in_interaction_area(true, self, true)
		_on_entered_extension()
