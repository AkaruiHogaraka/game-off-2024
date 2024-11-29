extends BasePickupItem

@export var item_path: String
@export var sprite: Sprite2D
@export var particles: GPUParticles2D

@onready var item_preload: BaseInventoryItem = load(item_path).instantiate()

func initialise() -> void:
	ui.item_label.text = item_preload.name
	ui.item_texture_rect.set_texture(item_preload.pickup_texture)
	
	if GlobalItems.has_lantern:
		get_parent().queue_free()

func on_pickup_extension() -> void:
	GlobalReference.Player.Inventory.add_item_to_inventory(item_preload)
	GlobalItems.has_lantern = true
	
	sprite.set_visible(false)
	particles.set_visible(false)
