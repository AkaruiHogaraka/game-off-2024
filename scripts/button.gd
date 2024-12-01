class_name ActivateButton extends Node2D

@export var sprite: Sprite2D
@export var area: Area2D

@export var activated_sfx: AudioStreamPlayer
@export var deactivated_sfx: AudioStreamPlayer

var activated: bool

func _physics_process(delta: float) -> void:
	if activated and not area.has_overlapping_bodies():
		_on_body_exited(self)

func _on_body_exited(body: Node2D) -> void:
	if activated and not area.has_overlapping_bodies():
		if not GlobalScene.internal_scene_change_cooldown:
			GlobalAudio.play_sfx(deactivated_sfx)
		activated = false
		sprite.set_visible(true)

func _on_body_entered(body: Node2D) -> void:
	if not activated:
		if not GlobalScene.internal_scene_change_cooldown:
			GlobalAudio.play_sfx(activated_sfx)
		activated = true
		sprite.set_visible(false)
