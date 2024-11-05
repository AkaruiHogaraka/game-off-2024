extends CanvasLayer

var menu_active: bool = true

@export var markers: Array[Control]
@export var buttons: Array[Button]
@export var menu_cusor: Control

var index: int

func _unhandled_input(event: InputEvent) -> void:
	if not menu_active: return
	
	if Input.is_action_just_pressed("move_up"):
		index -= 1
	if Input.is_action_just_pressed("move_down"):
		index += 1
		
	if Input.is_action_just_pressed("interact"):
		buttons[index].pressed.emit()
	
	index = index % markers.size()
	
	menu_cusor.set_position(markers[index].global_position)

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"menu_active": menu_active
	}
	
	return data

func load_data(data: Dictionary) -> void:
	menu_active = data["menu_active"]
	if not menu_active:
		queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_play_pressed() -> void:
	menu_active = false
	set_process_unhandled_input(false)
	GlobalScene.change_dream_scene(get_parent().alternate_scene, true)
