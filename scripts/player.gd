class_name PlayerController extends CharacterBody2D

@export var move_speed: float = 20
@export var acceleration: float = 10
@export var gravity: float = 10
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@export var interaction_sprite: Sprite2D
@export var sprite: AnimatedSprite2D

var _speed_multiplier: float = 1.0

var _raw_input: Vector2
var _walk_velocity: Vector2
var _gravity_velocity: Vector2

var _is_jumping: bool
var _jump_time: float
var _can_dream: bool = true
var _is_interacting: bool
var _is_in_interaction_area: bool
var _current_area: Node

var mask: Sprite2D

var last_safe_position: Vector2
var last_door_position: Vector2
var last_door_scene: String
var process: bool

@onready var Input_Handler: InputHandler = $Input

@onready var _jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var _jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var _fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GlobalReference.Player = self
	GlobalReference.PlayerParent = get_parent()
	toggle_fog(false)
	mask = $Fog/BackBufferCopy2/Mask/Sprite2D
	set_interaction_display(false)
	process = true

func _process(delta):
	if not process: return
	$Fog/BackBufferCopy2/Mask.call_deferred("set_global_position", round($FogFollowPoint.global_position))
	
	animate_sprite()
	
	if not Input_Handler._can_input: 
		reset_velocities()
	
	velocity = _walk() + _gravity()
	move_and_slide()
	
	update_last_safe_position()
	
	if _raw_input == Vector2.ZERO:
		global_position = round(global_position)

func animate_sprite() -> void:
	if _raw_input.x != 0: sprite.play("walk")
	elif _raw_input.x == 0: sprite.play("default")

func _walk() -> Vector2:
	_walk_velocity = _walk_velocity.move_toward(Vector2(_raw_input.x, 0) * (move_speed * _speed_multiplier), acceleration * get_process_delta_time())
	return _walk_velocity
	
func _gravity() -> Vector2:
	if is_on_floor() and not _is_jumping:
		_gravity_velocity = Vector2.ZERO
		return _gravity_velocity
	
	if is_on_floor() and _is_jumping:
		_is_jumping = false
	
	if is_on_ceiling_only():
		_gravity_velocity = Vector2.ZERO
	
	_gravity_velocity += Vector2(0, _jump_gravity if _gravity_velocity.y < 0.0 else _fall_gravity) * get_process_delta_time()
	return _gravity_velocity

func is_valid_jump() -> bool:
	return is_on_floor() or Input_Handler._can_coyote_jump()

func reset_velocities() -> void:
	_raw_input = Vector2.ZERO
	_walk_velocity = Vector2.ZERO

func set_can_dream(value: bool) -> void:
	_can_dream = value

func _on_dream() -> void:
	if is_on_floor() and _raw_input.x == 0 and _can_dream:
		GlobalScene.change_dream_scene(GlobalScene.CurrentScene.alternate_scene, not GlobalScene.CurrentScene.is_alternate_scene_dream)

func toggle_fog(value: bool) -> void:
	$Fog.set_visible(value)

func set_speed_multiplier(multiplier: float) -> void:
	_speed_multiplier = multiplier

func set_interaction_display(enabled: bool) -> void:
	if _is_interacting and enabled: return
	if _is_in_interaction_area: return 
	interaction_sprite.set_visible(enabled)

func set_is_in_interaction_area(value: bool, node: Node, override: bool) -> void:
	if not override:
		if _current_area != node and _current_area != null: 
			return
			
	_current_area = node
	_is_in_interaction_area = value

func update_last_safe_position() -> void:
	if not is_on_floor(): return
	var space_state = get_world_2d().direct_space_state
	var query_one = PhysicsRayQueryParameters2D.create(global_position + Vector2.UP + ((Vector2.RIGHT * _raw_input.x) * 10), global_position + Vector2.DOWN * 5, 16, [get_rid()])
	var result_one = space_state.intersect_ray(query_one)
	
	var query_two = PhysicsRayQueryParameters2D.create(global_position + Vector2.UP + ((Vector2.RIGHT * -_raw_input.x) * 10), global_position + Vector2.DOWN * 5, 16, [get_rid()])
	var result_two = space_state.intersect_ray(query_two)
	
	if result_one.is_empty() or result_two.is_empty(): return
	
	var query_three = PhysicsRayQueryParameters2D.create(global_position + Vector2.UP, global_position + Vector2.DOWN * 5, 16, [get_rid()])
	var result_three = space_state.intersect_ray(query_three)
	
	if result_three.is_empty(): return
	
	last_safe_position = result_three["position"]

func update_last_door_position(pos: Vector2, path: String) -> void:
	last_door_position = pos
	last_door_scene = path

func on_interaction() -> void:
	_is_interacting = true

func on_interaction_let_go() -> void:
	_is_interacting = false

func on_move(direction: float) -> void:
	_raw_input.x = direction
	if direction != 0: $Sprite.scale.x = $Sprite.scale.y * direction

func on_jump(is_jumping: bool, direction: float) -> void:
	_is_jumping = is_jumping
	_raw_input.y = direction
	
	if _is_jumping: _gravity_velocity.y = _jump_velocity
