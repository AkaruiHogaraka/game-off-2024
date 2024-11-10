extends Area2D

var in_area: bool
var enter_once: bool

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if not in_area or enter_once: return
	enter_once = true
	GlobalScene.change_scene(get_parent().get_child(0))
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = false
