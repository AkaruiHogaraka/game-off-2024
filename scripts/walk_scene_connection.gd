extends Area2D

var in_area: bool
var dot_last_frame: int

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if not in_area: return
	
	var dot: int = global_position.dot(GlobalReference.Player.global_position.direction_to(global_position))
	if dot != 0 and dot_last_frame != 0 and dot != dot_last_frame:
		print("%s %s" % [dot, dot_last_frame])
		GlobalScene.change_scene(get_parent().get_child(0))
	
	dot_last_frame = dot
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = false
