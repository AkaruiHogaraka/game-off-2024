extends AnimatableBody2D

@export var sprite: AnimatedSprite2D
@export var moveable: BaseInteraction

var suspend_block: bool

func _ready() -> void:
	sprite.play("spawn")
	suspend_block = true
	await sprite.animation_finished
	suspend_block = false

func _physics_process(delta: float) -> void:
	if suspend_block:
		moveable.gravity = 0.0

func on_despawn() -> void:
	sprite.play("spawn", -1)
	await sprite.animation_finished
