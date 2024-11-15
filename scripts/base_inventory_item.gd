class_name BaseInventoryItem extends Node2D

@export var pickup_texture: Texture
@export var ui_texture: Texture

func on_item_equip() -> void:
	pass

func on_item_unequip() -> void:
	pass

func on_item_use() -> void:
	pass

func on_passive_item_effect() -> void:
	pass
