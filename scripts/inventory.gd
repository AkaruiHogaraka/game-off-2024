class_name ItemInventory extends Node2D

var items: Array[BaseInventoryItem]
var item_index: int

func _ready() -> void:
	item_index = -1
	
	for child in get_children():
		call_deferred("add_item_to_inventory", child)

func _physics_process(delta: float) -> void:
	if items.is_empty(): return
	
	items[item_index].on_passive_item_effect()

func on_item_use() -> void:
	if items.is_empty(): return
	
	items[item_index].on_item_use()

func on_cycle_items() -> void:
	if items.is_empty(): return
	
	if item_index >= 0: items[item_index].on_item_unequip()
	
	item_index = (item_index + 1) % items.size()
	
	GlobalReference.Game.reality_inventory_ui.set_texture(items[item_index].ui_texture)
	GlobalReference.Game.dream_inventory_ui.set_texture(items[item_index].ui_texture)
	
	items[item_index].on_item_equip()

func add_item_to_inventory(item: BaseInventoryItem) -> void:
	items.append(item)
	add_child(item)
	on_cycle_items()
