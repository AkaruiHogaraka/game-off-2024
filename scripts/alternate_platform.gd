extends Node2D

@export var default_on: bool = true
var is_on: bool

func _ready() -> void:
	$OnSprite.set_visible(default_on)
	$OffSprite.set_visible(not default_on)
	$StaticBody2D/CollisionShape2D.set_disabled(not default_on)
	
	GlobalReference.Player.Input_Handler.Jumping.connect(toggle_state)
	
	if GlobalReference.jump_toggle:
		toggle_state(1, 2)

func toggle_state(_arg1, _arg2) -> void:
	if not GlobalReference.Player.is_valid_jump(): return
	
	$OnSprite.set_visible(not $OnSprite.visible)
	$OffSprite.set_visible(not $OffSprite.visible)
	$StaticBody2D/CollisionShape2D.set_disabled(not $StaticBody2D/CollisionShape2D.disabled)
