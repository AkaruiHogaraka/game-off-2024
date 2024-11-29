class_name PlayerController extends CharacterBody2D

signal Dead()

@export var starting_health: int = 3

@export var move_speed: float = 20
@export var acceleration: float = 10
@export var gravity: float = 10
@export var jump_height: float
@export var jump_time_to_peak: float
@export var jump_time_to_descent: float

@export var interaction_sprite: Sprite2D
@export var sprite: AnimatedSprite2D
@export var left_arm_sprite: AnimatedSprite2D

@export var jump_sfx: AudioStreamPlayer

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
var _is_currently_interacting: bool = false
var _interaction_object: BaseInteraction
var mask: Sprite2D

var current_health: int

var last_safe_position: Vector2
var last_door_position: Vector2
var jump_position: Vector2
var last_door_scene: String
var process: bool
var process_animation: bool

@onready var Input_Handler: InputHandler = $Input
@onready var Inventory: ItemInventory = $Inventory
@onready var sprite_parent: Node2D = $Sprite
@onready var arm_sprite_parent: Node2D = $Sprite/LeftArm
@onready var safe_ground_raycast: RayCast2D = $SafeGround

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
	process_animation = false
	
	sprite.play("sleep")
	left_arm_sprite.play("sleep")
	
	_is_currently_interacting = false
	current_health = starting_health
	Dead.connect(_on_dead)

func _process(delta):
	if process:
		$Fog/BackBufferCopy2/Mask.call_deferred("set_global_position", round($FogFollowPoint.global_position))
		
		if not Input_Handler._can_input: 
			reset_velocities()
		
		velocity = _walk() + _gravity()
		move_and_slide()
		
		update_last_safe_position()
	
	if process_animation:
		animate_sprite()
		animate_left_arm()
	
	if _raw_input.x == 0 and is_on_floor():
		global_position = round(global_position)

func animate_sprite() -> void:
	if not is_on_floor() and not safe_ground_raycast.is_colliding():
		if _gravity_velocity.y < 0:
			sprite.play("jump")
		if _gravity_velocity.y >= 0 and sprite.get_animation() != "fall":
			sprite.play("fall")
		
		return
	
	if $Sprite.scale.x != _raw_input.x and _raw_input.x != 0: # Pull objects
		sprite.play("pull")
		
		return
	
	if _is_currently_interacting and _interaction_object and _raw_input.x != 0: # Push objects
		sprite.play("push")
		
		return
	
	if _raw_input.x != 0: 
		sprite.play("walk")
	elif _raw_input.x == 0: sprite.play("idle")

func animate_left_arm() -> void:
	left_arm_sprite.play(sprite.get_animation())
	left_arm_sprite.set_frame_and_progress(sprite.get_frame(), sprite.get_frame_progress())

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
	
	if _gravity_velocity.y > 0.0:
		Input_Handler.set_can_jump(true)
	
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

func add_health(value: int) -> void:
	current_health += value
	
	for i in value:
		GlobalReference.Game.dream_heart_ui.add_heart()
		GlobalReference.Game.reality_heart_ui.add_heart()

func reduce_health(value: int) -> bool:
	current_health -= value
	if current_health < 0: current_health = 0
	
	var dead: bool = current_health <= 0
	
	GlobalReference.Game.dream_heart_ui.update_heart_display()
	GlobalReference.Game.reality_heart_ui.update_heart_display()
	
	if dead: 
		Dead.emit()
		return false
	
	return true

func _on_dead() -> void:
	GlobalScene.last_door_respawn(last_door_position, last_door_scene)

func on_interaction() -> void:
	_is_interacting = true

func on_interaction_let_go() -> void:
	_is_interacting = false
	if _interaction_object and _interaction_object.has_method("_let_go_interaction"):
		_interaction_object._let_go_interaction(true)

func on_move(direction: float) -> void:
	_raw_input.x = direction
	set_sprite_direction(direction)

func set_sprite_direction(direction: float) -> void:
	if direction != 0 and not _is_currently_interacting: sprite_parent.scale.x = sprite_parent.scale.y * direction

func on_jump(is_jumping: bool, direction: float) -> void:
	_is_jumping = is_jumping
	_raw_input.y = direction
	
	if _is_jumping: 
		_gravity_velocity.y = _jump_velocity
		jump_position = get_global_position()
		GlobalAudio.play_sfx(jump_sfx, true)
