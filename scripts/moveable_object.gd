extends BaseInteraction

@export var parent_radius: float
@export var moveable_parent: StaticBody2D
@export var speed_penalty_multiplier: float

@export var left_ray: RayCast2D
@export var right_ray: RayCast2D
@export var ground_ray: RayCast2D

@export var ground_impact_sfx: AudioStreamPlayer

var holding_interaction: bool

var distance_to_maintain: Vector2

var fall_let_go_once: bool
var impact_once: bool

var gravity: float
var initialise_delay: float

func _initialise() -> void:
	GlobalReference.Player.Input_Handler.InteractionLetGo.connect(_let_go_interaction)
	initialise_delay = 0.1

func _physics_process(delta: float) -> void:
	if holding_interaction and not GlobalReference.Player.is_on_floor():
		_let_go_interaction()
		return
	
	if initialise_delay >= 0:
		initialise_delay -= delta
	
	if _is_on_floor():
		gravity = 0.0
		moveable_parent.global_position = floor(moveable_parent.global_position) if moveable_parent.test_move(moveable_parent.transform, Vector2.DOWN) else ceil(moveable_parent.global_position)
		
		if impact_once: 
			GlobalAudio.play_sfx(ground_impact_sfx)
			impact_once = false
	
	if not _is_on_floor():
		if not fall_let_go_once:
			fall_let_go_once = true
			_let_go_interaction()
			if not call_deferred("_is_on_floor"):
				
				impact_once = true
		
		gravity += 4 * delta
		
		moveable_parent.move_and_collide(Vector2.DOWN * gravity)
	
	if not holding_interaction: return 
	
	if _is_on_floor():
		var position: Vector2 = GlobalReference.Player.global_position + distance_to_maintain
		var collision_info: KinematicCollision2D = KinematicCollision2D.new()
		
		#if GlobalReference.Player._raw_input.x == 0: return
		
		fall_let_go_once = false
		gravity = 0.0
		
		if moveable_parent.test_move(moveable_parent.transform, GlobalReference.Player._raw_input.x * Vector2(0.5, 0), collision_info):
			GlobalReference.Player.set_speed_multiplier(0.0)
			get_tree().create_tween().tween_property(moveable_parent, "global_position", round(moveable_parent.global_position), 0.1)
			
			return
		
		GlobalReference.Player.set_speed_multiplier(speed_penalty_multiplier)
		moveable_parent.global_position = moveable_parent.global_position.move_toward(position, 1000 * delta)

func _on_interaction() -> void:
	if not in_area or not GlobalReference.Player.is_on_floor() or GlobalReference.Player._is_currently_interacting: return 
	holding_interaction = true
	GlobalReference.Player.Input_Handler.set_can_jump(false)
	GlobalReference.Player._is_currently_interacting = true
	GlobalReference.Player._interaction_object = self
	distance_to_maintain = moveable_parent.global_position - GlobalReference.Player.global_position
	GlobalReference.Player.set_is_in_interaction_area(false, self, false)
	GlobalReference.Player.set_interaction_display(false)

func _let_go_interaction(override: bool = false) -> void:
	if not in_area and not override: return
	holding_interaction = false
	GlobalReference.Player._is_currently_interacting = false
	GlobalReference.Player.set_speed_multiplier(1.0)
	GlobalReference.Player._interaction_object = null
	GlobalReference.Player.Input_Handler.set_can_jump(true)
	GlobalReference.Player.set_interaction_display(true)
	GlobalReference.Player.set_is_in_interaction_area(true, self, false)
	
	moveable_parent.global_position = round(moveable_parent.global_position)
	
func _is_on_floor() -> bool:
	if left_ray.is_colliding() or right_ray.is_colliding() or ground_ray.is_colliding() or initialise_delay >= 0: return true
	else: return false

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"position": moveable_parent.global_position
	}
	
	return data

func load_data(data: Dictionary) -> void:
	moveable_parent.global_position = data["position"]
