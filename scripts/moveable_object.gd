extends Node

@export var parent_radius: float
@export var moveable_parent: StaticBody2D
@export var speed_penalty_multiplier: float

var in_area: bool
var holding_interaction: bool

var distance_to_maintain: Vector2

func _ready() -> void:
	GlobalReference.Player.Input_Handler.Interaction.connect(_interaction)
	GlobalReference.Player.Input_Handler.InteractionLetGo.connect(_let_go_interaction)

func _physics_process(delta: float) -> void:
	if not holding_interaction: return
	
	var position: Vector2 = GlobalReference.Player.global_position + distance_to_maintain
	var collision_info: KinematicCollision2D = KinematicCollision2D.new()
	
	if GlobalReference.Player._raw_input.x == 0: return
	
	if moveable_parent.test_move(moveable_parent.transform, GlobalReference.Player._raw_input.x * Vector2(0.5, 0), collision_info):
		GlobalReference.Player.set_speed_multiplier(0.0)
		get_tree().create_tween().tween_property(moveable_parent, "global_position", Vector2(round(moveable_parent.global_position.x), moveable_parent.global_position.y), 0.2)
		
		return
	
	GlobalReference.Player.set_speed_multiplier(speed_penalty_multiplier)
	moveable_parent.global_position = moveable_parent.global_position.move_toward(position, 100 * delta)

func _interaction() -> void:
	if not in_area or not GlobalReference.Player.is_on_floor(): return 
	holding_interaction = true
	GlobalReference.Player.Input_Handler.set_can_jump(false)
	distance_to_maintain = moveable_parent.global_position - GlobalReference.Player.global_position

func _let_go_interaction() -> void:
	holding_interaction = false
	GlobalReference.Player.set_speed_multiplier(1.0)
	GlobalReference.Player.Input_Handler.set_can_jump(true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		_let_go_interaction()
		in_area = false
		
func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"position": moveable_parent.global_position
	}
	
	return data

func load_data(data: Dictionary) -> void:
	moveable_parent.global_position = data["position"]
