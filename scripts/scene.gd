class_name Scene extends Node2D

@export var alternate_scene: SceneConnection
@export var is_alternate_scene_dream: bool

func _ready() -> void:
	if GlobalScene.CurrentScene == null:
		GlobalScene.CurrentScene = self
