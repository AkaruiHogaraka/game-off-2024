extends BaseInteraction

@export var parent_radius: float
@export var moveable_parent: StaticBody2D
@export var speed_penalty_multiplier: float

var holding_interaction: bool

var distance_to_maintain: Vector2

func _initialise() -> void:
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
	moveable_parent.global_position = moveable_parent.global_position.move_toward(position, 200 * delta)

func _on_interaction() -> void:
	if not in_area or not GlobalReference.Player.is_on_floor(): return 
	holding_interaction = true
	GlobalReference.Player.Input_Handler.set_can_jump(false)
	distance_to_maintain = moveable_parent.global_position - GlobalReference.Player.global_position
	GlobalReference.Player.set_is_in_interaction_area(false, self, false)
	GlobalReference.Player.set_interaction_display(false)

func _let_go_interaction() -> void:
	if not in_area: return
	holding_interaction = false
	GlobalReference.Player.set_speed_multiplier(1.0)
	GlobalReference.Player.Input_Handler.set_can_jump(true)
	GlobalReference.Player.set_interaction_display(true)
	GlobalReference.Player.set_is_in_interaction_area(true, self, false)
	
	moveable_parent.global_position = round(moveable_parent.global_position)
	
func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"position": moveable_parent.global_position
	}
	
	return data

func load_data(data: Dictionary) -> void:
	moveable_parent.global_position = data["position"]
