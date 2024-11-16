extends AudioStreamPlayer

@export var max: float = 1.0
@export var min: float = 1.0

func _ready() -> void:
	set_pitch_scale(randf_range(min, max))
