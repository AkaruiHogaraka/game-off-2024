extends BaseInteraction

var changed_once: bool

func _on_interaction() -> void:
	if not in_area: return
	if changed_once: return
	GlobalReference.Player.set_interaction_display(false)
	changed_once = await GlobalScene.change_scene(get_parent().get_child(0))
