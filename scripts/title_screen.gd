extends Control

var menu_active: bool = true

@export var camera_position: Marker2D
@export var camera: Node2D

var delay_free: bool

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if not menu_active: return
		
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("jump"):
		_on_wake_up()

func save_data() -> Dictionary:
	var data: Dictionary = {
		"path": get_path(),
		"menu_active": menu_active
	}
	
	return data

func load_data(data: Dictionary) -> void:
	menu_active = data["menu_active"]
	if not menu_active:
		if delay_free:
			await get_tree().create_timer(0.5).timeout
		
		queue_free()

func _on_wake_up() -> void:
	menu_active = false
	set_process_unhandled_input(false)
	
	delay_free = true
	
	GlobalScene.change_dream_scene(get_parent().alternate_scene, true, true)
	GlobalReference.start_game_time()
