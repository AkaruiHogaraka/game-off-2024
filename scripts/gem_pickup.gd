extends BasePickupItem

@export var gem: Gem
@export var dream_gem: bool

func initialise() -> void:
	if gem == null: return
	
	ui.item_label.text = gem.gem_name + " "
	ui.item_texture_rect.set_texture(gem.gem_texture)

func on_pickup_extension() -> void:
	if dream_gem:
		GlobalItems.dream_gems += 1
		GlobalReference.Game.dream_gem_count.text = "x%s" % GlobalItems.dream_gems
	else:
		GlobalItems.gems += 1
		GlobalReference.Game.reality_gem_count.text = "x%s" % GlobalItems.gems
