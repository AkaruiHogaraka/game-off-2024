class_name PlayerController extends CharacterBody2D

@export var move_speed: float = 20
@export var acceleration: float = 10
@export var gravity: float = 10
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

var _raw_input: Vector2
var _walk_velocity: Vector2
var _gravity_velocity: Vector2

var _is_jumping: bool
var _jump_time: float
var _can_dream: bool = true

@onready var Input_Handler: InputHandler = $Input

@onready var _jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var _jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var _fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GlobalReference.Player = self
	GlobalReference.PlayerParent = get_parent()
	toggle_fog(false)

func _process(delta):
	if not Input_Handler._can_input: 
		reset_velocities()
	
	velocity = _walk() + _gravity()
	move_and_slide()
	
func _walk() -> Vector2:
	_walk_velocity = _walk_velocity.move_toward(Vector2(_raw_input.x, 0) * move_speed, acceleration * get_process_delta_time())
	return Vector2(_raw_input.x, 0) * move_speed
	
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

func on_move(direction: float) -> void:
	_raw_input.x = direction
	if direction != 0: $Sprite.scale.x = $Sprite.scale.y * direction

func on_jump(is_jumping: bool, direction: float) -> void:
	_is_jumping = is_jumping
	_raw_input.y = direction
	
	if _is_jumping: _gravity_velocity.y = _jump_velocity
