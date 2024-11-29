extends Node

var jump_toggle: bool

var Player: PlayerController
var PlayerParent: Node2D
var PlayerRealityPosition: Vector2
var PlayerRealityReference: Node2D
var Writer: DialogueWriter

var DreamMaterial: Material
var RealityMaterial: Material

var Game: GameManager
var GameTime: float

var temp_game_screen: CanvasLayer

var _start_game: bool

var friend_seen: Array[bool] = [
	false, # Tutorial 00
	false, # Tutorial 01
	false, # Tutorial 02
	false, # Tutorial 03
	false, # Tutorial 04
	false, # Block 00
	false, # Block 02
	false, # Lantern 00
	false, # Lantern 01
	false, # Lantern 02
]

func _ready() -> void:
	_start_game = false

func start_game_time() -> void:
	GameTime = 0
	_start_game = true
	jump_toggle = true
	
	for i in friend_seen.size() - 1:
		friend_seen[i] = false

func end_game_time() -> void:
	_start_game = false

func _physics_process(delta: float) -> void:
	if not _start_game: return
	GameTime += delta

func connect_signal(connect_to: Signal, object: Object, function: String) -> void:
	connect_to.connect(Callable(object, function))

func _toggle_jump(_arg, _arg2) -> void:
	if not Player.is_valid_jump(): return
	jump_toggle = not jump_toggle
