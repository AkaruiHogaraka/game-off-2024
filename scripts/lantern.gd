extends BaseInventoryItem

@export var arm_sprite: AnimatedSprite2D
@export var lantern_mask: MaskPreset

func on_item_unequip() -> void:
	arm_sprite.set_visible(false)
	GlobalReference.Player.arm_sprite_parent.set_visible(true)
	
	GlobalScene.is_holding_lantern = false
	
	var mask_mat: Material = GlobalReference.Player.mask.material
	
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/radius_inner", GlobalScene.CurrentScene.mask_settings.radius_inner, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/radius_middle", GlobalScene.CurrentScene.mask_settings.radius_middle, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/radius_outer", GlobalScene.CurrentScene.mask_settings.radius_outer, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/noise_strength_inner", GlobalScene.CurrentScene.mask_settings.noise_strength_inner, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/noise_strength_middle", GlobalScene.CurrentScene.mask_settings.noise_strength_middle, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/noise_strength_outer", GlobalScene.CurrentScene.mask_settings.noise_strength_outer, 0.3)

func on_item_equip() -> void:
	arm_sprite.set_visible(true)
	GlobalReference.Player.arm_sprite_parent.set_visible(false)
	GlobalScene.is_holding_lantern = true
	
	if GlobalScene.NewMask.name != "depth_3":
		return
	
	var mask_mat: Material = GlobalReference.Player.mask.material
	
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/radius_inner", lantern_mask.radius_inner, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/radius_middle", lantern_mask.radius_middle, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/radius_outer", lantern_mask.radius_outer, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/noise_strength_inner", lantern_mask.noise_strength_inner, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/noise_strength_middle", lantern_mask.noise_strength_middle, 0.3)
	get_tree().create_tween().tween_property(mask_mat, "shader_parameter/noise_strength_outer", lantern_mask.noise_strength_outer, 0.3)

func on_passive_item_effect() -> void:
	var main_sprite: AnimatedSprite2D = GlobalReference.Player.sprite
	
	arm_sprite.play(main_sprite.get_animation())
	arm_sprite.set_frame_and_progress(main_sprite.get_frame(), main_sprite.get_frame_progress())
	
	scale.x = GlobalReference.Player.sprite_parent.scale.x
