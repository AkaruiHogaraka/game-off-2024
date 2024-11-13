extends BasePickupItem

@export var item_path: String

@onready var item_preload: BaseInventoryItem = load(item_path).instantiate()

func initialise() -> void:
	ui.item_label.text = item_preload.name
	ui.item_texture_rect.set_texture(item_preload.pickup_texture)

func on_pickup_extension() -> void:
	GlobalReference.Player.Inventory.add_item_to_inventory(item_preload)
