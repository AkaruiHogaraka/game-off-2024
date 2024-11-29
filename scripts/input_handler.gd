class_name InputHandler extends Node

signal Dream()
signal DownJump()
signal Interaction()
signal InteractionLetGo()
signal DirectionInput(_direction: float)
signal Jumping(_jump: bool, _direction: float)
signal CycleItem()
signal UseItem()

@export var jump_buffer: float = 0.2
@export var coyote_buffer: float = 0.2
@export var dream_cooldown: float = 0.5

var _raw_input: Vector2
var _jump_buffer_timer: float
var _buffer_jump: bool
var _coyote_buffer_timer: float
var _coyote_jump: bool
var _can_input: bool = true
var _dream_cooldown: float
var _can_jump: bool = true
var _movement_held: bool
var _last_movement: float

func _ready() -> void:
	Jumping.connect(GlobalReference._toggle_jump)

func _unhandled_input(event: InputEvent) -> void:
	if not _can_input: return
	
	if event.is_action_pressed("interact"):
		Interaction.emit()
	if event.is_action_released("interact"):
		InteractionLetGo.emit()
	
	if event.is_action_pressed("cycle_item"):
		CycleItem.emit()
	
	if event.is_action_pressed("use_item"):
		UseItem.emit()
		
	if Input.is_action_pressed("move_up") and Input.is_action_just_pressed("jump"):
		if _dream_cooldown <= 0:
			_dream_cooldown = dream_cooldown
			Dream.emit()
		return
		
	if Input.is_action_pressed("move_down"):
		if Input.is_action_pressed("jump") and _can_jump:
			DownJump.emit()
			return
		
		if GlobalReference.Player.is_on_floor():
			DirectionInput.emit(0)
			return
	
	_raw_input.x = Input.get_axis("move_left", "move_right")
	DirectionInput.emit(_raw_input.x)
	
	if Input.is_action_just_pressed("jump") and _can_jump:
		if _can_coyote_jump(): _signal_jump()
		else: 
			_buffer_jump = true
			_jump_buffer_timer = 0

func _physics_process(delta: float) -> void:
	_dream_cooldown -= delta
	
	if not GlobalReference.Player.is_on_floor():
		_coyote_buffer_timer += delta
	
	if GlobalReference.Player.is_on_floor() and _can_jump:
		if _buffer_jump: _signal_jump()
		_coyote_buffer_timer = 0
	
	if _buffer_jump:
		_jump_buffer_timer += delta
		if _jump_buffer_timer >= jump_buffer:
			_buffer_jump = false

func _can_coyote_jump() -> bool:
	return _coyote_buffer_timer <= coyote_buffer

func toggle_inputs(enabled: bool) -> void:
	_can_input = enabled

func set_can_jump(value: bool) -> void:
	_can_jump = value

func _signal_jump() -> void:
	_raw_input.y = 1
	set_can_jump(false)
	Jumping.emit(true, _raw_input.y)
	_buffer_jump = false
	
func _is_movement_occuring() -> bool:
	return abs(_raw_input.x) != 0 or abs(_raw_input.y) != 0
