class_name Scene extends Node2D

func _ready() -> void:
	if GlobalScene.CurrentScene == null:
		GlobalScene.CurrentScene = self
