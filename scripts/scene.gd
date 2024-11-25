class_name Scene extends Node2D

@export var scene_camera: Node2D

@export var alternate_scene: SceneConnection
@export var is_alternate_scene_dream: bool

@export var mask_settings: MaskPreset

var current_frame: int = 0
var current_scene_path: String

func _ready() -> void:
	if GlobalScene.CurrentScene == null:
		GlobalScene.CurrentScene = self

func _physics_process(delta: float) -> void:
	current_frame += 1
	if current_frame >= mask_settings.next_noise_frame_count:
		GlobalReference.Player.mask.get_material().set("shader_parameter/noise_scale", randf_range(1.0, 2.0))
		current_frame = 0

func set_mask() -> void:
	
	var mask_mat: Material = GlobalReference.Player.mask.get_material()

	mask_mat.set("shader_parameter/radius_inner", mask_settings.radius_inner)
	mask_mat.set("shader_parameter/radius_middle", mask_settings.radius_middle)
	mask_mat.set("shader_parameter/radius_outer", mask_settings.radius_outer)
	mask_mat.set("shader_parameter/noise_strength_inner", mask_settings.noise_strength_inner)
	mask_mat.set("shader_parameter/noise_strength_middle", mask_settings.noise_strength_middle)
	mask_mat.set("shader_parameter/noise_strength_outer", mask_settings.noise_strength_outer)
	
