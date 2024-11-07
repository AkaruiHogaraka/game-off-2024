extends BaseInteraction

var changed_once: bool

func _on_interaction() -> void:
	if not in_area: return
	if changed_once: return
	changed_once = true
	GlobalScene.change_scene(get_parent().get_child(0))
	GlobalReference.Player.set_interaction_display(false)
