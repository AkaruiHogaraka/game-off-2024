extends BaseTrigger

@export var tutorial: Control

var active: bool = true
var wait: bool

func _physics_process(delta: float) -> void:
	if is_all_areas_triggered() and not wait and active:
		print("Trigged")
		active = false
		wait = true
		tutorial.set_modulate(Color.RED)
		await get_tree().create_timer(0.24).timeout
		tutorial.set_modulate(Color.GREEN)
		await get_tree().create_timer(0.24).timeout
		tutorial.set_visible(active)
		wait = false

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"active": active
	}
	
	return data

func load_data(data: Dictionary) -> void:
	active = data["active"]
	tutorial.set_visible(active)
