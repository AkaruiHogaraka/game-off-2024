extends BaseInventoryItem

@export var arm_sprite: AnimatedSprite2D
@export var lantern_mask: MaskPreset

func on_item_unequip() -> void:
	arm_sprite.set_visible(false)
	GlobalReference.Player.arm_sprite_parent.set_visible(true)
	
	GlobalScene.CurrentScene.set_mask()
	GlobalScene.is_holding_lantern = false

func on_item_equip() -> void:
	arm_sprite.set_visible(true)
	GlobalReference.Player.arm_sprite_parent.set_visible(false)

func on_passive_item_effect() -> void:
	var main_sprite: AnimatedSprite2D = GlobalReference.Player.sprite
	
	arm_sprite.play(main_sprite.get_animation())
	arm_sprite.set_frame_and_progress(main_sprite.get_frame(), main_sprite.get_frame_progress())
	
	scale.x = GlobalReference.Player.sprite_parent.scale.x
	
	if GlobalScene.NewMask.name != "depth_3":
		return
	
	GlobalScene.is_holding_lantern = true
	
	var mask_mat: Material = GlobalReference.Player.mask.material
	
	mask_mat.set("shader_parameter/next_noise_frame_count", lantern_mask.next_noise_frame_count)
	mask_mat.set("shader_parameter/radius_inner", lantern_mask.radius_inner)
	mask_mat.set("shader_parameter/radius_middle", lantern_mask.radius_middle)
	mask_mat.set("shader_parameter/radius_outer", lantern_mask.radius_outer)
	mask_mat.set("shader_parameter/noise_strength_inner", lantern_mask.noise_strength_inner)
	mask_mat.set("shader_parameter/noise_strength_middle", lantern_mask.noise_strength_middle)
	mask_mat.set("shader_parameter/noise_strength_outer", lantern_mask.noise_strength_outer)
