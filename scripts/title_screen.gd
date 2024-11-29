extends Control

var menu_active: bool = true

@export var camera_position: Marker2D
@export var camera: Node2D
@export var start_button: Control
@export var friend: Node2D
@export var walk_to: Array[Marker2D]

var delay_free: bool
var direction: int

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
		friend.queue_free()

func _on_wake_up() -> void:
	menu_active = false
	set_process_unhandled_input(false)
	
	delay_free = true
	
	await _fade_out_start_button()
	
	var animation: AnimatedSprite2D = friend.get_child(0)
	
	animation.play("wake_up")
	await animation.animation_finished
	animation.play("idle")
	await get_tree().create_timer(0.2).timeout
	
	_set_friend_sprite_direction(-1)
	await get_tree().create_timer(0.3).timeout
	
	animation.play("walk")
	await _friend_walk_to(walk_to[0])
	
	animation.play("idle")
	_set_friend_sprite_direction(1)
	await get_tree().create_timer(0.75).timeout
	
	_set_friend_sprite_direction(-1)
	await get_tree().create_timer(0.3).timeout
	
	animation.play("walk")
	await _friend_walk_to(walk_to[1])
	
	GlobalScene.change_dream_scene(get_parent().alternate_scene, true, true)
	GlobalReference.start_game_time()

func _friend_walk_to(walk_to: Marker2D) -> void:
	var distance: float = absf(friend.global_position.x - walk_to.global_position.x)
	var direction: float = -1 if friend.global_position.x - walk_to.global_position.x > 0 else 1
	var speed: float = GlobalReference.Player.move_speed * 1.8
	
	print(speed)
	
	_set_friend_sprite_direction(direction)
	self.direction = direction
	
	await create_tween().tween_property(friend.get_child(0), "global_position:x", walk_to.global_position.x, distance / speed).finished

func _set_friend_sprite_direction(direction: int) -> void:
	if direction != 0: friend.get_child(0).scale.x = friend.get_child(0).scale.y * direction

func _fade_out_start_button() -> void:
	var mat: Material = start_button.get_material()
	
	var colour_one: Color = mat.get("shader_parameter/replace_one")
	var colour_two: Color = mat.get("shader_parameter/replace_two")
	var colour_three: Color = mat.get("shader_parameter/replace_three")
	var colour_four: Color = mat.get("shader_parameter/replace_four")
	
	mat.set("shader_parameter/replace_four", colour_three)
	
	await get_tree().create_timer(0.24).timeout
	
	mat.set("shader_parameter/replace_three", colour_two)
	mat.set("shader_parameter/replace_four", colour_two)
	
	await get_tree().create_timer(0.24).timeout
	
	mat.set("shader_parameter/replace_two", colour_one)
	mat.set("shader_parameter/replace_three", colour_one)
	mat.set("shader_parameter/replace_four", colour_one)
	
	await get_tree().create_timer(0.24).timeout
