extends Area2D

var in_area: bool
var changed_once: bool

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GlobalReference.Player.Input_Handler.Interaction.connect(_on_interaction)

func _on_interaction() -> void:
	if not in_area: return
	if changed_once: return
	changed_once = true
	GlobalScene.change_scene(get_parent().get_child(0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = false
