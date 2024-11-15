extends BaseInventoryItem

@export var arm_sprite: AnimatedSprite2D

func on_item_unequip() -> void:
	arm_sprite.set_visible(false)
	GlobalReference.Player.arm_sprite_parent.set_visible(true)

func on_item_equip() -> void:
	arm_sprite.set_visible(true)
	GlobalReference.Player.arm_sprite_parent.set_visible(false)

func on_passive_item_effect() -> void:
	var main_sprite: AnimatedSprite2D = GlobalReference.Player.sprite
	
	arm_sprite.play(main_sprite.get_animation())
	arm_sprite.set_frame_and_progress(main_sprite.get_frame(), main_sprite.get_frame_progress())
	
	scale.x = GlobalReference.Player.sprite_parent.scale.x
