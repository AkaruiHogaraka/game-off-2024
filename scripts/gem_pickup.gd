extends BasePickupItem

@export var gem: Gem
@export var dream_gem: bool

func initialise() -> void:
	ui.item_label.text = gem.gem_name + " "
	ui.item_texture_rect.set_texture(gem.gem_texture)

func _on_pickup_extension() -> void:
	if dream_gem:
		GlobalItems.dream_gems += 1
	else:
		GlobalItems.gems += 1
