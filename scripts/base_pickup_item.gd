class_name BasePickupItem extends Node

signal Pickup()

@export var item_name: String
@export var item_texture: Texture2D
@export var ui: ItemPickupUI

func _ready() -> void:
	ui.item_texture_rect.set_texture(item_texture)
	ui.item_label.text = item_name
	ui.set_visible(false)
	initialise()

func initialise() -> void:
	pass

func on_pickup_extension() -> void:
	pass

func on_pickup() -> void:
	ui.set_visible(true)
	
	on_pickup_extension()
	Pickup.emit()
	
	await get_tree().create_timer(1.0).timeout
	
	ui.set_visible(false)
