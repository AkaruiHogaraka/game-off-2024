class_name InputHandler extends Node

signal DownJump()
signal Interaction()
signal DirectionInput(_direction: float)
signal Jumping(_jump: bool, _direction: float)

@export var jump_buffer: float = 0.2
@export var coyote_buffer: float = 0.2

var _raw_input: Vector2
var _jump_buffer_timer: float
var _buffer_jump: bool
var _coyote_buffer_timer: float
var _coyote_jump: bool

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		Interaction.emit()
		
	_raw_input.x = Input.get_axis("move_left", "move_right")
	DirectionInput.emit(_raw_input.x)
	
	if Input.is_action_pressed("jump") and Input.is_action_pressed("move_down"):
		DownJump.emit()
		return 
	
	if Input.is_action_just_pressed("jump"):
		if _can_coyote_jump(): _signal_jump()
		else: 
			_buffer_jump = true
			_jump_buffer_timer = 0

func _physics_process(delta: float) -> void:
	if not GlobalReference.Player.is_on_floor():
		_coyote_buffer_timer += delta
	
	if GlobalReference.Player.is_on_floor():
		if _buffer_jump: _signal_jump()
		_coyote_buffer_timer = 0
	
	if _buffer_jump:
		_jump_buffer_timer += delta
		if _jump_buffer_timer >= jump_buffer:
			_buffer_jump = false

func _can_coyote_jump() -> bool:
	return _coyote_buffer_timer <= coyote_buffer

func _signal_jump() -> void:
	_raw_input.y = 1
	Jumping.emit(true, _raw_input.y)
	_buffer_jump = false
	
func _is_movement_occuring() -> bool:
	return abs(_raw_input.x) != 0 or abs(_raw_input.y) != 0
