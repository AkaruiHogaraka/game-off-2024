extends Node

var jump_toggle: bool

var Player: PlayerController
var PlayerParent: Node2D
var PlayerRealityPosition: Vector2
var PlayerRealityReference: Node2D

var Game: GameManager

func connect_signal(connect_to: Signal, object: Object, function: String) -> void:
	connect_to.connect(Callable(object, function))

func _toggle_jump(_arg, _arg2) -> void:
	if not Player.is_valid_jump(): return
	jump_toggle = not jump_toggle
